"""
Puzzlify Audio Generator
Generates all required audio assets using Python's built-in wave module.
No third-party dependencies needed.
"""

import wave
import struct
import math
import os

SAMPLE_RATE = 44100
OUTPUT_DIR = r"d:\puzzlify\puzzlify\assets\audio"
os.makedirs(OUTPUT_DIR, exist_ok=True)


# ── Helpers ───────────────────────────────────────────────────────────────────

def clamp(x, lo=-1.0, hi=1.0):
    return max(lo, min(hi, x))

def write_wav(filename, samples, sr=SAMPLE_RATE):
    path = os.path.join(OUTPUT_DIR, filename)
    with wave.open(path, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sr)
        packed = struct.pack(f'<{len(samples)}h', *[int(clamp(s) * 32767) for s in samples])
        wf.writeframes(packed)
    print(f"  OK {filename}  ({len(samples)/sr:.2f}s)")

def sine(freq, i, sr=SAMPLE_RATE):
    return math.sin(2 * math.pi * freq * i / sr)

def envelope(i, total, attack=0.01, release=0.05, sr=SAMPLE_RATE):
    a, r = int(attack * sr), int(release * sr)
    if i < a: return i / a
    if i > total - r: return (total - i) / r
    return 1.0

def concat(*tracks):
    result = []
    for t in tracks:
        result.extend(t)
    return result

def add(*tracks):
    length = max(len(t) for t in tracks)
    result = [0.0] * length
    for t in tracks:
        for i, v in enumerate(t):
            result[i] += v
    peak = max(abs(x) for x in result) or 1.0
    return [x / peak * 0.9 for x in result]

def fade_out(samples, duration=0.5, sr=SAMPLE_RATE):
    n = int(duration * sr)
    result = list(samples)
    for i in range(min(n, len(result))):
        result[-(i+1)] *= i / n
    return result


# ── Sound Effects ──────────────────────────────────────────────────────────────

print("\nGenerating sound effects...")

# tile_pick.wav
def gen_tile_pick():
    n = int(0.12 * SAMPLE_RATE)
    return [0.7 * math.exp(-25 * i/SAMPLE_RATE) * math.sin(2*math.pi*(800-400*i/n)*i/SAMPLE_RATE) for i in range(n)]

write_wav("tile_pick.wav", gen_tile_pick())

# tile_step.wav
def gen_tile_step():
    n = int(0.06 * SAMPLE_RATE)
    return [0.45 * math.exp(-60 * i/SAMPLE_RATE) * math.sin(2*math.pi*500*i/SAMPLE_RATE) for i in range(n)]

write_wav("tile_step.wav", gen_tile_step())

# connect.wav
def gen_connect():
    n = int(0.45 * SAMPLE_RATE)
    samples = []
    for i in range(n):
        env = math.exp(-6 * i/SAMPLE_RATE)
        s  = 0.50 * env * math.sin(2*math.pi*880*i/SAMPLE_RATE)
        s += 0.30 * env * math.sin(2*math.pi*1320*i/SAMPLE_RATE)
        s += 0.15 * env * math.sin(2*math.pi*2200*i/SAMPLE_RATE)
        samples.append(s)
    return samples

write_wav("connect.wav", gen_connect())

# win.wav
def gen_win():
    freqs = [523.25, 659.25, 783.99, 1046.50]
    parts = []
    for j, f in enumerate(freqs):
        dur = 0.25 if j < 3 else 0.8
        n = int(dur * SAMPLE_RATE)
        seg = []
        for i in range(n):
            decay = -3 if j == 3 else -5
            env = math.exp(decay * i/SAMPLE_RATE)
            s  = 0.5 * env * math.sin(2*math.pi*f*i/SAMPLE_RATE)
            s += 0.2 * env * math.sin(2*math.pi*f*2*i/SAMPLE_RATE)
            seg.append(s)
        parts.append(seg)
    raw = concat(*parts)
    peak = max(abs(x) for x in raw) or 1.0
    return [x / peak * 0.85 for x in raw]

write_wav("win.wav", gen_win())

# button.wav
def gen_button():
    n = int(0.08 * SAMPLE_RATE)
    return [0.55 * math.exp(-40 * i/SAMPLE_RATE) * math.sin(2*math.pi*1000*i/SAMPLE_RATE) for i in range(n)]

write_wav("button.wav", gen_button())


# ── Background Music ───────────────────────────────────────────────────────────

print("Generating background music (may take a moment)...")

NOTE = {
    'C3':130.81,'E3':164.81,'F3':174.61,'G3':196.00,'A3':220.00,'B3':246.94,
    'C4':261.63,'D4':293.66,'E4':329.63,'F4':349.23,'G4':392.00,'A4':440.00,'B4':493.88,
    'C5':523.25,'D5':587.33,'E5':659.25,'G5':783.99,'A5':880.00,
}

def chord_seg(freqs, duration, amp=0.18, attack=0.05, release=0.15, sr=SAMPLE_RATE):
    n = int(duration * sr)
    a, r = int(attack * sr), int(release * sr)
    result = []
    for i in range(n):
        env = 1.0
        if i < a: env = i / a
        elif i > n - r: env = (n - i) / r
        s = sum(amp * env * math.sin(2*math.pi*f*i/sr) for f in freqs)
        result.append(s)
    return result

def pad_note(freq, duration, amp=0.10, harmonics=3, sr=SAMPLE_RATE):
    n = int(duration * sr)
    attack = int(0.08 * sr)
    result = []
    for i in range(n):
        env = i / attack if i < attack else 1.0 - 0.3*(i-attack)/(n-attack+1)
        s = sum(amp/(h+1) * env * math.sin(2*math.pi*freq*(h+1)*i/sr) for h in range(harmonics))
        result.append(s)
    return result

# splash_bg.wav  — calm Cmaj/Am/F/G loop
BPM_S = 70; BEAT_S = 60/BPM_S; BAR_S = BEAT_S*4
chords_s = [
    ([NOTE['C3'],NOTE['G3'],NOTE['E4'],NOTE['C5']], BAR_S*2),
    ([NOTE['A3'],NOTE['E4'],NOTE['A4'],NOTE['C5']], BAR_S*2),
    ([NOTE['F3'],NOTE['C4'],NOTE['A4']], BAR_S*2),
    ([NOTE['G3'],NOTE['B3'],NOTE['D5']], BAR_S*2),
]
harmony_s = concat(*[chord_seg(f, d, amp=0.20, attack=0.15, release=0.3) for f,d in chords_s])

melody_defs_s = [
    (NOTE['E4'],BAR_S),(NOTE['G4'],BAR_S),(NOTE['A4'],BAR_S),(NOTE['G4'],BEAT_S),(NOTE['E4'],BEAT_S*3),
    (NOTE['F4'],BAR_S),(NOTE['A4'],BAR_S),(NOTE['G4'],BAR_S*2),
]
melody_s = concat(*[pad_note(f, d, amp=0.07) for f,d in melody_defs_s])

combined_s = add(harmony_s, melody_s[:len(harmony_s)])
write_wav("splash_bg.wav", fade_out(combined_s, 1.5))

# game_bg.wav  — upbeat Cmaj/Em/F/G loop at 90bpm
BPM_G = 90; BEAT_G = 60/BPM_G; BAR_G = BEAT_G*4
chords_g = [
    ([NOTE['C3'],NOTE['E4'],NOTE['G4']], BAR_G),
    ([NOTE['E3'],NOTE['G4'],NOTE['B4']], BAR_G),
    ([NOTE['F3'],NOTE['A4'],NOTE['C5']], BAR_G),
    ([NOTE['G3'],NOTE['B3'],NOTE['D5']], BAR_G),
]
harmony_g_raw = concat(*[chord_seg(f, d, amp=0.18, attack=0.04, release=0.2) for f,d in chords_g] * 4)

melody_defs_g = [
    (NOTE['C5'],BEAT_G),(NOTE['E5'],BEAT_G),(NOTE['G5'],BEAT_G),(NOTE['E5'],BEAT_G),
    (NOTE['D5'],BEAT_G),(NOTE['E5'],BEAT_G*2),(NOTE['C5'],BEAT_G),
    (NOTE['A4'],BEAT_G),(NOTE['C5'],BEAT_G),(NOTE['E5'],BEAT_G),(NOTE['D5'],BEAT_G),
    (NOTE['E5'],BEAT_G*4),
]
melody_g = concat(*[pad_note(f, d, amp=0.07) for f,d in melody_defs_g] * 4)

combined_g = add(harmony_g_raw, melody_g[:len(harmony_g_raw)])
write_wav("game_bg.wav", fade_out(combined_g, 2.0))

print("\nAll audio files generated!")
for f in sorted(os.listdir(OUTPUT_DIR)):
    if f.endswith('.wav'):
        size = os.path.getsize(os.path.join(OUTPUT_DIR, f))
        print(f"  {f:22s}  {size//1024:>4} KB")

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ───────────────────────────────────────────────────
  late AnimationController _bgCtrl; // Animated background orbs
  late AnimationController _logoCtrl; // Logo entry bounce
  late AnimationController _ringCtrl; // Ring rotation
  late AnimationController _titleCtrl; // Title + subtitle stagger
  late AnimationController _shimmerCtrl; // Shimmer sweep on title
  late AnimationController _progressCtrl; // Loading bar fill

  // ── Animations ────────────────────────────────────────────────────
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();
    AudioService.instance.playSplashMusic();

    // Background orbs — slow, infinite
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Ring rotation — infinite
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Shimmer sweep — infinite
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Logo entry — elastic bounce in
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Title staggered entry
    _titleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _titleCtrl,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleCtrl,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _titleCtrl,
            curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    // Progress bar fill
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _progressValue = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut));

    // Staggered launch sequence
    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _titleCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _progressCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 3200), _goHome);
  }

  void _goHome() {
    if (!mounted) return;
    AudioService.instance.stopMusic();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, _, _) => const HomeScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _logoCtrl.dispose();
    _ringCtrl.dispose();
    _titleCtrl.dispose();
    _shimmerCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // Animated neon background
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, _) => CustomPaint(
              painter: _BgPainter(_bgCtrl.value),
              child: const SizedBox.expand(),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLogo(),
                const SizedBox(height: 36),
                _buildTitle(),
                const SizedBox(height: 10),
                _buildSubtitle(),
                const SizedBox(height: 56),
                _buildProgressBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Logo ───────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoCtrl, _ringCtrl, _bgCtrl]),
      builder: (_, _) {
        final pulse = (sin(_bgCtrl.value * 2 * pi * 3) + 1) / 2;
        return FadeTransition(
          opacity: _logoFade,
          child: Transform.scale(
            scale: _logoScale.value,
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accent.withValues(
                            alpha: 0.3 + 0.15 * pulse,
                          ),
                          blurRadius: 50,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                  ),

                  // Spinning gradient ring
                  Transform.rotate(
                    angle: _ringCtrl.value * 2 * pi,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const SweepGradient(
                          colors: [
                            Color(0xFF7C6FF7),
                            Color(0xFFFF4F5E),
                            Color(0xFF4FDD6F),
                            Color(0xFFFFD044),
                            Color(0xFF00D2FF),
                            Color(0xFF7C6FF7),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Dark inner circle (mask)
                  Container(
                    width: 126,
                    height: 126,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.bgDark,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),

                  // Inner frosted glass circle
                  ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.accent.withValues(alpha: 0.15),
                              AppTheme.bgCard.withValues(alpha: 0.4),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: const Icon(
                          Icons.hub_rounded,
                          color: Colors.white,
                          size: 52,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Title with shimmer ────────────────────────────────────────────

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: Listenable.merge([_titleCtrl, _shimmerCtrl]),
      builder: (_, _) {
        return FadeTransition(
          opacity: _titleFade,
          child: SlideTransition(
            position: _titleSlide,
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) {
                final shimmerPos = _shimmerCtrl.value * 3 - 1;
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: const [Colors.white, Color(0xFFB0AAFF), Colors.white],
                  stops: [
                    (shimmerPos - 0.3).clamp(0.0, 1.0),
                    shimmerPos.clamp(0.0, 1.0),
                    (shimmerPos + 0.3).clamp(0.0, 1.0),
                  ],
                ).createShader(bounds);
              },
              child: Text(
                'PUZZLIFY',
                style: AppTheme.heading(48, letterSpacing: 4),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Subtitle ──────────────────────────────────────────────────────

  Widget _buildSubtitle() {
    return AnimatedBuilder(
      animation: _titleCtrl,
      builder: (_, _) {
        return FadeTransition(
          opacity: _subtitleFade,
          child: SlideTransition(
            position: _subtitleSlide,
            child: Text(
              'Flow Line Puzzle',
              style: AppTheme.body(16, color: AppTheme.textSecondary),
            ),
          ),
        );
      },
    );
  }

  // ── Progress bar ──────────────────────────────────────────────────

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressCtrl, _shimmerCtrl]),
      builder: (_, _) {
        final val = _progressValue.value;
        return Opacity(
          opacity: val > 0 ? 1.0 : 0.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: val,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C6FF7), Color(0xFF00D2FF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${(val * 100).round()}%',
                  style: AppTheme.body(
                    12,
                    color: AppTheme.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Background Glow Painter ───────────────────────────────────────────────────

class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Primary purple orb — drifts slowly
    final dx1 = cos(t * 2 * pi) * 100;
    final dy1 = sin(t * 2 * pi) * 120;
    paint.color = AppTheme.accent.withValues(alpha: 0.18);
    canvas.drawCircle(Offset(cx + dx1, cy + dy1 - 80), 180, paint);

    // Secondary cyan orb — opposite motion
    final dx2 = cos(t * 2 * pi + pi) * 120;
    final dy2 = sin(t * 2 * pi + pi) * 80;
    paint.color = const Color(0xFF00D2FF).withValues(alpha: 0.12);
    canvas.drawCircle(Offset(cx + dx2, cy + dy2 + 120), 160, paint);

    // Subtle warm accent
    final dx3 = sin(t * 2 * pi * 0.7) * 60;
    final dy3 = cos(t * 2 * pi * 0.7) * 100;
    paint.color = const Color(0xFFFF4F5E).withValues(alpha: 0.06);
    canvas.drawCircle(Offset(cx + dx3, cy + dy3), 140, paint);
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) => old.t != t;
}

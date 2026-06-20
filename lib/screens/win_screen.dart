import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/level_config.dart';
import '../theme/app_theme.dart';
import '../data/levels_data.dart';
import 'game_screen.dart';
import 'level_select_screen.dart';

class WinScreen extends StatefulWidget {
  final LevelConfig level;
  final int stars; // 1 – 3
  final int moves;
  final double fillPercent; // 0.0 – 1.0

  const WinScreen({
    super.key,
    required this.level,
    required this.stars,
    required this.moves,
    required this.fillPercent,
  });

  @override
  State<WinScreen> createState() => _WinScreenState();
}

class _WinScreenState extends State<WinScreen> with TickerProviderStateMixin {
  // ── Animations ────────────────────────────────────────────────────
  late AnimationController _entryCtrl;
  late AnimationController _starsCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _bgAnimCtrl;

  late Animation<double> _cardSlide;
  late Animation<double> _cardFade;

  final _rng = Random();

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _starsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _bgAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _cardSlide = Tween<double>(
      begin: 80,
      end: 0,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _cardFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);

    _entryCtrl.forward();
    Future.delayed(
      const Duration(milliseconds: 400),
      () => _starsCtrl.forward(),
    );
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _starsCtrl.dispose();
    _particleCtrl.dispose();
    _bgAnimCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────

  bool get _hasPerfect => widget.fillPercent >= 1.0;

  LevelConfig? get _nextLevel {
    final levels = LevelsData.getLevels(widget.level.difficultyIndex);
    final nextIdx = widget.level.id; // id is 1-based, so nextIdx == next id - 1
    if (nextIdx < levels.length) return levels[nextIdx];
    return null;
  }

  Color _starColor(int s) {
    if (s == 3) return AppTheme.starColor; // Gold
    if (s == 2) return const Color(0xFF00D2FF); // Cyan/Silver
    return const Color(0xFFFF4F5E); // Red/Bronze
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorTheme = _starColor(widget.stars);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // Animated Background Orbs
          AnimatedBuilder(
            animation: _bgAnimCtrl,
            builder: (_, _) => CustomPaint(
              painter: _BgPainter(_bgAnimCtrl.value, colorTheme),
              child: const SizedBox.expand(),
            ),
          ),

          // Particle confetti background
          _ParticleLayer(ctrl: _particleCtrl, rng: _rng, stars: widget.stars),

          // Card
          AnimatedBuilder(
            animation: _entryCtrl,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, _cardSlide.value),
              child: FadeTransition(opacity: _cardFade, child: child),
            ),
            child: _buildCard(context, colorTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, Color colorTheme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: AppTheme.bgCard.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: colorTheme.withValues(
                    alpha: widget.stars == 3 ? 0.8 : 0.4,
                  ),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorTheme.withValues(alpha: 0.15),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTrophy(colorTheme),
                  const SizedBox(height: 24),
                  _buildTitle(),
                  const SizedBox(height: 28),
                  _buildStarsRow(),
                  const SizedBox(height: 32),
                  _buildStatsCard(colorTheme),
                  const SizedBox(height: 36),
                  _buildButtons(context, colorTheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Trophy ────────────────────────────────────────────────────────

  Widget _buildTrophy(Color colorTheme) {
    return AnimatedBuilder(
      animation: _bgAnimCtrl,
      builder: (_, _) {
        final pulse =
            (sin(_bgAnimCtrl.value * 2 * pi * 5) + 1) / 2; // Fast pulse
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                colorTheme.withValues(alpha: 0.5),
                colorTheme.withValues(alpha: 0.1),
              ],
            ),
            border: Border.all(
              color: colorTheme.withValues(alpha: 0.8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: colorTheme.withValues(alpha: 0.4 + 0.3 * pulse),
                blurRadius: 40,
                spreadRadius: 10 * pulse,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 64,
              shadows: [
                Shadow(
                  color: colorTheme.withValues(alpha: 0.8),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Title ─────────────────────────────────────────────────────────

  Widget _buildTitle() {
    final title = widget.stars == 3
        ? 'Perfect!'
        : widget.stars == 2
        ? 'Great Job!'
        : 'Level Done!';
    final sub = _hasPerfect
        ? 'You filled every cell — flawless!'
        : 'Connect all pairs to earn 3 stars.';

    return Column(
      children: [
        Text(title, style: AppTheme.heading(38, color: Colors.white)),
        const SizedBox(height: 8),
        Text(
          sub,
          style: AppTheme.body(14, color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Stars row ─────────────────────────────────────────────────────

  Widget _buildStarsRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < widget.stars;
        final delay = i * 0.25;

        return AnimatedBuilder(
          animation: _starsCtrl,
          builder: (_, _) {
            final t = ((_starsCtrl.value - delay) / 0.4).clamp(0.0, 1.0);
            final scale = filled ? Curves.elasticOut.transform(t) : 1.0;
            return Transform.scale(
              scale: scale,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 56,
                  color: filled ? AppTheme.starColor : Colors.white24,
                  shadows: filled
                      ? [
                          Shadow(
                            color: AppTheme.starColor.withValues(alpha: 0.6),
                            blurRadius: 20,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // ── Stats card ────────────────────────────────────────────────────

  Widget _buildStatsCard(Color colorTheme) {
    final fillPct = (widget.fillPercent * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat(Icons.grid_on_rounded, '$fillPct%', 'Filled'),
          _vDivider(),
          _stat(Icons.touch_app_rounded, '${widget.moves}', 'Moves'),
          _vDivider(),
          _stat(
            Icons.star_rounded,
            '${widget.stars}/3',
            'Stars',
            valueColor: colorTheme,
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label, {Color? valueColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white54, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTheme.heading(24, color: valueColor ?? Colors.white),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTheme.body(12, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _vDivider() => Container(
    height: 48,
    width: 1,
    color: Colors.white.withValues(alpha: 0.1),
  );

  // ── Buttons ───────────────────────────────────────────────────────

  Widget _buildButtons(BuildContext context, Color colorTheme) {
    final next = _nextLevel;

    return Column(
      children: [
        // Next level (if available)
        if (next != null)
          _primaryBtn(
            label: 'Next Level',
            icon: Icons.arrow_forward_rounded,
            colorTheme: colorTheme,
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => GameScreen(level: next)),
            ),
          ),

        const SizedBox(height: 16),

        Row(
          children: [
            // Retry
            Expanded(
              child: _secondaryBtn(
                label: 'Retry',
                icon: Icons.restart_alt_rounded,
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(level: widget.level),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Level select
            Expanded(
              child: _secondaryBtn(
                label: 'Levels',
                icon: Icons.grid_view_rounded,
                onTap: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
                  (r) => r.isFirst,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _primaryBtn({
    required String label,
    required IconData icon,
    required Color colorTheme,
    required VoidCallback onTap,
  }) {
    // If not gold, default to standard purple gradient for "Next Level"
    final useGold = colorTheme == AppTheme.starColor;
    final c1 = useGold ? const Color(0xFFFFD044) : const Color(0xFF9D97FF);
    final c2 = useGold ? const Color(0xFFD69A00) : const Color(0xFF5548CC);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [c1, c2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: c1.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(label, style: AppTheme.heading(18, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _secondaryBtn({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.body(
                15,
                color: Colors.white,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Confetti / particle layer ─────────────────────────────────────────────────

class _ParticleLayer extends StatelessWidget {
  final AnimationController ctrl;
  final Random rng;
  final int stars;

  const _ParticleLayer({
    required this.ctrl,
    required this.rng,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, _) => CustomPaint(
        painter: _ParticlePainter(ctrl.value, rng, stars),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double t;
  final Random rng;
  final int stars;

  static late List<_Particle> _particles;
  static bool _init = false;

  _ParticlePainter(this.t, this.rng, this.stars) {
    if (!_init) {
      _particles = List.generate(
        stars == 3 ? 80 : 40,
        (_) => _Particle.random(rng),
      );
      _init = true;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final progress = (t + p.offset) % 1.0;
      final x = p.x * size.width;
      final y = (progress * (size.height + 40)) - 20;
      final opacity = progress < 0.1
          ? progress / 0.1
          : progress > 0.85
          ? (1 - progress) / 0.15
          : 1.0;

      canvas.drawCircle(
        Offset(x, y),
        p.radius,
        Paint()..color = p.color.withValues(alpha: opacity * 0.75),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => t != old.t;
}

class _Particle {
  final double x, offset, radius;
  final Color color;

  _Particle({
    required this.x,
    required this.offset,
    required this.radius,
    required this.color,
  });

  static _Particle random(Random r) => _Particle(
    x: r.nextDouble(),
    offset: r.nextDouble(),
    radius: 3 + r.nextDouble() * 4,
    color: AppTheme.dotColors[r.nextInt(AppTheme.dotColors.length)],
  );
}

// ── Background Glow Painter ───────────────────────────────────────────────────

class _BgPainter extends CustomPainter {
  final double t;
  final Color baseColor;

  _BgPainter(this.t, this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    void drawOrb(Offset center, double r, Color c) {
      paint.color = c;
      canvas.drawCircle(center, r, paint);
    }

    final cx = size.width / 2;
    final cy = size.height / 2;

    final dx1 = cos(t * 2 * pi) * 120;
    final dy1 = sin(t * 2 * pi) * 150;
    drawOrb(
      Offset(cx + dx1, cy + dy1 - 100),
      150,
      baseColor.withValues(alpha: 0.15),
    );

    final dx2 = cos(t * 2 * pi + pi) * 140;
    final dy2 = sin(t * 2 * pi + pi) * 100;

    final accentColor = baseColor == AppTheme.starColor
        ? const Color(0xFFFF6B00) // Gold pairs with Orange
        : const Color(0xFFB14DFF); // Purple otherwise

    drawOrb(
      Offset(cx + dx2, cy + dy2 + 100),
      160,
      accentColor.withValues(alpha: 0.15),
    );
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) =>
      old.t != t || old.baseColor != baseColor;
}

import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/levels_data.dart';
import '../models/level_config.dart';
import '../services/level_generator.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'level_select_screen.dart';
import 'missions_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  String _userName = '';
  int _totalStars = 0;
  LevelConfig? _nextLevel;

  @override
  void initState() {
    super.initState();
    _loadProfile();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────
  // Data
  // ─────────────────────────────────────────────────────────────────

  Future<void> _loadProfile() async {
    final name = await StorageService.getUserName();
    final allStars = await StorageService.getAllStars();
    final stars = allStars.values.fold<int>(0, (sum, val) => sum + val);

    // Auto-detect next unplayed level
    LevelConfig? nextLvl;
    for (int diff = 0; diff < 4; diff++) {
      final levels = LevelsData.getLevels(diff);
      for (int i = 0; i < levels.length; i++) {
        if ((allStars[levels[i].levelKey] ?? 0) == 0) {
          nextLvl = levels[i];
          break;
        }
      }
      if (nextLvl != null) break;
    }
    // Fallback if everything is beaten
    nextLvl ??= LevelsData.getLevel(0, 0);

    if (mounted) {
      setState(() {
        _userName = name;
        _totalStars = stars;
        _nextLevel = nextLvl;
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          _AnimatedBackground(animation: _bgCtrl),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 32),
                  _buildMainPlayCard(),
                  const SizedBox(height: 24),
                  Expanded(child: _buildSecondaryGrid()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Profile Header ───────────────────────────────────────────────

  Widget _buildProfileHeader() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        _loadProfile();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.bgCard.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF9D97FF), Color(0xFF4A3FCC)],
                    ),
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName.isEmpty ? 'Loading...' : _userName,
                        style: AppTheme.heading(16, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Welcome back!',
                        style: AppTheme.body(12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.bgDark.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppTheme.starColor,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_totalStars',
                        style: AppTheme.heading(16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Main Hero Card ───────────────────────────────────────────────

  Widget _buildMainPlayCard() {
    if (_nextLevel == null) return const SizedBox(height: 180);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GameScreen(level: _nextLevel!)),
        );
        _loadProfile();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFB14DFF).withValues(alpha: 0.7),
                  const Color(0xFF4A3FCC).withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB14DFF).withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  bottom: -30,
                  child: Icon(
                    Icons.play_circle_filled_rounded,
                    size: 160,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _nextLevel!.difficulty.toUpperCase(),
                          style: AppTheme.body(
                            11,
                            color: Colors.white,
                            weight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'CONTINUE JOURNEY',
                        style: AppTheme.heading(28, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Level ${_nextLevel!.id}',
                        style: AppTheme.body(14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Secondary Grid ───────────────────────────────────────────────

  Widget _buildSecondaryGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.05,
      physics: const BouncingScrollPhysics(),
      children: [
        _buildGridAction(
          title: 'ALL LEVELS',
          subtitle: 'Browse library',
          icon: Icons.grid_view_rounded,
          color: const Color(0xFF4FDD6F),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
            );
            _loadProfile();
          },
        ),
        _buildGridAction(
          title: 'ARCADE',
          subtitle: 'Endless mode',
          icon: Icons.all_inclusive_rounded,
          color: const Color(0xFFFFD044),
          onTap: () async {
            final level = LevelGenerator.generate(
              gridSize: 8,
              difficultyIndex: 3,
              difficultyName: 'Expert',
            );
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => GameScreen(level: level)),
            );
            _loadProfile();
          },
        ),
        _buildGridAction(
          title: 'MISSIONS',
          subtitle: 'Active Bounties',
          icon: Icons.military_tech_rounded,
          color: const Color(0xFFFF4F5E),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MissionsScreen()),
            );
            _loadProfile();
          },
        ),
        _buildGridAction(
          title: 'SETTINGS',
          subtitle: 'Options & Audio',
          icon: Icons.settings_rounded,
          color: const Color(0xFFB14DFF),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
            _loadProfile();
          },
        ),
        _buildGridAction(
          title: 'LEADERBOARD',
          subtitle: 'Global Ranking',
          icon: Icons.leaderboard_rounded,
          color: const Color(0xFF00D2FF),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
            );
            _loadProfile();
          },
        ),
      ],
    );
  }

  Widget _buildGridAction({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.bgCard.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: color.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 36),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.heading(16, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.body(11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated background (floating orbs + dot grid) ─────────────────

class _AnimatedBackground extends StatelessWidget {
  final Animation<double> animation;
  const _AnimatedBackground({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) => CustomPaint(
        painter: _BgPainter(animation.value),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle dot matrix
    final dotPaint = Paint()
      ..color = AppTheme.gridLine.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    const spacing = 36.0;
    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }

    // Floating colour orbs
    _orb(
      canvas,
      Offset(size.width * 0.18, size.height * 0.28),
      AppTheme.accent.withValues(alpha: 0.06 + 0.03 * t),
      160,
    );
    _orb(
      canvas,
      Offset(size.width * 0.82, size.height * 0.65),
      const Color(0xFFFF4F5E).withValues(alpha: 0.05 + 0.025 * t),
      130,
    );
    _orb(
      canvas,
      Offset(size.width * 0.55, size.height * 0.08),
      const Color(0xFF4FDD6F).withValues(alpha: 0.04 + 0.02 * t),
      110,
    );
    _orb(
      canvas,
      Offset(size.width * 0.28, size.height * 0.82),
      const Color(0xFFFFD044).withValues(alpha: 0.04 + 0.02 * t),
      100,
    );
  }

  void _orb(Canvas canvas, Offset c, Color color, double r) =>
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 55),
      );

  @override
  bool shouldRepaint(_BgPainter old) => t != old.t;
}

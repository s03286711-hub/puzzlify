import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/levels_data.dart';
import '../models/level_config.dart';
import '../services/level_generator.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/top_notification.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;
  late AnimationController _bgAnimCtrl;
  Map<String, int> _allStars = {};

  static const List<String> _labels = ['Easy', 'Medium', 'Hard', 'Expert'];
  static const List<Color> _diffColors = [
    Color(0xFF4FDD6F), // Easy  – green
    Color(0xFFFFD044), // Medium – yellow
    Color(0xFFFF4F5E), // Hard  – red
    Color(0xFFB14DFF), // Expert – purple
  ];
  static const List<IconData> _diffIcons = [
    Icons.sentiment_very_satisfied_rounded,
    Icons.sentiment_neutral_rounded,
    Icons.whatshot_rounded,
    Icons.diamond_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
    
    _bgAnimCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();

    _loadStars();
  }

  Future<void> _loadStars() async {
    final stars = await StorageService.getAllStars();
    if (mounted) setState(() => _allStars = stars);
  }

  @override
  void dispose() {
    _bgAnimCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // Animated Neon Background
          AnimatedBuilder(
            animation: _bgAnimCtrl,
            builder: (_, _) => CustomPaint(
              painter: _BgPainter(_bgAnimCtrl.value),
              child: const SizedBox.expand(),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildCustomAppBar(),
                _buildCustomTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: List.generate(4, _buildDifficultyPage),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text('LEVEL LIBRARY', style: AppTheme.heading(22, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.bgCard.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(
          color: _diffColors[_tabCtrl.index].withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _diffColors[_tabCtrl.index], width: 1.5),
          boxShadow: [
            BoxShadow(color: _diffColors[_tabCtrl.index].withValues(alpha: 0.2), blurRadius: 8),
          ]
        ),
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        tabs: List.generate(4, (i) {
          final isActive = _tabCtrl.index == i;
          return Tab(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _diffIcons[i],
                  size: 16,
                  color: isActive ? _diffColors[i] : AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _labels[i],
                  style: AppTheme.body(
                    12,
                    color: isActive ? Colors.white : AppTheme.textSecondary,
                    weight: isActive ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────

  Widget _buildDifficultyPage(int index) {
    List<LevelConfig> levels;
    int size;
    Color color = _diffColors[index];

    switch (index) {
      case 0:
        levels = LevelsData.easyLevels;
        size = 5;
        break;
      case 1:
        levels = LevelsData.mediumLevels;
        size = 6;
        break;
      case 2:
        levels = LevelsData.hardLevels;
        size = 7;
        break;
      case 3:
      default:
        levels = LevelsData.expertLevels;
        size = 8;
        break;
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: levels.length + 1,
      itemBuilder: (ctx, idx) {
        if (idx == levels.length) {
          return _buildRandomLevelCard(size, index, color);
        }
        final lvl = levels[idx];
        final stars = _allStars[lvl.levelKey] ?? 0;
        final isUnlocked = _isLevelUnlocked(index, idx, levels);
        return _buildLevelCard(lvl, idx, stars, isUnlocked, color);
      },
    );
  }

  bool _isLevelUnlocked(int diffIndex, int levelIndex, List<LevelConfig> levels) {
    if (diffIndex == 0 && levelIndex == 0) return true;
    if (levelIndex > 0) {
      final prevKey = levels[levelIndex - 1].levelKey;
      final prevStars = _allStars[prevKey] ?? 0;
      if (prevStars > 0) return true;
    }
    if (levelIndex == 0 && diffIndex > 0) {
      List<LevelConfig> prevDiffLevels;
      if (diffIndex == 1) {
        prevDiffLevels = LevelsData.easyLevels;
      } else if (diffIndex == 2) {
        prevDiffLevels = LevelsData.mediumLevels;
      } else {
        prevDiffLevels = LevelsData.hardLevels;
      }

      if (prevDiffLevels.isEmpty) return true;
      final lastKey = prevDiffLevels.last.levelKey;
      final lastStars = _allStars[lastKey] ?? 0;
      if (lastStars > 0) return true;
    }
    return false;
  }

  // ─────────────────────────────────────────────────────────────────

  Widget _buildLevelCard(
      LevelConfig lvl, int index, int starsEarned, bool isUnlocked, Color color) {
    return GestureDetector(
      onTap: isUnlocked
          ? () => _playLevel(lvl)
          : () => _showLockedMsg(color),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isUnlocked 
                  ? AppTheme.bgCard.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isUnlocked 
                    ? color.withValues(alpha: starsEarned == 3 ? 0.8 : 0.4)
                    : Colors.white.withValues(alpha: 0.05),
                width: isUnlocked ? 1.5 : 1,
              ),
              boxShadow: starsEarned == 3 ? [
                BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 15)
              ] : null,
            ),
            child: Stack(
              children: [
                if (!isUnlocked)
                  const Center(
                    child: Icon(Icons.lock_rounded, size: 36, color: Colors.white24),
                  )
                else ...[
                  Positioned(
                    top: 12,
                    left: 16,
                    child: Text(
                      '#${index + 1}',
                      style: AppTheme.heading(24, color: color),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (starIdx) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Icon(
                            starIdx < starsEarned 
                                ? Icons.star_rounded 
                                : Icons.star_border_rounded,
                            color: starIdx < starsEarned 
                                ? AppTheme.starColor 
                                : Colors.white24,
                            size: 22,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRandomLevelCard(int size, int diffIndex, Color color) {
    return GestureDetector(
      onTap: () async {
        final cfg = LevelGenerator.generate(
          gridSize: size,
          difficultyIndex: diffIndex,
          difficultyName: 'Endless ARCADE',
        );
        _playLevel(cfg);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.4),
                  color.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color, width: 1.5),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 20)
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.all_inclusive_rounded, size: 40, color: Colors.white),
                const SizedBox(height: 8),
                Text('ENDLESS', style: AppTheme.heading(16, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLockedMsg(Color color) {
    TopNotification.show(context, 'Complete previous levels to unlock!', color: color);
  }

  Future<void> _playLevel(LevelConfig lvl) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(level: lvl)),
    );
    _loadStars();
  }
}

// Reuse the background painter from home_screen for visual consistency
class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    
    void drawOrb(Offset center, double r, Color c) {
      paint.color = c;
      canvas.drawCircle(center, r, paint);
    }
    
    final cx = size.width / 2;
    final cy = size.height / 2;
    
    // Orb 1: Cyan
    final dx1 = cos(t * 2 * pi) * 100;
    final dy1 = sin(t * 2 * pi) * 150;
    drawOrb(Offset(cx + dx1, cy + dy1 - 100), 120, const Color(0xFF00D2FF).withValues(alpha: 0.15));
    
    // Orb 2: Purple
    final dx2 = cos(t * 2 * pi + pi) * 120;
    final dy2 = sin(t * 2 * pi + pi) * 100;
    drawOrb(Offset(cx + dx2, cy + dy2 + 100), 140, const Color(0xFFB14DFF).withValues(alpha: 0.15));
    
    // Orb 3: Red
    final dx3 = sin(t * 2 * pi * 1.5) * 80;
    drawOrb(Offset(cx + dx3, cy + 300), 100, const Color(0xFFFF4F5E).withValues(alpha: 0.1));
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) => old.t != t;
}

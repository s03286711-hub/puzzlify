import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/grid_pos.dart';
import '../models/level_config.dart';
import '../painters/grid_painter.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'win_screen.dart';

class GameScreen extends StatefulWidget {
  final LevelConfig level;
  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _Snapshot {
  final Map<int, List<GridPos>> paths;
  final Set<int> completed;
  _Snapshot({required this.paths, required this.completed});
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // ── Game state ────────────────────────────────────────────────────
  late Map<int, List<GridPos>> _paths;
  late Set<int> _completedColors;
  int? _activeDragColor;
  GridPos? _lastDragPos;
  int _moves = 0;
  bool _isWon = false;

  // Undo stack
  final _undoStack = <_Snapshot>[];

  // ── Animations ───────────────────────────────────────────────────
  late AnimationController _glowCtrl;
  late AnimationController _winCtrl;
  late AnimationController _bgAnimCtrl;

  @override
  void initState() {
    super.initState();
    _initGame();
    // Start gameplay music
    AudioService.instance.playGameMusic();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _winCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _bgAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  void _initGame() {
    _paths = {
      for (final p in widget.level.colorPairs) p.colorIndex: <GridPos>[],
    };
    _completedColors = {};
    _activeDragColor = null;
    _lastDragPos = null;
    _moves = 0;
    _isWon = false;
    _undoStack.clear();
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _winCtrl.dispose();
    _bgAnimCtrl.dispose();
    AudioService.instance.stopMusic();
    super.dispose();
  }

  // ── Colors ────────────────────────────────────────────────────────
  Color get _difficultyColor {
    switch (widget.level.difficultyIndex) {
      case 0:
        return const Color(0xFF4FDD6F); // Easy
      case 1:
        return const Color(0xFFFFD044); // Medium
      case 2:
        return const Color(0xFFFF4F5E); // Hard
      case 3:
      default:
        return const Color(0xFFB14DFF); // Expert
    }
  }

  // ── Touch helpers ─────────────────────────────────────────────────

  GridPos? _toGrid(Offset local, double cellSize) {
    final r = (local.dy / cellSize).floor();
    final c = (local.dx / cellSize).floor();
    if (r < 0 ||
        r >= widget.level.gridSize ||
        c < 0 ||
        c >= widget.level.gridSize) {
      return null;
    }
    return GridPos(r, c);
  }

  // ── Pan handlers ──────────────────────────────────────────────────

  void _onPanStart(DragStartDetails d, double cellSize) {
    if (_isWon) return;
    final pos = _toGrid(d.localPosition, cellSize);
    if (pos == null) return;

    for (final pair in widget.level.colorPairs) {
      if (pair.hasEndpoint(pos)) {
        _saveUndo();
        HapticFeedback.lightImpact();
        AudioService.instance.playTilePick();
        setState(() {
          _activeDragColor = pair.colorIndex;
          _paths[pair.colorIndex] = [pos];
          _completedColors.remove(pair.colorIndex);
          _lastDragPos = pos;
          _moves++;
        });
        return;
      }
    }
    _activeDragColor = null;
  }

  void _onPanUpdate(DragUpdateDetails d, double cellSize) {
    if (_isWon || _activeDragColor == null) return;
    final pos = _toGrid(d.localPosition, cellSize);
    if (pos == null || pos == _lastDragPos) return;
    _extendPath(pos);
    _lastDragPos = pos;
  }

  void _onPanEnd(DragEndDetails _) {
    if (_activeDragColor != null) {
      setState(() {
        _activeDragColor = null;
        _lastDragPos = null;
      });
      _refreshCompleted();
      _checkWin();
    }
  }

  // ── Core path logic ───────────────────────────────────────────────

  void _extendPath(GridPos pos) {
    final color = _activeDragColor!;
    final path = _paths[color]!;
    if (path.isEmpty) return;

    final last = path.last;
    if (!last.isAdjacentTo(pos)) return;

    final existingIdx = path.indexOf(pos);
    if (existingIdx >= 0) {
      setState(() {
        _paths[color] = path.sublist(0, existingIdx + 1);
        _completedColors.remove(color);
      });
      return;
    }

    for (final pair in widget.level.colorPairs) {
      if (pair.colorIndex != color && pair.hasEndpoint(pos)) return;
    }

    for (final entry in _paths.entries) {
      if (entry.key == color) continue;
      final idx = entry.value.indexOf(pos);
      if (idx >= 0) {
        setState(() {
          _paths[entry.key] = entry.value.sublist(0, idx);
          _completedColors.remove(entry.key);
        });
      }
    }

    setState(() => path.add(pos));
    AudioService.instance.playTileStep();

    final pair = widget.level.colorPairs.firstWhere(
      (p) => p.colorIndex == color,
    );
    final other = pair.otherEndpoint(path.first);
    if (pos == other) {
      HapticFeedback.mediumImpact();
      AudioService.instance.playConnect();
      setState(() {
        _completedColors.add(color);
        _activeDragColor = null;
        _lastDragPos = null;
      });
      _checkWin();
      return;
    }

    _refreshCompleted();
  }

  void _refreshCompleted() {
    for (final pair in widget.level.colorPairs) {
      final path = _paths[pair.colorIndex] ?? [];
      final ok =
          path.length >= 2 &&
          pair.hasEndpoint(path.first) &&
          pair.hasEndpoint(path.last) &&
          path.first != path.last;
      if (ok) {
        _completedColors.add(pair.colorIndex);
      } else {
        _completedColors.remove(pair.colorIndex);
      }
    }
  }

  void _checkWin() {
    if (_completedColors.length != widget.level.colorPairs.length) return;

    final filled = <GridPos>{};
    for (final path in _paths.values) {
      filled.addAll(path);
    }
    final fillPct = filled.length / widget.level.totalCells;

    final stars = fillPct >= 1.0
        ? 3
        : fillPct >= 0.75
        ? 2
        : 1;

    HapticFeedback.heavyImpact();
    AudioService.instance.playWin();
    setState(() => _isWon = true);
    _winCtrl.forward();
    StorageService.saveStars(widget.level.levelKey, stars);

    Future.delayed(const Duration(milliseconds: 750), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WinScreen(
            level: widget.level,
            stars: stars,
            moves: _moves,
            fillPercent: fillPct,
          ),
        ),
      );
    });
  }

  // ── Undo / Reset ──────────────────────────────────────────────────

  void _saveUndo() {
    _undoStack.add(
      _Snapshot(
        paths: {for (final e in _paths.entries) e.key: List.from(e.value)},
        completed: Set.from(_completedColors),
      ),
    );
    if (_undoStack.length > 30) _undoStack.removeAt(0);
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    HapticFeedback.lightImpact();
    final snap = _undoStack.removeLast();
    setState(() {
      _paths = snap.paths;
      _completedColors = snap.completed;
      _activeDragColor = null;
    });
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(_initGame);
  }

  // ── Build ─────────────────────────────────────────────────────────

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
              painter: _BgPainter(_bgAnimCtrl.value, _difficultyColor),
              child: const SizedBox.expand(),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildProgressHUD(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (ctx, constraints) {
                      final size = min(
                        constraints.maxWidth - 32,
                        constraints.maxHeight - 32,
                      );
                      final cellSize = size / widget.level.gridSize;
                      return Center(child: _buildBoard(size, cellSize));
                    },
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Column(
            children: [
              Text(
                'LEVEL ${widget.level.id}',
                style: AppTheme.heading(20, color: Colors.white),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _difficultyColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _difficultyColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  widget.level.difficulty.toUpperCase(),
                  style: AppTheme.body(
                    11,
                    color: _difficultyColor,
                    weight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          // Moves counter in top right
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.bgCard.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_moves',
                  style: AppTheme.heading(20, color: Colors.white),
                ),
                Text(
                  'MOVES',
                  style: AppTheme.body(10, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress HUD ──────────────────────────────────────────────────

  Widget _buildProgressHUD() {
    final connected = _completedColors.length;
    final total = widget.level.colorPairs.length;
    final progress = total == 0 ? 0.0 : connected / total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.bgCard.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                ..._buildDotIndicators(),
                const SizedBox(width: 16),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.black.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1.0
                            ? const Color(0xFF4FDD6F)
                            : _difficultyColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$connected/$total',
                  style: AppTheme.heading(14, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDotIndicators() {
    return widget.level.colorPairs.map((pair) {
      final done = _completedColors.contains(pair.colorIndex);
      final color = AppTheme.dotColors[pair.colorIndex];
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 12,
        height: 12,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done ? color : color.withValues(alpha: 0.15),
          border: done ? null : Border.all(color: color.withValues(alpha: 0.5)),
          boxShadow: done
              ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8)]
              : null,
        ),
      );
    }).toList();
  }

  // ── Game board ────────────────────────────────────────────────────

  Widget _buildBoard(double size, double cellSize) {
    return AnimatedBuilder(
      animation: _winCtrl,
      builder: (_, child) {
        final winScale = 1.0 + 0.04 * sin(_winCtrl.value * pi);
        return Transform.scale(scale: winScale, child: child);
      },
      child: GestureDetector(
        onPanStart: (d) => _onPanStart(d, cellSize),
        onPanUpdate: (d) => _onPanUpdate(d, cellSize),
        onPanEnd: _onPanEnd,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _difficultyColor.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _difficultyColor.withValues(alpha: 0.15),
                    blurRadius: 30,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: AnimatedBuilder(
                animation: _glowCtrl,
                builder: (_, _) => CustomPaint(
                  painter: GridPainter(
                    level: widget.level,
                    paths: _paths,
                    completedColors: _completedColors,
                    glowAnim: _glowCtrl.value,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _glassBtn(
              icon: Icons.undo_rounded,
              label: 'UNDO',
              onTap: _undoStack.isNotEmpty ? _undo : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _glassBtn(
              icon: Icons.restart_alt_rounded,
              label: 'RESET',
              onTap: _paths.values.any((p) => p.isNotEmpty) ? _reset : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassBtn({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.bgCard.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(label, style: AppTheme.heading(16, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
      160,
      baseColor.withValues(alpha: 0.12),
    );

    final dx2 = cos(t * 2 * pi + pi) * 140;
    final dy2 = sin(t * 2 * pi + pi) * 100;

    final accentColor = const Color(0xFF00D2FF); // Cyan always pairs nicely

    drawOrb(
      Offset(cx + dx2, cy + dy2 + 100),
      180,
      accentColor.withValues(alpha: 0.12),
    );
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) =>
      old.t != t || old.baseColor != baseColor;
}

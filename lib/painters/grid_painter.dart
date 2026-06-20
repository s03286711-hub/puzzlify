import 'dart:math';
import 'package:flutter/material.dart';
import '../models/grid_pos.dart';
import '../models/level_config.dart';
import '../theme/app_theme.dart';

/// CustomPainter that renders the entire game board:
///   1. Subtle cell-fill backgrounds for occupied cells
///   2. Grid lines
///   3. Coloured paths (thick, rounded, with glow when complete)
///   4. Endpoint dots (glowing pulse when complete)
class GridPainter extends CustomPainter {
  final LevelConfig level;
  final Map<int, List<GridPos>> paths;
  final Set<int> completedColors;

  /// Animation value 0..1 (repeating) driving the glow / pulse effects.
  final double glowAnim;

  const GridPainter({
    required this.level,
    required this.paths,
    required this.completedColors,
    this.glowAnim = 0,
  });

  // ─────────────────────────────────────────────────────────────────
  // Paint
  // ─────────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / level.gridSize;
    _drawCellFills(canvas, size, cellSize);
    _drawGridLines(canvas, size, cellSize);
    _drawPaths(canvas, cellSize);
    _drawDots(canvas, cellSize);
  }

  // ── Cell fills ───────────────────────────────────────────────────

  void _drawCellFills(Canvas canvas, Size size, double cellSize) {
    for (int r = 0; r < level.gridSize; r++) {
      for (int c = 0; c < level.gridSize; c++) {
        final pos = GridPos(r, c);
        // Skip endpoint cells — they'll be drawn as solid dots.
        final isEndpoint = level.colorPairs.any((p) => p.hasEndpoint(pos));
        if (isEndpoint) continue;

        // Find which colour owns this cell.
        int colorIdx = -1;
        for (final e in paths.entries) {
          if (e.value.contains(pos)) {
            colorIdx = e.key;
            break;
          }
        }
        if (colorIdx < 0) continue;

        final color = AppTheme.dotColors[colorIdx];
        final rect = Rect.fromLTWH(
          c * cellSize + 1.5,
          r * cellSize + 1.5,
          cellSize - 3,
          cellSize - 3,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(cellSize * 0.18)),
          Paint()
            ..color = color.withValues(alpha: 0.18)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  // ── Grid lines ───────────────────────────────────────────────────

  void _drawGridLines(Canvas canvas, Size size, double cellSize) {
    final paint = Paint()
      ..color = AppTheme.gridLine
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= level.gridSize; i++) {
      final p = i * cellSize;
      canvas.drawLine(Offset(p, 0), Offset(p, size.height), paint);
      canvas.drawLine(Offset(0, p), Offset(size.width, p), paint);
    }
  }

  // ── Paths ────────────────────────────────────────────────────────

  void _drawPaths(Canvas canvas, double cellSize) {
    for (final entry in paths.entries) {
      final colorIdx = entry.key;
      final path = entry.value;
      if (path.length < 2) continue;

      final color = AppTheme.dotColors[colorIdx];
      final isComplete = completedColors.contains(colorIdx);
      final flPath = _buildFlutterPath(path, cellSize);

      // Soft glow underneath for completed paths
      if (isComplete) {
        final glowOpacity = 0.12 + 0.08 * sin(glowAnim * 2 * pi);
        canvas.drawPath(
          flPath,
          Paint()
            ..color = color.withValues(alpha: glowOpacity)
            ..strokeWidth = cellSize * 0.72
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
            ..style = PaintingStyle.stroke,
        );
      }

      // Main path line
      canvas.drawPath(
        flPath,
        Paint()
          ..color = isComplete ? color : color.withValues(alpha: 0.88)
          ..strokeWidth = cellSize * 0.44
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke,
      );
    }
  }

  Path _buildFlutterPath(List<GridPos> positions, double cellSize) {
    final p = Path();
    final first = _cellCenter(positions.first, cellSize);
    p.moveTo(first.dx, first.dy);
    for (int i = 1; i < positions.length; i++) {
      final c = _cellCenter(positions[i], cellSize);
      p.lineTo(c.dx, c.dy);
    }
    return p;
  }

  // ── Dots ─────────────────────────────────────────────────────────

  void _drawDots(Canvas canvas, double cellSize) {
    final r = cellSize * 0.33;

    for (final pair in level.colorPairs) {
      final color = AppTheme.dotColors[pair.colorIndex];
      final isComplete = completedColors.contains(pair.colorIndex);

      for (final ep in [pair.start, pair.end]) {
        final c = _cellCenter(ep, cellSize);

        // Animated glow ring for completed colours
        if (isComplete) {
          final pulse = 1.0 + 0.1 * sin(glowAnim * 2 * pi);
          canvas.drawCircle(
            c,
            r * 1.7 * pulse,
            Paint()
              ..color = color.withValues(alpha: 0.22)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
          );
        }

        // Subtle white ring (border)
        canvas.drawCircle(
          c,
          r + 2.5,
          Paint()..color = Colors.white.withValues(alpha: 0.12),
        );

        // Main dot
        canvas.drawCircle(c, r, Paint()..color = color);

        // Specular highlight
        canvas.drawCircle(
          c - Offset(r * 0.27, r * 0.27),
          r * 0.30,
          Paint()..color = Colors.white.withValues(alpha: 0.38),
        );
      }
    }
  }

  // ── Utilities ────────────────────────────────────────────────────

  Offset _cellCenter(GridPos pos, double cellSize) =>
      Offset((pos.col + 0.5) * cellSize, (pos.row + 0.5) * cellSize);

  @override
  bool shouldRepaint(GridPainter old) =>
      glowAnim != old.glowAnim ||
      paths != old.paths ||
      completedColors != old.completedColors;
}

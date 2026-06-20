import 'grid_pos.dart';

/// Represents one matching pair of colored endpoints on the grid.
class ColorPair {
  final GridPos start;
  final GridPos end;
  final int colorIndex;

  const ColorPair(this.start, this.end, this.colorIndex);

  bool hasEndpoint(GridPos pos) => pos == start || pos == end;

  GridPos otherEndpoint(GridPos pos) {
    assert(hasEndpoint(pos), 'pos must be one of the pair endpoints');
    return pos == start ? end : start;
  }
}

/// Full configuration for a single level.
class LevelConfig {
  final int id;
  final int gridSize;
  final List<ColorPair> colorPairs;
  final String difficulty;
  final int difficultyIndex; // 0=Easy, 1=Medium, 2=Hard

  const LevelConfig({
    required this.id,
    required this.gridSize,
    required this.colorPairs,
    required this.difficulty,
    required this.difficultyIndex,
  });

  int get colorCount => colorPairs.length;
  int get totalCells => gridSize * gridSize;

  /// Unique key used for persistence.
  String get levelKey => 'lv_${difficultyIndex}_$id';
}

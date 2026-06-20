class GridPos {
  final int row, col;

  const GridPos(this.row, this.col);

  /// Returns true if this cell is directly above/below/left/right of [other].
  bool isAdjacentTo(GridPos other) {
    final dr = (row - other.row).abs();
    final dc = (col - other.col).abs();
    return (dr == 1 && dc == 0) || (dr == 0 && dc == 1);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPos &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row * 100 + col;

  @override
  String toString() => 'GridPos($row, $col)';
}

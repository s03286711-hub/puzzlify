import '../models/grid_pos.dart';
import '../models/level_config.dart';

/// SOLVABLE level data: 10 Easy (5×5), 10 Medium (6×6), 10 Hard (7×7).
///
/// Every level was designed backwards — a full-grid solution was laid out
/// first, then the endpoints were extracted.  This guarantees every puzzle
/// has at least one valid solution that fills the entire grid.
///
/// Color index legend:
///   0=Red  1=Blue  2=Green  3=Yellow  4=Purple
///   5=Orange  6=Pink  7=Cyan  8=White  9=Coral
class LevelsData {
  // ──────────────────────────────────────────────────────────────────
  // EASY  –  5 × 5 grids
  // ──────────────────────────────────────────────────────────────────
  static const List<LevelConfig> easyLevels = [
    // ── E1 : 3 colours ──
    // Solution paths:
    //   R: (0,0)→(0,1)→(0,2)→(0,3)→(0,4)→(1,4)→(2,4)→(3,4)→(4,4)
    //   B: (1,0)→(1,1)→(1,2)→(1,3)→(2,3)→(2,2)→(2,1)→(2,0)→(3,0)→(4,0)
    //   G: (3,1)→(3,2)→(3,3)→(4,3)→(4,2)→(4,1)
    LevelConfig(
      id: 1, gridSize: 5, difficulty: 'Easy', difficultyIndex: 0,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(4, 4), 0),
        ColorPair(GridPos(1, 0), GridPos(4, 0), 1),
        ColorPair(GridPos(3, 1), GridPos(4, 1), 2),
      ],
    ),

    // ── E2 : 4 colours ──
    // Solution paths:
    //   R: (0,0)→(0,1)→(0,2)→(0,3)→(0,4)→(1,4)→(1,3)
    //   B: (1,0)→(2,0)→(3,0)→(4,0)→(4,1)→(4,2)→(4,3)→(4,4)
    //   G: (1,1)→(1,2)→(2,2)→(2,1)→(3,1)→(3,2)
    //   Y: (2,3)→(2,4)→(3,4)→(3,3)
    LevelConfig(
      id: 2, gridSize: 5, difficulty: 'Easy', difficultyIndex: 0,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(1, 3), 0),
        ColorPair(GridPos(1, 0), GridPos(4, 4), 1),
        ColorPair(GridPos(1, 1), GridPos(3, 2), 2),
        ColorPair(GridPos(2, 3), GridPos(3, 3), 3),
      ],
    ),

    // ── E3 : 4 colours ──
    // Solution paths:
    //   R: (0,0)→(1,0)→(2,0)→(3,0)→(4,0)→(4,1)
    //   B: (0,1)→(0,2)→(0,3)→(0,4)→(1,4)→(1,3)→(1,2)→(1,1)
    //   G: (2,1)→(2,2)→(2,3)→(2,4)→(3,4)→(3,3)→(3,2)→(3,1)
    //   Y: (4,2)→(4,3)→(4,4)
    LevelConfig(
      id: 3, gridSize: 5, difficulty: 'Easy', difficultyIndex: 0,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(4, 1), 0),
        ColorPair(GridPos(0, 1), GridPos(1, 1), 1),
        ColorPair(GridPos(2, 1), GridPos(3, 1), 2),
        ColorPair(GridPos(4, 2), GridPos(4, 4), 3),
      ],
    ),

    // ── E4 : 5 colours (rows – trivially fillable) ──
    LevelConfig(
      id: 4, gridSize: 5, difficulty: 'Easy', difficultyIndex: 0,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(0, 4), 0),
        ColorPair(GridPos(1, 0), GridPos(1, 4), 1),
        ColorPair(GridPos(2, 0), GridPos(2, 4), 2),
        ColorPair(GridPos(3, 0), GridPos(3, 4), 3),
        ColorPair(GridPos(4, 0), GridPos(4, 4), 4),
      ],
    ),

    // ── E5 : 5 colours ──
    // Solution paths:
    //   R: (0,0)→(0,1)→(1,1)→(1,0)
    //   B: (0,2)→(0,3)→(0,4)→(1,4)→(1,3)→(1,2)
    //   G: (2,0)→(2,1)→(2,2)→(3,2)→(3,1)→(3,0)→(4,0)
    //   Y: (2,3)→(2,4)→(3,4)→(3,3)→(4,3)→(4,4)
    //   P: (4,1)→(4,2)
    LevelConfig(
      id: 5, gridSize: 5, difficulty: 'Easy', difficultyIndex: 0,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(1, 0), 0),
        ColorPair(GridPos(0, 2), GridPos(1, 2), 1),
        ColorPair(GridPos(2, 0), GridPos(4, 0), 2),
        ColorPair(GridPos(2, 3), GridPos(4, 4), 3),
        ColorPair(GridPos(4, 1), GridPos(4, 2), 4),
      ],
    ),

    // ── E6 : 5 colours ──
    // Solution paths:
    //   R: (0,0)→(0,1)→(0,2)→(1,2)→(1,1)→(1,0)→(2,0)
    //   B: (0,3)→(0,4)→(1,4)→(1,3)
    //   G: (2,1)→(2,2)→(2,3)→(2,4)→(3,4)→(3,3)→(3,2)→(3,1)→(3,0)
    //   Y: (4,0)→(4,1)→(4,2)
    //   P: (4,3)→(4,4)
    LevelConfig(
      id: 6, gridSize: 5, difficulty: 'Easy', difficultyIndex: 0,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(2, 0), 0),
        ColorPair(GridPos(0, 3), GridPos(1, 3), 1),
        ColorPair(GridPos(2, 1), GridPos(3, 0), 2),
        ColorPair(GridPos(4, 0), GridPos(4, 2), 3),
        ColorPair(GridPos(4, 3), GridPos(4, 4), 4),
      ],
    ),

    // ── E7 : 5 colours ──
    // Solution paths:
    //   R: (0,0)→(1,0)→(2,0)→(2,1)→(2,2)
    //   B: (0,1)→(0,2)→(0,3)→(0,4)
    //   G: (1,1)→(1,2)→(1,3)→(1,4)→(2,4)→(2,3)
    //   Y: (3,0)→(3,1)→(3,2)→(3,3)→(3,4)
    //   P: (4,0)→(4,1)→(4,2)→(4,3)→(4,4)
    LevelConfig(
      id: 7, gridSize: 5, difficulty: 'Easy', difficultyIndex: 0,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(2, 2), 0),
        ColorPair(GridPos(0, 1), GridPos(0, 4), 1),
        ColorPair(GridPos(1, 1), GridPos(2, 3), 2),
        ColorPair(GridPos(3, 0), GridPos(3, 4), 3),
        ColorPair(GridPos(4, 0), GridPos(4, 4), 4),
      ],
    ),

    // ── E8 : 4 colours ──
    // Solution paths:
    //   R: (0,0)→(0,1)→(0,2)→(0,3)→(0,4)
    //   B: (1,0)→(1,1)→(1,2)→(1,3)→(1,4)→(2,4)→(2,3)
    //   G: (2,0)→(2,1)→(2,2)→(3,2)→(3,1)→(3,0)→(4,0)→(4,1)→(4,2)
    //   Y: (3,3)→(3,4)→(4,4)→(4,3)
    LevelConfig(
      id: 8, gridSize: 5, difficulty: 'Easy', difficultyIndex: 0,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(0, 4), 0),
        ColorPair(GridPos(1, 0), GridPos(2, 3), 1),
        ColorPair(GridPos(2, 0), GridPos(4, 2), 2),
        ColorPair(GridPos(3, 3), GridPos(4, 3), 3),
      ],
    ),

    // ── E9 : 4 colours ──
    // Solution paths:
    //   R: (0,0)→(0,1)→(1,1)→(1,0)→(2,0)→(2,1)
    //   B: (0,2)→(0,3)→(0,4)→(1,4)→(1,3)→(1,2)→(2,2)→(2,3)→(2,4)
    //   G: (3,0)→(3,1)→(3,2)→(4,2)→(4,1)→(4,0)
    //   Y: (3,3)→(3,4)→(4,4)→(4,3)
    LevelConfig(
      id: 9, gridSize: 5, difficulty: 'Easy', difficultyIndex: 0,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(2, 1), 0),
        ColorPair(GridPos(0, 2), GridPos(2, 4), 1),
        ColorPair(GridPos(3, 0), GridPos(4, 0), 2),
        ColorPair(GridPos(3, 3), GridPos(4, 3), 3),
      ],
    ),

    // ── E10 : 5 colours ──
    // Solution paths:
    //   R: (0,0)→(0,1)→(0,2)
    //   B: (0,3)→(0,4)→(1,4)→(2,4)→(3,4)→(4,4)→(4,3)
    //   G: (1,0)→(1,1)→(1,2)→(1,3)
    //   Y: (2,0)→(2,1)→(2,2)→(2,3)→(3,3)→(3,2)→(3,1)→(3,0)
    //   P: (4,0)→(4,1)→(4,2)
    LevelConfig(
      id: 10, gridSize: 5, difficulty: 'Easy', difficultyIndex: 0,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(0, 2), 0),
        ColorPair(GridPos(0, 3), GridPos(4, 3), 1),
        ColorPair(GridPos(1, 0), GridPos(1, 3), 2),
        ColorPair(GridPos(2, 0), GridPos(3, 0), 3),
        ColorPair(GridPos(4, 0), GridPos(4, 2), 4),
      ],
    ),
  ];

  // ──────────────────────────────────────────────────────────────────
  // MEDIUM  –  6 × 6 grids
  // ──────────────────────────────────────────────────────────────────
  static const List<LevelConfig> mediumLevels = [
    // ── M1 : 5 colours ──
    // R row0, B row1→(2,1) snake, G (2,2)→(3,0) snake, Y row4, P row5 rev
    LevelConfig(
      id: 1, gridSize: 6, difficulty: 'Medium', difficultyIndex: 1,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(0, 5), 0),
        ColorPair(GridPos(1, 5), GridPos(2, 1), 1),
        ColorPair(GridPos(2, 2), GridPos(3, 0), 2),
        ColorPair(GridPos(4, 0), GridPos(4, 5), 3),
        ColorPair(GridPos(5, 5), GridPos(5, 0), 4),
      ],
    ),

    // ── M2 : 6 colours (2×3 blocks) ──
    LevelConfig(
      id: 2, gridSize: 6, difficulty: 'Medium', difficultyIndex: 1,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(1, 0), 0),
        ColorPair(GridPos(0, 3), GridPos(1, 3), 1),
        ColorPair(GridPos(2, 0), GridPos(3, 0), 2),
        ColorPair(GridPos(2, 3), GridPos(3, 3), 3),
        ColorPair(GridPos(4, 0), GridPos(5, 0), 4),
        ColorPair(GridPos(4, 3), GridPos(5, 3), 5),
      ],
    ),

    // ── M3 : 5 colours ──
    // R left col→(5,2), B (0,1)→(5,3) spiral, G row1 mid, Y (2,1)↔(3,1), P row4 mid
    LevelConfig(
      id: 3, gridSize: 6, difficulty: 'Medium', difficultyIndex: 1,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(5, 2), 0),
        ColorPair(GridPos(0, 1), GridPos(5, 3), 1),
        ColorPair(GridPos(1, 1), GridPos(1, 4), 2),
        ColorPair(GridPos(2, 1), GridPos(3, 1), 3),
        ColorPair(GridPos(4, 1), GridPos(4, 4), 4),
      ],
    ),

    // ── M4 : 6 colours (row-by-row) ──
    LevelConfig(
      id: 4, gridSize: 6, difficulty: 'Medium', difficultyIndex: 1,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(0, 5), 0),
        ColorPair(GridPos(1, 0), GridPos(1, 5), 1),
        ColorPair(GridPos(2, 0), GridPos(2, 5), 2),
        ColorPair(GridPos(3, 0), GridPos(3, 5), 3),
        ColorPair(GridPos(4, 0), GridPos(4, 5), 4),
        ColorPair(GridPos(5, 0), GridPos(5, 5), 5),
      ],
    ),

    // ── M5 : 6 colours ──
    LevelConfig(
      id: 5, gridSize: 6, difficulty: 'Medium', difficultyIndex: 1,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(1, 0), 0),
        ColorPair(GridPos(0, 2), GridPos(1, 2), 1),
        ColorPair(GridPos(0, 4), GridPos(3, 4), 2),
        ColorPair(GridPos(2, 0), GridPos(3, 0), 3),
        ColorPair(GridPos(4, 0), GridPos(5, 0), 4),
        ColorPair(GridPos(4, 3), GridPos(5, 3), 5),
      ],
    ),

    // ── M6 : 5 colours ──
    LevelConfig(
      id: 6, gridSize: 6, difficulty: 'Medium', difficultyIndex: 1,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(2, 5), 0),
        ColorPair(GridPos(1, 0), GridPos(2, 0), 1),
        ColorPair(GridPos(3, 0), GridPos(5, 1), 2),
        ColorPair(GridPos(3, 2), GridPos(5, 3), 3),
        ColorPair(GridPos(3, 4), GridPos(5, 5), 4),
      ],
    ),

    // ── M7 : 6 colours ──
    LevelConfig(
      id: 7, gridSize: 6, difficulty: 'Medium', difficultyIndex: 1,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(0, 2), 0),
        ColorPair(GridPos(0, 3), GridPos(0, 5), 1),
        ColorPair(GridPos(1, 0), GridPos(2, 0), 2),
        ColorPair(GridPos(1, 3), GridPos(2, 3), 3),
        ColorPair(GridPos(3, 0), GridPos(5, 2), 4),
        ColorPair(GridPos(3, 3), GridPos(5, 5), 5),
      ],
    ),

    // ── M8 : 5 colours ──
    LevelConfig(
      id: 8, gridSize: 6, difficulty: 'Medium', difficultyIndex: 1,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(5, 0), 0),
        ColorPair(GridPos(0, 1), GridPos(1, 1), 1),
        ColorPair(GridPos(2, 1), GridPos(3, 1), 2),
        ColorPair(GridPos(2, 3), GridPos(3, 3), 3),
        ColorPair(GridPos(4, 1), GridPos(5, 1), 4),
      ],
    ),

    // ── M9 : 6 colours ──
    LevelConfig(
      id: 9, gridSize: 6, difficulty: 'Medium', difficultyIndex: 1,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(1, 0), 0),
        ColorPair(GridPos(0, 4), GridPos(2, 5), 1),
        ColorPair(GridPos(2, 0), GridPos(3, 0), 2),
        ColorPair(GridPos(4, 0), GridPos(5, 0), 3),
        ColorPair(GridPos(4, 2), GridPos(5, 2), 4),
        ColorPair(GridPos(3, 4), GridPos(3, 5), 5),
      ],
    ),

    // ── M10 : 7 colours ──
    LevelConfig(
      id: 10, gridSize: 6, difficulty: 'Medium', difficultyIndex: 1,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(3, 0), 0),
        ColorPair(GridPos(0, 2), GridPos(3, 2), 1),
        ColorPair(GridPos(0, 4), GridPos(0, 5), 2),
        ColorPair(GridPos(1, 4), GridPos(3, 5), 3),
        ColorPair(GridPos(4, 0), GridPos(5, 0), 4),
        ColorPair(GridPos(4, 2), GridPos(5, 2), 5),
        ColorPair(GridPos(4, 4), GridPos(5, 4), 6),
      ],
    ),
  ];

  // ──────────────────────────────────────────────────────────────────
  // HARD  –  7 × 7 grids
  // ──────────────────────────────────────────────────────────────────
  static const List<LevelConfig> hardLevels = [
    // ── H1 : 6 colours ──
    // Row-snakes: R row0, B (1,6)→(2,1), G (2,2)→(3,0), Y row4, P row5 rev, O row6
    LevelConfig(
      id: 1, gridSize: 7, difficulty: 'Hard', difficultyIndex: 2,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(0, 6), 0),
        ColorPair(GridPos(1, 6), GridPos(2, 1), 1),
        ColorPair(GridPos(2, 2), GridPos(3, 0), 2),
        ColorPair(GridPos(4, 0), GridPos(4, 6), 3),
        ColorPair(GridPos(5, 6), GridPos(5, 0), 4),
        ColorPair(GridPos(6, 0), GridPos(6, 6), 5),
      ],
    ),

    // ── H2 : 7 colours (row-by-row) ──
    LevelConfig(
      id: 2, gridSize: 7, difficulty: 'Hard', difficultyIndex: 2,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(0, 6), 0),
        ColorPair(GridPos(1, 0), GridPos(1, 6), 1),
        ColorPair(GridPos(2, 0), GridPos(2, 6), 2),
        ColorPair(GridPos(3, 0), GridPos(3, 6), 3),
        ColorPair(GridPos(4, 0), GridPos(4, 6), 4),
        ColorPair(GridPos(5, 0), GridPos(5, 6), 5),
        ColorPair(GridPos(6, 0), GridPos(6, 6), 6),
      ],
    ),

    // ── H3 : 7 colours ──
    LevelConfig(
      id: 3, gridSize: 7, difficulty: 'Hard', difficultyIndex: 2,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(1, 0), 0),
        ColorPair(GridPos(0, 2), GridPos(1, 2), 1),
        ColorPair(GridPos(0, 5), GridPos(3, 5), 2),
        ColorPair(GridPos(2, 0), GridPos(3, 0), 3),
        ColorPair(GridPos(4, 0), GridPos(6, 2), 4),
        ColorPair(GridPos(4, 3), GridPos(5, 3), 5),
        ColorPair(GridPos(6, 3), GridPos(6, 6), 6),
      ],
    ),

    // ── H4 : 8 colours ──
    LevelConfig(
      id: 4, gridSize: 7, difficulty: 'Hard', difficultyIndex: 2,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(1, 0), 0),
        ColorPair(GridPos(0, 2), GridPos(1, 2), 1),
        ColorPair(GridPos(0, 4), GridPos(2, 6), 2),
        ColorPair(GridPos(2, 0), GridPos(3, 0), 3),
        ColorPair(GridPos(3, 4), GridPos(4, 4), 4),
        ColorPair(GridPos(4, 0), GridPos(5, 0), 5),
        ColorPair(GridPos(5, 4), GridPos(6, 4), 6),
        ColorPair(GridPos(6, 0), GridPos(6, 3), 7),
      ],
    ),

    // ── H5 : 7 colours (diagonal staircase) ──
    // R down col0, then B–P are staircase bands from top-right
    LevelConfig(
      id: 5, gridSize: 7, difficulty: 'Hard', difficultyIndex: 2,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(6, 0), 0),
        ColorPair(GridPos(0, 1), GridPos(1, 6), 1),
        ColorPair(GridPos(1, 1), GridPos(2, 6), 2),
        ColorPair(GridPos(2, 1), GridPos(3, 6), 3),
        ColorPair(GridPos(3, 1), GridPos(4, 6), 4),
        ColorPair(GridPos(4, 1), GridPos(5, 6), 5),
        ColorPair(GridPos(5, 1), GridPos(6, 6), 6),
      ],
    ),

    // ── H6 : 8 colours ──
    LevelConfig(
      id: 6, gridSize: 7, difficulty: 'Hard', difficultyIndex: 2,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(1, 0), 0),
        ColorPair(GridPos(0, 3), GridPos(1, 3), 1),
        ColorPair(GridPos(0, 5), GridPos(3, 5), 2),
        ColorPair(GridPos(2, 0), GridPos(3, 0), 3),
        ColorPair(GridPos(4, 0), GridPos(6, 1), 4),
        ColorPair(GridPos(4, 2), GridPos(6, 3), 5),
        ColorPair(GridPos(4, 4), GridPos(6, 5), 6),
        ColorPair(GridPos(4, 6), GridPos(6, 6), 7),
      ],
    ),

    // ── H7 : 6 colours (staircase bands) ──
    LevelConfig(
      id: 7, gridSize: 7, difficulty: 'Hard', difficultyIndex: 2,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(1, 6), 0),
        ColorPair(GridPos(1, 0), GridPos(2, 6), 1),
        ColorPair(GridPos(2, 0), GridPos(3, 6), 2),
        ColorPair(GridPos(3, 0), GridPos(4, 6), 3),
        ColorPair(GridPos(4, 0), GridPos(6, 1), 4),
        ColorPair(GridPos(5, 3), GridPos(6, 2), 5),
      ],
    ),

    // ── H8 : 8 colours ──
    LevelConfig(
      id: 8, gridSize: 7, difficulty: 'Hard', difficultyIndex: 2,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(1, 0), 0),
        ColorPair(GridPos(0, 2), GridPos(1, 2), 1),
        ColorPair(GridPos(0, 5), GridPos(1, 5), 2),
        ColorPair(GridPos(2, 0), GridPos(4, 2), 3),
        ColorPair(GridPos(2, 3), GridPos(3, 3), 4),
        ColorPair(GridPos(2, 5), GridPos(5, 5), 5),
        ColorPair(GridPos(4, 3), GridPos(6, 2), 6),
        ColorPair(GridPos(6, 3), GridPos(6, 6), 7),
      ],
    ),

    // ── H9 : 7 colours ──
    LevelConfig(
      id: 9, gridSize: 7, difficulty: 'Hard', difficultyIndex: 2,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(0, 6), 0),
        ColorPair(GridPos(1, 0), GridPos(3, 2), 1),
        ColorPair(GridPos(1, 3), GridPos(3, 3), 2),
        ColorPair(GridPos(3, 4), GridPos(4, 3), 3),
        ColorPair(GridPos(4, 0), GridPos(6, 0), 4),
        ColorPair(GridPos(5, 3), GridPos(6, 3), 5),
        ColorPair(GridPos(6, 1), GridPos(6, 2), 6),
      ],
    ),

    // ── H10 : 8 colours ──
    LevelConfig(
      id: 10, gridSize: 7, difficulty: 'Hard', difficultyIndex: 2,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(1, 0), 0),
        ColorPair(GridPos(0, 4), GridPos(1, 4), 1),
        ColorPair(GridPos(2, 0), GridPos(6, 1), 2),
        ColorPair(GridPos(2, 2), GridPos(3, 2), 3),
        ColorPair(GridPos(2, 5), GridPos(5, 5), 4),
        ColorPair(GridPos(4, 2), GridPos(5, 2), 5),
        ColorPair(GridPos(6, 2), GridPos(6, 3), 6),
        ColorPair(GridPos(6, 4), GridPos(6, 6), 7),
      ],
    ),
  ];

  // ──────────────────────────────────────────────────────────────────
  // EXPERT  –  8 × 8 grids (Creative & Difficult)
  // ──────────────────────────────────────────────────────────────────
  static const List<LevelConfig> expertLevels = [
    // ── EX1 : 9 colours ──
    LevelConfig(
      id: 1, gridSize: 8, difficulty: 'Expert', difficultyIndex: 3,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(7, 0), 0),
        ColorPair(GridPos(7, 1), GridPos(7, 7), 1),
        ColorPair(GridPos(0, 1), GridPos(0, 7), 2),
        ColorPair(GridPos(1, 7), GridPos(6, 6), 3),
        ColorPair(GridPos(1, 1), GridPos(6, 1), 4),
        ColorPair(GridPos(6, 2), GridPos(5, 5), 5),
        ColorPair(GridPos(4, 5), GridPos(5, 6), 6),
        ColorPair(GridPos(1, 2), GridPos(2, 2), 7),
        ColorPair(GridPos(2, 3), GridPos(4, 3), 8),
      ],
    ),

    // ── EX2 : 10 colours ──
    LevelConfig(
      id: 2, gridSize: 8, difficulty: 'Expert', difficultyIndex: 3,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(0, 1), 0),
        ColorPair(GridPos(0, 2), GridPos(2, 1), 1),
        ColorPair(GridPos(2, 0), GridPos(7, 0), 2),
        ColorPair(GridPos(7, 1), GridPos(7, 7), 3),
        ColorPair(GridPos(0, 3), GridPos(0, 7), 4),
        ColorPair(GridPos(1, 7), GridPos(6, 7), 5),
        ColorPair(GridPos(6, 6), GridPos(6, 2), 6),
        ColorPair(GridPos(5, 2), GridPos(6, 1), 7),
        ColorPair(GridPos(1, 3), GridPos(1, 4), 8),
        ColorPair(GridPos(2, 4), GridPos(3, 4), 9),
      ],
    ),

    // ── EX3 : 10 colours ──
    LevelConfig(
      id: 3, gridSize: 8, difficulty: 'Expert', difficultyIndex: 3,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(1, 1), 0),
        ColorPair(GridPos(0, 3), GridPos(0, 7), 1),
        ColorPair(GridPos(1, 7), GridPos(7, 7), 2),
        ColorPair(GridPos(7, 6), GridPos(7, 0), 3),
        ColorPair(GridPos(6, 0), GridPos(3, 0), 4),
        ColorPair(GridPos(1, 3), GridPos(1, 6), 5),
        ColorPair(GridPos(2, 6), GridPos(6, 6), 6),
        ColorPair(GridPos(6, 5), GridPos(3, 1), 7),
        ColorPair(GridPos(2, 3), GridPos(3, 2), 8),
        ColorPair(GridPos(3, 3), GridPos(4, 3), 9),
      ],
    ),

    // ── EX4 : 6 colours ──
    LevelConfig(
      id: 4, gridSize: 8, difficulty: 'Expert', difficultyIndex: 3,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(0, 7), 0),
        ColorPair(GridPos(1, 0), GridPos(1, 7), 1),
        ColorPair(GridPos(2, 0), GridPos(2, 7), 2),
        ColorPair(GridPos(3, 0), GridPos(7, 0), 3),
        ColorPair(GridPos(3, 1), GridPos(3, 4), 4),
        ColorPair(GridPos(3, 5), GridPos(7, 7), 5),
      ],
    ),

    // ── EX5 : 7 colours ──
    LevelConfig(
      id: 5, gridSize: 8, difficulty: 'Expert', difficultyIndex: 3,
      colorPairs: [
        ColorPair(GridPos(0, 0), GridPos(7, 0), 0),
        ColorPair(GridPos(0, 1), GridPos(7, 1), 1),
        ColorPair(GridPos(0, 2), GridPos(7, 2), 2),
        ColorPair(GridPos(0, 3), GridPos(0, 7), 3),
        ColorPair(GridPos(1, 3), GridPos(3, 7), 4),
        ColorPair(GridPos(4, 3), GridPos(6, 7), 5),
        ColorPair(GridPos(7, 3), GridPos(7, 7), 6),
      ],
    ),
  ];

  // ──────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────
  static List<LevelConfig> getLevels(int difficultyIndex) {
    switch (difficultyIndex) {
      case 0:
        return easyLevels;
      case 1:
        return mediumLevels;
      case 2:
        return hardLevels;
      case 3:
        return expertLevels;
      default:
        return easyLevels;
    }
  }

  static LevelConfig getLevel(int difficultyIndex, int levelIndex) =>
      getLevels(difficultyIndex)[levelIndex];

  static int getLevelCount(int difficultyIndex) =>
      getLevels(difficultyIndex).length;
}

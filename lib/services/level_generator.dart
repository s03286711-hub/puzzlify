import 'dart:math';
import '../models/grid_pos.dart';
import '../models/level_config.dart';

/// Generates mathematically guaranteed solvable levels for Flow using MCMC.
class LevelGenerator {
  static final _rng = Random();

  /// Generates a random, solvable level of the given grid size.
  static LevelConfig generate({
    required int gridSize,
    required int difficultyIndex,
    required String difficultyName,
  }) {
    // Determine target colors based on grid size
    int targetColors;
    if (gridSize <= 5) {
      targetColors = 4 + _rng.nextInt(3); // 4 to 6
    } else if (gridSize == 6) {
      targetColors = 5 + _rng.nextInt(3); // 5 to 7
    } else {
      targetColors = 6 + _rng.nextInt(4); // 6 to 9
    }

    int n = gridSize;
    int numNodes = n * n;

    List<bool> hEdges = List.filled(numNodes, false);
    List<bool> vEdges = List.filled(numNodes, false);

    // 1. Initial State: N horizontal paths
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n - 1; c++) {
        hEdges[r * n + c] = true;
      }
    }

    int currentPaths = n;

    // 2. Adjust to targetColors by merging paths (if needed)
    while (currentPaths > targetColors) {
      List<int> endpoints = _findEndpoints(n, hEdges, vEdges);
      endpoints.shuffle(_rng);
      bool merged = false;
      for (int ep in endpoints) {
        int r = ep ~/ n;
        int c = ep % n;
        List<int> neighbors = [];
        if (r > 0) neighbors.add(ep - n);
        if (r < n - 1) neighbors.add(ep + n);
        if (c > 0) neighbors.add(ep - 1);
        if (c < n - 1) neighbors.add(ep + 1);

        neighbors.shuffle(_rng);
        for (int nx in neighbors) {
          if (endpoints.contains(nx)) {
            // Do not create a loop by merging endpoints of the SAME path
            if (_areInSamePath(n, ep, nx, hEdges, vEdges)) continue;

            if (nx == ep + 1) {
              hEdges[ep] = true;
            } else if (nx == ep - 1) {
              hEdges[nx] = true;
            } else if (nx == ep + n) {
              vEdges[ep] = true;
            } else if (nx == ep - n) {
              vEdges[nx] = true;
            }
            currentPaths--;
            merged = true;
            break;
          }
        }
        if (merged) break;
      }
      if (!merged) {
        // Fallback: Retry generation
        return generate(
          gridSize: gridSize,
          difficultyIndex: difficultyIndex,
          difficultyName: difficultyName,
        );
      }
    }

    // 3. Adjust to targetColors by splitting paths (if needed)
    while (currentPaths < targetColors) {
      List<int> validEdges = [];
      List<int> degrees = _getDegrees(n, hEdges, vEdges);

      for (int i = 0; i < numNodes; i++) {
        if (hEdges[i]) {
          if (degrees[i] == 2 && degrees[i + 1] == 2) validEdges.add(i);
        }
        if (vEdges[i]) {
          if (degrees[i] == 2 && degrees[i + n] == 2) {
            validEdges.add(numNodes + i);
          }
        }
      }

      if (validEdges.isEmpty) {
        return generate(
          gridSize: gridSize,
          difficultyIndex: difficultyIndex,
          difficultyName: difficultyName,
        );
      }

      int edge = validEdges[_rng.nextInt(validEdges.length)];
      if (edge < numNodes) {
        hEdges[edge] = false;
      } else {
        vEdges[edge - numNodes] = false;
      }

      currentPaths++;
    }

    // 4. Shuffle / Perturb using MCMC
    int iterations = 10000;
    int successes = 0;
    while (successes < 2000 && iterations > 0) {
      iterations--;
      int r = _rng.nextInt(n - 1);
      int c = _rng.nextInt(n - 1);
      int tl = r * n + c;
      int tr = tl + 1;
      int bl = tl + n;

      bool hTop = hEdges[tl];
      bool hBot = hEdges[bl];
      bool vLeft = vEdges[tl];
      bool vRight = vEdges[tr];

      // Horizontal parallel -> Vertical parallel
      if (hTop && hBot && !vLeft && !vRight) {
        hEdges[tl] = false;
        hEdges[bl] = false;
        vEdges[tl] = true;
        vEdges[tr] = true;
        if (!_isValid(n, targetColors, hEdges, vEdges)) {
          hEdges[tl] = true;
          hEdges[bl] = true;
          vEdges[tl] = false;
          vEdges[tr] = false;
        } else {
          successes++;
        }
      }
      // Vertical parallel -> Horizontal parallel
      else if (!hTop && !hBot && vLeft && vRight) {
        hEdges[tl] = true;
        hEdges[bl] = true;
        vEdges[tl] = false;
        vEdges[tr] = false;
        if (!_isValid(n, targetColors, hEdges, vEdges)) {
          hEdges[tl] = false;
          hEdges[bl] = false;
          vEdges[tl] = true;
          vEdges[tr] = true;
        } else {
          successes++;
        }
      }
    }

    // 5. Extract paths and form LevelConfig
    List<List<int>> paths = _extractPaths(n, hEdges, vEdges);
    if (paths.length != targetColors) {
      return generate(
        gridSize: gridSize,
        difficultyIndex: difficultyIndex,
        difficultyName: difficultyName,
      );
    }

    List<ColorPair> pairs = [];
    List<int> colorIndices = List.generate(10, (i) => i)..shuffle(_rng);
    for (int i = 0; i < targetColors; i++) {
      int s = paths[i].first;
      int e = paths[i].last;
      pairs.add(
        ColorPair(
          GridPos(s ~/ n, s % n),
          GridPos(e ~/ n, e % n),
          colorIndices[i],
        ),
      );
    }

    return LevelConfig(
      id: 1000 + _rng.nextInt(900000), // Random IDs for generated levels > 1000
      gridSize: gridSize,
      colorPairs: pairs,
      difficulty: '$difficultyName (Random)',
      difficultyIndex: difficultyIndex,
    );
  }

  // ── Helper Methods ─────────────────────────────────────────────────────────

  static List<int> _findEndpoints(int n, List<bool> hEdges, List<bool> vEdges) {
    List<int> endpoints = [];
    List<int> degs = _getDegrees(n, hEdges, vEdges);
    for (int i = 0; i < n * n; i++) {
      if (degs[i] == 1) endpoints.add(i);
    }
    return endpoints;
  }

  static List<int> _getDegrees(int n, List<bool> hEdges, List<bool> vEdges) {
    List<int> degs = List.filled(n * n, 0);
    for (int i = 0; i < n * n; i++) {
      int r = i ~/ n;
      int c = i % n;
      if (c > 0 && hEdges[i - 1]) degs[i]++;
      if (c < n - 1 && hEdges[i]) degs[i]++;
      if (r > 0 && vEdges[i - n]) degs[i]++;
      if (r < n - 1 && vEdges[i]) degs[i]++;
    }
    return degs;
  }

  static bool _isValid(
    int n,
    int targetColors,
    List<bool> hEdges,
    List<bool> vEdges,
  ) {
    List<int> endpoints = _findEndpoints(n, hEdges, vEdges);
    if (endpoints.length != targetColors * 2) return false;

    // Ensure 100% of the grid is covered by these paths
    List<bool> visited = List.filled(n * n, false);
    int visitedCount = 0;

    for (int ep in endpoints) {
      if (visited[ep]) continue;

      int curr = ep;
      int prev = -1;

      while (true) {
        visited[curr] = true;
        visitedCount++;

        int r = curr ~/ n;
        int c = curr % n;

        int next = -1;
        if (c > 0 && hEdges[curr - 1] && curr - 1 != prev) {
          next = curr - 1;
        } else if (c < n - 1 && hEdges[curr] && curr + 1 != prev) {
          next = curr + 1;
        } else if (r > 0 && vEdges[curr - n] && curr - n != prev) {
          next = curr - n;
        } else if (r < n - 1 && vEdges[curr] && curr + n != prev) {
          next = curr + n;
        }

        if (next == -1) break;

        prev = curr;
        curr = next;
      }
    }
    return visitedCount == n * n;
  }

  static List<List<int>> _extractPaths(
    int n,
    List<bool> hEdges,
    List<bool> vEdges,
  ) {
    List<int> endpoints = _findEndpoints(n, hEdges, vEdges);
    List<bool> visited = List.filled(n * n, false);
    List<List<int>> paths = [];

    for (int ep in endpoints) {
      if (visited[ep]) continue;

      List<int> path = [];
      int curr = ep;
      int prev = -1;

      while (true) {
        visited[curr] = true;
        path.add(curr);

        int r = curr ~/ n;
        int c = curr % n;

        int next = -1;
        if (c > 0 && hEdges[curr - 1] && curr - 1 != prev) {
          next = curr - 1;
        } else if (c < n - 1 && hEdges[curr] && curr + 1 != prev) {
          next = curr + 1;
        } else if (r > 0 && vEdges[curr - n] && curr - n != prev) {
          next = curr - n;
        } else if (r < n - 1 && vEdges[curr] && curr + n != prev) {
          next = curr + n;
        }

        if (next == -1) break;

        prev = curr;
        curr = next;
      }
      paths.add(path);
    }
    return paths;
  }

  static bool _areInSamePath(
    int n,
    int a,
    int b,
    List<bool> hEdges,
    List<bool> vEdges,
  ) {
    List<bool> visited = List.filled(n * n, false);
    List<int> q = [a];
    visited[a] = true;
    while (q.isNotEmpty) {
      int curr = q.removeLast();
      if (curr == b) return true;
      int r = curr ~/ n;
      int c = curr % n;
      if (c > 0 && hEdges[curr - 1] && !visited[curr - 1]) {
        visited[curr - 1] = true;
        q.add(curr - 1);
      }
      if (c < n - 1 && hEdges[curr] && !visited[curr + 1]) {
        visited[curr + 1] = true;
        q.add(curr + 1);
      }
      if (r > 0 && vEdges[curr - n] && !visited[curr - n]) {
        visited[curr - n] = true;
        q.add(curr - n);
      }
      if (r < n - 1 && vEdges[curr] && !visited[curr + n]) {
        visited[curr + n] = true;
        q.add(curr + n);
      }
    }
    return false;
  }
}

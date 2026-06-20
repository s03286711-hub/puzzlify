import json

# Check Flow level solver
def solve_level(grid_size, color_pairs):
    def get_neighbors(r, c):
        for dr, dc in [(-1,0), (1,0), (0,-1), (0,1)]:
            nr, nc = r + dr, c + dc
            if 0 <= nr < grid_size and 0 <= nc < grid_size:
                yield nr, nc

    # Grid: -1 empty, 0..N colors
    grid = [[-1]*grid_size for _ in range(grid_size)]
    endpoints = {}
    for i, pair in enumerate(color_pairs):
        r1, c1 = pair[0]
        r2, c2 = pair[1]
        grid[r1][c1] = i
        grid[r2][c2] = i
        endpoints[i] = ((r1, c1), (r2, c2))

    num_colors = len(color_pairs)
    
    # Simple backtracking
    def solve(color_idx, curr_r, curr_c, visited):
        if color_idx == num_colors:
            # Check if all grid cells are filled? The game requires filling the whole grid for 3 stars, but maybe just connecting is enough? Wait, standard Flow requires full grid for "Perfect". Let's just look for any solution first.
            # Actually, standard flow requires full grid to win? In this game, checkWin checks if all colors are connected.
            # Then it checks fillPct for stars. But usually a level should have a perfect solution.
            return True

        end_r, end_c = endpoints[color_idx][1]
        
        # If we reached the end for this color
        if curr_r == end_r and curr_c == end_c:
            return solve(color_idx + 1, endpoints[color_idx + 1][0][0] if color_idx + 1 < num_colors else -1, endpoints[color_idx + 1][0][1] if color_idx + 1 < num_colors else -1, visited)

        # Try neighbors
        for nr, nc in get_neighbors(curr_r, curr_c):
            if (nr, nc) not in visited:
                if grid[nr][nc] == -1 or (nr == end_r and nc == end_c):
                    visited.add((nr, nc))
                    if solve(color_idx, nr, nc, visited):
                        return True
                    visited.remove((nr, nc))
        return False

    visited = set()
    visited.add(endpoints[0][0])
    # Fast check: just see if it's connected
    import time
    start = time.time()
    # It might be too slow. Let's write a more efficient solver or just output the levels for verification.
    
    print(f"Solving level with {num_colors} colors...")
    # This naive solver is extremely slow. We will use a different approach or just replace the levels with known good levels from Flow Free 8x8.

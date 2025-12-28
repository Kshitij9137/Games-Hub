import 'dart:math';

class GameLogic {
  int score = 0;
  List<List<int>> grid = [];
  final Random _random = Random();

  // Initialize a 4x4 grid with two starting numbers
  void initGame() {
    score = 0;
    grid = List.generate(4, (_) => List.filled(4, 0));
    addNewTile();
    addNewTile();
  }

  // Add a 2 (90% chance) or 4 (10% chance) to a random empty spot
  void addNewTile() {
    List<Point<int>> emptySpots = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (grid[i][j] == 0) {
          emptySpots.add(Point(i, j));
        }
      }
    }
    if (emptySpots.isNotEmpty) {
      Point<int> spot = emptySpots[_random.nextInt(emptySpots.length)];
      grid[spot.x][spot.y] = _random.nextInt(10) == 0 ? 4 : 2;
    }
  }

  // --- Movement Logic ---

  // Helper: Operates on a single row to slide and merge
  List<int> _operate(List<int> row) {
    // 1. Slide non-zeros to the left
    row = row.where((e) => e != 0).toList();

    // 2. Merge adjacent equals
    for (int i = 0; i < row.length - 1; i++) {
      if (row[i] == row[i + 1]) {
        row[i] *= 2;
        score += row[i]; // Update Score
        row[i + 1] = 0;
      }
    }

    // 3. Slide again and fill remaining with 0
    row = row.where((e) => e != 0).toList();
    while (row.length < 4) {
      row.add(0);
    }
    return row;
  }

  // Move Left
  bool moveLeft() {
    bool changed = false;
    for (int i = 0; i < 4; i++) {
      List<int> newRow = _operate(grid[i]);
      if (grid[i].toString() != newRow.toString()) {
        grid[i] = newRow;
        changed = true;
      }
    }
    return changed;
  }

  // Move Right (Reverse row -> Move Left -> Reverse back)
  bool moveRight() {
    bool changed = false;
    for (int i = 0; i < 4; i++) {
      List<int> reversed = grid[i].reversed.toList();
      List<int> newRow = _operate(reversed);
      if (grid[i].toString() != newRow.reversed.toList().toString()) {
        grid[i] = newRow.reversed.toList();
        changed = true;
      }
    }
    return changed;
  }

  // Move Up (Transpose -> Move Left -> Transpose back)
  bool moveUp() {
    bool changed = false;
    grid = _transpose(grid);
    if (moveLeft()) changed = true;
    grid = _transpose(grid);
    return changed;
  }

  // Move Down (Transpose -> Move Right -> Transpose back)
  bool moveDown() {
    bool changed = false;
    grid = _transpose(grid);
    if (moveRight()) changed = true;
    grid = _transpose(grid);
    return changed;
  }

  // Helper to swap rows and columns
  List<List<int>> _transpose(List<List<int>> matrix) {
    List<List<int>> newGrid = List.generate(4, (_) => List.filled(4, 0));
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        newGrid[i][j] = matrix[j][i];
      }
    }
    return newGrid;
  }

  // Check for Game Over
  bool isGameOver() {
    // If there is an empty spot, game is not over
    for (var row in grid) {
      if (row.contains(0)) return false;
    }
    // Check horizontal merges
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 3; j++) {
        if (grid[i][j] == grid[i][j + 1]) return false;
      }
    }
    // Check vertical merges
    for (int j = 0; j < 4; j++) {
      for (int i = 0; i < 3; i++) {
        if (grid[i][j] == grid[i + 1][j]) return false;
      }
    }
    return true;
  }
}

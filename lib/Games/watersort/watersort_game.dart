import 'watersort_bottle.dart';
import 'watersort_levels.dart';

class WaterSortGame {
  List<WaterSortBottle> bottles = [];
  int? selectedBottleIndex;
  int moves = 0;
  int currentLevel = 1;
  bool isLevelComplete = false;

  // History stores complete bottle states before each move
  final List<List<WaterSortBottle>> _history = [];

  static const int totalLevels = 5;

  void startLevel(int level) {
    currentLevel = level;
    bottles = WaterSortLevels.getLevel(level);
    moves = 0;
    selectedBottleIndex = null;
    isLevelComplete = false;
    _history.clear();
  }

  void restartLevel() {
    startLevel(currentLevel);
  }

  bool get canUndo => _history.isNotEmpty && !isLevelComplete;

  // Undo last move by restoring previous state
  bool undo() {
    if (!canUndo) return false;

    final lastState = _history.removeLast();
    bottles = lastState.map((b) => b.copy()).toList();

    moves = moves > 0 ? moves - 1 : 0;
    selectedBottleIndex = null;
    isLevelComplete = false;

    return true;
  }

  // Save current state (deep copy of all bottles)
  void _saveSnapshot() {
    final snapshot = bottles.map((b) => b.copy()).toList();
    _history.add(snapshot);
  }

  void selectBottle(int index) {
    if (isLevelComplete) return;
    if (index < 0 || index >= bottles.length) return;

    final clicked = bottles[index];

    // No bottle selected yet
    if (selectedBottleIndex == null) {
      // Only select if bottle has liquid to pour
      if (clicked.canPour) {
        selectedBottleIndex = index;
      }
      return;
    }

    // Clicking same bottle - deselect
    if (selectedBottleIndex == index) {
      selectedBottleIndex = null;
      return;
    }

    // Try to pour from selected to clicked
    final fromIdx = selectedBottleIndex!;
    final toIdx = index;

    final fromBottle = bottles[fromIdx];
    final toBottle = bottles[toIdx];

    // Check if pour is valid
    if (!fromBottle.canPourTo(toBottle)) {
      selectedBottleIndex = null;
      return;
    }

    // Save state before making move
    _saveSnapshot();

    // Perform the pour
    final poured = fromBottle.pourTo(toBottle);

    if (poured > 0) {
      moves++;
      selectedBottleIndex = null;

      // Check if level is complete
      if (_checkLevelComplete()) {
        isLevelComplete = true;
      }
    } else {
      // Pour failed, remove the saved snapshot
      if (_history.isNotEmpty) {
        _history.removeLast();
      }
      selectedBottleIndex = null;
    }
  }

  // Level is complete when all bottles are either:
  // 1. Empty, OR
  // 2. Completely filled with one uniform color
  bool _checkLevelComplete() {
    for (final bottle in bottles) {
      // Empty bottles are OK
      if (bottle.isEmpty) continue;

      // Non-empty bottles must be completely full and uniform
      if (!bottle.isFull || !bottle.isUniform) {
        return false;
      }
    }
    return true;
  }

  int get bottleCount => bottles.length;

  // Get hint for next possible move
  List<int>? getHint() {
    for (int i = 0; i < bottles.length; i++) {
      if (!bottles[i].canPour) continue;

      for (int j = 0; j < bottles.length; j++) {
        if (i == j) continue;
        if (bottles[i].canPourTo(bottles[j])) {
          return [i, j]; // Return from index and to index
        }
      }
    }
    return null; // No valid moves
  }
}

import 'memory_card.dart';
import 'memory_levels.dart';

class MemoryMatchGame {
  List<MemoryCard> cards = [];
  int moves = 0;
  int matchedPairs = 0;
  int elapsedTime = 0;
  bool isLevelComplete = false;
  bool isGameOver = false;
  int currentLevel = 1;
  int stars = 0;
  // ignore: unused_field
  DateTime? _startTime;
  bool _timerRunning = false;

  List<int> flippedIndices = [];
  bool _isBusy = false;

  bool get isBusy => _isBusy;
  bool get hasTimeLimit =>
      MemoryLevels.getLevelConfig(currentLevel).timeLimit > 0;
  int get timeLeft {
    final config = MemoryLevels.getLevelConfig(currentLevel);
    return config.timeLimit - elapsedTime;
  }

  void startLevel(int level) {
    currentLevel = level;
    final config = MemoryLevels.getLevelConfig(level);
    final symbols = MemoryLevels.generateSymbols(config.theme, config.pairs);

    cards = [];
    for (int i = 0; i < symbols.length; i++) {
      cards.add(MemoryCard(symbol: symbols[i]));
    }

    // Shuffle cards
    cards.shuffle();

    moves = 0;
    matchedPairs = 0;
    elapsedTime = 0;
    isLevelComplete = false;
    isGameOver = false;
    stars = 0;
    flippedIndices.clear();
    _isBusy = false;
    _timerRunning = true;
    _startTime = DateTime.now();

    // Start timer
    _startTimer();
  }

  void restartGame() {
    startLevel(currentLevel);
  }

  void flipCard(int index) {
    if (_isBusy ||
        cards[index].isMatched ||
        cards[index].isFlipped ||
        isGameOver) {
      return;
    }

    cards[index].isFlipped = true;
    flippedIndices.add(index);

    if (flippedIndices.length == 2) {
      moves++;
      _checkForMatch();
    }
  }

  void _checkForMatch() {
    _isBusy = true;

    final firstIndex = flippedIndices[0];
    final secondIndex = flippedIndices[1];
    final firstCard = cards[firstIndex];
    final secondCard = cards[secondIndex];

    if (firstCard.symbol == secondCard.symbol) {
      // Match found
      firstCard.isMatched = true;
      secondCard.isMatched = true;
      matchedPairs++;

      flippedIndices.clear();
      _isBusy = false;

      // Check if level is complete
      final config = MemoryLevels.getLevelConfig(currentLevel);
      if (matchedPairs == config.pairs) {
        _completeLevel();
      }
    } else {
      // No match - flip back after delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        cards[firstIndex].isFlipped = false;
        cards[secondIndex].isFlipped = false;
        flippedIndices.clear();
        _isBusy = false;
      });
    }
  }

  void _completeLevel() {
    isLevelComplete = true;
    _timerRunning = false;
    stars = MemoryLevels.calculateStars(
      moves,
      elapsedTime,
      MemoryLevels.getLevelConfig(currentLevel),
    );
  }

  void _startTimer() {
    _timerRunning = true;
    // Simulate timer - in real implementation, use Timer.periodic
    Future.doWhile(() async {
      if (!_timerRunning) return false;

      await Future.delayed(const Duration(seconds: 1));

      if (_timerRunning) {
        elapsedTime++;

        // Check time limit
        final config = MemoryLevels.getLevelConfig(currentLevel);
        if (config.timeLimit > 0 && elapsedTime >= config.timeLimit) {
          isGameOver = true;
          _timerRunning = false;
        }
      }

      return _timerRunning;
    });
  }

  void dispose() {
    _timerRunning = false;
  }
}

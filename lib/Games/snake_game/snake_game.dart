import 'dart:math';
import 'snake_models.dart';

class SnakeGame {
  static const int gridWidth = 20;
  static const int gridHeight = 20;
  static const int initialLength = 3;

  List<Position> snake = [];
  Direction direction = Direction.right;
  Direction? nextDirection;
  Position? food;
  List<Obstacle> obstacles = [];
  PowerUp? activePowerUp;
  int powerUpDurationLeft = 0;

  int score = 0;
  int highScore = 0;
  bool isGameOver = false;
  bool isPaused = false;
  int level = 1;
  int baseSpeed = 300; // milliseconds per move
  int currentSpeed = 300;

  SnakeSkin currentSkin = SnakeSkin.getAllSkins()[0];

  final Random _random = Random();

  void startGame() {
    // Initialize snake in the middle
    snake = [
      Position(gridWidth ~/ 2, gridHeight ~/ 2),
      Position(gridWidth ~/ 2 - 1, gridHeight ~/ 2),
      Position(gridWidth ~/ 2 - 2, gridHeight ~/ 2),
    ];

    direction = Direction.right;
    nextDirection = null;
    score = 0;
    level = 1;
    isGameOver = false;
    isPaused = false;
    obstacles.clear();
    activePowerUp = null;
    powerUpDurationLeft = 0;
    currentSpeed = baseSpeed;

    _generateFood();
    _generateObstacles(3);
  }

  void restartGame() {
    startGame();
  }

  void togglePause() {
    if (!isGameOver) {
      isPaused = !isPaused;
    }
  }

  void changeDirection(Direction newDirection) {
    // Prevent reversing into itself
    if (_isOppositeDirection(newDirection, direction)) {
      return;
    }
    nextDirection = newDirection;
  }

  bool _isOppositeDirection(Direction dir1, Direction dir2) {
    return (dir1 == Direction.up && dir2 == Direction.down) ||
        (dir1 == Direction.down && dir2 == Direction.up) ||
        (dir1 == Direction.left && dir2 == Direction.right) ||
        (dir1 == Direction.right && dir2 == Direction.left);
  }

  void update() {
    if (isGameOver || isPaused) return;

    // Update direction
    if (nextDirection != null) {
      direction = nextDirection!;
      nextDirection = null;
    }

    // Move snake
    Position newHead = snake.first.move(direction);

    // Check collision with walls
    if (_isOutOfBounds(newHead)) {
      if (powerUpDurationLeft > 0 &&
          activePowerUp?.type == PowerUpType.invincible) {
        // Wrap around when invincible
        newHead = _wrapPosition(newHead);
      } else {
        _gameOver();
        return;
      }
    }

    // Check collision with self
    if (snake.contains(newHead)) {
      if (powerUpDurationLeft > 0 &&
          activePowerUp?.type == PowerUpType.invincible) {
        // Pass through self when invincible
      } else {
        _gameOver();
        return;
      }
    }

    // Check collision with obstacles
    if (_collidesWithObstacle(newHead)) {
      if (powerUpDurationLeft > 0 &&
          activePowerUp?.type == PowerUpType.invincible) {
        // Destroy obstacle when invincible
        obstacles.removeWhere((obs) => obs.position == newHead);
      } else {
        _gameOver();
        return;
      }
    }

    // Add new head
    snake.insert(0, newHead);

    // Check if food is eaten
    if (newHead == food) {
      _eatFood();
    } else {
      // Remove tail if no food eaten
      snake.removeLast();
    }

    // Update power-up duration
    if (powerUpDurationLeft > 0) {
      powerUpDurationLeft--;
      if (powerUpDurationLeft == 0) {
        _deactivatePowerUp();
      }
    }

    // Check for level up
    _checkLevelUp();
  }

  void _eatFood() {
    int scoreGain = 10;
    if (activePowerUp?.type == PowerUpType.scoreBoost) {
      scoreGain *= 2;
    }
    score += scoreGain;

    if (score > highScore) {
      highScore = score;
    }

    // 30% chance to spawn power-up
    if (_random.nextDouble() < 0.3) {
      _generatePowerUp();
    }

    _generateFood();
  }

  void _generateFood() {
    do {
      food = Position(_random.nextInt(gridWidth), _random.nextInt(gridHeight));
    } while (snake.contains(food) || _collidesWithObstacle(food!));
  }

  void _generateObstacles(int count) {
    obstacles.clear();
    for (int i = 0; i < count; i++) {
      Position pos;
      do {
        pos = Position(_random.nextInt(gridWidth), _random.nextInt(gridHeight));
      } while (snake.contains(pos) ||
          pos == food ||
          _collidesWithObstacle(pos));
      obstacles.add(Obstacle(pos));
    }
  }

  void _generatePowerUp() {
    Position pos;
    do {
      pos = Position(_random.nextInt(gridWidth), _random.nextInt(gridHeight));
    } while (snake.contains(pos) || pos == food || _collidesWithObstacle(pos));

    final types = PowerUpType.values;
    final type = types[_random.nextInt(types.length)];

    activePowerUp = PowerUp(position: pos, type: type);
    powerUpDurationLeft = 0; // Not active until collected
  }

  void _collectPowerUp() {
    if (activePowerUp == null) return;

    powerUpDurationLeft = activePowerUp!.duration;

    switch (activePowerUp!.type) {
      case PowerUpType.slow:
        currentSpeed = (baseSpeed * 1.5).toInt();
        break;
      case PowerUpType.fast:
        currentSpeed = (baseSpeed * 0.7).toInt();
        score += 20; // Bonus for risk
        break;
      case PowerUpType.invincible:
        // Speed remains same
        break;
      case PowerUpType.scoreBoost:
        // Will double score gains
        break;
    }
  }

  void _deactivatePowerUp() {
    activePowerUp = null;
    currentSpeed = baseSpeed;
  }

  bool _isOutOfBounds(Position pos) {
    return pos.x < 0 || pos.x >= gridWidth || pos.y < 0 || pos.y >= gridHeight;
  }

  Position _wrapPosition(Position pos) {
    return Position(
      (pos.x + gridWidth) % gridWidth,
      (pos.y + gridHeight) % gridHeight,
    );
  }

  bool _collidesWithObstacle(Position pos) {
    return obstacles.any((obs) => obs.position == pos);
  }

  void _checkLevelUp() {
    int newLevel = (score ~/ 100) + 1;
    if (newLevel > level) {
      level = newLevel;
      baseSpeed = max(100, 300 - (level - 1) * 20);
      currentSpeed = baseSpeed;
      _generateObstacles(min(3 + level, 10));
    }
  }

  void _gameOver() {
    isGameOver = true;
    if (score > highScore) {
      highScore = score;
    }
  }

  void changeSkin(SnakeSkin skin) {
    currentSkin = skin;
  }

  // Check if snake head is on power-up
  void checkPowerUpCollection() {
    if (activePowerUp != null &&
        powerUpDurationLeft == 0 &&
        snake.first == activePowerUp!.position) {
      _collectPowerUp();
    }
  }
}

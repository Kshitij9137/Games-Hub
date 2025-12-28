import 'dart:async';
//import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'snake_game.dart';
import 'snake_models.dart';

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen>
    with TickerProviderStateMixin {
  late SnakeGame _game;
  Timer? _gameTimer;
  bool _showSkinSelector = false;
  late AnimationController _pulseController;
  late AnimationController _foodController;

  @override
  void initState() {
    super.initState();
    _game = SnakeGame();
    _game.startGame();
    _startGameLoop();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _foodController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _pulseController.dispose();
    _foodController.dispose();
    super.dispose();
  }

  void _startGameLoop() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(Duration(milliseconds: _game.currentSpeed), (
      timer,
    ) {
      if (!_game.isPaused && !_game.isGameOver) {
        setState(() {
          _game.update();
          _game.checkPowerUpCollection();
        });

        if (_game.currentSpeed != timer.tick) {
          _startGameLoop();
        }
      }
    });
  }

  void _handleSwipe(DragEndDetails details) {
    if (_game.isGameOver) return;

    final velocity = details.velocity.pixelsPerSecond;
    if (velocity.dx.abs() > velocity.dy.abs()) {
      if (velocity.dx > 0) {
        _game.changeDirection(Direction.right);
      } else {
        _game.changeDirection(Direction.left);
      }
    } else {
      if (velocity.dy > 0) {
        _game.changeDirection(Direction.down);
      } else {
        _game.changeDirection(Direction.up);
      }
    }
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _game.changeDirection(Direction.up);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _game.changeDirection(Direction.down);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _game.changeDirection(Direction.left);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _game.changeDirection(Direction.right);
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        setState(() => _game.togglePause());
      }
    }
  }

  void _restartGame() {
    setState(() {
      _game.restartGame();
      _startGameLoop();
    });
  }

  void _togglePause() {
    setState(() {
      _game.togglePause();
    });
  }

  void _showSkinsDialog() {
    setState(() {
      _showSkinSelector = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKey: _handleKeyPress,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A1628), Color(0xFF162447), Color(0xFF1F4068)],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildAppBar(),
                    _buildStatsBar(),
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GestureDetector(
                              onPanEnd: _handleSwipe,
                              child: _buildGameBoard(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildControls(),
                    const SizedBox(height: 20),
                  ],
                ),
                if (_game.isGameOver) _buildGameOverOverlay(),
                if (_game.isPaused && !_game.isGameOver) _buildPauseOverlay(),
                if (_showSkinSelector) _buildSkinSelector(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xCC1B2B44), Color(0xCC162447)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A00D4FF),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF00D4FF)),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Snake Game',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF00D4FF),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _game.isPaused ? Icons.play_arrow : Icons.pause,
              color: const Color(0xFF00D4FF),
            ),
            onPressed: _togglePause,
          ),
          IconButton(
            icon: const Icon(Icons.palette, color: Color(0xFF00D4FF)),
            onPressed: _showSkinsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00D4FF)),
            onPressed: _restartGame,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2A5298)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x4D00D4FF), width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x3300D4FF), blurRadius: 15, spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('SCORE', '${_game.score}', const Color(0xFF00FF88)),
          _buildStatItem('BEST', '${_game.highScore}', const Color(0xFFFFD700)),
          _buildStatItem('LEVEL', '${_game.level}', const Color(0xFF00D4FF)),
          if (_game.powerUpDurationLeft > 0) _buildPowerUpIndicator(),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB0E0FF),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Color(0x33000000 | (color.value & 0x00FFFFFF)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Color(0x80000000 | (color.value & 0x00FFFFFF)),
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPowerUpIndicator() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(
                  0x4D000000 | (_game.activePowerUp!.color.value & 0x00FFFFFF),
                ),
                Color(
                  0x1A000000 | (_game.activePowerUp!.color.value & 0x00FFFFFF),
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _game.activePowerUp!.color, width: 2),
            boxShadow: [
              BoxShadow(
                color: _game.activePowerUp!.color,
                blurRadius: 10 + (_pulseController.value * 5),
                spreadRadius: _pulseController.value * 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                _game.activePowerUp!.icon,
                color: _game.activePowerUp!.color,
                size: 24,
              ),
              const SizedBox(width: 6),
              Text(
                '${(_game.powerUpDurationLeft / 10).ceil()}s',
                style: TextStyle(
                  color: _game.activePowerUp!.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameBoard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x6600D4FF), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x4D00D4FF), blurRadius: 25, spreadRadius: 3),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: CustomPaint(
          painter: SnakePainter(
            snake: _game.snake,
            food: _game.food,
            obstacles: _game.obstacles,
            powerUp: _game.activePowerUp,
            isPowerUpActive: _game.powerUpDurationLeft > 0,
            skin: _game.currentSkin,
            gridWidth: SnakeGame.gridWidth,
            gridHeight: SnakeGame.gridHeight,
            foodAnimation: _foodController.value,
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildControlButton(
            Icons.keyboard_arrow_up,
            () => _game.changeDirection(Direction.up),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                Icons.keyboard_arrow_left,
                () => _game.changeDirection(Direction.left),
              ),
              const SizedBox(width: 80),
              _buildControlButton(
                Icons.keyboard_arrow_right,
                () => _game.changeDirection(Direction.right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            Icons.keyboard_arrow_down,
            () => _game.changeDirection(Direction.down),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2A5298)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x6600D4FF), width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x3300D4FF), blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 36),
        color: const Color(0xFF00D4FF),
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Container(
      color: const Color(0xD9000000),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E3A5F), Color(0xFF2A5298), Color(0xFF1B4965)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFF3366), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66FF3366),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cancel, color: Color(0xFFFF3366), size: 70),
              const SizedBox(height: 20),
              const Text(
                'Game Over!',
                style: TextStyle(
                  color: Color(0xFF00D4FF),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              _buildScoreLine(
                'SCORE',
                '${_game.score}',
                const Color(0xFF00FF88),
              ),
              const SizedBox(height: 12),
              _buildScoreLine(
                'BEST',
                '${_game.highScore}',
                const Color(0xFFFFD700),
              ),
              const SizedBox(height: 12),
              _buildScoreLine(
                'LEVEL',
                '${_game.level}',
                const Color(0xFF00D4FF),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.home, size: 24),
                    label: const Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D4FF),
                      foregroundColor: const Color(0xFF0D1B2A),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _restartGame,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text(
                      'Play Again',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF88),
                      foregroundColor: const Color(0xFF0D1B2A),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreLine(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB0E0FF),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Color(0x33000000 | (color.value & 0x00FFFFFF)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPauseOverlay() {
    return AbsorbPointer(
      absorbing: true,
      child: Container(
        color: const Color(0xCC000000),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A5F), Color(0xFF2A5298)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF00D4FF), width: 3),
              boxShadow: const [
                BoxShadow(color: Color(0x6600D4FF), blurRadius: 25),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.pause_circle_filled,
                  color: Color(0xFF00D4FF),
                  size: 80,
                ),
                const SizedBox(height: 24),
                const Text(
                  'PAUSED',
                  style: TextStyle(
                    color: Color(0xFF00D4FF),
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _togglePause,
                  icon: const Icon(Icons.play_arrow, size: 28),
                  label: const Text(
                    'Resume',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4FF),
                    foregroundColor: const Color(0xFF0D1B2A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkinSelector() {
    return AbsorbPointer(
      absorbing: false,
      child: Container(
        color: const Color(0xD9000000),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A5F), Color(0xFF2A5298)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFAA00FF), width: 3),
              boxShadow: const [
                BoxShadow(color: Color(0x4DAA00FF), blurRadius: 25),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎨 Select Skin',
                  style: TextStyle(
                    color: Color(0xFF00D4FF),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: SnakeSkin.getAllSkins().map((skin) {
                    bool isSelected = _game.currentSkin.name == skin.name;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _game.changeSkin(skin);
                          _showSkinSelector = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(
                                0x66000000 |
                                    (skin.headColor.value & 0x00FFFFFF),
                              ),
                              Color(
                                0x33000000 |
                                    (skin.bodyColor.value & 0x00FFFFFF),
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00FF88)
                                : skin.headColor,
                            width: isSelected ? 4 : 2,
                          ),
                          boxShadow: isSelected
                              ? const [
                                  BoxShadow(
                                    color: Color(0x8000FF88),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              skin.headIcon ?? Icons.circle,
                              color: skin.headColor,
                              size: 36,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              skin.name,
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF00FF88)
                                    : Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => setState(() => _showSkinSelector = false),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0x3300D4FF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Color(0xFF00D4FF),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for smooth, flexible snake
class SnakePainter extends CustomPainter {
  final List<Position> snake;
  final Position? food;
  final List<Obstacle> obstacles;
  final PowerUp? powerUp;
  final bool isPowerUpActive;
  final SnakeSkin skin;
  final int gridWidth;
  final int gridHeight;
  final double foodAnimation;

  SnakePainter({
    required this.snake,
    required this.food,
    required this.obstacles,
    required this.powerUp,
    required this.isPowerUpActive,
    required this.skin,
    required this.gridWidth,
    required this.gridHeight,
    required this.foodAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / gridWidth;
    final cellHeight = size.height / gridHeight;

    // Draw grid (subtle)
    _drawGrid(canvas, size, cellWidth, cellHeight);

    // Draw obstacles
    _drawObstacles(canvas, cellWidth, cellHeight);

    // Draw power-up
    if (powerUp != null && !isPowerUpActive) {
      _drawPowerUp(canvas, cellWidth, cellHeight);
    }

    // Draw food
    if (food != null) {
      _drawFood(canvas, cellWidth, cellHeight);
    }

    // Draw smooth snake
    _drawSmoothSnake(canvas, cellWidth, cellHeight);
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    double cellWidth,
    double cellHeight,
  ) {
    final paint = Paint()
      ..color = const Color(0x0D00D4FF)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= gridWidth; i++) {
      canvas.drawLine(
        Offset(i * cellWidth, 0),
        Offset(i * cellWidth, size.height),
        paint,
      );
    }

    for (int i = 0; i <= gridHeight; i++) {
      canvas.drawLine(
        Offset(0, i * cellHeight),
        Offset(size.width, i * cellHeight),
        paint,
      );
    }
  }

  void _drawSmoothSnake(Canvas canvas, double cellWidth, double cellHeight) {
    if (snake.isEmpty) return;

    final radius = cellWidth * 0.4;

    // Draw body segments with smooth connections
    for (int i = snake.length - 1; i >= 0; i--) {
      final pos = snake[i];
      final centerX = (pos.x + 0.5) * cellWidth;
      final centerY = (pos.y + 0.5) * cellHeight;

      final isHead = i == 0;
      final color = isHead ? skin.headColor : skin.bodyColor;

      // Calculate size based on position (tail is smaller)
      final sizeMultiplier = isHead ? 1.0 : 1.0 - (i / snake.length * 0.3);
      final currentRadius = radius * sizeMultiplier;

      // Body segment with glow
      final paint = Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, isHead ? 8 : 4);

      canvas.drawCircle(
        Offset(centerX, centerY),
        currentRadius + (isHead ? 2 : 1),
        paint,
      );

      // Main body
      final mainPaint = Paint()..color = color;
      canvas.drawCircle(Offset(centerX, centerY), currentRadius, mainPaint);

      // Highlight for 3D effect
      final highlightPaint = Paint()
        ..color = const Color(0x4DFFFFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(centerX - currentRadius * 0.3, centerY - currentRadius * 0.3),
        currentRadius * 0.3,
        highlightPaint,
      );

      // Connect segments
      if (i < snake.length - 1) {
        final nextPos = snake[i + 1];
        final nextCenterX = (nextPos.x + 0.5) * cellWidth;
        final nextCenterY = (nextPos.y + 0.5) * cellHeight;

        final connectionPaint = Paint()
          ..color = skin.bodyColor
          ..strokeWidth = currentRadius * 1.8
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          Offset(centerX, centerY),
          Offset(nextCenterX, nextCenterY),
          connectionPaint,
        );
      }

      // Draw eyes on head
      if (isHead && skin.headIcon == null) {
        _drawSnakeEyes(canvas, centerX, centerY, currentRadius);
      } else if (isHead && skin.headIcon != null) {
        // Draw icon
        final iconPainter = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(skin.headIcon!.codePoint),
            style: TextStyle(
              fontSize: currentRadius * 1.2,
              fontFamily: skin.headIcon!.fontFamily,
              color: Colors.white,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        iconPainter.layout();
        iconPainter.paint(
          canvas,
          Offset(
            centerX - iconPainter.width / 2,
            centerY - iconPainter.height / 2,
          ),
        );
      }
    }
  }

  void _drawSnakeEyes(
    Canvas canvas,
    double centerX,
    double centerY,
    double radius,
  ) {
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;

    final eyeSize = radius * 0.25;
    final eyeOffset = radius * 0.35;

    // Left eye
    canvas.drawCircle(
      Offset(centerX - eyeOffset, centerY - eyeOffset),
      eyeSize,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(centerX - eyeOffset, centerY - eyeOffset),
      eyeSize * 0.6,
      pupilPaint,
    );

    // Right eye
    canvas.drawCircle(
      Offset(centerX + eyeOffset, centerY - eyeOffset),
      eyeSize,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(centerX + eyeOffset, centerY - eyeOffset),
      eyeSize * 0.6,
      pupilPaint,
    );
  }

  void _drawFood(Canvas canvas, double cellWidth, double cellHeight) {
    if (food == null) return;

    final centerX = (food!.x + 0.5) * cellWidth;
    final centerY = (food!.y + 0.5) * cellHeight;
    final radius = cellWidth * 0.35;

    // Pulsing animation
    final animatedRadius = radius * (1.0 + foodAnimation * 0.2);

    // Outer glow
    final glowPaint = Paint()
      ..color = const Color(0x80FF3366)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(Offset(centerX, centerY), animatedRadius + 5, glowPaint);

    // Gradient food
    final gradient = RadialGradient(
      colors: [const Color(0xFFFF6B9D), const Color(0xFFFF3366)],
    );

    final rect = Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: animatedRadius,
    );

    final gradientPaint = Paint()..shader = gradient.createShader(rect);

    canvas.drawCircle(Offset(centerX, centerY), animatedRadius, gradientPaint);

    // Highlight
    final highlightPaint = Paint()
      ..color = const Color(0x66FFFFFF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(
      Offset(centerX - radius * 0.3, centerY - radius * 0.3),
      radius * 0.4,
      highlightPaint,
    );
  }

  void _drawObstacles(Canvas canvas, double cellWidth, double cellHeight) {
    for (final obstacle in obstacles) {
      final centerX = (obstacle.position.x + 0.5) * cellWidth;
      final centerY = (obstacle.position.y + 0.5) * cellHeight;
      final size = cellWidth * 0.7;

      // Outer glow
      final glowPaint = Paint()
        ..color = const Color(0x66415A77)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(centerX, centerY),
            width: size + 4,
            height: size + 4,
          ),
          const Radius.circular(8),
        ),
        glowPaint,
      );

      // Main obstacle
      final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF778DA9), const Color(0xFF415A77)],
      );

      final rect = Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: size,
        height: size,
      );

      final gradientPaint = Paint()..shader = gradient.createShader(rect);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        gradientPaint,
      );

      // Inner highlight
      final highlightPaint = Paint()
        ..color = const Color(0x33FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(centerX, centerY),
            width: size - 4,
            height: size - 4,
          ),
          const Radius.circular(4),
        ),
        highlightPaint,
      );
    }
  }

  void _drawPowerUp(Canvas canvas, double cellWidth, double cellHeight) {
    if (powerUp == null) return;

    final centerX = (powerUp!.position.x + 0.5) * cellWidth;
    final centerY = (powerUp!.position.y + 0.5) * cellHeight;
    final radius = cellWidth * 0.4;

    // Rotating glow effect
    final glowPaint = Paint()
      ..color = Color(0x99000000 | (powerUp!.color.value & 0x00FFFFFF))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(Offset(centerX, centerY), radius + 8, glowPaint);

    // Gradient power-up
    final gradient = RadialGradient(
      colors: [
        powerUp!.color,
        Color(0x80000000 | (powerUp!.color.value & 0x00FFFFFF)),
      ],
    );

    final rect = Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: radius,
    );

    final gradientPaint = Paint()..shader = gradient.createShader(rect);

    canvas.drawCircle(Offset(centerX, centerY), radius, gradientPaint);

    // Icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(powerUp!.icon.codePoint),
        style: TextStyle(
          fontSize: radius * 1.2,
          fontFamily: powerUp!.icon.fontFamily,
          color: Colors.white,
          shadows: [
            Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(centerX - iconPainter.width / 2, centerY - iconPainter.height / 2),
    );

    // Rotating ring
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset(centerX, centerY), radius + 3, ringPaint);
  }

  @override
  bool shouldRepaint(SnakePainter oldDelegate) {
    return oldDelegate.snake != snake ||
        oldDelegate.food != food ||
        oldDelegate.obstacles.length != obstacles.length ||
        oldDelegate.powerUp != powerUp ||
        oldDelegate.isPowerUpActive != isPowerUpActive ||
        oldDelegate.foodAnimation != foodAnimation;
  }
}

import 'package:flutter/material.dart';
import 'game_logic.dart';
import 'game_colors.dart';

class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen>
    with SingleTickerProviderStateMixin {
  final GameLogic _game = GameLogic();
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _game.initGame();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _handleMove(Function moveFn) {
    setState(() {
      if (moveFn()) {
        _game.addNewTile();
        if (_game.isGameOver()) {
          _showGameOverDialog();
        }
      }
    });
  }

  void _resetGame() {
    setState(() {
      _game.initGame();
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "🎮 Game Over",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Text(
                    "Final Score",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${_game.score}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              "Close",
              style: TextStyle(color: Color(0xFF546E7A)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64B5F6),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Play Again",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double gridSize = MediaQuery.of(context).size.width - 40;
    double tileSize = (gridSize - 60) / 4;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2332),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF64B5F6)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "2048",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF64B5F6)),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Score Display
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A2332), Color(0xFF0D47A1)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0x4D64B5F6), // Alpha 0x4D = 30% opacity
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x3364B5F6), // Alpha 0x33 = 20% opacity
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Text(
                      "SCORE",
                      style: TextStyle(
                        color: Color(0xFF64B5F6),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${_game.score}",
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 3D Game Board
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              // For opacity animation, compute color with alpha manually
              int alpha = (_glowController.value * 77)
                  .toInt(); // 0.3 * 255 = 77 approx
              Color glowColor = Color.fromARGB(
                alpha,
                100,
                181,
                246,
              ); // RGB from 0x64B5F6

              return Center(
                child: Container(
                  width: gridSize,
                  height: gridSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: glowColor,
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: Colors.black.withAlpha(
                          128,
                        ), // 0.5 opacity ~ 128 alpha
                        blurRadius: 30,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1a237e),
                            Color(0xFF0d47a1),
                            Color(0xFF01579b),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Grid lines
                          CustomPaint(
                            painter: Grid2048Painter(),
                            size: Size.infinite,
                          ),
                          // Game content
                          GestureDetector(
                            onVerticalDragEnd: (details) {
                              if (details.primaryVelocity! < 0)
                                _handleMove(_game.moveUp);
                              if (details.primaryVelocity! > 0)
                                _handleMove(_game.moveDown);
                            },
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity! < 0)
                                _handleMove(_game.moveLeft);
                              if (details.primaryVelocity! > 0)
                                _handleMove(_game.moveRight);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(4, (i) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(4, (j) {
                                      return EnhancedTileWidget(
                                        value: _game.grid[i][j],
                                        size: tileSize,
                                      );
                                    }),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          // Instructions
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2332),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0x3364B5F6), // 20% opacity for border
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.swipe, color: Color(0xFF64B5F6), size: 20),
                SizedBox(width: 10),
                Text(
                  "Swipe to move tiles and reach 2048!",
                  style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Custom painter for grid lines
class Grid2048Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0x2644B5F6) // 0x26 = approx 15% opacity
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final cellWidth = size.width / 4;
    final cellHeight = size.height / 4;

    // Draw vertical lines
    for (int i = 0; i <= 4; i++) {
      canvas.drawLine(
        Offset(i * cellWidth, 0),
        Offset(i * cellWidth, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (int i = 0; i <= 4; i++) {
      canvas.drawLine(
        Offset(0, i * cellHeight),
        Offset(size.width, i * cellHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Enhanced Tile Widget with 3D effects
class EnhancedTileWidget extends StatelessWidget {
  final int value;
  final double size;

  const EnhancedTileWidget({
    super.key,
    required this.value,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: value == 0
            ? const LinearGradient(
                colors: [
                  Color(0x331976D2), // 0x33 ~ 20% opacity
                  Color(0x4D0D47A1), // 0x4D ~ 30% opacity
                ],
              )
            : _getTileGradient(value),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0x4D1565C0), // 30% opacity
          width: 1,
        ),
        boxShadow: value == 0
            ? []
            : [
                BoxShadow(
                  color: _getGlowColor(
                    value,
                  ).withAlpha(153), // 0.6 * 255 ≈ 153 alpha
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withAlpha(77), // 0.3 opacity
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Center(
        child: value == 0
            ? const SizedBox()
            : Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(-0.1),
                alignment: Alignment.center,
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontSize: _getFontSize(value),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: _getGlowColor(value),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                      const Shadow(
                        color: Colors.black,
                        blurRadius: 5,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  LinearGradient _getTileGradient(int value) {
    Color baseColor = GameColors.getTileColor(value);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [baseColor, Color.lerp(baseColor, Colors.black, 0.2)!],
    );
  }

  Color _getGlowColor(int value) {
    if (value >= 2048) return const Color(0xFFFFD700); // Gold
    if (value >= 1024) return const Color(0xFFFFA500); // Orange
    if (value >= 512) return const Color(0xFFFF6B6B); // Red
    if (value >= 256) return const Color(0xFFFF8C42); // Orange-red
    if (value >= 128) return const Color(0xFFFFD93D); // Yellow
    if (value >= 64) return const Color(0xFFFF6B9D); // Pink
    if (value >= 32) return const Color(0xFFFF6B6B); // Light red
    if (value >= 16) return const Color(0xFFFF9B9B); // Lighter red
    if (value >= 8) return const Color(0xFFFFA07A); // Light orange
    if (value >= 4) return const Color(0xFFFFB347); // Peach
    return const Color(0xFF64B5F6); // Default blue
  }

  double _getFontSize(int value) {
    if (value >= 1024) return 24;
    if (value >= 128) return 28;
    if (value >= 16) return 32;
    return 36;
  }
}

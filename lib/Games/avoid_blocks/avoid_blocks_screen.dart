import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class AvoidBlocksScreen extends StatefulWidget {
  const AvoidBlocksScreen({super.key});

  @override
  State<AvoidBlocksScreen> createState() => _AvoidBlocksScreenState();
}

class _AvoidBlocksScreenState extends State<AvoidBlocksScreen> {
  double playerX = 0.0;
  final double playerWidth = 70;
  final double playerHeight = 70;

  List<Block> blocks = [];
  bool isGameOver = false;

  Timer? gameTimer;
  Timer? spawnTimer;

  double blockSpeed = 3.0;
  int startTime = DateTime.now().millisecondsSinceEpoch;
  int bestScore = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startGame();
      });
    }
  }

  void startGame() {
    if (!mounted) return;

    setState(() {
      isGameOver = false;
      blocks.clear();
      blockSpeed = 3.0;
      startTime = DateTime.now().millisecondsSinceEpoch;
      playerX = (MediaQuery.of(context).size.width - playerWidth) / 2;
    });

    gameTimer?.cancel();
    spawnTimer?.cancel();

    gameTimer = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => updateGame(),
    );
    spawnTimer = Timer.periodic(
      const Duration(milliseconds: 900),
      (_) => spawnBlock(),
    );
  }

  void spawnBlock() {
    if (!mounted) return;

    final random = Random();
    final sizes = [35.0, 45.0, 55.0, 65.0];
    final size = sizes[random.nextInt(sizes.length)];

    setState(() {
      blocks.add(
        Block(
          x: random.nextDouble() * (MediaQuery.of(context).size.width - size),
          y: -size,
          size: size,
          color: _getRandomBlueColor(),
        ),
      );
    });
  }

  Color _getRandomBlueColor() {
    final random = Random();
    final blues = [
      const Color(0xFF64B5F6),
      const Color(0xFF42A5F5),
      const Color(0xFF2196F3),
      const Color(0xFF1E88E5),
      const Color(0xFF1976D2),
      const Color(0xFF03A9F4),
      const Color(0xFF29B6F6),
      const Color(0xFF4FC3F7),
      const Color(0xFF4DD0E1),
      const Color(0xFF26C6DA),
    ];
    return blues[random.nextInt(blues.length)];
  }

  void updateGame() {
    if (!mounted || isGameOver) return;

    setState(() {
      for (var block in blocks) {
        block.y += blockSpeed;
      }

      blocks.removeWhere((b) => b.y > MediaQuery.of(context).size.height);

      if (checkCollision()) {
        triggerGameOver();
      }
    });
  }

  bool checkCollision() {
    double playerLeft = playerX;
    double playerRight = playerX + playerWidth;
    double playerTop = MediaQuery.of(context).size.height - playerHeight - 40;
    double playerBottom = playerTop + playerHeight;

    for (var b in blocks) {
      double blockLeft = b.x;
      double blockRight = b.x + b.size;
      double blockTop = b.y;
      double blockBottom = b.y + b.size;

      bool overlapX = playerLeft < blockRight && playerRight > blockLeft;
      bool overlapY = playerTop < blockBottom && playerBottom > blockTop;

      if (overlapX && overlapY) return true;
    }
    return false;
  }

  void triggerGameOver() {
    gameTimer?.cancel();
    spawnTimer?.cancel();

    int score = ((DateTime.now().millisecondsSinceEpoch - startTime) / 1000)
        .floor();

    if (score > bestScore) bestScore = score;

    setState(() {
      isGameOver = true;
    });

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _buildGameOverPopup(score),
      );
    }
  }

  Widget _buildGameOverPopup(int score) {
    return PopScope(
      canPop: false,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(28),
              width: 320,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade900,
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.games_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Game Over",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3730A3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "$score seconds",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Your Score",
                          style: TextStyle(
                            color: Color(0xFFE5E7EB),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (score == bestScore && score > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD97706)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "New Best Score!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF374151),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Go back to home
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.home, size: 20),
                            SizedBox(width: 6),
                            Text(
                              "Home",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          startGame();
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, size: 20),
                            SizedBox(width: 6),
                            Text(
                              "Play Again",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            playerX += details.delta.dx;
            playerX = playerX.clamp(
              0,
              MediaQuery.of(context).size.width - playerWidth,
            );
          });
        },
        child: Stack(
          children: [
            // Enhanced Background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1E3A8A),
                      Color(0xFF1E40AF),
                      Color(0xFF1D4ED8),
                    ],
                  ),
                ),
                child: Image.asset('assets/avoid_bg.jpg', fit: BoxFit.cover),
              ),
            ),

            // Background Particles
            ...List.generate(15, (index) {
              final random = Random(index);
              return Positioned(
                left: random.nextDouble() * MediaQuery.of(context).size.width,
                top: random.nextDouble() * MediaQuery.of(context).size.height,
                child: Container(
                  width: random.nextDouble() * 3 + 1,
                  height: random.nextDouble() * 3 + 1,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5E7EB),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),

            // Header
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF374151),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Avoid the Blocks",
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Score Box
            Positioned(
              top: MediaQuery.of(context).padding.top + 100,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E40AF),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.timer_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${((DateTime.now().millisecondsSinceEpoch - startTime) / 1000).floor()}s",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.leaderboard_rounded,
                              color: Color(0xFFF59E0B),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Best: $bestScore s",
                              style: const TextStyle(
                                color: Color(0xFFE5E7EB),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Blocks - Removed AnimatedContainer
            ...blocks.map(
              (b) => Positioned(
                left: b.x,
                top: b.y,
                child: Container(
                  width: b.size,
                  height: b.size,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        b.color,
                        Color.lerp(b.color, const Color(0xFF1E3A8A), 0.3)!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(b.size * 0.3),
                    boxShadow: [
                      BoxShadow(
                        color: b.color,
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ),

            // Player - Removed AnimatedContainer
            Positioned(
              bottom: 40,
              left: playerX,
              child: Container(
                width: playerWidth,
                height: playerHeight,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF2563EB),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: Color(0xFF60A5FA),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),

            // Control Buttons
            Positioned(
              bottom: 40,
              left: 20,
              child: _buildControlButton(Icons.arrow_back_ios_rounded, () {
                setState(() {
                  playerX -= 40;
                  playerX = playerX.clamp(
                    0,
                    MediaQuery.of(context).size.width - playerWidth,
                  );
                });
              }),
            ),

            Positioned(
              bottom: 40,
              right: 20,
              child: _buildControlButton(Icons.arrow_forward_ios_rounded, () {
                setState(() {
                  playerX += 40;
                  playerX = playerX.clamp(
                    0,
                    MediaQuery.of(context).size.width - playerWidth,
                  );
                });
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF374151),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}

class Block {
  double x;
  double y;
  double size;
  Color color;

  Block({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
  });
}

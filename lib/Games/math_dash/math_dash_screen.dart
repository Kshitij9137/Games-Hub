import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class MathDashScreen extends StatefulWidget {
  const MathDashScreen({super.key});

  @override
  State<MathDashScreen> createState() => _MathDashScreenState();
}

class _MathDashScreenState extends State<MathDashScreen>
    with TickerProviderStateMixin {
  // Game Settings
  static const int _initialLives = 3;
  static const int _baseDurationSeconds = 5;

  // State Variables
  int _score = 0;
  int _lives = _initialLives;
  bool _isPlaying = false;
  bool _isGameOver = false;

  // Equation Logic
  String _currentEquation = "";
  int _correctAnswer = 0;
  List<int> _answerOptions = [];

  // Animation
  late AnimationController _fallController;
  late Animation<double> _fallAnimation;
  double _screenHeight = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _fallController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _baseDurationSeconds),
    );

    _fallController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleMiss();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Calculate drop height based on screen size (approximate safe area)
    _screenHeight =
        MediaQuery.of(context).size.height - 250; // 250 keeps it above buttons
    _fallAnimation = Tween<double>(
      begin: -50,
      end: _screenHeight,
    ).animate(CurvedAnimation(parent: _fallController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _fallController.dispose();
    super.dispose();
  }

  // --- Game Logic ---

  void _startGame() {
    setState(() {
      _score = 0;
      _lives = _initialLives;
      _isGameOver = false;
      _isPlaying = true;
    });
    _nextRound();
  }

  void _nextRound() {
    _generateEquation();
    _fallController.duration = Duration(
      milliseconds: max(
        1500,
        5000 - (_score * 100),
      ), // Speed increases as score goes up
    );
    _fallController.reset();
    _fallController.forward();
  }

  void _generateEquation() {
    final Random random = Random();
    int a = random.nextInt(10) + 1; // 1 to 10
    int b = random.nextInt(10) + 1;
    bool isAddition = random.nextBool();

    setState(() {
      if (isAddition) {
        _currentEquation = "$a + $b = ?";
        _correctAnswer = a + b;
      } else {
        // Ensure positive result for subtraction
        if (a < b) {
          int temp = a;
          a = b;
          b = temp;
        }
        _currentEquation = "$a - $b = ?";
        _correctAnswer = a - b;
      }

      // Generate options
      Set<int> options = {_correctAnswer};
      while (options.length < 3) {
        int offset = random.nextInt(5) + 1;
        options.add(
          random.nextBool() ? _correctAnswer + offset : _correctAnswer - offset,
        );
      }
      _answerOptions = options.toList()..shuffle();
    });
  }

  void _checkAnswer(int selectedAnswer) {
    if (!_isPlaying) return;

    if (selectedAnswer == _correctAnswer) {
      // Correct!
      setState(() {
        _score++;
      });
      _nextRound();
    } else {
      // Wrong answer tapped
      _handleMiss();
    }
  }

  void _handleMiss() {
    _fallController.stop();
    setState(() {
      _lives--;
    });

    if (_lives <= 0) {
      _gameOver();
    } else {
      // Brief pause before next round so user sees they missed
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_isGameOver) _nextRound();
      });
    }
  }

  void _gameOver() {
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });
  }

  // --- UI Widgets ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D022F), // Deep Blue Background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Math Dash", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. Background Stars/Particles (Static for performance)
          Positioned(
            top: 50,
            left: 50,
            child: Icon(
              Icons.star,
              color: Colors.white.withOpacity(0.1),
              size: 20,
            ),
          ),
          Positioned(
            bottom: 200,
            right: 40,
            child: Icon(
              Icons.star,
              color: Colors.white.withOpacity(0.1),
              size: 30,
            ),
          ),

          // 2. Score and Lives Header
          Positioned(
            top: 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Score: $_score",
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: List.generate(
                    3,
                    (index) => Icon(
                      index < _lives ? Icons.favorite : Icons.favorite_border,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. The Falling Equation
          if (_isPlaying && !_isGameOver)
            AnimatedBuilder(
              animation: _fallController,
              builder: (context, child) {
                return Positioned(
                  top: _fallAnimation.value,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.cyanAccent.withOpacity(0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Text(
                        _currentEquation,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

          /// 4. Game Over Screen
          if (_isGameOver)
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A40),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "GAME OVER",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Final Score: $_score",
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B7280),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.home, size: 20),
                          label: const Text(
                            "Home",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _startGame,
                          icon: const Icon(Icons.refresh, size: 20),
                          label: const Text(
                            "Try Again",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // 5. Start Screen
          if (!_isPlaying && !_isGameOver)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calculate_outlined,
                    size: 80,
                    color: Colors.cyanAccent,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Math Dash",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Solve before it drops!",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B894),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _startGame,
                    child: const Text(
                      "START GAME",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 6. Answer Buttons (Bottom)
          if (_isPlaying)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _answerOptions.map((option) {
                  return _buildAnswerButton(option);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(int number) {
    return GestureDetector(
      onTap: () => _checkAnswer(number),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF3B2E7E),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white54, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "$number",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

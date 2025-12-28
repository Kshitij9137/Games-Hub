import 'package:flutter/material.dart';
import 'package:flutter_application_gameshub/Games/memory_match/memory_card.dart';
import 'memory_match_game.dart';
import 'memory_levels.dart';
import 'widgets/level_complete_dialog.dart';

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  late MemoryMatchGame _game;
  int _selectedLevel = 1;
  final PageController _levelPageController = PageController();

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _game.dispose();
    _levelPageController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _game = MemoryMatchGame();
      _game.startLevel(_selectedLevel);
    });
  }

  void _restartGame() {
    setState(() {
      _game.restartGame();
    });
  }

  void _selectLevel(int level) {
    setState(() {
      _selectedLevel = level;
      _game.startLevel(level);
    });
  }

  void _onCardTap(int index) {
    if (_game.isBusy ||
        _game.cards[index].isMatched ||
        _game.cards[index].isFlipped ||
        _game.isGameOver) {
      return;
    }

    setState(() {
      _game.flipCard(index);
    });

    if (_game.isLevelComplete) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _showLevelCompleteDialog();
      });
    }
  }

  void _showLevelCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LevelCompleteDialog(
        level: _game.currentLevel,
        moves: _game.moves,
        time: _game.elapsedTime,
        stars: _game.stars,
        onRestart: _restartGame,
        onNextLevel: _game.currentLevel < 10
            ? () {
                Navigator.of(context).pop();
                _selectLevel(_game.currentLevel + 1);
              }
            : null,
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return const Color(0xFF00B894);
      case 'Easy':
        return const Color(0xFF74B9FF);
      case 'Medium':
        return const Color(0xFFFDCB6E);
      case 'Hard':
        return const Color(0xFFE17055);
      case 'Expert':
        return const Color(0xFFE84393);
      case 'Master':
        return const Color(0xFF6C5CE7);
      default:
        return const Color(0xFF00B894);
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelConfig = MemoryLevels.getLevelConfig(_selectedLevel);

    return Scaffold(
      backgroundColor: const Color(0xFF0D022F),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Memory Match',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'Level $_selectedLevel - ${levelConfig.difficulty}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF3B2E7E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _restartGame,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Game stats
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF3B2E7E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF755CF9), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('MOVES', '${_game.moves}'),
                      _buildStatItem(
                        'PAIRS',
                        '${_game.matchedPairs}/${levelConfig.pairs}',
                      ),
                      _buildStatItem('TIME', '${_game.elapsedTime}s'),
                    ],
                  ),
                  if (_game.hasTimeLimit) ...[
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: _game.timeLeft / levelConfig.timeLimit,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _game.timeLeft > levelConfig.timeLimit * 0.3
                            ? const Color(0xFF00B894)
                            : const Color(0xFFFF6B6B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Time Left: ${_game.timeLeft}s',
                      style: TextStyle(
                        color: _game.timeLeft > levelConfig.timeLimit * 0.3
                            ? const Color(0xFF00B894)
                            : const Color(0xFFFF6B6B),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Level selector - COMPACT VERSION
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B2E7E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF755CF9), width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'Levels',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 55,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          const SizedBox(width: 4),
                          ...List.generate(10, (index) {
                            final level = index + 1;
                            final config = MemoryLevels.getLevelConfig(level);
                            return GestureDetector(
                              onTap: () => _selectLevel(level),
                              child: Container(
                                width: 50,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: _selectedLevel == level
                                      ? _getDifficultyColor(config.difficulty)
                                      : const Color(0xFF2A1E6B),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF755CF9),
                                    width: _selectedLevel == level ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$level',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: _selectedLevel == level
                                              ? 14
                                              : 12,
                                        ),
                                      ),
                                      Text(
                                        '${config.rows}x${config.cols}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Theme indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1E6B),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF755CF9), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getThemeIcon(levelConfig.theme),
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${levelConfig.theme.toUpperCase()} • ${levelConfig.difficulty}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Game grid - EXPANDED for proper sizing
            Expanded(
              child: Stack(
                children: [
                  // Cards grid
                  GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: levelConfig.cols,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _game.cards.length,
                    itemBuilder: (context, index) {
                      return MemoryCardWidget(
                        card: _game.cards[index],
                        onTap: () => _onCardTap(index),
                      );
                    },
                  ),

                  // Game over overlay
                  if (_game.isGameOver)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B2E7E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFF6B6B),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.timer_off,
                                color: Color(0xFFFF6B6B),
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Time\'s Up!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _restartGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00B894),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text(
                                  'Try Again',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getThemeIcon(String theme) {
    switch (theme) {
      case 'emoji':
        return Icons.emoji_emotions;
      case 'animals':
        return Icons.pets;
      case 'food':
        return Icons.restaurant;
      case 'sports':
        return Icons.sports_baseball;
      case 'travel':
        return Icons.flight;
      case 'music':
        return Icons.music_note;
      case 'weather':
        return Icons.wb_sunny;
      case 'holidays':
        return Icons.celebration;
      case 'ocean':
        return Icons.waves;
      case 'space':
        return Icons.rocket_launch;
      default:
        return Icons.emoji_emotions;
    }
  }
}

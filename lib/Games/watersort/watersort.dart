import 'package:flutter/material.dart';
import 'watersort_game.dart';
import 'watersort_bottle.dart';

class WaterSortScreen extends StatefulWidget {
  const WaterSortScreen({super.key});

  @override
  State<WaterSortScreen> createState() => _WaterSortScreenState();
}

class _WaterSortScreenState extends State<WaterSortScreen> {
  late WaterSortGame _game;
  List<int>? _hintIndices;
  bool _showingHint = false;

  @override
  void initState() {
    super.initState();
    _game = WaterSortGame();
    _game.startLevel(1);
  }

  void _restartLevel() {
    setState(() {
      _game.restartLevel();
      _hintIndices = null;
      _showingHint = false;
    });
  }

  void _nextLevel() {
    setState(() {
      if (_game.currentLevel < WaterSortGame.totalLevels) {
        _game.startLevel(_game.currentLevel + 1);
      } else {
        _game.startLevel(1);
      }
      _hintIndices = null;
      _showingHint = false;
    });
  }

  void _previousLevel() {
    setState(() {
      if (_game.currentLevel > 1) {
        _game.startLevel(_game.currentLevel - 1);
      }
      _hintIndices = null;
      _showingHint = false;
    });
  }

  void _undo() {
    setState(() {
      _game.undo();
      _hintIndices = null;
      _showingHint = false;
    });
  }

  void _showHint() {
    setState(() {
      _hintIndices = _game.getHint();
      _showingHint = true;
    });

    // Clear hint after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _hintIndices = null;
          _showingHint = false;
        });
      }
    });
  }

  void _onBottleTap(int index) {
    setState(() {
      _game.selectBottle(index);
      _hintIndices = null;
      _showingHint = false;
    });
  }

  bool _isHintBottle(int index) {
    if (_hintIndices == null) return false;
    return _hintIndices!.contains(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF021133),
        title: const Text(
          'Water Sort Puzzle',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline, color: Color(0xFFFFD700)),
            onPressed: _showHint,
            tooltip: 'Hint',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _restartLevel,
            tooltip: 'Restart',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              // Header with level info and controls
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF07122F).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF00B4FF).withOpacity(0.12),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoColumn('LEVEL', '${_game.currentLevel}'),
                    _infoColumn('MOVES', '${_game.moves}'),
                    ElevatedButton.icon(
                      onPressed: _game.canUndo ? _undo : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _game.canUndo
                            ? const Color(0xFF00D2FF).withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        elevation: 0,
                        side: BorderSide(
                          color: _game.canUndo
                              ? const Color(0xFF00D2FF)
                              : Colors.grey,
                          width: 1,
                        ),
                      ),
                      icon: Icon(
                        Icons.undo,
                        color: _game.canUndo
                            ? const Color(0xFF00D2FF)
                            : Colors.grey,
                      ),
                      label: Text(
                        'Undo',
                        style: TextStyle(
                          color: _game.canUndo
                              ? const Color(0xFF00D2FF)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Hint message
              if (_showingHint && _hintIndices != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lightbulb, color: Color(0xFFFFD700), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Glowing bottles show the next move!',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              if (_showingHint && _hintIndices != null)
                const SizedBox(height: 12),

              // Game board
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF04102A), Color(0xFF021133)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF00D2FF).withOpacity(0.08),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 14,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final bottles = _game.bottles;
                      final cols = (constraints.maxWidth / 120).floor().clamp(
                        2,
                        6,
                      );
                      final spacing = 12.0;
                      final bottleWidth =
                          (constraints.maxWidth - (cols - 1) * spacing) / cols;

                      return Stack(
                        children: [
                          // Background grid
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(painter: _MatrixGridPainter()),
                            ),
                          ),

                          // Bottles
                          SingleChildScrollView(
                            child: Center(
                              child: Wrap(
                                spacing: spacing,
                                runSpacing: 18,
                                alignment: WrapAlignment.center,
                                children: List.generate(bottles.length, (i) {
                                  final bottle = bottles[i];
                                  final isHint = _isHintBottle(i);

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        bottleWidth.clamp(80, 140) * 0.2,
                                      ),
                                      boxShadow: isHint
                                          ? [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFFFFD700,
                                                ).withOpacity(0.6),
                                                blurRadius: 20,
                                                spreadRadius: 2,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: WaterSortBottleWidget(
                                      bottle: bottle,
                                      width: bottleWidth.clamp(80, 140),
                                      isSelected:
                                          _game.selectedBottleIndex == i,
                                      onTap: () => _onBottleTap(i),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),

                          // Win overlay
                          if (_game.isLevelComplete) _buildWinOverlay(),
                        ],
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Bottom navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _game.currentLevel > 1 ? _previousLevel : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B6BFF),
                      disabledBackgroundColor: Colors.grey.shade800,
                    ),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Previous'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _restartLevel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                    ),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Restart'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _nextLevel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D2FF),
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: Text(
                      _game.currentLevel < WaterSortGame.totalLevels
                          ? 'Next'
                          : 'Restart',
                      style: const TextStyle(color: Colors.black),
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

  Widget _buildWinOverlay() {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.black.withOpacity(0.75),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF021133),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00D2FF), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D2FF).withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Color(0xFFFFD700),
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Level Complete!',
                    style: TextStyle(
                      color: Color(0xFF00D2FF),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Completed in ${_game.moves} moves',
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_game.currentLevel > 1)
                        ElevatedButton.icon(
                          onPressed: _previousLevel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B6BFF),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                        ),
                      if (_game.currentLevel > 1) const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _nextLevel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D2FF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        icon: Icon(
                          _game.currentLevel < WaterSortGame.totalLevels
                              ? Icons.arrow_forward
                              : Icons.replay,
                          color: Colors.black,
                        ),
                        label: Text(
                          _game.currentLevel < WaterSortGame.totalLevels
                              ? 'Next Level'
                              : 'Play Again',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF00D2FF),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _MatrixGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D2FF).withOpacity(0.03)
      ..strokeWidth = 1;

    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

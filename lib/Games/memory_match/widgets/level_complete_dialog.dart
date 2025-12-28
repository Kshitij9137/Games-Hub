import 'package:flutter/material.dart';
import '../memory_levels.dart';
import 'star_rating_widget.dart';

class LevelCompleteDialog extends StatelessWidget {
  final int level;
  final int moves;
  final int time;
  final int stars;
  final VoidCallback onRestart;
  final VoidCallback? onNextLevel;

  const LevelCompleteDialog({
    super.key,
    required this.level,
    required this.moves,
    required this.time,
    required this.stars,
    required this.onRestart,
    this.onNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    final config = MemoryLevels.getLevelConfig(level);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF3B2E7E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF755CF9), width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, color: Color(0xFF00B894), size: 60),
            const SizedBox(height: 16),
            Text(
              'Level $level Complete!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              config.difficulty,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Star rating
            StarRatingWidget(stars: stars),
            const SizedBox(height: 20),

            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1E6B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildStatRow('Moves', '$moves', config.maxMoves),
                  _buildStatRow('Time', '${time}s', config.maxTime),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home, size: 20),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5568),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  label: const Text('Home'),
                ),
                ElevatedButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.refresh, size: 20),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF755CF9),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  label: const Text('Play Again'),
                ),
                if (onNextLevel != null)
                  ElevatedButton.icon(
                    onPressed: onNextLevel,
                    icon: const Icon(Icons.arrow_forward, size: 20),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B894),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    label: const Text('Next Level'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, int target) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: TextStyle(
              color: _getValueColor(value, target, label),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Target: $target${label == 'Time' ? 's' : ''}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getValueColor(String value, int target, String label) {
    final numericValue = int.tryParse(value.replaceAll('s', '')) ?? 0;
    if (label == 'Time') {
      return numericValue <= target
          ? const Color(0xFF00B894)
          : const Color(0xFFFF6B6B);
    } else {
      return numericValue <= target
          ? const Color(0xFF00B894)
          : const Color(0xFFFF6B6B);
    }
  }
}

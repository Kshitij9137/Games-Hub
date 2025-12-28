import 'package:flutter/material.dart';
import 'game_colors.dart';

class TileWidget extends StatelessWidget {
  final int value;
  final double size;

  const TileWidget({super.key, required this.value, required this.size});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: value == 0
            ? GameColors.emptyTile
            : GameColors.getTileColor(value),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: value == 0
            ? const SizedBox()
            : Text(
                '$value',
                style: TextStyle(
                  fontSize: value > 512
                      ? 24
                      : 32, // Smaller font for big numbers
                  fontWeight: FontWeight.bold,
                  color: GameColors.getTileTextColor(value),
                ),
              ),
      ),
    );
  }
}

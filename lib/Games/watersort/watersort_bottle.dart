import 'package:flutter/material.dart';

class WaterSortBottle {
  static const int capacity = 4;
  final List<Color?> liquids = List.filled(capacity, null);

  WaterSortBottle(List<Color?> initialLiquids) {
    for (int i = 0; i < capacity; i++) {
      liquids[i] = (i < initialLiquids.length) ? initialLiquids[i] : null;
    }
  }

  // Is completely empty
  bool get isEmpty => liquids.every((l) => l == null);

  // Is completely full (no nulls)
  bool get isFull => liquids.every((l) => l != null);

  // Count how many liquids are in the bottle
  int get liquidCount => liquids.where((l) => l != null).length;

  // Available space in bottle
  int get availableSpace => capacity - liquidCount;

  // Are non-null liquids contiguous from bottom and all the same color
  bool get isUniform {
    if (isEmpty) return true;

    Color? firstColor;
    bool foundFirst = false;

    // Find first non-null from bottom
    for (int i = 0; i < capacity; i++) {
      if (liquids[i] != null) {
        if (!foundFirst) {
          firstColor = liquids[i];
          foundFirst = true;
        } else if (liquids[i] != firstColor) {
          return false;
        }
      }
    }

    return true;
  }

  // Top color (highest non-null element)
  Color? get topColor {
    for (int i = capacity - 1; i >= 0; i--) {
      if (liquids[i] != null) return liquids[i];
    }
    return null;
  }

  // Number of contiguous same-color units at the top
  int get topLiquidAmount {
    final Color? color = topColor;
    if (color == null) return 0;

    int count = 0;
    for (int i = capacity - 1; i >= 0; i--) {
      if (liquids[i] == color) {
        count++;
      } else if (liquids[i] != null) {
        break; // Stop when we hit a different color
      }
    }
    return count;
  }

  bool get canPour => topColor != null;

  // Whether we can pour top block to other bottle
  bool canPourTo(WaterSortBottle other) {
    if (!canPour) return false;
    if (other.isFull) return false;
    if (identical(this, other)) return false;

    final ourColor = topColor;
    final theirTop = other.topColor;

    // Can pour into empty bottle
    if (theirTop == null) return true;

    // Can pour only if colors match
    return theirTop == ourColor;
  }

  // Perform pour from this bottle to other
  int pourTo(WaterSortBottle other) {
    if (!canPourTo(other)) return 0;

    final Color? color = topColor;
    if (color == null) return 0;

    // How many contiguous units of this color are at the top
    final int amount = topLiquidAmount;

    // How much space is available in the target bottle
    final int availSpace = other.availableSpace;
    if (availSpace <= 0) return 0;

    // Determine how many we can actually pour
    final int pourAmount = amount <= availSpace ? amount : availSpace;
    if (pourAmount <= 0) return 0;

    // Remove from this bottle (from top down)
    List<Color?> colorsToTransfer = [];
    int removed = 0;
    for (int i = capacity - 1; i >= 0 && removed < pourAmount; i--) {
      if (liquids[i] == color) {
        colorsToTransfer.add(liquids[i]);
        liquids[i] = null;
        removed++;
      }
    }

    // Add to other bottle (fill from bottom up to first null)
    int added = 0;
    for (int i = 0; i < capacity && added < colorsToTransfer.length; i++) {
      if (other.liquids[i] == null) {
        other.liquids[i] = colorsToTransfer[added];
        added++;
      }
    }

    return added;
  }

  // Create a deep copy of this bottle
  WaterSortBottle copy() {
    return WaterSortBottle(List<Color?>.from(liquids));
  }
}

class WaterSortBottleWidget extends StatelessWidget {
  final WaterSortBottle bottle;
  final double width;
  final bool isSelected;
  final VoidCallback? onTap;

  const WaterSortBottleWidget({
    super.key,
    required this.bottle,
    required this.width,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final height = width * 1.6;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: width,
        height: height,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF071A52), Color(0xFF00D2FF)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF07122F), Color(0xFF081538)],
                ),
          borderRadius: BorderRadius.circular(width * 0.18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00D2FF)
                : Colors.blueGrey.shade100.withOpacity(0.06),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF00D2FF).withOpacity(0.25)
                  : Colors.black.withOpacity(0.6),
              blurRadius: isSelected ? 18 : 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(width * 0.14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final innerHeight = constraints.maxHeight;
              final layerHeight = innerHeight / WaterSortBottle.capacity;

              return Column(
                children: List.generate(WaterSortBottle.capacity, (i) {
                  final idx = WaterSortBottle.capacity - 1 - i;
                  final color = bottle.liquids[idx];

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: layerHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: color ?? Colors.transparent,
                      border: Border(
                        top: BorderSide(
                          color: Colors.black.withOpacity(0.15),
                          width: 0.4,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}

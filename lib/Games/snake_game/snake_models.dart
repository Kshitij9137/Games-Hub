import 'package:flutter/material.dart';

enum Direction { up, down, left, right }

enum PowerUpType { slow, fast, invincible, scoreBoost }

class Position {
  final int x;
  final int y;

  Position(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  Position move(Direction direction) {
    switch (direction) {
      case Direction.up:
        return Position(x, y - 1);
      case Direction.down:
        return Position(x, y + 1);
      case Direction.left:
        return Position(x - 1, y);
      case Direction.right:
        return Position(x + 1, y);
    }
  }
}

class PowerUp {
  final Position position;
  final PowerUpType type;
  final int duration; // in game ticks
  final Color color;
  final IconData icon;

  PowerUp({required this.position, required this.type, this.duration = 100})
    : color = _getColorForType(type),
      icon = _getIconForType(type);

  static Color _getColorForType(PowerUpType type) {
    switch (type) {
      case PowerUpType.slow:
        return const Color(0xFF2196F3); // Blue
      case PowerUpType.fast:
        return const Color(0xFFFF9800); // Orange
      case PowerUpType.invincible:
        return const Color(0xFF9C27B0); // Purple
      case PowerUpType.scoreBoost:
        return const Color(0xFFFFEB3B); // Yellow
    }
  }

  static IconData _getIconForType(PowerUpType type) {
    switch (type) {
      case PowerUpType.slow:
        return Icons.slow_motion_video;
      case PowerUpType.fast:
        return Icons.flash_on;
      case PowerUpType.invincible:
        return Icons.shield;
      case PowerUpType.scoreBoost:
        return Icons.star;
    }
  }
}

class Obstacle {
  final Position position;

  Obstacle(this.position);
}

class SnakeSkin {
  final String name;
  final Color headColor;
  final Color bodyColor;
  final IconData? headIcon;
  final bool unlocked;

  SnakeSkin({
    required this.name,
    required this.headColor,
    required this.bodyColor,
    this.headIcon,
    this.unlocked = true,
  });

  static List<SnakeSkin> getAllSkins() {
    return [
      SnakeSkin(
        name: 'Classic',
        headColor: const Color(0xFF4CAF50),
        bodyColor: const Color(0xFF81C784),
        unlocked: true,
      ),
      SnakeSkin(
        name: 'Fire',
        headColor: const Color(0xFFFF5722),
        bodyColor: const Color(0xFFFF8A65),
        headIcon: Icons.whatshot,
        unlocked: true,
      ),
      SnakeSkin(
        name: 'Ice',
        headColor: const Color(0xFF2196F3),
        bodyColor: const Color(0xFF64B5F6),
        headIcon: Icons.ac_unit,
        unlocked: true,
      ),
      SnakeSkin(
        name: 'Gold',
        headColor: const Color(0xFFFFD700),
        bodyColor: const Color(0xFFFFE55C),
        headIcon: Icons.stars,
        unlocked: true,
      ),
      SnakeSkin(
        name: 'Toxic',
        headColor: const Color(0xFF9C27B0),
        bodyColor: const Color(0xFFBA68C8),
        headIcon: Icons.science,
        unlocked: true,
      ),
      SnakeSkin(
        name: 'Neon',
        headColor: const Color(0xFF00E5FF),
        bodyColor: const Color(0xFF00BCD4),
        headIcon: Icons.bolt,
        unlocked: true,
      ),
    ];
  }
}

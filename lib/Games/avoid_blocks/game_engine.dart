// lib/Games/avoid_blocks/game_engine.dart

import 'dart:math';
import 'block_model.dart';
import 'player_model.dart';

class GameEngine {
  final Random _rnd = Random();

  // Entities
  List<Block> blocks = [];
  Player player = Player();

  // relative speed: y units per second (relative coordinates)
  double fallSpeed = 0.25; // starts modest (0.25 of screen per second)

  // spawn rate: probability per second that a block will spawn
  double spawnRatePerSecond = 1.2; // average 1.2 blocks / sec

  bool isGameOver = false;

  // score (seconds survived)
  double score = 0.0;
  double highScore = 0.0;

  // sizes
  final double blockSize = 0.08; // relative width

  void reset() {
    blocks.clear();
    player = Player();
    fallSpeed = 0.25;
    spawnRatePerSecond = 1.2;
    isGameOver = false;
    score = 0.0;
  }

  /// Move player by deltaX in relative units (0..1)
  void movePlayerBy(double deltaX) {
    player.x += deltaX;
    if (player.x < player.width / 2) player.x = player.width / 2;
    if (player.x > 1 - player.width / 2) player.x = 1 - player.width / 2;
  }

  /// Spawns blocks based on probability. dt is seconds since last frame.
  void trySpawn(double dt) {
    // spawnChance = spawnRatePerSecond * dt
    double chance = spawnRatePerSecond * dt;
    if (_rnd.nextDouble() < chance) {
      double x = _rnd.nextDouble() * (1.0 - blockSize) + blockSize / 2;
      blocks.add(Block(x: x, y: -blockSize / 2, size: blockSize));
    }
  }

  /// Update all blocks, return true if collision occurred.
  bool update(double dt) {
    if (isGameOver) return true;

    // update score
    score += dt;

    // move blocks
    for (var b in blocks) {
      b.y += fallSpeed * dt;
    }

    // remove off-screen blocks
    blocks.removeWhere((b) => b.y - b.size / 2 > 1.2);

    // collision detection (AABB) — accurate and robust
    for (var b in blocks) {
      // block bounds
      double bLeft = b.x - b.size / 2;
      double bRight = b.x + b.size / 2;
      double bTop = b.y - b.size / 2;
      double bBottom = b.y + b.size / 2;

      // player bounds (player.width is fraction of screen width; for vertical we use player.height)
      double pLeft = player.x - player.width / 2;
      double pRight = player.x + player.width / 2;
      double pTop = player.y - player.height / 2;
      double pBottom = player.y + player.height / 2;

      bool overlapX = !(bRight < pLeft || bLeft > pRight);
      bool overlapY = !(bBottom < pTop || bTop > pBottom);

      if (overlapX && overlapY) {
        isGameOver = true;
        // update high score
        if (score > highScore) highScore = score;
        return true;
      }
    }

    return false;
  }

  /// Called by external timer every 10s to increase difficulty
  void increaseDifficulty() {
    fallSpeed += 0.08; // increase fall speed
    spawnRatePerSecond += 0.2; // spawn blocks a bit more frequently
  }
}

// lib/Games/avoid_blocks/block_model.dart

class Block {
  /// x,y are relative coords in range 0.0 .. 1.0
  double x;
  double y;

  /// relative size (fraction of screen width)
  final double size;

  Block({required this.x, required this.y, this.size = 0.08});
}

// lib/Games/avoid_blocks/player_model.dart

class Player {
  /// center x in 0.0 .. 1.0
  double x;

  /// relative width and height (fractions of screen width/height)
  final double width; // relative to screen width
  final double height; // relative to screen height

  /// fixed vertical position (center) as fraction of screen height
  final double y;

  Player({this.x = 0.5, this.width = 0.18, this.height = 0.10, this.y = 0.90});
}

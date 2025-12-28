import 'package:flutter/material.dart';

class StarRatingWidget extends StatelessWidget {
  final int stars;
  final double size;

  const StarRatingWidget({super.key, required this.stars, this.size = 32.0});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Icon(
          index < stars ? Icons.star : Icons.star_border,
          color: const Color(0xFFFFD700),
          size: size,
        );
      }),
    );
  }
}

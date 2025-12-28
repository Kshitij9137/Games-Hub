import 'package:flutter/material.dart';

class GameCard extends StatefulWidget {
  final String title;
  final String assetPath; // The path to the image in your assets folder
  final bool hasNewTag;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.title,
    required this.assetPath,
    this.hasNewTag = false,
    required this.onTap,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 105,
            decoration: BoxDecoration(
              color: const Color.fromARGB(190, 15, 15, 70),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFF755CF9), width: 3),
            ),
            child: Row(
              children: [
                // Icon section
                Container(
                  width: 110,
                  height: 110,
                  padding: const EdgeInsets.all(14.0),
                  child: Image.asset(
                    // Use Image.asset to display the image
                    widget.assetPath,
                    fit: BoxFit.contain,
                  ),
                ),
                // Title section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // NEW tag
          if (widget.hasNewTag)
            Positioned(
              top: -5,
              right: 10,
              child: Transform.rotate(
                angle: 0.2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(195, 120, 134, 212),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Pro',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

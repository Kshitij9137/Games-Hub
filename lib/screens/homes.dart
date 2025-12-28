import "package:flutter/material.dart";
import "package:flutter_application_gameshub/Games/TicTakToe/tictaktoe.dart";
import "package:flutter_application_gameshub/Games/chess/chess_mode_selection.dart";
import "package:flutter_application_gameshub/Games/game_2048/game_2048_screen.dart";
import "package:flutter_application_gameshub/Games/memory_match/memory_match.dart";
import "package:flutter_application_gameshub/Games/snake_game/snake_game_screen.dart";
import "package:flutter_application_gameshub/common/widgets/game_card.dart";
import 'package:flutter_application_gameshub/Games/watersort/watersort.dart';
import 'package:flutter_application_gameshub/Games/avoid_blocks/avoid_blocks_screen.dart';
import 'package:flutter_application_gameshub/Games/math_dash/math_dash_screen.dart';
import 'package:flutter_application_gameshub/screens/settings_screen.dart';
import 'package:flutter_application_gameshub/screens/pro_screen.dart';
import 'package:flutter_application_gameshub/common/popup_pro_block.dart';

// Global PRO variable
bool isProUser = false;

// Game model class
class Game {
  final String title;
  final String assetPath;
  final bool isFree;
  final bool hasNewTag;
  final VoidCallback onTap;

  Game({
    required this.title,
    required this.assetPath,
    required this.isFree,
    required this.hasNewTag,
    required this.onTap,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List of all games
  List<Game> get allGames => [
    // FREE GAMES
    Game(
      title: 'Tic Tac Toe',
      assetPath: 'assets/tictactoe.png',
      isFree: true,
      hasNewTag: false,
      onTap: () => _navigateToTicTacToe(context),
    ),
    Game(
      title: 'Memory Match',
      assetPath: 'assets/memory_match.png',
      isFree: true,
      hasNewTag: false,
      onTap: () => _navigateToMemoryMatch(context),
    ),
    Game(
      title: 'Math Dash',
      assetPath: 'assets/math_dash.png',
      isFree: true,
      hasNewTag: false,
      onTap: () => _navigateToMathDash(context),
    ),
    Game(
      title: 'Chess',
      assetPath: 'assets/chess.jpg',
      isFree: true,
      hasNewTag: false,
      onTap: () => _navigateToChessGame(context),
    ),
    // Make Avoid Blocks FREE
    Game(
      title: 'Avoid the Blocks',
      assetPath: 'assets/avoid_blocks.png',
      isFree: true, // Now free
      hasNewTag: false,
      onTap: () => _navigateToAvoidBlocks(context),
    ),

    // PRO GAMES
    Game(
      title: 'Snake Game',
      assetPath: 'assets/snakegame.png',
      isFree: false,
      hasNewTag: true,
      onTap: () => _navigateToSnakeGame(context),
    ),
    Game(
      title: '2048 Pro',
      assetPath: 'assets/2048_logo.png',
      isFree: false,
      hasNewTag: true,
      onTap: () => _navigateTo2048(context),
    ),
    Game(
      title: 'Water Sort',
      assetPath: 'assets/watersort.png',
      isFree: false,
      hasNewTag: true,
      onTap: () => _navigateTowatersort(context),
    ),
  ];

  // Get sorted games (free first, then pro)
  List<Game> get sortedGames {
    return List<Game>.from(allGames)..sort((a, b) {
      // Free games come first
      if (a.isFree && !b.isFree) return -1;
      if (!a.isFree && b.isFree) return 1;
      return 0;
    });
  }

  // Get free games
  List<Game> get freeGames => sortedGames.where((game) => game.isFree).toList();

  // Get pro games
  List<Game> get proGames => sortedGames.where((game) => !game.isFree).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // PRO Badge - Make it clickable
                  GestureDetector(
                    onTap: () async {
                      // Navigate to Pro Screen and wait for result
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProScreen()),
                      );

                      // If user purchased Pro, update the state
                      if (result == true) {
                        setState(() {
                          isProUser = true;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: isProUser
                            ? const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFF6C63FF), Color(0xFF3F3BAA)],
                              ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: isProUser
                                ? Colors.amber.withOpacity(0.4)
                                : Colors.deepPurple.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isProUser ? Icons.star : Icons.workspace_premium,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isProUser ? 'Pro Active' : 'Get Pro',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Settings
                  GestureDetector(
                    onTap: () => _navigateToSettings(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B2E7E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Games list with sections
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView(
                  children: [
                    const SizedBox(height: 10),

                    // FREE GAMES SECTION
                    if (freeGames.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Free Games',
                        const Color.fromARGB(255, 92, 6, 221),
                      ),
                      const SizedBox(height: 10),
                      ...freeGames.map(
                        (game) => Column(
                          children: [
                            _buildGameCard(game),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // PRO GAMES SECTION
                    if (proGames.isNotEmpty) ...[
                      _buildSectionHeader('Pro Games', Colors.purple),
                      const SizedBox(height: 10),
                      ...proGames.map(
                        (game) => Column(
                          children: [
                            _buildGameCard(game),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build section header
  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (title == 'Pro Games' && !isProUser)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'UPGRADE TO PLAY',
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  // Build game card with Pro lock overlay if needed
  Widget _buildGameCard(Game game) {
    return Stack(
      children: [
        GameCard(
          title: game.title,
          assetPath: game.assetPath,
          hasNewTag: game.hasNewTag,
          onTap: game.onTap,
        ),
        // Lock overlay for pro games if user is not pro
        if (!game.isFree && !isProUser)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                showProBlockedPopup(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.purple.withOpacity(0.8),
                        ),
                        child: const Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PRO',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  //                   NAVIGATION WITH PRO BLOCK
  // ============================================================

  void _navigateToTicTacToe(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TicTacToeScreen()),
    );
  }

  // PRO BLOCK FOR SNAKE
  void _navigateToSnakeGame(BuildContext context) {
    if (!isProUser) {
      showProBlockedPopup(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SnakeGameScreen()),
    );
  }

  // PRO BLOCK 2048
  void _navigateTo2048(BuildContext context) {
    if (!isProUser) {
      showProBlockedPopup(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Game2048Screen()),
    );
  }

  void _navigateToMemoryMatch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MemoryMatchScreen()),
    );
  }

  // PRO BLOCK WaterSort
  void _navigateTowatersort(BuildContext context) {
    if (!isProUser) {
      showProBlockedPopup(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WaterSortScreen()),
    );
  }

  // Avoid Blocks is now FREE
  void _navigateToAvoidBlocks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AvoidBlocksScreen()),
    );
  }

  void _navigateToMathDash(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MathDashScreen()),
    );
  }

  void _navigateToChessGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChessModeSelection()),
    );
  }

  // SETTINGS
  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }
}

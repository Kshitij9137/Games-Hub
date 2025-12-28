import 'package:flutter/material.dart';
import 'chess_board.dart';
import 'chess_ai.dart';
import 'dart:math' as math;

class ChessGame extends StatefulWidget {
  final GameMode mode;

  const ChessGame({Key? key, required this.mode}) : super(key: key);

  @override
  State<ChessGame> createState() => _ChessGameState();
}

class _ChessGameState extends State<ChessGame>
    with SingleTickerProviderStateMixin {
  late ChessBoard board;
  late ChessAI ai;
  Position? selectedPosition;
  List<Position> validMoves = [];
  bool isAIThinking = false;
  Position? lastMoveFrom;
  Position? lastMoveTo;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    board = ChessBoard();
    ai = ChessAI(board);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _resetGame() {
    setState(() {
      board = ChessBoard();
      ai = ChessAI(board);
      selectedPosition = null;
      validMoves = [];
      isAIThinking = false;
      lastMoveFrom = null;
      lastMoveTo = null;
    });
  }

  void _onSquareTap(int row, int col) {
    if (isAIThinking) return;

    final pos = Position(row, col);
    final piece = board.getPiece(pos);

    if (selectedPosition != null) {
      if (validMoves.any((m) => m.row == row && m.col == col)) {
        setState(() {
          lastMoveFrom = selectedPosition;
          lastMoveTo = pos;

          board.movePiece(selectedPosition!, pos);
          selectedPosition = null;
          validMoves = [];

          if (board.isCheckmate(board.currentTurn)) {
            _showGameOverDialog(
              board.currentTurn == PieceColor.white ? 'Black' : 'White',
            );
            return;
          }
          if (board.isStalemate(board.currentTurn)) {
            _showGameOverDialog('Draw');
            return;
          }

          if (widget.mode == GameMode.playerVsAI &&
              board.currentTurn == PieceColor.black) {
            _makeAIMove();
          }
        });
      } else if (piece != null && piece.color == board.currentTurn) {
        setState(() {
          selectedPosition = pos;
          validMoves = board.getValidMoves(pos);
        });
      } else {
        setState(() {
          selectedPosition = null;
          validMoves = [];
        });
      }
    } else {
      if (piece != null && piece.color == board.currentTurn) {
        setState(() {
          selectedPosition = pos;
          validMoves = board.getValidMoves(pos);
        });
      }
    }
  }

  Future<void> _makeAIMove() async {
    setState(() {
      isAIThinking = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    final move = ai.getBestMove();
    if (move != null) {
      setState(() {
        lastMoveFrom = move.from;
        lastMoveTo = move.to;

        board.movePiece(move.from, move.to);
        isAIThinking = false;

        if (board.isCheckmate(board.currentTurn)) {
          _showGameOverDialog('Black');
        } else if (board.isStalemate(board.currentTurn)) {
          _showGameOverDialog('Draw');
        }
      });
    } else {
      setState(() {
        isAIThinking = false;
      });
    }
  }

  void _showGameOverDialog(String winner) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          winner == 'Draw' ? '🤝 Game Over - Draw!' : '👑 $winner Wins!',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        content: Text(
          winner == 'Draw'
              ? 'The game ended in a stalemate.'
              : 'Checkmate! ${winner == "Black" ? "AI" : "You"} won the game!',
          style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 16),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
            },
            icon: const Icon(Icons.home, size: 18, color: Color(0xFF64B5F6)),
            label: const Text(
              'Home',
              style: TextStyle(color: Color(0xFF64B5F6)),
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 18, color: Color(0xFF546E7A)),
            label: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF546E7A)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            icon: const Icon(Icons.refresh, size: 18),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64B5F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            label: const Text('New Game'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2332),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF64B5F6)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.mode == GameMode.playerVsAI
              ? 'Player vs AI'
              : 'Player vs Player',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF64B5F6)),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildCapturedPiecesRow(PieceColor.white),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: AspectRatio(aspectRatio: 1, child: _build3DBoard()),
            ),
          ),
          const SizedBox(height: 16),
          _buildCapturedPiecesRow(PieceColor.black),
          const SizedBox(height: 16),
          _buildTurnIndicator(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _build3DBoard() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF64B5F6,
                ).withOpacity(0.3 * _glowController.value),
                blurRadius: 40,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1a237e),
                    const Color(0xFF0d47a1),
                    const Color(0xFF01579b),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Grid lines
                  CustomPaint(painter: GridPainter(), size: Size.infinite),
                  // Chess squares and pieces
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                        ),
                    itemCount: 64,
                    itemBuilder: (context, index) {
                      final row = index ~/ 8;
                      final col = index % 8;
                      return _buildSquare(row, col);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSquare(int row, int col) {
    final pos = Position(row, col);
    final piece = board.getPiece(pos);
    final isSelected =
        selectedPosition?.row == row && selectedPosition?.col == col;
    final isValidMove = validMoves.any((m) => m.row == row && m.col == col);
    final isLight = (row + col) % 2 == 0;
    final isLastMove =
        (lastMoveFrom?.row == row && lastMoveFrom?.col == col) ||
        (lastMoveTo?.row == row && lastMoveTo?.col == col);

    return GestureDetector(
      onTap: () => _onSquareTap(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF64B5F6).withOpacity(0.6)
              : isLastMove
              ? const Color(0xFF4CAF50).withOpacity(0.3)
              : isLight
              ? const Color(0xFF1976D2).withOpacity(0.3)
              : const Color(0xFF0D47A1).withOpacity(0.5),
          border: Border.all(
            color: const Color(0xFF1565C0).withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Stack(
          children: [
            // Valid move indicator
            if (isValidMove)
              Center(
                child: Container(
                  width: piece != null ? 45 : 20,
                  height: piece != null ? 45 : 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: piece != null
                        ? Border.all(color: const Color(0xFF64B5F6), width: 3)
                        : null,
                    color: piece == null
                        ? const Color(0xFF64B5F6).withOpacity(0.6)
                        : Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF64B5F6).withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),

            // Chess piece with 3D effect
            if (piece != null)
              Center(
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(-0.2),
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: piece.color == PieceColor.white
                              ? const Color(0xFF64B5F6).withOpacity(0.6)
                              : const Color(0xFF1A237E).withOpacity(0.8),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Text(
                      _getPieceSymbol(piece),
                      style: TextStyle(
                        fontSize: 42,
                        height: 1,
                        fontWeight: FontWeight.bold,
                        color: piece.color == PieceColor.white
                            ? const Color(0xFFE3F2FD)
                            : const Color(0xFF1A237E),
                        shadows: [
                          Shadow(
                            color: piece.color == PieceColor.white
                                ? const Color(0xFF64B5F6)
                                : Colors.black,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                          Shadow(
                            color: piece.color == PieceColor.white
                                ? Colors.white
                                : const Color(0xFF0D47A1),
                            blurRadius: 15,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Coordinates
            if (col == 0)
              Positioned(
                left: 3,
                top: 3,
                child: Text(
                  '${8 - row}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF64B5F6).withOpacity(0.5),
                  ),
                ),
              ),
            if (row == 7)
              Positioned(
                right: 3,
                bottom: 3,
                child: Text(
                  String.fromCharCode(97 + col),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF64B5F6).withOpacity(0.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapturedPiecesRow(PieceColor capturedColor) {
    final captured = board.capturedPieces
        .where((p) => p.color == capturedColor)
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2332), Color(0xFF0D1B2A)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF64B5F6).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            capturedColor == PieceColor.white ? '⚪' : '⚫',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: captured.isEmpty
                ? Text(
                    'No captures',
                    style: TextStyle(
                      color: const Color(0xFFB0BEC5).withOpacity(0.5),
                      fontSize: 13,
                    ),
                  )
                : Wrap(
                    spacing: 6,
                    children: captured
                        .map(
                          (p) => Text(
                            _getPieceSymbol(p),
                            style: TextStyle(
                              fontSize: 22,
                              color: p.color == PieceColor.white
                                  ? const Color(0xFF64B5F6)
                                  : const Color(0xFF1A237E),
                              shadows: [
                                Shadow(
                                  color: p.color == PieceColor.white
                                      ? const Color(0xFF64B5F6)
                                      : Colors.black,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A2332),
            const Color(0xFF0D47A1).withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF64B5F6).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64B5F6).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: board.currentTurn == PieceColor.white
                  ? const Color(0xFFE3F2FD)
                  : const Color(0xFF1A237E),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF64B5F6), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF64B5F6).withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isAIThinking
                ? '🤔 AI is thinking...'
                : '${board.currentTurn == PieceColor.white ? "⚪ White" : "⚫ Black"}\'s Turn',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getPieceSymbol(Piece piece) {
    const symbols = {
      PieceType.king: '♔',
      PieceType.queen: '♕',
      PieceType.rook: '♖',
      PieceType.bishop: '♗',
      PieceType.knight: '♘',
      PieceType.pawn: '♙',
    };
    return symbols[piece.type]!;
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF64B5F6).withOpacity(0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final cellWidth = size.width / 8;
    final cellHeight = size.height / 8;

    // Draw vertical lines
    for (int i = 0; i <= 8; i++) {
      canvas.drawLine(
        Offset(i * cellWidth, 0),
        Offset(i * cellWidth, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (int i = 0; i <= 8; i++) {
      canvas.drawLine(
        Offset(0, i * cellHeight),
        Offset(size.width, i * cellHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum GameMode { playerVsPlayer, playerVsAI }

import 'chess_board.dart';
import 'dart:math';

class ChessAI {
  final ChessBoard board;
  int depth = 4;
  final Random _random = Random();
  int moveCount = 0;
  Move? lastMove;
  Move? secondLastMove;

  ChessAI(this.board);

  Move? getBestMove() {
    moveCount++;
    final moves = board.getAllPossibleMoves(PieceColor.black);
    if (moves.isEmpty) return null;

    // Opening book for first move - prioritize center pawns
    if (moveCount == 1) {
      // Prefer e5 (e7-e5) or d5 (d7-d5)
      final centerPawnMoves = moves.where((m) {
        final piece = board.getPiece(m.from);
        if (piece?.type == PieceType.pawn) {
          // e7-e5 or d7-d5
          if ((m.from.col == 4 || m.from.col == 3) &&
              m.from.row == 1 &&
              m.to.row == 3) {
            return true;
          }
        }
        return false;
      }).toList();

      if (centerPawnMoves.isNotEmpty) {
        return centerPawnMoves[_random.nextInt(centerPawnMoves.length)];
      }
    }

    // Filter out moves that cause immediate repetition
    final filteredMoves = moves.where((move) {
      // Don't allow immediate move reversal (like rook going back and forth)
      if (lastMove != null &&
          move.from == lastMove!.to &&
          move.to == lastMove!.from) {
        return false; // This would reverse the last move
      }

      // Don't allow three-move repetition pattern
      if (secondLastMove != null &&
          move.from == secondLastMove!.from &&
          move.to == secondLastMove!.to) {
        return false; // This repeats a move from 2 turns ago
      }

      // Check for threefold repetition
      final testBoard = board.clone();
      testBoard.movePiece(move.from, move.to);
      if (testBoard.isThreefoldRepetition()) {
        return false;
      }

      return true;
    }).toList();

    final movesToEvaluate = filteredMoves.isNotEmpty ? filteredMoves : moves;
    final orderedMoves = _orderMoves(movesToEvaluate);

    Move? bestMove;
    double bestValue = double.negativeInfinity;

    // Evaluate each move
    for (final move in orderedMoves) {
      final testBoard = board.clone();
      testBoard.movePiece(move.from, move.to);

      double value = _minimax(
        testBoard,
        depth - 1,
        double.negativeInfinity,
        double.infinity,
        false,
      );

      // Opening phase penalties
      if (moveCount <= 10) {
        final piece = board.getPiece(move.from);

        // Strongly discourage early queen and rook moves
        if (piece?.type == PieceType.queen && move.from.row == 0) {
          value -= 5.0;
        }
        if (piece?.type == PieceType.rook && move.from.row == 0) {
          value -= 4.0;
        }

        // Encourage developing minor pieces
        if ((piece?.type == PieceType.knight ||
                piece?.type == PieceType.bishop) &&
            move.from.row == 0) {
          value += 1.5;
        }

        // Encourage center pawn moves
        if (piece?.type == PieceType.pawn &&
            (move.to.col == 3 || move.to.col == 4) &&
            (move.to.row == 2 || move.to.row == 3)) {
          value += 1.0;
        }
      }

      // Penalize moves that don't accomplish anything
      final pieceAtDestination = board.getPiece(move.to);
      if (pieceAtDestination == null && moveCount > 15) {
        // In mid-game, slightly prefer captures or advances
        if (!_isAdvancingPosition(move)) {
          value -= 0.3;
        }
      }

      // Add small random factor for variety
      value += _random.nextDouble() * 0.15;

      if (value > bestValue) {
        bestValue = value;
        bestMove = move;
      }
    }

    // Update move history
    secondLastMove = lastMove;
    lastMove = bestMove;

    return bestMove;
  }

  bool _isAdvancingPosition(Move move) {
    final piece = board.getPiece(move.from);
    if (piece == null) return false;

    // For black pieces, moving down the board (higher row number) is advancing
    return move.to.row > move.from.row ||
        _isCenterSquare(move.to) ||
        (piece.type == PieceType.pawn && move.to.row > move.from.row);
  }

  List<Move> _orderMoves(List<Move> moves) {
    final captures = <Move>[];
    final centerMoves = <Move>[];
    final developments = <Move>[];
    final others = <Move>[];

    for (final move in moves) {
      if (move.capturedPiece != null) {
        captures.add(move);
      } else if (_isCenterSquare(move.to)) {
        centerMoves.add(move);
      } else {
        final piece = board.getPiece(move.from);
        if ((piece?.type == PieceType.knight ||
                piece?.type == PieceType.bishop) &&
            move.from.row == 0) {
          developments.add(move);
        } else {
          others.add(move);
        }
      }
    }

    // Sort captures by value
    captures.sort((a, b) {
      final aValue = _getPieceValue(a.capturedPiece!.type);
      final bValue = _getPieceValue(b.capturedPiece!.type);
      return bValue.compareTo(aValue);
    });

    return [...captures, ...developments, ...centerMoves, ...others];
  }

  bool _isCenterSquare(Position pos) {
    return (pos.row >= 2 && pos.row <= 5) && (pos.col >= 2 && pos.col <= 5);
  }

  double _minimax(
    ChessBoard testBoard,
    int currentDepth,
    double alpha,
    double beta,
    bool isMaximizing,
  ) {
    if (currentDepth == 0) {
      return _evaluateBoard(testBoard);
    }

    if (testBoard.isThreefoldRepetition()) {
      return -5.0; // Heavily penalize repetition
    }

    if (testBoard.isCheckmate(PieceColor.black)) {
      return -10000.0 - currentDepth;
    }
    if (testBoard.isCheckmate(PieceColor.white)) {
      return 10000.0 + currentDepth;
    }
    if (testBoard.isStalemate(PieceColor.black) ||
        testBoard.isStalemate(PieceColor.white)) {
      return 0.0;
    }

    final currentColor = isMaximizing ? PieceColor.black : PieceColor.white;
    final moves = testBoard.getAllPossibleMoves(currentColor);

    if (moves.isEmpty) {
      return _evaluateBoard(testBoard);
    }

    final orderedMoves = _orderMoves(moves);

    if (isMaximizing) {
      double maxEval = double.negativeInfinity;
      for (final move in orderedMoves) {
        final newBoard = testBoard.clone();
        newBoard.movePiece(move.from, move.to);

        final eval = _minimax(newBoard, currentDepth - 1, alpha, beta, false);
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);

        if (beta <= alpha) {
          break;
        }
      }
      return maxEval;
    } else {
      double minEval = double.infinity;
      for (final move in orderedMoves) {
        final newBoard = testBoard.clone();
        newBoard.movePiece(move.from, move.to);

        final eval = _minimax(newBoard, currentDepth - 1, alpha, beta, true);
        minEval = min(minEval, eval);
        beta = min(beta, eval);

        if (beta <= alpha) {
          break;
        }
      }
      return minEval;
    }
  }

  double _getPieceValue(PieceType type) {
    const values = {
      PieceType.pawn: 1.0,
      PieceType.knight: 3.2,
      PieceType.bishop: 3.3,
      PieceType.rook: 5.0,
      PieceType.queen: 9.0,
      PieceType.king: 100.0,
    };
    return values[type]!;
  }

  double _evaluateBoard(ChessBoard testBoard) {
    double score = 0;

    const pawnPositionBonus = [
      [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      [5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0],
      [1.0, 1.0, 2.0, 3.0, 3.0, 2.0, 1.0, 1.0],
      [0.5, 0.5, 1.0, 2.5, 2.5, 1.0, 0.5, 0.5],
      [0.0, 0.0, 0.0, 2.0, 2.0, 0.0, 0.0, 0.0],
      [0.5, -0.5, -1.0, 0.0, 0.0, -1.0, -0.5, 0.5],
      [0.5, 1.0, 1.0, -2.0, -2.0, 1.0, 1.0, 0.5],
      [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    ];

    const knightPositionBonus = [
      [-5.0, -4.0, -3.0, -3.0, -3.0, -3.0, -4.0, -5.0],
      [-4.0, -2.0, 0.0, 0.5, 0.5, 0.0, -2.0, -4.0],
      [-3.0, 0.5, 1.5, 2.0, 2.0, 1.5, 0.5, -3.0],
      [-3.0, 0.0, 2.0, 2.5, 2.5, 2.0, 0.0, -3.0],
      [-3.0, 0.5, 2.0, 2.5, 2.5, 2.0, 0.5, -3.0],
      [-3.0, 0.0, 1.5, 2.0, 2.0, 1.5, 0.0, -3.0],
      [-4.0, -2.0, 0.0, 0.0, 0.0, 0.0, -2.0, -4.0],
      [-5.0, -4.0, -3.0, -3.0, -3.0, -3.0, -4.0, -5.0],
    ];

    const bishopPositionBonus = [
      [-2.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -2.0],
      [-1.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.5, -1.0],
      [-1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0],
      [-1.0, 0.0, 1.0, 1.5, 1.5, 1.0, 0.0, -1.0],
      [-1.0, 0.5, 0.5, 1.5, 1.5, 0.5, 0.5, -1.0],
      [-1.0, 0.0, 0.5, 1.0, 1.0, 0.5, 0.0, -1.0],
      [-1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1.0],
      [-2.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -2.0],
    ];

    const rookPositionBonus = [
      [0.0, 0.0, 0.0, 0.5, 0.5, 0.0, 0.0, 0.0],
      [-0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.5],
      [-0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.5],
      [-0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.5],
      [-0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.5],
      [-0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.5],
      [0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5],
      [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    ];

    const queenPositionBonus = [
      [-2.0, -1.0, -1.0, -0.5, -0.5, -1.0, -1.0, -2.0],
      [-1.0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, -1.0],
      [-1.0, 0.5, 0.5, 0.5, 0.5, 0.5, 0.0, -1.0],
      [0.0, 0.0, 0.5, 0.5, 0.5, 0.5, 0.0, -0.5],
      [-0.5, 0.0, 0.5, 0.5, 0.5, 0.5, 0.0, -0.5],
      [-1.0, 0.0, 0.5, 0.5, 0.5, 0.5, 0.0, -1.0],
      [-1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1.0],
      [-2.0, -1.0, -1.0, -0.5, -0.5, -1.0, -1.0, -2.0],
    ];

    const kingPositionBonus = [
      [2.0, 3.0, 1.0, 0.0, 0.0, 1.0, 3.0, 2.0],
      [2.0, 2.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0],
      [-1.0, -2.0, -2.0, -2.0, -2.0, -2.0, -2.0, -1.0],
      [-2.0, -3.0, -3.0, -4.0, -4.0, -3.0, -3.0, -2.0],
      [-3.0, -4.0, -4.0, -5.0, -5.0, -4.0, -4.0, -3.0],
      [-3.0, -4.0, -4.0, -5.0, -5.0, -4.0, -4.0, -3.0],
      [-3.0, -4.0, -4.0, -5.0, -5.0, -4.0, -4.0, -3.0],
      [-3.0, -4.0, -4.0, -5.0, -5.0, -4.0, -4.0, -3.0],
    ];

    int developedPieces = 0;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = testBoard.board[row][col];
        if (piece == null) continue;

        double pieceScore = _getPieceValue(piece.type);
        final posRow = piece.color == PieceColor.white ? row : 7 - row;

        switch (piece.type) {
          case PieceType.pawn:
            pieceScore += pawnPositionBonus[posRow][col] * 0.1;
            break;
          case PieceType.knight:
            pieceScore += knightPositionBonus[posRow][col] * 0.1;
            if (piece.color == PieceColor.black && row != 0) {
              developedPieces++;
            }
            break;
          case PieceType.bishop:
            pieceScore += bishopPositionBonus[posRow][col] * 0.1;
            if (piece.color == PieceColor.black && row != 0) {
              developedPieces++;
            }
            break;
          case PieceType.rook:
            pieceScore += rookPositionBonus[posRow][col] * 0.1;
            break;
          case PieceType.queen:
            pieceScore += queenPositionBonus[posRow][col] * 0.1;
            break;
          case PieceType.king:
            pieceScore += kingPositionBonus[posRow][col] * 0.1;
            break;
        }

        final validMoves = testBoard.getValidMoves(Position(row, col));
        pieceScore += validMoves.length * 0.05;

        if (piece.color == PieceColor.black) {
          score += pieceScore;
        } else {
          score -= pieceScore;
        }
      }
    }

    // Development bonus
    score += developedPieces * 0.8;

    // Center control
    final centerSquares = [
      Position(3, 3),
      Position(3, 4),
      Position(4, 3),
      Position(4, 4),
    ];

    for (final pos in centerSquares) {
      final piece = testBoard.getPiece(pos);
      if (piece != null) {
        final bonus = piece.color == PieceColor.black ? 0.5 : -0.5;
        score += bonus;
      }
    }

    if (testBoard.isInCheck(PieceColor.white)) {
      score += 1.5;
    }
    if (testBoard.isInCheck(PieceColor.black)) {
      score -= 1.5;
    }

    // Pawn structure
    for (int col = 0; col < 8; col++) {
      int whitePawns = 0;
      int blackPawns = 0;

      for (int row = 0; row < 8; row++) {
        final piece = testBoard.board[row][col];
        if (piece?.type == PieceType.pawn) {
          if (piece!.color == PieceColor.white) {
            whitePawns++;
          } else {
            blackPawns++;
          }
        }
      }

      if (whitePawns > 1) score += 0.5 * (whitePawns - 1);
      if (blackPawns > 1) score -= 0.5 * (blackPawns - 1);
    }

    return score;
  }
}

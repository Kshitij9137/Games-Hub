class Position {
  final int row;
  final int col;

  Position(this.row, this.col);

  bool isValid() => row >= 0 && row < 8 && col >= 0 && col < 8;

  @override
  bool operator ==(Object other) =>
      other is Position && other.row == row && other.col == col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => '${String.fromCharCode(97 + col)}${8 - row}';
}

enum PieceType { king, queen, rook, bishop, knight, pawn }

enum PieceColor { white, black }

class Piece {
  final PieceType type;
  final PieceColor color;
  bool hasMoved;

  Piece(this.type, this.color, {this.hasMoved = false});

  Piece copyWith({bool? hasMoved}) {
    return Piece(type, color, hasMoved: hasMoved ?? this.hasMoved);
  }
}

class Move {
  final Position from;
  final Position to;
  final Piece? capturedPiece;

  Move(this.from, this.to, {this.capturedPiece});

  @override
  String toString() => '${from.toString()}-${to.toString()}';

  @override
  bool operator ==(Object other) =>
      other is Move && other.from == from && other.to == to;

  @override
  int get hashCode => from.hashCode ^ to.hashCode;
}

class ChessBoard {
  late List<List<Piece?>> board;
  PieceColor currentTurn = PieceColor.white;
  List<Piece> capturedPieces = [];
  List<Move> moveHistory = [];
  Map<String, int> positionHistory = {};

  ChessBoard() {
    _initializeBoard();
  }

  void _initializeBoard() {
    board = List.generate(8, (_) => List.filled(8, null));

    // Pawns
    for (int i = 0; i < 8; i++) {
      board[1][i] = Piece(PieceType.pawn, PieceColor.black);
      board[6][i] = Piece(PieceType.pawn, PieceColor.white);
    }

    // Rooks
    board[0][0] = Piece(PieceType.rook, PieceColor.black);
    board[0][7] = Piece(PieceType.rook, PieceColor.black);
    board[7][0] = Piece(PieceType.rook, PieceColor.white);
    board[7][7] = Piece(PieceType.rook, PieceColor.white);

    // Knights
    board[0][1] = Piece(PieceType.knight, PieceColor.black);
    board[0][6] = Piece(PieceType.knight, PieceColor.black);
    board[7][1] = Piece(PieceType.knight, PieceColor.white);
    board[7][6] = Piece(PieceType.knight, PieceColor.white);

    // Bishops
    board[0][2] = Piece(PieceType.bishop, PieceColor.black);
    board[0][5] = Piece(PieceType.bishop, PieceColor.black);
    board[7][2] = Piece(PieceType.bishop, PieceColor.white);
    board[7][5] = Piece(PieceType.bishop, PieceColor.white);

    // Queens
    board[0][3] = Piece(PieceType.queen, PieceColor.black);
    board[7][3] = Piece(PieceType.queen, PieceColor.white);

    // Kings
    board[0][4] = Piece(PieceType.king, PieceColor.black);
    board[7][4] = Piece(PieceType.king, PieceColor.white);
  }

  Piece? getPiece(Position pos) {
    if (!pos.isValid()) return null;
    return board[pos.row][pos.col];
  }

  void setPiece(Position pos, Piece? piece) {
    if (pos.isValid()) {
      board[pos.row][pos.col] = piece;
    }
  }

  String getBoardHash() {
    final buffer = StringBuffer();
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece == null) {
          buffer.write('.');
        } else {
          final char = piece.type == PieceType.king
              ? 'K'
              : piece.type == PieceType.queen
              ? 'Q'
              : piece.type == PieceType.rook
              ? 'R'
              : piece.type == PieceType.bishop
              ? 'B'
              : piece.type == PieceType.knight
              ? 'N'
              : 'P';
          buffer.write(
            piece.color == PieceColor.white ? char : char.toLowerCase(),
          );
        }
      }
    }
    buffer.write(currentTurn == PieceColor.white ? 'W' : 'B');
    return buffer.toString();
  }

  bool isThreefoldRepetition() {
    final currentHash = getBoardHash();
    final count = positionHistory[currentHash] ?? 0;
    return count >= 2; // Third occurrence
  }

  List<Position> getValidMoves(Position from) {
    final piece = getPiece(from);
    if (piece == null || piece.color != currentTurn) return [];

    final moves = _getPossibleMoves(from, piece);
    return moves
        .where((to) => !_wouldBeInCheck(from, to, piece.color))
        .toList();
  }

  List<Position> _getPossibleMoves(Position from, Piece piece) {
    switch (piece.type) {
      case PieceType.pawn:
        return _getPawnMoves(from, piece.color);
      case PieceType.rook:
        return _getRookMoves(from, piece.color);
      case PieceType.knight:
        return _getKnightMoves(from, piece.color);
      case PieceType.bishop:
        return _getBishopMoves(from, piece.color);
      case PieceType.queen:
        return _getQueenMoves(from, piece.color);
      case PieceType.king:
        return _getKingMoves(from, piece.color);
    }
  }

  List<Position> _getPawnMoves(Position from, PieceColor color) {
    final moves = <Position>[];
    final direction = color == PieceColor.white ? -1 : 1;
    final startRow = color == PieceColor.white ? 6 : 1;

    // Forward move
    final forward = Position(from.row + direction, from.col);
    if (forward.isValid() && getPiece(forward) == null) {
      moves.add(forward);

      // Double move from start
      if (from.row == startRow) {
        final doubleForward = Position(from.row + direction * 2, from.col);
        if (doubleForward.isValid() && getPiece(doubleForward) == null) {
          moves.add(doubleForward);
        }
      }
    }

    // Captures
    for (final colOffset in [-1, 1]) {
      final capture = Position(from.row + direction, from.col + colOffset);
      if (capture.isValid()) {
        final target = getPiece(capture);
        if (target != null && target.color != color) {
          moves.add(capture);
        }
      }
    }

    return moves;
  }

  List<Position> _getRookMoves(Position from, PieceColor color) {
    return _getSlidingMoves(from, color, [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
    ]);
  }

  List<Position> _getBishopMoves(Position from, PieceColor color) {
    return _getSlidingMoves(from, color, [
      [-1, -1],
      [-1, 1],
      [1, -1],
      [1, 1],
    ]);
  }

  List<Position> _getQueenMoves(Position from, PieceColor color) {
    return _getSlidingMoves(from, color, [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
      [-1, -1],
      [-1, 1],
      [1, -1],
      [1, 1],
    ]);
  }

  List<Position> _getSlidingMoves(
    Position from,
    PieceColor color,
    List<List<int>> directions,
  ) {
    final moves = <Position>[];

    for (final dir in directions) {
      int row = from.row + dir[0];
      int col = from.col + dir[1];

      while (row >= 0 && row < 8 && col >= 0 && col < 8) {
        final pos = Position(row, col);
        final target = getPiece(pos);

        if (target == null) {
          moves.add(pos);
        } else {
          if (target.color != color) {
            moves.add(pos);
          }
          break;
        }

        row += dir[0];
        col += dir[1];
      }
    }

    return moves;
  }

  List<Position> _getKnightMoves(Position from, PieceColor color) {
    final moves = <Position>[];
    final offsets = [
      [-2, -1],
      [-2, 1],
      [-1, -2],
      [-1, 2],
      [1, -2],
      [1, 2],
      [2, -1],
      [2, 1],
    ];

    for (final offset in offsets) {
      final pos = Position(from.row + offset[0], from.col + offset[1]);
      if (pos.isValid()) {
        final target = getPiece(pos);
        if (target == null || target.color != color) {
          moves.add(pos);
        }
      }
    }

    return moves;
  }

  List<Position> _getKingMoves(Position from, PieceColor color) {
    final moves = <Position>[];
    final offsets = [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1],
    ];

    for (final offset in offsets) {
      final pos = Position(from.row + offset[0], from.col + offset[1]);
      if (pos.isValid()) {
        final target = getPiece(pos);
        if (target == null || target.color != color) {
          moves.add(pos);
        }
      }
    }

    return moves;
  }

  bool _wouldBeInCheck(Position from, Position to, PieceColor color) {
    final tempPiece = getPiece(from);
    final tempTarget = getPiece(to);

    setPiece(to, tempPiece);
    setPiece(from, null);

    final inCheck = isInCheck(color);

    setPiece(from, tempPiece);
    setPiece(to, tempTarget);

    return inCheck;
  }

  bool isInCheck(PieceColor color) {
    final kingPos = _findKing(color);
    if (kingPos == null) return false;

    final opponentColor = color == PieceColor.white
        ? PieceColor.black
        : PieceColor.white;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color == opponentColor) {
          final moves = _getPossibleMoves(Position(row, col), piece);
          if (moves.any((m) => m.row == kingPos.row && m.col == kingPos.col)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  Position? _findKing(PieceColor color) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null &&
            piece.type == PieceType.king &&
            piece.color == color) {
          return Position(row, col);
        }
      }
    }
    return null;
  }

  bool isCheckmate(PieceColor color) {
    if (!isInCheck(color)) return false;
    return !_hasAnyValidMove(color);
  }

  bool isStalemate(PieceColor color) {
    if (isInCheck(color)) return false;
    return !_hasAnyValidMove(color);
  }

  bool _hasAnyValidMove(PieceColor color) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color == color) {
          final moves = getValidMoves(Position(row, col));
          if (moves.isNotEmpty) return true;
        }
      }
    }
    return false;
  }

  void movePiece(Position from, Position to) {
    final piece = getPiece(from);
    if (piece == null) return;

    final capturedPiece = getPiece(to);
    if (capturedPiece != null) {
      capturedPieces.add(capturedPiece);
    }

    moveHistory.add(Move(from, to, capturedPiece: capturedPiece));

    // Pawn promotion
    if (piece.type == PieceType.pawn) {
      if ((piece.color == PieceColor.white && to.row == 0) ||
          (piece.color == PieceColor.black && to.row == 7)) {
        setPiece(to, Piece(PieceType.queen, piece.color, hasMoved: true));
        setPiece(from, null);
        currentTurn = currentTurn == PieceColor.white
            ? PieceColor.black
            : PieceColor.white;

        // Update position history
        final hash = getBoardHash();
        positionHistory[hash] = (positionHistory[hash] ?? 0) + 1;
        return;
      }
    }

    setPiece(to, piece.copyWith(hasMoved: true));
    setPiece(from, null);

    currentTurn = currentTurn == PieceColor.white
        ? PieceColor.black
        : PieceColor.white;

    // Update position history
    final hash = getBoardHash();
    positionHistory[hash] = (positionHistory[hash] ?? 0) + 1;
  }

  List<Move> getAllPossibleMoves(PieceColor color) {
    final moves = <Move>[];

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color == color) {
          final from = Position(row, col);
          final validMoves = getValidMoves(from);
          for (final to in validMoves) {
            moves.add(Move(from, to, capturedPiece: getPiece(to)));
          }
        }
      }
    }

    return moves;
  }

  ChessBoard clone() {
    final newBoard = ChessBoard();
    newBoard.currentTurn = currentTurn;
    newBoard.capturedPieces = List.from(capturedPieces);
    newBoard.positionHistory = Map.from(positionHistory);

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null) {
          newBoard.board[row][col] = piece.copyWith();
        } else {
          newBoard.board[row][col] = null;
        }
      }
    }

    return newBoard;
  }
}

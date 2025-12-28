// lib/Games/TicTakToe/tictaktoe_logic.dart
class TicTacToeLogic {
  List<String> board = List.filled(9, '');
  bool isXTurn = true;
  String winner = '';
  bool gameOver = false;
  int xScore = 0;
  int oScore = 0;
  bool isComputerMode = false;
  List<int> winningLine = [];

  void reset() {
    board = List.filled(9, '');
    isXTurn = true;
    winner = '';
    gameOver = false;
    winningLine = [];
  }

  void resetScore() {
    xScore = 0;
    oScore = 0;
    reset();
  }

  void setMode(bool computerMode) {
    isComputerMode = computerMode;
    resetScore();
  }

  bool makeMove(int index) {
    if (board[index] != '' || gameOver) return false;

    board[index] = isXTurn ? 'X' : 'O';
    isXTurn = !isXTurn;
    checkWinner();
    return true;
  }

  void checkWinner() {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (var pattern in winPatterns) {
      String pos1 = board[pattern[0]];
      String pos2 = board[pattern[1]];
      String pos3 = board[pattern[2]];

      if (pos1 != '' && pos1 == pos2 && pos2 == pos3) {
        winner = pos1;
        gameOver = true;
        winningLine = pattern;
        if (pos1 == 'X') {
          xScore++;
        } else {
          oScore++;
        }
        return;
      }
    }

    if (!board.contains('')) {
      gameOver = true;
    }
  }

  int getComputerMove() {
    int? move = findWinningMove('O');
    if (move != null) return move;

    move = findWinningMove('X');
    if (move != null) return move;

    if (board[4] == '') return 4;

    List<int> corners = [0, 2, 6, 8];
    for (int corner in corners) {
      if (board[corner] == '') return corner;
    }

    for (int i = 0; i < 9; i++) {
      if (board[i] == '') return i;
    }

    return -1;
  }

  int? findWinningMove(String player) {
    const winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      List<String> cells = [
        board[pattern[0]],
        board[pattern[1]],
        board[pattern[2]],
      ];

      if (cells.where((cell) => cell == player).length == 2 &&
          cells.contains('')) {
        for (int i = 0; i < 3; i++) {
          if (board[pattern[i]] == '') {
            return pattern[i];
          }
        }
      }
    }
    return null;
  }

  String getResultMessage() {
    if (winner != '') {
      if (isComputerMode) {
        return winner == 'X' ? 'You Win! 🎉' : 'Computer Wins! 🤖';
      }
      return '$winner Wins! 🏆';
    }
    return 'It\'s a Draw! 🤝';
  }
}

// game_logic.dart
class GameLogic {
  static List<List<int>> winningCombos = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  static String checkWinner(List<String> board) {
    for (var combo in winningCombos) {
      String a = board[combo[0]];
      String b = board[combo[1]];
      String c = board[combo[2]];
      if (a != '' && a == b && b == c) {
        return a; // "X" or "O"
      }
    }
    return '';
  }

  static bool isDraw(List<String> board) {
    return board.every((cell) => cell != '');
  }

  static List<int> getEmptyCells(List<String> board) {
    List<int> empty = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') empty.add(i);
    }
    return empty;
  }

  static int findWinningMove(List<String> board, String player) {
    for (var combo in winningCombos) {
      var a = combo[0], b = combo[1], c = combo[2];
      List<String> triplet = [board[a], board[b], board[c]];
      if (triplet.where((e) => e == player).length == 2 &&
          triplet.contains('')) {
        return [a, b, c][triplet.indexOf('')];
      }
    }
    return -1;
  }

  static bool isGameOver(List<String> board) {
    return checkWinner(board) != '' || isDraw(board);
  }
}

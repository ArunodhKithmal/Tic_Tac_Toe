// test/game_logic_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/game_logic.dart';

void main() {
  test('Detects winning condition for X', () {
    List<String> board = ['X', 'X', 'X', '', '', '', '', '', ''];
    expect(GameLogic.checkWinner(board), 'X');
  });

  test('Detects winning condition for O', () {
    List<String> board = ['', '', '', 'O', 'O', 'O', '', '', ''];
    expect(GameLogic.checkWinner(board), 'O');
  });

  test('Detects no winner and draw', () {
    List<String> board = ['X', 'O', 'X', 'X', 'O', 'O', 'O', 'X', 'X'];
    expect(GameLogic.checkWinner(board), '');
    expect(GameLogic.isDraw(board), true);
  });

  test('Finds empty cells correctly', () {
    List<String> board = ['X', '', 'O', '', '', '', '', 'X', 'O'];
    expect(GameLogic.getEmptyCells(board), [1, 3, 4, 5, 6]);
  });

  test('Finds winning move for O', () {
    List<String> board = ['O', 'O', '', '', '', '', '', '', ''];
    expect(GameLogic.findWinningMove(board, 'O'), 2);
  });

  //checking if the user/computer is trying to play in a valid (empty) cell
  test('Rejects move in non-empty cell', () {
    List<String> board = ['X', '', '', '', '', '', '', '', ''];
    bool isValid = GameLogic.getEmptyCells(
      board,
    ).contains(0); // Cell 0 already has X
    expect(isValid, false);
  });

  test('Accepts move in empty cell', () {
    List<String> board = ['X', '', '', '', '', '', '', '', ''];
    bool isValid = GameLogic.getEmptyCells(
      board,
    ).contains(1); // Cell 1 is empty
    expect(isValid, true);
  });

  //Tracking game state
  test('Detects ongoing game state correctly', () {
    List<String> board = ['X', 'O', 'X', '', '', '', '', '', ''];
    String winner = GameLogic.checkWinner(board);
    bool isDraw = GameLogic.isDraw(board);
    expect(winner, '');
    expect(isDraw, false); // Game is still ongoing
  });

  test('Game is over if there is a winner', () {
    List<String> board = ['X', 'X', 'X', '', '', '', '', '', ''];
    expect(GameLogic.isGameOver(board), true);
  });

  test('Game is over if board is full with no winner (draw)', () {
    List<String> board = ['X', 'O', 'X', 'X', 'O', 'O', 'O', 'X', 'X'];
    expect(GameLogic.isGameOver(board), true);
  });
}

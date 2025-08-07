// test/game_logic_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/game_logic.dart';

void main() {
  //TC1
  test('Detects winning condition for X', () {
    List<String> board = ['X', 'X', 'X', '', '', '', '', '', ''];
    expect(GameLogic.checkWinner(board), 'X');
  });

  //TC2
  test('Detects winning condition for O', () {
    List<String> board = ['', '', '', 'O', 'O', 'O', '', '', ''];
    expect(GameLogic.checkWinner(board), 'O');
  });

  //TC3
  test('Detects no winner and draw', () {
    List<String> board = ['X', 'O', 'X', 'X', 'O', 'O', 'O', 'X', 'X'];
    expect(GameLogic.checkWinner(board), '');
    expect(GameLogic.isDraw(board), true);
  });

  //TC4
  test('Detects ongoing game state correctly', () {
    List<String> board = ['X', 'O', 'X', '', '', '', '', '', ''];
    String winner = GameLogic.checkWinner(board);
    bool isDraw = GameLogic.isDraw(board);
    expect(winner, '');
    expect(isDraw, false); // Game is still ongoing
  });

  //TC5
  test('Finds empty cells correctly', () {
    List<String> board = ['X', '', 'O', '', '', '', '', 'X', 'O'];
    expect(GameLogic.getEmptyCells(board), [1, 3, 4, 5, 6]);
  });

  //TC6
  test('Accepts move in empty cell', () {
    List<String> board = ['X', '', '', '', '', '', '', '', ''];
    bool isValid = GameLogic.getEmptyCells(
      board,
    ).contains(1); // Cell 1 is empty
    expect(isValid, true);
  });

  //TC7
  //checking if the user/computer is trying to play in a valid (empty) cell
  test('Rejects move in non-empty cell', () {
    List<String> board = ['X', '', '', '', '', '', '', '', ''];
    bool isValid = GameLogic.getEmptyCells(
      board,
    ).contains(0); // Cell 0 already has X
    expect(isValid, false);
  });

  //TC8
  test('Finds winning move for O', () {
    List<String> board = ['O', 'O', '', '', '', '', '', '', ''];
    expect(GameLogic.findWinningMove(board, 'O'), 2);
  });

  //TC9
  //Tracking game state
  test('Detects ongoing game state correctly', () {
    List<String> board = ['X', 'O', 'X', '', '', '', '', '', ''];
    String winner = GameLogic.checkWinner(board);
    bool isDraw = GameLogic.isDraw(board);
    expect(winner, '');
    expect(isDraw, false); // Game is still ongoing
  });

  //TC10
  test('Game is over if there is a winner', () {
    List<String> board = ['X', 'X', 'X', '', '', '', '', '', ''];
    expect(GameLogic.isGameOver(board), true);
  });

  //TC11
  test('Game is over if board is full with no winner (draw)', () {
    List<String> board = ['X', 'O', 'X', 'X', 'O', 'O', 'O', 'X', 'X'];
    expect(GameLogic.isGameOver(board), true);
  });

  //TC12
  test('Detects diagonal win for X (bottom-left to top-right)', () {
    List<String> board = ['X', '', '', '', 'X', '', '', '', 'X'];
    expect(GameLogic.checkWinner(board), 'X');
  });

  //TC13
  test('Finds correct winning move when two in a row (X)', () {
    List<String> board = ['X', 'X', '', '', '', '', '', '', ''];
    int move = GameLogic.findWinningMove(board, 'X');
    expect(move, 2); // The empty spot to complete the win
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/logic/game_ai.dart';
import 'package:tic_tac_toe/models/game_models.dart';

void main() {
  group('Rules: winner()', () {
    test('row win', () {
      final b = <String>['X', 'X', 'X', '', '', '', '', '', ''];
      expect(GameLogic.winner(b), 'X');
    });

    test('column win', () {
      final b = <String>['O', '', '', 'O', '', '', 'O', '', ''];
      expect(GameLogic.winner(b), 'O');
    });

    test('diagonal win', () {
      final b = <String>['X', '', '', '', 'X', '', '', '', 'X'];
      expect(GameLogic.winner(b), 'X');
    });

    test('no winner', () {
      final b = <String>['X', 'O', 'X', 'X', 'O', 'O', 'O', 'X', 'X'];
      expect(GameLogic.winner(b), '');
    });
  });

  group('Rules: isDraw()', () {
    test('true when board full and no winner', () {
      final b = <String>['X', 'O', 'X', 'X', 'O', 'O', 'O', 'X', 'X'];
      expect(GameLogic.isDraw(b), isTrue);
    });

    test('false when winner exists', () {
      final b = <String>['X', 'X', 'X', '', '', '', '', '', ''];
      expect(GameLogic.isDraw(b), isFalse);
    });

    test('false when board not full', () {
      final b = emptyBoard();
      b[0] = 'X';
      expect(GameLogic.isDraw(b), isFalse);
    });
  });

  group('Helpers: emptyCells()', () {
    test('returns all empty indices', () {
      final b = emptyBoard();
      b[0] = 'X';
      b[4] = 'O';
      expect(GameLogic.emptyCells(b), [1, 2, 3, 5, 6, 7, 8]);
    });
  });

  group('AI: easy()', () {
    test('returns -1 on full board', () {
      final b = <String>['X', 'O', 'X', 'X', 'O', 'O', 'O', 'X', 'X'];
      expect(GameLogic.easy(b), -1);
    });

    test('returns a valid empty index', () {
      final b = emptyBoard();
      b[4] = 'X';
      final choice = GameLogic.easy(b);
      expect(choice, isNot(equals(-1)));
      expect(GameLogic.emptyCells(b).contains(choice), isTrue);
    });
  });

  group('AI: hard()', () {
    test('chooses winning move when available (O wins)', () {
      // O O _  -> should place at 2
      final b = <String>['O', 'O', '', '', '', '', '', '', ''];
      final choice = GameLogic.hard(b);
      expect(choice, 2);
    });

    test('blocks X when X is about to win', () {
      // X X _ -> O must block at 2
      final b = <String>['X', 'X', '', '', 'O', '', '', '', ''];
      final choice = GameLogic.hard(b);
      expect(choice, 2);
    });

    test('falls back to valid random when no win/block', () {
      final b = <String>['X', 'O', 'X', 'O', 'X', '', '', '', 'O'];
      final choice = GameLogic.hard(b);
      expect(GameLogic.emptyCells(b).contains(choice), isTrue);
    });
  });

  group('AI: medium()', () {
    test('useRandom=false behaves like hard() on deterministic board', () {
      final b = <String>['O', 'O', '', '', '', '', '', '', ''];
      final m = GameLogic.medium(b, useRandom: false);
      expect(m, 2); // same as hard()
    });

    test('useRandom=true returns one of the empty cells', () {
      final b = emptyBoard();
      b[0] = 'X';
      final choice = GameLogic.medium(b, useRandom: true);
      expect(GameLogic.emptyCells(b).contains(choice), isTrue);
    });
  });
}

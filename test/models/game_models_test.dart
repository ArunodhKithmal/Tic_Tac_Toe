import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/models/game_models.dart';

void main() {
  group('Enums & typedefs', () {
    test('GameMode and Player enums exist', () {
      // Just reference them so the file compiles/links.
      expect(GameMode.values.contains(GameMode.singleEasy), isTrue);
      expect(Player.values.contains(Player.X), isTrue);
    });

    test('Board typedef and emptyBoard()', () {
      final Board b = emptyBoard();
      expect(b.length, 9);
      expect(b.every((c) => c == ''), isTrue);
    });
  });

  group('Move model', () {
    test('stores player and cell', () {
      const m = Move(Player.X, 4);
      expect(m.player, Player.X);
      expect(m.cell, 4);
    });
  });

  group('GameStats', () {
    test('defaults are zero', () {
      const s = GameStats();
      expect(s.wins, 0);
      expect(s.losses, 0);
      expect(s.draws, 0);
    });

    test('incWins increments wins only', () {
      const s = GameStats();
      final s2 = s.incWins();
      expect(s2.wins, 1);
      expect(s2.losses, 0);
      expect(s2.draws, 0);
    });

    test('incLosses increments losses only', () {
      const s = GameStats();
      final s2 = s.incLosses();
      expect(s2.wins, 0);
      expect(s2.losses, 1);
      expect(s2.draws, 0);
    });

    test('incDraws increments draws only', () {
      const s = GameStats();
      final s2 = s.incDraws();
      expect(s2.wins, 0);
      expect(s2.losses, 0);
      expect(s2.draws, 1);
    });
  });
}

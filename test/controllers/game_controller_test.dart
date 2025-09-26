import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/controllers/game_controller.dart';
import 'package:tic_tac_toe/models/game_models.dart';
import 'package:tic_tac_toe/services/storage_service.dart';

class FakeStorageService extends StorageService {
  GameStats _mem = const GameStats();

  @override
  Future<GameStats> loadStats() async => _mem;

  @override
  Future<void> saveStats(GameStats s) async {
    _mem = s;
  }
}

Future<void> pumpMicrotask() => Future<void>.delayed(Duration.zero);

void main() {
  group('init & reset', () {
    test('loads stats on init', () async {
      final c = GameController(storage: FakeStorageService());
      await pumpMicrotask();
      expect(c.stats.wins, 0);
      expect(c.stats.losses, 0);
      expect(c.stats.draws, 0);
    });

    test('reset clears transient state and board', () async {
      final c = GameController(storage: FakeStorageService());
      await pumpMicrotask();

      c.mode = GameMode.singleEasy;
      c.started = true;
      c.over = true;
      c.resultText = 'something';
      c.p1 = 'A';
      c.p2 = 'B';
      c.history.add(const Move(Player.X, 0));
      c.board[0] = 'X';

      c.reset();

      expect(c.started, isFalse);
      expect(c.over, isFalse);
      expect(c.mode, isNull);
      expect(c.resultText, '');
      expect(c.p1, '');
      expect(c.p2, '');
      expect(c.history, isEmpty);
      expect(c.board.every((e) => e == ''), isTrue);
      expect(c.current, Player.X);
      expect(c.useRandomNext, isTrue);
    });
  });

  group('multiplayer', () {
    test(
      'X wins: over=true, message includes winner name, no stats updates',
      () async {
        final c = GameController(storage: FakeStorageService());
        await pumpMicrotask();
        c.startMulti(
          firstName: 'Alice',
          secondName: 'Bob',
          firstTurnName: 'Alice',
        );

        // X  X  X  wins on top row
        c.tapCell(0); // X
        c.tapCell(3); // O
        c.tapCell(1); // X
        c.tapCell(4); // O
        c.tapCell(2); // X -> win

        expect(c.over, isTrue);
        expect(c.resultText, contains('Alice'));
        expect((c.stats.wins, c.stats.losses, c.stats.draws), (0, 0, 0));
      },
    );

    test('undo removes last move and restores turn', () async {
      final c = GameController(storage: FakeStorageService());
      await pumpMicrotask();
      c.startMulti(firstName: 'A', secondName: 'B', firstTurnName: 'A');

      c.tapCell(0); // A (X)
      c.tapCell(4); // B (O)
      expect(c.board[4], 'O');

      c.undo(); // remove O at 4, give turn back to Player.O
      expect(c.board[4], '');
      expect(c.current, Player.O);
      expect(c.over, isFalse);
      expect(c.resultText, '');
    });
  });

  group('single-player', () {
    test('player X completes win -> stats.wins++ and message', () async {
      final fake = FakeStorageService();
      final c = GameController(storage: fake);
      await pumpMicrotask();
      c.startSingle(GameMode.singleHard, computerFirst: false);

      c.board = <String>['X', 'X', '', '', '', '', '', '', ''];
      c.current = Player.X;
      c.history.clear();

      c.tapCell(2); // X wins

      expect(c.over, isTrue);
      expect(c.resultText, contains('Congratulations'));
      expect((c.stats.wins, c.stats.losses, c.stats.draws), (1, 0, 0));
    });

    test('last empty cell causes draw -> stats.draws++', () async {
      final fake = FakeStorageService();
      final c = GameController(storage: fake);
      await pumpMicrotask();
      c.startSingle(GameMode.singleHard, computerFirst: false);

      c.board = <String>['X', 'O', 'X', 'X', 'O', 'O', 'O', 'X', ''];
      c.current = Player.X;
      c.history.clear();

      c.tapCell(8);

      expect(c.over, isTrue);
      expect(c.resultText, contains("tie"));
      expect(c.stats.draws, 1);
    });

    test('medium mode toggles useRandomNext after computer move', () async {
      final c = GameController(storage: FakeStorageService());
      await pumpMicrotask();
      c.startSingle(GameMode.singleMedium, computerFirst: false);

      expect(c.useRandomNext, isTrue);
      c.tapCell(0);
      expect(c.useRandomNext, isFalse);
      expect(c.board.where((e) => e.isNotEmpty).length, 2);
    });

    test(
      'undo in single-player removes (computer + player) last pair',
      () async {
        final c = GameController(storage: FakeStorageService());
        await pumpMicrotask();
        c.startSingle(GameMode.singleEasy, computerFirst: false);

        c.tapCell(0);
        final before = List<String>.from(c.board);
        c.undo();

        expect(
          c.board.where((e) => e.isNotEmpty).length,
          lessThan(before.where((e) => e.isNotEmpty).length),
        );
        expect(c.over, isFalse);
        expect(c.resultText, '');
      },
    );
  });
}

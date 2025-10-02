import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:tic_tac_toe/views/game_screen.dart';
import 'package:tic_tac_toe/controllers/game_controller.dart';
import 'package:tic_tac_toe/models/game_models.dart';
import 'package:tic_tac_toe/widgets/board_grid.dart';
import 'package:tic_tac_toe/services/storage_service.dart';

/// In-memory storage fake (no real SharedPreferences I/O).
class FakeStorageService extends StorageService {
  GameStats _mem = const GameStats();
  @override
  Future<GameStats> loadStats() async => _mem;
  @override
  Future<void> saveStats(GameStats s) async => _mem = s;
}

Widget _wrap(GameController c) {
  return ChangeNotifierProvider.value(
    value: c,
    child: const MaterialApp(home: GameScreen()),
  );
}

Future<void> _tick() => Future<void>.delayed(Duration.zero);

void main() {
  testWidgets('GS1: shows Start Game button when not started', (tester) async {
    final c = GameController(storage: FakeStorageService());
    await _tick();

    await tester.pumpWidget(_wrap(c));
    expect(find.text('Start Game'), findsOneWidget);
    expect(find.byType(BoardGrid), findsOneWidget);
  });

  testWidgets('GS2: tapping board before start shows SnackBar', (tester) async {
    final c = GameController(storage: FakeStorageService());
    await _tick();
    await tester.pumpWidget(_wrap(c));

    // Tap first cell inside the BoardGrid
    final grid = find.byType(BoardGrid);
    expect(grid, findsOneWidget);
    // Find a GestureDetector inside the BoardGrid (cell)
    final firstCell = find
        .descendant(of: grid, matching: find.byType(GestureDetector))
        .first;

    await tester.tap(firstCell);
    await tester.pump(); // allow SnackBar to appear
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Please start the game'), findsOneWidget);
  });

  testWidgets('GS3: single-player in-progress shows header + StatsCard', (
    tester,
  ) async {
    final c = GameController(storage: FakeStorageService());
    await _tick();

    // Put controller into an in-progress single-player state
    c.started = true;
    c.mode = GameMode.singleEasy;
    c.board = emptyBoard();
    c.notifyListeners();

    await tester.pumpWidget(_wrap(c));
    await tester.pump(); // settle post-frame callbacks

    expect(find.text('Single Player - Easy Mode'), findsOneWidget);
    expect(find.byType(BoardGrid), findsOneWidget);
    // StatsCard is shown only for single-player
    expect(find.textContaining('Wins:'), findsOneWidget); // from StatsCard
  });

  testWidgets('GS4: multiplayer in-progress shows vs header, no StatsCard', (
    tester,
  ) async {
    final c = GameController(storage: FakeStorageService());
    await _tick();

    c.started = true;
    c.mode = GameMode.multiplayer;
    c.p1 = 'Alice';
    c.p2 = 'Bob';
    c.notifyListeners();

    await tester.pumpWidget(_wrap(c));
    await tester.pump();

    expect(find.text('Alice (X)  VS  Bob (O)'), findsOneWidget);
    // No StatsCard text in multiplayer
    expect(find.textContaining('Wins:'), findsNothing);
  });

  testWidgets('GS5: finished game shows result text', (tester) async {
    final c = GameController(storage: FakeStorageService());
    await _tick();

    c.started = true;
    c.over = true;
    c.resultText = 'Congratulations! 🎉 You win!';
    c.notifyListeners();

    await tester.pumpWidget(_wrap(c));
    await tester.pump();

    expect(find.textContaining('Congratulations!'), findsOneWidget);
    // Start Game button should be hidden while started==true even if over
    expect(find.text('Start Game'), findsNothing);
  });
}

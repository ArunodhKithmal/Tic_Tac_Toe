import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/models/game_models.dart';
import 'package:tic_tac_toe/services/storage_service.dart';

void main() {
  late StorageService storage;

  setUp(() {
    // Reset the in-memory SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
    storage = StorageService();
  });

  test('loadStats returns zeros when nothing stored', () async {
    final s = await storage.loadStats();
    expect(s.wins, 0);
    expect(s.losses, 0);
    expect(s.draws, 0);
  });

  test('loadStats reads existing stored values', () async {
    SharedPreferences.setMockInitialValues({
      'wins': 3,
      'losses': 2,
      'draws': 1,
    });

    final s = await storage.loadStats();
    expect(s.wins, 3);
    expect(s.losses, 2);
    expect(s.draws, 1);
  });

  test('saveStats persists values (roundtrip)', () async {
    const s = GameStats(wins: 5, losses: 4, draws: 3);
    await storage.saveStats(s);

    final reread = await storage.loadStats();
    expect(reread.wins, 5);
    expect(reread.losses, 4);
    expect(reread.draws, 3);
  });

  test('saveStats overwrites previous values', () async {
    SharedPreferences.setMockInitialValues({
      'wins': 9,
      'losses': 9,
      'draws': 9,
    });

    await storage.saveStats(const GameStats(wins: 1, losses: 2, draws: 3));
    final reread = await storage.loadStats();

    expect(reread.wins, 1);
    expect(reread.losses, 2);
    expect(reread.draws, 3);
  });
}

import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_models.dart';

class StorageService {
  Future<GameStats> loadStats() async {
    final p = await SharedPreferences.getInstance();
    return GameStats(
      wins: p.getInt('wins') ?? 0,
      losses: p.getInt('losses') ?? 0,
      draws: p.getInt('draws') ?? 0,
    );
  }

  Future<void> saveStats(GameStats s) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('wins', s.wins);
    await p.setInt('losses', s.losses);
    await p.setInt('draws', s.draws);
  }
}

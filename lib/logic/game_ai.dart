import '../models/game_models.dart';
import 'dart:math';

class GameLogic {
  static const combos = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  static String winner(Board b) {
    for (final c in combos) {
      if (b[c[0]] != '' && b[c[0]] == b[c[1]] && b[c[1]] == b[c[2]]) {
        return b[c[0]]; // 'X' or 'O'
      }
    }
    return '';
  }

  static bool isDraw(Board b) => !b.contains('') && winner(b).isEmpty;

  static List<int> emptyCells(Board b) {
    final out = <int>[];
    for (var i = 0; i < 9; i++) {
      if (b[i].isEmpty) out.add(i);
    }
    return out;
  }

  static int _finishingMove(Board b, String p) {
    for (final c in combos) {
      final a = [b[c[0]], b[c[1]], b[c[2]]];
      if (a.where((v) => v == p).length == 2 && a.contains('')) {
        return c[a.indexOf('')];
      }
    }
    return -1;
  }

  // EASY: random
  static int easy(Board b) {
    final e = emptyCells(b);
    return e.isEmpty ? -1 : e[Random().nextInt(e.length)];
  }

  // HARD: win > block > random
  static int hard(Board b) {
    final w = _finishingMove(b, 'O');
    if (w != -1) return w;
    final blk = _finishingMove(b, 'X');
    if (blk != -1) return blk;
    return easy(b);
  }

  // MEDIUM: alternate random/hard (pass a toggle flag)
  static int medium(Board b, {required bool useRandom}) {
    return useRandom ? easy(b) : hard(b);
  }
}

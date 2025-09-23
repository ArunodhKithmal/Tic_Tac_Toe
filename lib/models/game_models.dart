import 'package:flutter/foundation.dart';

enum GameMode { singleEasy, singleMedium, singleHard, multiplayer }

enum Player { X, O }

@immutable
class Move {
  final Player player;
  final int cell;
  const Move(this.player, this.cell);
}

@immutable
class GameStats {
  final int wins, losses, draws;
  const GameStats({this.wins = 0, this.losses = 0, this.draws = 0});

  GameStats incWins() =>
      GameStats(wins: wins + 1, losses: losses, draws: draws);
  GameStats incLosses() =>
      GameStats(wins: wins, losses: losses + 1, draws: draws);
  GameStats incDraws() => GameStats(wins: wins, losses: losses, draws: draws);
}

typedef Board = List<String>;

Board emptyBoard() => List<String>.filled(9, '');

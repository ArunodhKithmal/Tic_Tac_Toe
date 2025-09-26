import 'package:flutter/foundation.dart';
import '../models/game_models.dart';
import '../services/storage_service.dart';
import '../logic/game_ai.dart';

class GameController extends ChangeNotifier {
  final StorageService storage;
  GameController({StorageService? storage})
    : storage = storage ?? StorageService() {
    _init();
  }

  Board board = emptyBoard();
  Player current = Player.X;
  GameMode? mode;
  bool started = false;
  bool over = false;
  bool useRandomNext = true;
  String resultText = '';
  String p1 = '', p2 = '';
  GameStats stats = const GameStats();
  final List<Move> history = [];

  Future<void> _init() async {
    stats = await storage.loadStats();
    notifyListeners();
  }

  void reset() {
    board = emptyBoard();
    current = Player.X;

    mode = null;
    started = false;
    over = false;
    useRandomNext = true;
    resultText = '';
    p1 = '';
    p2 = '';

    history.clear();
    notifyListeners();
  }

  void startSingle(GameMode m, {bool computerFirst = false}) {
    reset();
    started = true;
    mode = m;
    notifyListeners();

    if (computerFirst) _computerMove();
  }

  void startMulti({
    required String firstName,
    required String secondName,
    required String firstTurnName,
  }) {
    reset();
    started = true;
    mode = GameMode.multiplayer;
    p1 = firstName;
    p2 = secondName;
    current = (firstTurnName == firstName) ? Player.X : Player.O;
    notifyListeners();
  }

  void tapCell(int index) {
    if (!started || over || board[index].isNotEmpty) return;

    _place(current, index);
    _checkEnd();
    if (over) return;

    if (mode == GameMode.multiplayer) {
      current = current == Player.X ? Player.O : Player.X;
      notifyListeners();
    } else {
      _computerMove();
    }
  }

  void undo() {
    if (history.isEmpty || over) return;

    if (mode == GameMode.multiplayer) {
      final last = history.removeLast();
      board[last.cell] = '';
      current = last.player; // give turn back
      over = false;
      resultText = '';
      notifyListeners();
    } else {
      if (history.length < 2) return;
      final comp = history.removeLast();
      board[comp.cell] = '';
      final you = history.removeLast();
      board[you.cell] = '';
      over = false;
      resultText = '';
      notifyListeners();
    }
  }

  void _place(Player p, int i) {
    board[i] = p == Player.X ? 'X' : 'O';
    history.add(Move(p, i));
    notifyListeners();
  }

  void _computerMove() {
    if (mode == null || mode == GameMode.multiplayer) return;
    final i = switch (mode!) {
      GameMode.singleEasy => GameLogic.easy(board),
      GameMode.singleHard => GameLogic.hard(board),
      GameMode.singleMedium => GameLogic.medium(
        board,
        useRandom: useRandomNext,
      ),
      _ => -1,
    };
    useRandomNext = !useRandomNext;
    if (i != -1) {
      _place(Player.O, i);
      _checkEnd();
    }
  }

  void _checkEnd() {
    final win = GameLogic.winner(board);
    if (win.isNotEmpty) {
      over = true;
      if (mode == GameMode.multiplayer) {
        final winnerName = (win == 'X') ? p1 : p2;
        resultText = 'Congratulations! 🎉 $winnerName\nYou win!';
      } else {
        final playerWon = win == 'X';
        if (playerWon) {
          stats = stats.incWins();
          resultText = 'Congratulations! 🎉 You win!';
        } else {
          stats = stats.incLosses();
          resultText = '😞 You lost!\nTry again next time!';
        }
        storage.saveStats(stats);
      }
      notifyListeners();
      return;
    }

    if (GameLogic.isDraw(board)) {
      over = true;
      resultText = "It's a tie! 🤝";
      if (mode != GameMode.multiplayer) {
        stats = stats.incDraws();
        storage.saveStats(stats);
      }
      notifyListeners();
    }
  }
}

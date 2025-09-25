import 'package:flutter/foundation.dart';
import '../models/game_models.dart';

class GameController extends ChangeNotifier {
  Board board = emptyBoard();
  bool started = false;
  bool over = false;

  void start() {
    started = true;
    notifyListeners();
  }

  void reset() {
    board = emptyBoard();
    started = false;
    over = false;
    notifyListeners();
  }
}

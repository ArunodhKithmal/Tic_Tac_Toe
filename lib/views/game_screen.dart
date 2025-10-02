import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/game_models.dart';
import '../widgets/board_grid.dart';
import '../widgets/stats_card.dart';
import '../widgets/pill_label.dart';
import '../widgets/pill_button.dart';

import 'victory_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  void _openVictory(BuildContext context, GameController c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VictoryScreen(
          isMultiplayer: c.mode == GameMode.multiplayer,
          winnerText: c.resultText,
          // Match monolithic logic: trophy if player win, sad if lose, handshake if draw.
          isPlayerWin:
              c.mode != GameMode.multiplayer &&
              c.resultText.contains('Congratulations'),
          isDraw: c.resultText.contains("tie"),
          wins: c.stats.wins,
          losses: c.stats.losses,
          draws: c.stats.draws,
        ),
      ),
    );
  }

  Future<void> _handleInGameBack(BuildContext context, GameController c) async {
    if (!c.started) {
      await _chooseGameMode(context, c);
      return;
    }

    if (c.mode != GameMode.multiplayer) {
      final savedMode = c.mode!;
      c.reset();

      final who = await _chooseFirstPlayer(context, savedMode, c);
      if (who != null) {
        c.startSingle(savedMode, computerFirst: who == _First.computer);
        return;
      }

      final gm = await _chooseDifficultyMode(context, c);
      if (gm != null) {
        final who2 = await _chooseFirstPlayer(context, gm, c);
        if (who2 != null) {
          c.startSingle(gm, computerFirst: who2 == _First.computer);
          return;
        }
      }

      await _chooseGameMode(context, c);
      return;
    }

    final p1 = c.p1, p2 = c.p2;
    c.reset();

    final first = await _chooseFirstPlayerMulti(context, p1, p2);
    if (first != null) {
      c.startMulti(firstName: p1, secondName: p2, firstTurnName: first);
      return;
    }

    final names = await _enterPlayerNames(context);
    if (names != null) {
      final first2 = await _chooseFirstPlayerMulti(context, names.$1, names.$2);
      if (first2 != null) {
        c.startMulti(
          firstName: names.$1,
          secondName: names.$2,
          firstTurnName: first2,
        );
        return;
      }
    }

    await _chooseGameMode(context, c);
  }

  // === DIALOG FLOWS (match original UX) ===
  Future<void> _chooseGameMode(BuildContext context, GameController c) async {
    if (c.started) c.reset();
    final mode = await showDialog<_ChosenMode>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            // === Main content ===
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Mode',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Choose a game mode'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, const _ChosenMode.single()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            217,
                            228,
                            240,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Single Player',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, const _ChosenMode.multi()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            217,
                            228,
                            240,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Multiplayer',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // === Fancy Back button top-left ===
            Positioned(
              top: 8,
              left: 8,
              child: InkWell(
                onTap: () {
                  c.reset();
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).popUntil((route) => route.isFirst);
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade100.withOpacity(0.8),
                    border: Border.all(
                      color: Colors.blueGrey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black87,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (mode == null) return;

    if (mode.isSingle) {
      // ── single-player sub-flow: Difficulty -> Who First -> Start ────────────
      while (true) {
        final gm = await _chooseDifficultyMode(context, c);
        if (gm == null) {
          // Back from Difficulty -> go back to Mode selection
          return _chooseGameMode(context, c);
        }

        final who = await _chooseFirstPlayer(context, gm, c);
        if (who == null) {
          // Back from Who First -> re-ask Difficulty
          continue;
        }

        c.startSingle(gm, computerFirst: who == _First.computer);
        return;
      }
    } else {
      // ── multiplayer sub-flow (optional loop for Back behavior) ──────────────
      while (true) {
        final names = await _enterPlayerNames(context);
        if (names == null) {
          Future.microtask(() => _chooseGameMode(context, c));
          return;
        }

        final first = await _chooseFirstPlayerMulti(
          context,
          names.$1,
          names.$2,
        );
        if (first == null) {
          // Back from Who First (multi) -> re-ask names
          continue;
        }

        c.startMulti(
          firstName: names.$1,
          secondName: names.$2,
          firstTurnName: first,
        );
        return;
      }
    }
  }

  Future<GameMode?> _chooseDifficultyMode(
    BuildContext context,
    GameController c,
  ) async {
    return showDialog<GameMode>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            // === Main content ===
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Difficulty',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Choose Easy, Medium or Hard mode'),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, GameMode.singleEasy),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            217,
                            228,
                            240,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Easy',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, GameMode.singleMedium),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            217,
                            228,
                            240,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Medium',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, GameMode.singleHard),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            217,
                            228,
                            240,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Hard',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // === Top-left Back button: go back to Mode Selection ===
            Positioned(
              top: 8,
              left: 8,
              child: InkWell(
                onTap: () {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pop(null); // ← only close
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade100.withOpacity(0.8),
                    border: Border.all(
                      color: Colors.blueGrey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black87,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<_First?> _chooseFirstPlayer(
    BuildContext context,
    GameMode gm,
    GameController c,
  ) async {
    return showDialog<_First>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            // === Main content ===
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Who Goes First?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, _First.player),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            217,
                            228,
                            240,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Player First',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, _First.computer),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            217,
                            228,
                            240,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Computer First',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // === Fancy Back button (top-left): go back to Difficulty selection ===
            Positioned(
              top: 8,
              left: 8,
              child: InkWell(
                onTap: () {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pop(null); // ← only close
                },

                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade100.withOpacity(0.8),
                    border: Border.all(
                      color: Colors.blueGrey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black87,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<(String, String)?> _enterPlayerNames(BuildContext context) async {
    String p1 = '';
    String p2 = '';

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            // === Main content ===
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter Player Names',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'First Player Name',
                    ),
                    onChanged: (v) => p1 = v.trim(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Second Player Name',
                    ),
                    onChanged: (v) => p2 = v.trim(),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          217,
                          228,
                          240,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // === Top-left Back button -> return null ===
            Positioned(
              top: 8,
              left: 8,
              child: InkWell(
                onTap: () {
                  // Signal "Back" by returning null
                  Navigator.of(context, rootNavigator: true).pop(null);
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade100.withOpacity(0.8),
                    border: Border.all(
                      color: Colors.blueGrey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black87,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (ok != true || p1.isEmpty || p2.isEmpty) return null;
    return (p1, p2);
  }

  Future<String?> _chooseFirstPlayerMulti(
    BuildContext context,
    String p1,
    String p2,
  ) async {
    return showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            // === Main content ===
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Who Goes First?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, p1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            217,
                            228,
                            240,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        child: Text(
                          '$p1 First',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, p2),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            217,
                            228,
                            240,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        child: Text(
                          '$p2 First',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // === Top-left Back button: go back to Enter Player Names ===
            Positioned(
              top: 8,
              left: 8,
              child: InkWell(
                onTap: () {
                  // return null so the caller knows we hit Back
                  Navigator.of(context, rootNavigator: true).pop(null);
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade100.withOpacity(0.8),
                    border: Border.all(
                      color: Colors.blueGrey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black87,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<GameController>();

    // open victory screen when a game just ended
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (c.started && c.over) _openVictory(context, c);
    });

    String headerLabel() {
      if (!c.started || c.over) return '';
      if (c.mode == GameMode.multiplayer) {
        return '${c.p1} (X)  VS  ${c.p2} (O)';
      }
      return switch (c.mode!) {
        GameMode.singleEasy => 'Single Player - Easy Mode',
        GameMode.singleMedium => 'Single Player - Medium Mode',
        GameMode.singleHard => 'Single Player - Hard Mode',
        _ => '',
      };
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: const Color.fromARGB(255, 12, 44, 70),
        centerTitle: true,
        title: const Text(
          'Tic Tac Toe',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 35,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/Background.jpg',
            fit: BoxFit.cover,
            repeat: ImageRepeat.repeat,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(),
            child: Container(
              color: Colors.black.withAlpha((0.2 * 255).toInt()),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (c.started && !c.over)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 6),
                      child: PillLabel(headerLabel()),
                    ),

                  if (c.started && c.mode != GameMode.multiplayer)
                    StatsCard(
                      wins: c.stats.wins,
                      losses: c.stats.losses,
                      draws: c.stats.draws,
                      margin: const EdgeInsets.symmetric(
                        vertical: 6.0,
                        horizontal: 20.0,
                      ),
                    ),

                  // Board with identical styling + pre-start snackbar
                  Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 24.0,
                    ), // tighter
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color.fromARGB(255, 59, 83, 128),
                        width: 4.0,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: BoardGrid(
                      board: c.board,
                      onTap: (i) {
                        if (!c.started) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please start the game and select a game mode to start playing.',
                              ),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        c.tapCell(i);
                      },
                    ),
                  ),
                  // show Back + Undo ONLY while a game is in progress
                  // Show either (Back + Undo) during play OR the result section after finish
                  // Show either (Back + Undo) during play OR the result section after finish
                  if (c.started)
                    c.over
                        // === GAME FINISHED: show message + score card on this screen ===
                        ? Column(
                            children: [
                              Text(
                                c.resultText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 40, 60, 90),
                                  fontFamily: 'PlayfairDisplay',
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                          )
                        // === GAME IN PROGRESS: Back + Undo row ===
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 30,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                PillButton(
                                  text: 'Back',
                                  icon: Icons.arrow_back,
                                  onPressed: () => _handleInGameBack(
                                    context,
                                    context.read<GameController>(),
                                  ),
                                ),

                                PillButton(
                                  text: 'Undo',
                                  icon: Icons.undo,
                                  onPressed: c.history.isNotEmpty
                                      ? c.undo
                                      : null,
                                  enabled: c.history.isNotEmpty,
                                ),
                              ],
                            ),
                          ),

                  if (c.over && c.history.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      child: PillButton(
                        text: 'Play Again',
                        icon: Icons.replay,
                        onPressed: c.reset,
                      ),
                    ),

                  // === Start Game button (exact same look) ===
                  if (!c.started)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 30,
                      ),
                      child: PillButton(
                        text: 'Start Game',
                        icon: Icons.play_arrow,
                        onPressed: () => _chooseGameMode(context, c),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChosenMode {
  final bool isSingle;
  const _ChosenMode.single() : isSingle = true;
  const _ChosenMode.multi() : isSingle = false;
}

enum _First { player, computer }

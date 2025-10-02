import 'package:flutter/material.dart';
import 'package:tic_tac_toe/widgets/stats_card.dart';

class VictoryScreen extends StatelessWidget {
  final bool isMultiplayer;
  final String winnerText;
  final bool isPlayerWin; // used only in single-player
  final bool isDraw;
  final int wins, losses, draws;

  const VictoryScreen({
    super.key,
    required this.isMultiplayer,
    required this.winnerText,
    required this.isPlayerWin,
    required this.isDraw,
    required this.wins,
    required this.losses,
    required this.draws,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    if (isDraw) {
      icon = Icons.handshake;
    } else if (isMultiplayer) {
      icon = Icons.emoji_events; // show trophy irrespective of who won
    } else {
      icon = isPlayerWin
          ? Icons.emoji_events
          : Icons.sentiment_very_dissatisfied;
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(217, 12, 44, 70),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 100,
              color: isDraw ? Colors.orangeAccent : Colors.amberAccent,
            ),
            const SizedBox(height: 20),
            Text(
              isDraw ? "🤝 It's a draw!\nWell played both!" : winnerText,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (!isMultiplayer)
              StatsCard(
                wins: wins,
                losses: losses,
                draws: draws,
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 20.0,
                ),
              ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 185, 201, 231),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'Back to Game',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

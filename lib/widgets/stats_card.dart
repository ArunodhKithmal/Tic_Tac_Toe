// lib/widgets/stats_card.dart
import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final int wins;
  final int losses;
  final int draws;
  final EdgeInsetsGeometry? margin;

  const StatsCard({
    super.key,
    required this.wins,
    required this.losses,
    required this.draws,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          margin ?? const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF3B5380), // same navy as dialog buttons
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.85), width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Text(
        'Wins: $wins   |   Losses: $losses   |   Draws: $draws',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Calibri',
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

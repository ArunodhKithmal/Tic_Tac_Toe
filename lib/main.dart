import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/game_controller.dart';
import 'views/landing_screen.dart';

void main() {
  runApp(const NoughtsAndCrosses());
}

class NoughtsAndCrosses extends StatelessWidget {
  const NoughtsAndCrosses({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameController(),
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.teal,
          fontFamily: 'PlayfairDisplay',
        ),
        home: const LandingScreen(),
      ),
    );
  }
}

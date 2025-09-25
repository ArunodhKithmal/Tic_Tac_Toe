import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Tic Tac Toe — Landing', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

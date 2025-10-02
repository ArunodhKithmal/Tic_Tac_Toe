import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color navy = Color(0xFF3B5380);
  static const Color navyDisabled = Color.fromARGB(90, 59, 83, 128);
  static const Color navyBg = Color.fromARGB(255, 59, 83, 128);

  // Borders
  static Border appWhiteBorder([double w = 2]) =>
      Border.all(color: Colors.white.withOpacity(.9), width: w);

  // Common shadows
  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
  ];
}

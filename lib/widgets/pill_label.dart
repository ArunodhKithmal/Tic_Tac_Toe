import 'package:flutter/material.dart';
import '../ui/app_theme.dart';

class PillLabel extends StatelessWidget {
  final String text;
  final EdgeInsets padding;
  const PillLabel(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(18),
        border: AppTheme.appWhiteBorder(),
        boxShadow: AppTheme.softShadow,
      ),
      child: Padding(
        padding: padding,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

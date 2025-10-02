import 'package:flutter/material.dart';
import '../ui/app_theme.dart';

class PillButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool enabled;
  final EdgeInsets? padding;
  final double minWidth;

  const PillButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.enabled = true,
    this.padding,
    this.minWidth = 140,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth),
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: .2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.navyBg,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.navyDisabled,
          disabledForegroundColor: Colors.white70,
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          elevation: 8,
          shadowColor: Colors.black38,
          shape: const StadiumBorder(),
          side: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}

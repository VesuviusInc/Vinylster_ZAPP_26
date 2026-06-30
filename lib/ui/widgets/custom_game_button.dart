import 'package:flutter/material.dart';

class CustomGameButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final EdgeInsets? margin;
  final TextStyle? textStyle;
  final Color? buttonColor;

  const CustomGameButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.margin,
    this.textStyle,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.all(16),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: buttonColor ?? Colors.grey.shade400.withAlpha(150),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: textStyle?.color ?? Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(text, style: textStyle),
          ],
        ),
      ),
    );
  }
}
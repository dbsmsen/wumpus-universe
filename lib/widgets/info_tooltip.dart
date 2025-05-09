import 'package:flutter/material.dart';

class InfoTooltip extends StatelessWidget {
  final String message;
  final Widget child;

  const InfoTooltip({
    super.key,
    required this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      preferBelow: true,
      verticalOffset: 20,
      child: child,
    );
  }
}

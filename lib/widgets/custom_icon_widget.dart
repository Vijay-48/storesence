import 'package:flutter/material.dart';

class CustomIconWidget extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final VoidCallback? onTap;

  const CustomIconWidget({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: size ?? 24, color: color);

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(padding: const EdgeInsets.all(8.0), child: iconWidget),
      );
    }

    return iconWidget;
  }
}

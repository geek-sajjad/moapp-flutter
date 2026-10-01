import 'package:flutter/material.dart';

/// Circle avatar with the first letter of the customer's name.
class CustomerAvatar extends StatelessWidget {
  final String name;
  final bool muted;
  final double radius;

  const CustomerAvatar({
    super.key,
    required this.name,
    this.muted = false,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed.characters.first;
    return CircleAvatar(
      radius: radius,
      backgroundColor:
          muted ? scheme.surfaceContainerHighest : scheme.primaryContainer,
      foregroundColor:
          muted ? scheme.onSurfaceVariant : scheme.onPrimaryContainer,
      child: Text(
        initial,
        style: TextStyle(fontSize: radius * 0.85, fontWeight: FontWeight.w700),
      ),
    );
  }
}

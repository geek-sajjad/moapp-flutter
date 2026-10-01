import 'package:flutter/material.dart';

/// Port of the web `animate-fade-in-down` / `animate-slide-up` /
/// `animate-fade-in-scale` utilities. Plays once when first built.
enum EntryAnimationType { fadeInDown, slideUp, fadeInScale }

class EntryAnimation extends StatelessWidget {
  final Widget child;
  final EntryAnimationType type;
  final Duration duration;

  const EntryAnimation({
    super.key,
    required this.child,
    this.type = EntryAnimationType.slideUp,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeInOut,
      child: child,
      builder: (context, t, child) {
        final transformed = switch (type) {
          EntryAnimationType.fadeInDown => Transform.translate(
              offset: Offset(0, -12 * (1 - t)),
              child: child,
            ),
          EntryAnimationType.slideUp => Transform.translate(
              offset: Offset(0, 12 * (1 - t)),
              child: child,
            ),
          EntryAnimationType.fadeInScale => Transform.scale(
              scale: 0.95 + 0.05 * t,
              child: child,
            ),
        };
        return Opacity(opacity: t, child: transformed);
      },
    );
  }
}

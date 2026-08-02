import 'package:flutter/material.dart';

/// A slice of [controller]'s timeline, so different elements on the same
/// screen can start/finish their entrance animation at different moments
/// (a staggered reveal) instead of all animating in lockstep.
Animation<double> staggerInterval(
  AnimationController controller,
  double start,
  double end, {
  Curve curve = Curves.easeOutCubic,
}) {
  return CurvedAnimation(
    parent: controller,
    curve: Interval(start, end, curve: curve),
  );
}

/// Fades and slides [child] up into place as [animation] runs from 0 to 1.
/// Pair with [staggerInterval] to reveal a group of elements one after
/// another rather than all at once.
class FadeSlideIn extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final double offsetY;

  const FadeSlideIn({
    super.key,
    required this.animation,
    required this.child,
    this.offsetY = 18,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, offsetY * (1 - animation.value)),
            child: child,
          ),
        );
      },
    );
  }
}

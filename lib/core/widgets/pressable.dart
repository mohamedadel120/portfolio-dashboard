import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Scales its child to 0.97 while pressed (150ms, strong ease-out) and
/// reports hover only for mouse pointers. Honours reduced motion.
class Pressable extends StatefulWidget {
  final Widget Function(BuildContext context, bool hovered) builder;
  final VoidCallback? onTap;
  final MouseCursor? cursor;
  final double pressedScale;
  final String? semanticLabel;

  const Pressable({
    super.key,
    required this.builder,
    this.onTap,
    this.cursor,
    this.pressedScale = 0.97,
    this.semanticLabel,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hovered = false;
  bool _pressed = false;

  bool get _enabled => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    final scale = (_pressed && _enabled && !reduced) ? widget.pressedScale : 1.0;

    Widget child = MouseRegion(
      cursor: widget.cursor ??
          (_enabled ? SystemMouseCursors.click : SystemMouseCursors.basic),
      // MouseRegion only receives hover from devices that can hover, so
      // touch screens never get a stuck hover state.
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: AppMotion.fast,
          curve: AppMotion.ease,
          child: widget.builder(context, _hovered && _enabled),
        ),
      ),
    );

    if (widget.semanticLabel != null) {
      child = Semantics(
        button: true,
        enabled: _enabled,
        label: widget.semanticLabel,
        child: child,
      );
    }
    return child;
  }
}

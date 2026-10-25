import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

/// Scales its child to 0.97 while pressed (150ms, strong ease-out) and
/// reports hover only for mouse pointers. Honours reduced motion.
///
/// Keyboard: Tab reaches it, Enter or Space runs [onTap], and a 2px teal
/// ring shows while it has keyboard focus (not after a mouse click).
class Pressable extends StatefulWidget {
  final Widget Function(BuildContext context, bool hovered) builder;
  final VoidCallback? onTap;
  final MouseCursor? cursor;
  final double pressedScale;
  final String? semanticLabel;

  /// Corner radius of the focus ring; use a large value for round things.
  final double focusRadius;

  /// For on/off controls: read out as "on" or "off" by screen readers.
  final bool? toggled;

  const Pressable({
    super.key,
    required this.builder,
    this.onTap,
    this.cursor,
    this.pressedScale = 0.97,
    this.semanticLabel,
    this.focusRadius = 10,
    this.toggled,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hovered = false;
  bool _pressed = false;
  bool _keyboardFocus = false;
  final _focusNode = FocusNode();

  bool get _enabled => widget.onTap != null;

  // The ring belongs to the control that has focus itself, not to a card
  // whose Edit button inside has it.
  bool get _focused => _keyboardFocus && _focusNode.hasPrimaryFocus;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  // Flutter's default web shortcuts only activate with Space; buttons on
  // the web also answer to Enter.
  static const _shortcuts = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
  };

  late final Map<Type, Action<Intent>> _actions = {
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
      widget.onTap?.call();
      return null;
    }),
  };

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    final scale = (_pressed && _enabled && !reduced) ? widget.pressedScale : 1.0;

    Widget child = FocusableActionDetector(
      enabled: _enabled,
      focusNode: _focusNode,
      shortcuts: _shortcuts,
      actions: _actions,
      mouseCursor: widget.cursor ??
          (_enabled ? SystemMouseCursors.click : SystemMouseCursors.basic),
      // Hover only comes from devices that can hover, so touch screens
      // never get a stuck hover state.
      onShowHoverHighlight: (v) => setState(() {
        _hovered = v;
        if (!v) _pressed = false;
      }),
      // True only when focus came from the keyboard.
      onShowFocusHighlight: (v) => setState(() => _keyboardFocus = v),
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
          // Always painted, only the colour changes: dropping the layer would
          // rebuild everything inside, and a card would lose its focused
          // Edit button.
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              border: Border.all(color: _focused ? AppColors.primary : Colors.transparent, width: 2),
              borderRadius: BorderRadius.circular(widget.focusRadius),
            ),
            child: widget.builder(context, _hovered && _enabled),
          ),
        ),
      ),
    );

    if (widget.semanticLabel != null || widget.toggled != null) {
      child = Semantics(
        button: widget.toggled == null,
        enabled: _enabled,
        toggled: widget.toggled,
        label: widget.semanticLabel,
        child: child,
      );
    }
    return child;
  }
}

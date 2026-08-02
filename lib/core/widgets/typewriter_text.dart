import 'dart:async';
import 'package:flutter/material.dart';

/// One-shot typewriter reveal of [text] followed by a blinking cursor.
/// Doesn't loop — intended for content the user sees once, not something
/// sat on screen indefinitely, where a repeating animation would distract.
class Typewriter extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration speed;

  const Typewriter({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 45),
  });

  @override
  State<Typewriter> createState() => _TypewriterState();
}

class _TypewriterState extends State<Typewriter> {
  String _displayed = '';
  bool _showCursor = true;
  Timer? _typeTimer;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _startTyping();
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() => _showCursor = !_showCursor);
    });
  }

  void _startTyping() {
    var index = 0;
    _typeTimer = Timer.periodic(widget.speed, (timer) {
      if (index >= widget.text.length) {
        timer.cancel();
        return;
      }
      setState(() => _displayed += widget.text[index]);
      index++;
    });
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.style?.color ?? Colors.white;
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: widget.style,
        children: [
          TextSpan(text: _displayed),
          TextSpan(
            text: '|',
            style: TextStyle(color: color.withValues(alpha: _showCursor ? 1 : 0)),
          ),
        ],
      ),
    );
  }
}

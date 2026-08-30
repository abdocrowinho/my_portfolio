// Types a developer-style introduction with a blinking terminal cursor.
import 'dart:async';

import 'package:abdelrhman_protfolio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TerminalTypewriter extends StatefulWidget {
  const TerminalTypewriter({required this.text, super.key});
  final String text;
  @override
  State<TerminalTypewriter> createState() => _TerminalTypewriterState();
}

class _TerminalTypewriterState extends State<TerminalTypewriter> {
  Timer? _timer;
  int _visibleCharacters = 0;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 34), (timer) {
      if (_visibleCharacters >= widget.text.length) { timer.cancel(); } else { setState(() => _visibleCharacters++); }
    });
  }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) => RichText(
    text: TextSpan(
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontFamily: 'monospace', color: AppColors.accent),
      children: [
        TextSpan(text: widget.text.substring(0, _visibleCharacters)),
        const WidgetSpan(alignment: PlaceholderAlignment.middle, child: _BlinkingCursor()),
      ],
    ),
  );
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 550))..repeat(reverse: true);
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(opacity: _controller, child: Container(width: 8, height: 18, margin: const EdgeInsets.only(left: 4), color: AppColors.accent));
}

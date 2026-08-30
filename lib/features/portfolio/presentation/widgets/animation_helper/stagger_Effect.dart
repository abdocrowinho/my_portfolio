// lib/core/widgets/stagger_reveal.dart
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

enum StaggerEffect {
  fadeUp,
  fadeLeft,
  fadeRight,
  scaleFade,
  alternateSides,
  tiltAlternate, // fade + slight rotation, alternating left/right
}

class StaggerReveal extends StatefulWidget {
  const StaggerReveal({
    required this.children,
    required this.builder,
    this.effect = StaggerEffect.fadeUp,
    this.itemDelay = const Duration(milliseconds: 80),
    this.duration = const Duration(milliseconds: 500),
    this.distance = 24,
    this.visibleThreshold = 0.15,
    super.key,
  });

  final List<Widget> children;
  final Widget Function(BuildContext context, List<Widget> animatedChildren)
  builder;
  final StaggerEffect effect;
  final Duration itemDelay;
  final Duration duration;
  final double distance;
  final double visibleThreshold;

  @override
  State<StaggerReveal> createState() => _StaggerRevealState();
}

class _StaggerRevealState extends State<StaggerReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;

  int get _totalMs =>
      widget.duration.inMilliseconds +
          widget.itemDelay.inMilliseconds * widget.children.length;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _totalMs),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    if (_started) return;
    _started = true;
    _controller.forward();
  }

  Animation<double> _intervalFor(int index) {
    final startMs = widget.itemDelay.inMilliseconds * index;
    final endMs = startMs + widget.duration.inMilliseconds;
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(
        (startMs / _totalMs).clamp(0.0, 1.0),
        (endMs / _totalMs).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  Widget _animate(int index, Widget child) {
    final animation = _intervalFor(index);
    return AnimatedBuilder(
      animation: animation,
      builder: (_, c) {
        final t = animation.value;
        final isEven = index.isEven;
        var effect = widget.effect;
        if (effect == StaggerEffect.alternateSides) {
          effect = isEven ? StaggerEffect.fadeLeft : StaggerEffect.fadeRight;
        }

        var offset = Offset.zero;
        var scale = 1.0;
        var rotation = 0.0;

        switch (effect) {
          case StaggerEffect.fadeUp:
            offset = Offset(0, widget.distance * (1 - t));
          case StaggerEffect.fadeLeft:
            offset = Offset(-widget.distance * (1 - t), 0);
          case StaggerEffect.fadeRight:
            offset = Offset(widget.distance * (1 - t), 0);
          case StaggerEffect.scaleFade:
            scale = 0.85 + (0.15 * t);
          case StaggerEffect.tiltAlternate:
            offset = Offset(0, widget.distance * 0.6 * (1 - t));
            scale = 0.92 + (0.08 * t);
            rotation = (isEven ? -0.06 : 0.06) * (1 - t);
          case StaggerEffect.alternateSides:
            break; // resolved above
        }

        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: offset,
            child: Transform.rotate(
              angle: rotation,
              child: Transform.scale(scale: scale, child: c),
            ),
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) => VisibilityDetector(
    key: ValueKey('stagger-reveal-${widget.hashCode}'),
    onVisibilityChanged: (info) {
      if (info.visibleFraction > widget.visibleThreshold) _start();
    },
    child: widget.builder(
      context,
      List.generate(
        widget.children.length,
            (i) => _animate(i, widget.children[i]),
      ),
    ),
  );
}
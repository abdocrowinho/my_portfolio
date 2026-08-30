// Reveals a section once it approaches the viewport during portfolio scrolling.
import 'package:flutter/material.dart';

enum ScrollRevealVariant { fadeUp, slideFromRight, slideFromLeft, scaleIn, tiltIn }

class ScrollReveal extends StatefulWidget {
  const ScrollReveal({
    required this.scrollController,
    required this.child,
    this.delay = Duration.zero,
    this.variant = ScrollRevealVariant.fadeUp,
    super.key,
  });

  final ScrollController scrollController;
  final Widget child;
  final Duration delay;
  final ScrollRevealVariant variant;

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
    value: 1,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    final progress = animation.value;
    final transform = switch (widget.variant) {
      ScrollRevealVariant.fadeUp => Matrix4.translationValues(0, 82 * (1 - progress), 0),
      ScrollRevealVariant.slideFromRight => Matrix4.translationValues(130 * (1 - progress), 0, 0),
      ScrollRevealVariant.slideFromLeft => Matrix4.translationValues(-130 * (1 - progress), 0, 0),
      ScrollRevealVariant.scaleIn => Matrix4.diagonal3Values(.82 + (.18 * progress), .82 + (.18 * progress), 1),
      ScrollRevealVariant.tiltIn => Matrix4.identity()..translate(0.0, 68 * (1 - progress))..rotateZ(.07 * (1 - progress)),
    };
    return Opacity(opacity: progress, child: Transform(transform: transform, alignment: Alignment.center, child: widget.child));
  }
}

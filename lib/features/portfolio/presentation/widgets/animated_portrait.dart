// Presents the developer portrait with restrained motion that adds life to the hero.
import 'package:abdelrhman_protfolio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AnimatedPortrait extends StatefulWidget {
  const AnimatedPortrait({super.key});

  @override
  State<AnimatedPortrait> createState() => _AnimatedPortraitState();
}

class _AnimatedPortraitState extends State<AnimatedPortrait>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (_, child) {
      final progress = Curves.easeInOut.transform(_controller.value);
      return Transform.translate(
        offset: Offset(0, -8 * progress),
        child: Transform.rotate(
          angle: -0.018 + (0.036 * progress),
          child: child,
        ),
      );
    },
    child: const _PortraitFrame(),
  );
}

class _PortraitFrame extends StatelessWidget {
  const _PortraitFrame();

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: 300,
        height: 300,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [
              AppColors.accent,
              AppColors.accentDark,
              AppColors.surfaceLight,
              AppColors.accent,
            ],
          ),
        ),
      ),
      Container(
        width: 282,
        height: 282,
        decoration: const BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
      ),
      ClipOval(
        child: Image.asset(
          'assets/images/abdelrahman_portrait.png',
          width: 268,
          height: 268,
          fit: BoxFit.cover,
          alignment: const Alignment(0.12, -0.3),
        ),
      ),
      const Positioned(right: 8, bottom: 28, child: _StatusDot()),
    ],
  );
}

class _StatusDot extends StatelessWidget {
  const _StatusDot();

  @override
  Widget build(BuildContext context) => Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: AppColors.accent,
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.background, width: 5),
    ),
    child: const Icon(
      Icons.code_rounded,
      size: 15,
      color: AppColors.background,
    ),
  );
}

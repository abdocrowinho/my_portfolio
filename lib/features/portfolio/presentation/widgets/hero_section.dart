// lib/features/portfolio/presentation/widgets/hero_section.dart
import 'package:abdelrhman_protfolio/core/responsive/responsive_layout.dart';
import 'package:abdelrhman_protfolio/core/theme/app_colors.dart';
import 'package:abdelrhman_protfolio/core/utils/cv_downloader.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/content/portfolio_content.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/widgets/animated_portrait.dart';
import 'package:abdelrhman_protfolio/core/widgets/terminal_typewriter.dart';
import 'package:flutter/material.dart';

import 'animation_helper/stagger_Effect.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    required this.onViewProjects,
    required this.onContact,
    super.key,
  });

  final VoidCallback onViewProjects;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context)
        .textTheme
        .displayLarge
        ?.copyWith(fontSize: context.isDesktop ? 64 : 46);

    final introduction = StaggerReveal(
      effect: StaggerEffect.fadeUp,
      itemDelay: const Duration(milliseconds: 100),
      duration: const Duration(milliseconds: 450),
      distance: 20,
      children: [
        const _AvailabilityBadge(),
        Text('Abdelrhman\nOsama.', style: titleStyle),
        const Text('Android Developer · Kotlin · Jetpack Compose'),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: TerminalTypewriter(
            text:
            '${PortfolioContent.title}. '
                'I turn complex product ideas into reliable, thoughtful experiences.',
          ),
        ),
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: onViewProjects,
              icon: const Icon(Icons.arrow_downward_rounded),
              label: const Text('Explore my work'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
              ),
            ),
            TextButton(
              onPressed: onContact,
              child: const Text('Start a conversation'),
            ),
            OutlinedButton.icon(
              onPressed: downloadCv,
              icon: const Icon(Icons.download_rounded),
              label: const Text('Download CV'),
            ),
          ],
        ),
        const Wrap(
          spacing: 20,
          runSpacing: 12,
          children: [
            _FocusLabel('Kotlin'),
            _FocusLabel('Compose'),
            _FocusLabel('MVI'),
            _FocusLabel('Real-time systems'),
          ],
        ),
      ],
      builder: (context, animated) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          animated[0],
          const SizedBox(height: 28),
          animated[1],
          const SizedBox(height: 20),
          animated[2],
          const SizedBox(height: 16),
          animated[3],
          const SizedBox(height: 34),
          animated[4],
          const SizedBox(height: 64),
          animated[5],
        ],
      ),
    );

    final portrait = StaggerReveal(
      effect: StaggerEffect.scaleFade,
      duration: const Duration(milliseconds: 700),
      children: const [AnimatedPortrait()],
      builder: (context, animated) => animated.first,
    );

    return Padding(
      padding: EdgeInsets.only(top: context.isDesktop ? 112 : 64, bottom: 110),
      child: context.isDesktop
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: introduction),
          const SizedBox(width: 56),
          portrait,
        ],
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: portrait),
          const SizedBox(height: 48),
          introduction,
        ],
      ),
    );
  }

}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.surfaceLight,
      borderRadius: BorderRadius.all(Radius.circular(30)),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      child: Text(
        '●  Cairo, Egypt · Open to opportunities',
        style: TextStyle(color: AppColors.accent, fontSize: 13),
      ),
    ),
  );
}

class _FocusLabel extends StatelessWidget {
  const _FocusLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
    ),
  );
}

// Summarizes relevant professional experience without duplicating a full resume.
import 'package:abdelrhman_protfolio/core/theme/app_colors.dart';
import 'package:abdelrhman_protfolio/core/widgets/section_heading.dart';
import 'package:flutter/material.dart';

import 'animation_helper/stagger_Effect.dart';

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SectionHeading(
        title: 'Experience',
      ),
      const SizedBox(height: 28),
      StaggerReveal(
        effect: StaggerEffect.alternateSides,
        itemDelay: const Duration(milliseconds: 120),
        distance: 40,
        children: const [
          _ExperienceItem(
            role: 'DoDeal — Desktop CRM',
            company: 'Freelance · CMP, Kotlin, Ktor, MVI',
            period: '2026',
            description:
                'Native CRM for Windows and macOS from one Kotlin codebase, using Clean Architecture and MVI.',
          ),
          _ExperienceItem(
            role: 'Android Developer Trainee',
            company: 'Route IT Training Center',
            period: 'May 2024 — October 2024',
          ),
        ],
        builder: (context, animated) => Column(children: animated),
      ),
    ],
  );
}

class _ExperienceItem extends StatelessWidget {
  const _ExperienceItem({
    required this.role,
    required this.company,
    required this.period,
    this.description,
  });
  final String role;
  final String company;
  final String period;
  final String? description;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(role, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 7),
        Text('$company  ·  $period'),
        if (description case final value?) ...[
          const SizedBox(height: 10),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    ),
  );
}

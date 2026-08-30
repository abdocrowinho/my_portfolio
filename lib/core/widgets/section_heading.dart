// Renders a consistent eyebrow, title, and optional description for site sections.
import 'package:abdelrhman_protfolio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    required this.title,
    this.description,
    super.key,
  });

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),
      Text(title, style: Theme.of(context).textTheme.headlineMedium),

      SizedBox(height: 7),
      Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(10),
        )
      )
      ,

      if (description case final text?) ...[
        const SizedBox(height: 14),
        Text(text, style: Theme.of(context).textTheme.bodyLarge),
      ],
    ],
  );
}

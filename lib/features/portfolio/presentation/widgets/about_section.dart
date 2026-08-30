// Explains the developer's product and engineering approach in a concise form.
import 'package:abdelrhman_protfolio/core/widgets/section_heading.dart';
import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SectionHeading(
        title: 'About Me',
      ),
      const SizedBox(height: 24),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Text(
          'I am an Android developer focused on Kotlin and Jetpack Compose. I care about the whole product: resilient architecture, clear state, responsive interfaces, and the small interaction details that make software feel considered.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    ],
  );
}

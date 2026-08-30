// lib/features/portfolio/presentation/widgets/contact_section.dart

import 'package:abdelrhman_protfolio/core/theme/app_colors.dart';
import 'package:abdelrhman_protfolio/core/widgets/section_heading.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          title: 'Get In Touch',
          description:
          'Have a project, app idea, or mobile architecture challenge? Let’s connect and build something useful.',
        ),

        const SizedBox(height: 48),

        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 800;

            final information = const _ContactInformation();

            if (isMobile) {
              return information;
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: information,
                ),

                const SizedBox(width: 80),

                Expanded(
                  child: _ContactCard(),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ============================================================================
// CONTACT INFORMATION
// ============================================================================

class _ContactInformation extends StatelessWidget {
  const _ContactInformation();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 18),

        Text(
          'Have a project in mind? Feel free to reach out through any of the channels below.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .62),
            fontSize: 16,
            height: 1.55,
          ),
        ),

        const SizedBox(height: 35),

        const _ContactItem(
          icon: Icons.email_outlined,
          title: 'Email',
          value: 'abdelrhamnosama287@gmail.com',
        ),

        const SizedBox(height: 24),

        const _ContactItem(
          icon: Icons.phone_outlined,
          title: 'Phone',
          value: '01287019667',
        ),

        const SizedBox(height: 24),

        const _ContactItem(
          icon: Icons.location_on_outlined,
          title: 'Location',
          value: 'Egypt, Cairo, Maadi',
        ),

        const SizedBox(height: 40),

        const Text(
          'Connect with me',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 18),

        Row(
          children: [
            _SocialButton(
              label: 'GitHub',
              asset: 'assets/social/github.png',
              url: 'https://github.com/abdocrowinho',
              invert: true,
            ),
            const SizedBox(width: 12),
            _SocialButton(
              label: 'LinkedIn',
              asset: 'assets/social/linkedin.png',
              url: 'https://www.linkedin.com/in/abdelrahman-osama-mohamed/',
            ),
            const SizedBox(width: 12),
            _SocialButton(
              label: 'WhatsApp',
              asset: 'assets/social/whatsapp.png',
              url: 'https://wa.me/201287019667',
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// CONTACT ITEM
// ============================================================================

class _ContactItem extends StatelessWidget {
  const _ContactItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () async {
        if (title == 'Email') {
          await launchUrl(
            Uri.parse('mailto:abdelrhamnosama287@gmail.com'),
            mode: LaunchMode.externalApplication,
          );
        }

        if (title == 'Phone') {
          await launchUrl(
            Uri.parse('tel:01287019667'),
            mode: LaunchMode.externalApplication,
          );
        }

        if (title == 'Location') {
          await launchUrl(
            Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=Maadi,Cairo,Egypt',
            ),
            mode: LaunchMode.externalApplication,
          );
        }
      },

      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 3,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppColors.accent,
              size: 25,
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .62),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SOCIAL BUTTON
// ============================================================================
class _SocialButton extends StatefulWidget {
  const _SocialButton({
    required this.label,
    required this.asset,
    required this.url,
    this.invert = false,
  });

  final String label;
  final String asset;
  final String url;
  final bool invert;

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _hovered = false;

  Future<void> _open() async {
    await launchUrl(
      Uri.parse(widget.url),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() => _hovered = true);
        },
        onExit: (_) {
          setState(() => _hovered = false);
        },
        child: GestureDetector(
          onTap: _open,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(13),
            transform: Matrix4.identity()
              ..translate(
                0.0,
                _hovered ? -4.0 : 0.0,
              ),
            decoration: BoxDecoration(
              color: _hovered
                  ? AppColors.accent.withValues(alpha: 0.12)
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _hovered
                    ? AppColors.accent.withValues(alpha: 0.55)
                    : AppColors.border,
              ),
              boxShadow: _hovered
                  ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
                  : null,
            ),
            child: ColorFiltered(
              colorFilter: widget.invert
                  ? const ColorFilter.mode(
                AppColors.textPrimary,
                BlendMode.srcIn,
              )
                  : const ColorFilter.mode(
                Colors.transparent,
                BlendMode.srcOver,
              ),
              child: Image.asset(
                widget.asset,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// ============================================================================
// RIGHT CONTACT CARD
// ============================================================================

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 280,
      ),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.border,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.handshake_outlined,
              color: AppColors.accent,
              size: 29,
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Let’s work together.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Whether you have a new idea, need help with a mobile application, or want to discuss architecture and development, I’d be happy to hear from you.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .62),
              fontSize: 16,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 25),

          Text(
            'Available for new opportunities.',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
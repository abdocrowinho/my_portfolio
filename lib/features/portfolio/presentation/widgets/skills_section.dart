import 'package:abdelrhman_protfolio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  static const _categories = [
    _SkillCategory(
      title: 'MOBILE DEVELOPMENT',
      icon: Icons.phone_android_rounded,
      skills: [
        'Kotlin',
        'Jetpack Compose',
        'Flutter',
        'Dart',
        'Kotlin Multiplatform',
      ],
    ),
    _SkillCategory(
      title: 'ARCHITECTURE & PATTERNS',
      icon: Icons.layers_outlined,
      skills: [
        'Clean Architecture',
        'MVI',
        'MVVM',
        'SOLID',
        'OOP',
        'System Design',
        'Design Pattern',
      ],
    ),
    _SkillCategory(
      title: 'BACKEND & REAL-TIME',
      icon: Icons.storage_outlined,
      skills: [
        'REST APIs',
        'WebSockets',
        'Supabase',
        'Firebase',
      ],
    ),
    _SkillCategory(
      title: 'DATA & DATABASE',
      icon: Icons.data_object_rounded,
      skills: [
        'Room',
        'SQLflite',
      ],
    ),
    _SkillCategory(
      title: 'AI & DEVELOPMENT',
      icon: Icons.auto_awesome_outlined,
      skills: [
        'Prompt Engineering',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================================
        // TITLE
        // ============================================================

        Text(
          'Skills',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 42,
          ),
        ),

        const SizedBox(height: 7),

        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        const SizedBox(height: 20),

        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 800,
          ),
          child: Text(
            'A focused toolkit for building, integrating, shipping, and maintaining high-quality mobile applications.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: .62),
              height: 1.5,
              fontSize: 16,
            ),
          ),
        ),

        const SizedBox(height: 38),

        // ============================================================
        // GRID
        // ============================================================

        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final int columns;

            if (width >= 1050) {
              columns = 3;
            } else if (width >= 650) {
              columns = 2;
            } else {
              columns = 1;
            }

            const gap = 20.0;
            final cardWidth = (width - gap * (columns - 1)) / columns;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: List.generate(
                _categories.length,
                (index) => SizedBox(
                  width: cardWidth,
                  child: _AnimatedSkillCard(
                    category: _categories[index],
                    delay: Duration(milliseconds: 100 * index),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ============================================================================
// CATEGORY
// ============================================================================

class _SkillCategory {
  const _SkillCategory({
    required this.title,
    required this.icon,
    required this.skills,
  });

  final String title;
  final IconData icon;
  final List<String> skills;
}

// ============================================================================
// ANIMATED CARD
// ============================================================================

class _AnimatedSkillCard extends StatefulWidget {
  const _AnimatedSkillCard({
    required this.category,
    required this.delay,
  });

  final _SkillCategory category;
  final Duration delay;

  @override
  State<_AnimatedSkillCard> createState() =>
      _AnimatedSkillCardState();
}

class _AnimatedSkillCardState
    extends State<_AnimatedSkillCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fade;

  late final Animation<Offset> _slide;

  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 650,
      ),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, .12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _scale = Tween<double>(
      begin: .94,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scale,
          child: _SkillCard(
            category: widget.category,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CARD
// ============================================================================

class _SkillCard extends StatefulWidget {
  const _SkillCard({
    required this.category,
  });

  final _SkillCategory category;

  @override
  State<_SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<_SkillCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 480;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 220,
        ),
        curve: Curves.easeOut,

        padding: EdgeInsets.all(isNarrow ? 18 : 24),

        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.surface.withValues(alpha: .55)
              : Colors.transparent,

          border: Border.all(
            color: _hovered
                ? AppColors.accent.withValues(alpha: .45)
                : AppColors.border,
          ),

          borderRadius: BorderRadius.circular(16),

          boxShadow: _hovered
              ? [
            BoxShadow(
              color: AppColors.accent.withValues(
                alpha: .07,
              ),
              blurRadius: 25,
              spreadRadius: 1,
            ),
          ]
              : null,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================================
            // HEADER
            // ==========================================================

            Row(
              children: [
                AnimatedScale(
                  scale: _hovered ? 1.08 : 1,
                  duration: const Duration(
                    milliseconds: 220,
                  ),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(
                        alpha: .10,
                      ),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      widget.category.icon,
                      color: AppColors.accent,
                      size: 22,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    widget.category.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==========================================================
            // TAGS
            // ==========================================================

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.category.skills
                  .asMap()
                  .entries
                  .map(
                    (entry) => _AnimatedChip(
                      label: entry.value,
                      index: entry.key,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ANIMATED CHIP
// ============================================================================

class _AnimatedChip extends StatefulWidget {
  const _AnimatedChip({
    required this.label,
    required this.index,
  });

  final String label;
  final int index;

  @override
  State<_AnimatedChip> createState() => _AnimatedChipState();
}

class _AnimatedChipState
    extends State<_AnimatedChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 400,
      ),
    );

    Future.delayed(
      Duration(
        milliseconds: 250 + (widget.index * 45),
      ),
          () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
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

    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.border,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .88),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

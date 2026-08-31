import 'package:abdelrhman_protfolio/core/responsive/responsive_layout.dart';
import 'package:abdelrhman_protfolio/core/theme/app_colors.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectShowcase extends StatelessWidget {
  const ProjectShowcase({
    required this.project,
    required this.onOpen,
    super.key,
  });

  final PortfolioProject project;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final visibleTags = project.tags.take(5).toList();
    final hiddenTagCount = project.tags.length - visibleTags.length;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.border,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // IMAGE
          // ============================================================

          SizedBox(
            height: isDesktop ? 340 : 310,
            width: double.infinity,
            child: _ImageGallery(
              urls: project.imageUrls,
            ),
          ),

          // ============================================================
          // CONTENT
          // ============================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(
                    project.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final style = Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(
                            color: Colors.white.withValues(alpha: .68),
                            height: 1.55,
                          );
                      final isOverflowing = _isDescriptionOverflowing(
                        context,
                        style,
                        constraints.maxWidth,
                      );
                      final text = isOverflowing
                          ? _trimDescriptionForSeeMore(
                              context,
                              style,
                              constraints.maxWidth,
                            )
                          : project.description;
                      return SizedBox(
                        height: _threeLineHeight(context, style),
                        child: MouseRegion(
                          cursor: isOverflowing
                              ? SystemMouseCursors.click
                              : MouseCursor.defer,
                          child: GestureDetector(
                            onTap: isOverflowing
                                ? () => _showFullDescription(context)
                                : null,
                            child: Text.rich(
                              TextSpan(
                                style: style,
                                children: [
                                  TextSpan(text: text),
                                  if (isOverflowing)
                                    TextSpan(
                                      text: '… See more',
                                      style: style?.copyWith(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                ],
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                if (visibleTags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: visibleTags.map(_Tag.new).toList(),
                  ),

                if (hiddenTagCount > 0)
                  TextButton(
                    onPressed: () => _showAllTags(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      padding: const EdgeInsets.only(top: 6, bottom: 2),
                    ),
                    child: Text('See more ($hiddenTagCount)'),
                  ),

                if (project.tags.isNotEmpty) const SizedBox(height: 10),

                  // ======================================================
                  // GITHUB
                  // ======================================================

                if (project.repoUrl != null && project.repoUrl!.trim().isNotEmpty) ...[
                  OutlinedButton.icon(
                    onPressed: () => _openRepo(project.repoUrl!),
                    icon: const Icon(Icons.code_rounded, size: 19),
                    label: const Text('GitHub'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openRepo(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null) return;

    await launchUrl(
      uri,
      webOnlyWindowName: '_blank',
    );
  }

  void _showAllTags(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('${project.name} tags'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: project.tags.map(_Tag.new).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  bool _isDescriptionOverflowing(
    BuildContext context,
    TextStyle? style,
    double maxWidth,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: project.description, style: style),
      maxLines: 3,
      textDirection: Directionality.of(context),
    )..layout(maxWidth: maxWidth);
    return painter.didExceedMaxLines;
  }

  String _trimDescriptionForSeeMore(
    BuildContext context,
    TextStyle? style,
    double maxWidth,
  ) {
    const suffix = '… See more';
    var low = 0;
    var high = project.description.length;

    while (low < high) {
      final middle = (low + high + 1) ~/ 2;
      final candidate = '${project.description.substring(0, middle).trimRight()}$suffix';
      final painter = TextPainter(
        text: TextSpan(text: candidate, style: style),
        maxLines: 3,
        textDirection: Directionality.of(context),
      )..layout(maxWidth: maxWidth);
      if (painter.didExceedMaxLines) {
        high = middle - 1;
      } else {
        low = middle;
      }
    }
    return project.description.substring(0, low).trimRight();
  }

  double _threeLineHeight(BuildContext context, TextStyle? style) {
    final painter = TextPainter(
      text: TextSpan(text: 'A', style: style),
      textDirection: Directionality.of(context),
    )..layout();
    return painter.preferredLineHeight * 3;
  }

  void _showFullDescription(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(project.name),
        content: SingleChildScrollView(child: Text(project.description)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// IMAGE GALLERY
// ============================================================================

class _ImageGallery extends StatefulWidget {
  const _ImageGallery({
    required this.urls,
  });

  final List<String> urls;

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  late final PageController _controller;

  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (widget.urls.length <= 1) return;

    final next = (_index + 1) % widget.urls.length;

    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _previous() {
    if (widget.urls.length <= 1) return;

    final previous =
        (_index - 1 + widget.urls.length) % widget.urls.length;

    _controller.animateToPage(
      previous,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _openViewer(int initialIndex) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .94),
      builder: (_) {
        return _FullscreenGallery(
          urls: widget.urls,
          initialIndex: initialIndex,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.urls.isEmpty) {
      return const _EmptyImage();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // ================================================================
        // CROPPED IMAGE
        // ================================================================

        PageView.builder(
          controller: _controller,
          itemCount: widget.urls.length,
          onPageChanged: (value) {
            if (!mounted) return;

            setState(() {
              _index = value;
            });
          },
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _openViewer(index),
              child: Container(
                color: AppColors.accent,
                child: Image.network(
                  widget.urls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, __, ___) {
                    return const _EmptyImage();
                  },
                  loadingBuilder: (
                      context,
                      child,
                      progress,
                      ) {
                    if (progress == null) {
                      return child;
                    }

                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),

        // ================================================================
        // CLICK / ZOOM INDICATOR
        // ================================================================

        Positioned(
          right: 14,
          top: 14,
          child: IgnorePointer(
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xCC101827),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.zoom_in_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),
          ),
        ),

        // ================================================================
        // PREVIOUS
        // ================================================================

        if (widget.urls.length > 1)
          Positioned(
            left: 14,
            top: 0,
            bottom: 0,
            child: Center(
              child: _ArrowButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: _previous,
              ),
            ),
          ),

        // ================================================================
        // NEXT
        // ================================================================

        if (widget.urls.length > 1)
          Positioned(
            right: 14,
            top: 0,
            bottom: 0,
            child: Center(
              child: _ArrowButton(
                icon: Icons.arrow_forward_ios_rounded,
                onTap: _next,
              ),
            ),
          ),

        // ================================================================
        // COUNTER
        // ================================================================

        if (widget.urls.length > 1)
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xE6101827),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_index + 1} / ${widget.urls.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// FULLSCREEN IMAGE VIEWER
// ============================================================================

class _FullscreenGallery extends StatefulWidget {
  const _FullscreenGallery({
    required this.urls,
    required this.initialIndex,
  });

  final List<String> urls;
  final int initialIndex;

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late final PageController _controller;

  late int _index;

  @override
  void initState() {
    super.initState();

    _index = widget.initialIndex;

    _controller = PageController(
      initialPage: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (widget.urls.length <= 1) return;

    final next = (_index + 1) % widget.urls.length;

    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _previous() {
    if (widget.urls.length <= 1) return;

    final previous =
        (_index - 1 + widget.urls.length) % widget.urls.length;

    _controller.animateToPage(
      previous,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // ==============================================================
          // IMAGES
          // ==============================================================

          PageView.builder(
            controller: _controller,
            itemCount: widget.urls.length,
            onPageChanged: (value) {
              setState(() {
                _index = value;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Center(
                  child: Image.network(
                    widget.urls[index],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 60,
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // ==============================================================
          // CLOSE
          // ==============================================================

          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xCC101827),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(
                Icons.close_rounded,
              ),
            ),
          ),

          // ==============================================================
          // LEFT
          // ==============================================================

          if (widget.urls.length > 1)
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: _ArrowButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: _previous,
                ),
              ),
            ),

          // ==============================================================
          // RIGHT
          // ==============================================================

          if (widget.urls.length > 1)
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: _ArrowButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  onTap: _next,
                ),
              ),
            ),

          // ==============================================================
          // COUNTER
          // ==============================================================

          if (widget.urls.length > 1)
            Positioned(
              bottom: 25,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xE6101827),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_index + 1} / ${widget.urls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// ARROW BUTTON
// ============================================================================

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xE6101827),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: Colors.white,
            size: 17,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TAG
// ============================================================================

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1935),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.accent,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY IMAGE
// ============================================================================

class _EmptyImage extends StatelessWidget {
  const _EmptyImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.accent,
      alignment: Alignment.center,
      child: const Icon(
        Icons.photo_library_outlined,
        color: Colors.white70,
        size: 42,
      ),
    );
  }
}

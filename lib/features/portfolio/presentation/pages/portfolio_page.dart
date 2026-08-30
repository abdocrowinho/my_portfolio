// Composes the public portfolio beneath a fixed navigation bar with section reveal transitions.
import 'package:abdelrhman_protfolio/core/di/service_locator.dart';
import 'package:abdelrhman_protfolio/core/theme/app_colors.dart';
import 'package:abdelrhman_protfolio/core/widgets/responsive_container.dart';
import 'package:abdelrhman_protfolio/core/widgets/scroll_reveal.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/state/portfolio_intent.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/state/portfolio_state.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/state/portfolio_view_model.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/widgets/about_section.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/widgets/contact_section.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/widgets/experience_section.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/widgets/hero_section.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/widgets/portfolio_footer.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/widgets/portfolio_nav_bar.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/widgets/projects_section.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/widgets/skills_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/animation_helper/playful_mascot.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final _scrollController = ScrollController();
  final _sectionKeys = List.generate(6, (_) => GlobalKey());
  bool _isManagementMode = false;
  MascotSection _mascotSection = MascotSection.none;

  static const _mascotSectionMap = {
    0: MascotSection.hero,
    1: MascotSection.about,
    2: MascotSection.skills,
    3: MascotSection.projects,
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateMascotSection);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateMascotSection());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateMascotSection);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateMascotSection() {
    if (!mounted) return;
    final screenHeight = MediaQuery.of(context).size.height;
    var detected = MascotSection.none;
    for (final entry in _mascotSectionMap.entries) {
      final box =
      _sectionKeys[entry.key].currentContext?.findRenderObject()
      as RenderBox?;
      if (box == null || !box.attached) continue;
      final top = box.localToGlobal(Offset.zero).dy;
      final bottom = top + box.size.height;
      // Section counts as "active" while its band crosses the upper-middle
      // of the viewport — favors the lower matching section on overlap.
      if (top < screenHeight * 0.55 && bottom > screenHeight * 0.15) {
        detected = entry.value;
      }
    }
    if (detected != _mascotSection) setState(() => _mascotSection = detected);
  }

  void _scrollTo(int index) {
    final sectionContext = _sectionKeys[index].currentContext;
    if (sectionContext != null) {
      Scrollable.ensureVisible(
        sectionContext,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
        alignment: .06,
      );
    }
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
    serviceLocator<PortfolioViewModel>()..handle(const LoadProjects()),
    child: Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: ResponsiveContainer(
                child: Padding(
                  padding: const EdgeInsets.only(top: 86),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Section(
                        key: _sectionKeys[0],
                        controller: _scrollController,
                        variant: ScrollRevealVariant.scaleIn,
                        child: HeroSection(
                          onViewProjects: () => _scrollTo(3),
                          onContact: () => _scrollTo(5),
                        ),
                      ),
                      _Section(
                        key: _sectionKeys[1],
                        controller: _scrollController,
                        variant: ScrollRevealVariant.slideFromRight,
                        child: const AboutSection(),
                      ),
                      _Section(
                        key: _sectionKeys[2],
                        controller: _scrollController,
                        variant: ScrollRevealVariant.scaleIn,
                        child: const SkillsSection(),
                      ),
                      _Section(
                        key: _sectionKeys[3],
                        controller: _scrollController,
                        variant: ScrollRevealVariant.slideFromLeft,
                        child: BlocBuilder<PortfolioViewModel, PortfolioState>(
                          builder: (_, state) => ProjectsSection(
                            state: state,
                            isManagementMode: _isManagementMode,
                            onToggleManagement: () => setState(
                                  () => _isManagementMode = !_isManagementMode,
                            ),
                          ),
                        ),
                      ),
                      _Section(
                        key: _sectionKeys[4],
                        controller: _scrollController,
                        variant: ScrollRevealVariant.tiltIn,
                        child: const ExperienceSection(),
                      ),
                      _Section(
                        key: _sectionKeys[5],
                        controller: _scrollController,
                        variant: ScrollRevealVariant.fadeUp,
                        child: const ContactSection(),
                      ),
                      const PortfolioFooter(),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: DecoratedBox(
                decoration: const BoxDecoration(color: AppColors.background),
                child: ResponsiveContainer(
                  child: PortfolioNavBar(onNavigate: _scrollTo),
                ),
              ),
            ),
            Positioned.fill(
              child: PlayfulMascot(section: _mascotSection),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({
    required super.key,
    required this.controller,
    required this.child,
    this.variant = ScrollRevealVariant.fadeUp,
  });

  final ScrollController controller;
  final Widget child;
  final ScrollRevealVariant variant;

  @override
  Widget build(BuildContext context) => ScrollReveal(
    scrollController: controller,
    variant: variant,
    child: Padding(padding: const EdgeInsets.only(bottom: 112), child: child),
  );
}
// lib/features/portfolio/presentation/widgets/projects_section.dart

import 'package:abdelrhman_protfolio/core/theme/app_colors.dart';
import 'package:abdelrhman_protfolio/core/widgets/section_heading.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/state/portfolio_state.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/state/portfolio_view_model.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/widgets/project_details_dialog.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/widgets/project_management_panel.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/widgets/project_showcase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'animation_helper/stagger_Effect.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({
    required this.state,
    required this.isManagementMode,
    required this.onToggleManagement,
    super.key,
  });

  final PortfolioState state;
  final bool isManagementMode;
  final VoidCallback onToggleManagement;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SectionHeading(
        title: 'Projects',
        description:
        'Project case studies and media will be published here directly from the portfolio dashboard.',
      ),

      const SizedBox(height: 20),

      // ============================================================
      // MANAGEMENT MODE
      // ============================================================
      if (!kIsWeb)
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: onToggleManagement,
            icon: Icon(
              isManagementMode
                  ? Icons.visibility_outlined
                  : Icons.tune_outlined,
            ),
            label: Text(
              isManagementMode
                  ? 'View projects'
                  : 'Manage projects',
            ),
          ),
        ),

      const SizedBox(height: 20),

      // ============================================================
      // VIEW / MANAGEMENT
      // ============================================================

      isManagementMode
          ? ProjectManagementPanel(state: state)
          : _ProjectBody(state: state),
    ],
  );
}

class _ProjectBody extends StatelessWidget {
  const _ProjectBody({
    required this.state,
  });

  final PortfolioState state;

  @override
  Widget build(BuildContext context) => switch (state) {
    PortfolioLoading() ||
    PortfolioInitial() =>
    const Center(
      child: CircularProgressIndicator(),
    ),

    PortfolioEmpty() => const _EmptyProjects(),

    PortfolioError(:final message) => Text(message),

    PortfolioLoaded(:final projects) =>
        _ProjectGrid(projects: projects),
  };
}

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(
        color: AppColors.border,
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.auto_awesome_outlined,
          color: AppColors.accent,
        ),
        SizedBox(height: 16),
        Text(
          'The work archive is being prepared.',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Projects, screenshots, and video will appear here once they are published from the dashboard.',
        ),
      ],
    ),
  );
}

// ============================================================================
// PROJECT GRID
// ============================================================================

class _ProjectGrid extends StatelessWidget {
  const _ProjectGrid({
    required this.projects,
  });

  final List<PortfolioProject> projects;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // --------------------------------------------------------------
        // Responsive columns
        // --------------------------------------------------------------
        //
        // Desktop  -> 3 generous columns
        // Tablet   -> 2 generous columns
        // Mobile   -> 1 tall card, so project content is never clipped.
        //
        final width = constraints.maxWidth;

        final int columns;

        if (width >= 1100) {
          columns = 3;
        } else if (width >= 700) {
          columns = 2;
        } else {
          columns = 1;
        }

        return StaggerReveal(
          effect: StaggerEffect.tiltAlternate,
          itemDelay: const Duration(milliseconds: 80),
          duration: const Duration(milliseconds: 450),
          children: projects
              .map(
                (project) => _ProjectCard(
              project: project,
            ),
          )
              .toList(),
          builder: (context, animated) {
            return GridView.count(
              crossAxisCount: columns,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: _getAspectRatio(
                columns,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: animated,
            );
          },
        );
      },
    );
  }

  double _getAspectRatio(int columns) {
    if (columns == 3) {
      return 0.54;
    }

    if (columns == 2) {
      return 0.52;
    }

    return 0.48;
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
  });

  final PortfolioProject project;

  @override
  Widget build(BuildContext context) {
    return ProjectShowcase(
      project: project,


      onOpen: () async {
        final fullProject = await context
            .read<PortfolioViewModel>()
            .getProjectById(project.id);

        if (fullProject != null && context.mounted) {
          showDialog<void>(
            context: context,
            builder: (_) => ProjectDetailsDialog(
              project: fullProject,
            ),
          );
        }
      },
    );
  }
}

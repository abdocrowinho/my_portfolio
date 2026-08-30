// Provides concise web-only controls for creating, editing, and deleting projects.
import 'package:abdelrhman_protfolio/core/theme/app_colors.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/state/portfolio_state.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/state/portfolio_view_model.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/widgets/project_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProjectManagementPanel extends StatelessWidget {
  const ProjectManagementPanel({required this.state, super.key});
  final PortfolioState state;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FilledButton.icon(
        onPressed: () => _showEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Add project'),
      ),
      const SizedBox(height: 18),
      if (state case PortfolioLoaded(:final projects)) ...[
        if (projects.isEmpty) const Text('No published projects yet.'),
        ...projects.map((project) => _ManagementItem(project: project)),
      ] else if (state is PortfolioLoading)
        const Center(child: CircularProgressIndicator())
      else
        const Text('Load projects before managing them.'),
    ],
  );

  void _showEditor(BuildContext context, [PortfolioProject? project]) =>
      showDialog<void>(
        context: context,
        builder: (_) => BlocProvider.value(
          value: context.read<PortfolioViewModel>(),
          child: ProjectEditor(project: project),
        ),
      );
}

class _ManagementItem extends StatelessWidget {
  const _ManagementItem({required this.project});
  final PortfolioProject project;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            project.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton(
          tooltip: 'Edit',
          onPressed: () => _showEditor(context),
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          tooltip: 'Delete',
          onPressed: () => _confirmDelete(context),
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
        ),
      ],
    ),
  );

  void _showEditor(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => BlocProvider.value(
      value: context.read<PortfolioViewModel>(),
      child: ProjectEditor(project: project),
    ),
  );

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete project?'),
        content: Text(
          '${project.name} and its uploaded media will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true && context.mounted) {
      await context.read<PortfolioViewModel>().deleteProject(project);
    }
  }
}

// Shows a full project record fetched by ID without embedding details in the project list.
import 'package:abdelrhman_protfolio/core/theme/app_colors.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/widgets/project_media_player.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectDetailsDialog extends StatelessWidget {
  const ProjectDetailsDialog({required this.project, super.key});
  final PortfolioProject project;

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: AppColors.surface,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(project.description),
            if (project.completedAt case final date?) ...[
              const SizedBox(height: 12),
              Text('Completed ${date.toLocal().toString().split(' ').first}'),
            ],
            if (project.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 22),
              _ImageGallery(urls: project.imageUrls),
            ],
            if (project.videoUrl case final videoUrl?) ...[
              const SizedBox(height: 22),
              ProjectMediaPlayer(videoUrl: videoUrl),
            ],
            if (project.repoUrl case final repoUrl?) ...[
              const SizedBox(height: 18),
              TextButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse(repoUrl),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open repository'),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _ImageGallery extends StatelessWidget {
  const _ImageGallery({required this.urls});
  final List<String> urls;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 280,
    child: PageView.builder(
      itemCount: urls.length,
      itemBuilder: (_, index) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(urls[index], fit: BoxFit.cover),
      ),
    ),
  );
}

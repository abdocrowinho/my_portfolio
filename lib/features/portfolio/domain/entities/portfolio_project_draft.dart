// Collects editable project content and selected media before a repository operation.
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/project_media_file.dart';

class PortfolioProjectDraft {
  const PortfolioProjectDraft({
    required this.name,
    required this.description,
    required this.newImages,
    this.video,
    this.repoUrl,
    this.completedAt,
    this.tags = const [],
  });

  final String name;
  final String description;
  final List<ProjectMediaFile> newImages;
  final ProjectMediaFile? video;
  final String? repoUrl;
  final DateTime? completedAt;
  final List<String> tags;
}

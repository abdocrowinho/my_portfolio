// Represents a publishable portfolio project independent from its data source.
class PortfolioProject {
  const PortfolioProject({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrls,
    this.videoUrl,
    this.repoUrl,
    this.completedAt,
    this.tags = const [],
  });

  final String id;
  final String name;
  final String description;
  final List<String> imageUrls;
  final String? videoUrl;
  final String? repoUrl;
  final DateTime? completedAt;
  final List<String> tags;
}

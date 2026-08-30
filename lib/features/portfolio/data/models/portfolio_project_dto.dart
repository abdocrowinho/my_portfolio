// Maps Edge Function project payloads to domain entities without leaking API fields.
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project.dart';

class PortfolioProjectDto {
  const PortfolioProjectDto({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrls,
    this.videoUrl,
    this.repoUrl,
    this.completedAt,
    this.tags = const [],
  });

  factory PortfolioProjectDto.fromJson(Map<String, dynamic> json) =>
      PortfolioProjectDto(
        id: json['id'].toString(),
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        imageUrls: (json['image_urls'] ?? json['imageUrls'] as Object? ?? [])
            .cast<String>(),
        videoUrl: json['video_url'] as String? ?? json['videoUrl'] as String?,
        repoUrl: json['repo_url'] as String? ?? json['repoUrl'] as String?,
        completedAt: _parseDate(json['completed_at'] ?? json['completedAt']),
        tags: _parseTags(json['tags']),
      );

  final String id;
  final String name;
  final String description;
  final List<String> imageUrls;
  final String? videoUrl;
  final String? repoUrl;
  final DateTime? completedAt;
  final List<String> tags;

  PortfolioProject toDomain() => PortfolioProject(
    id: id,
    name: name,
    description: description,
    imageUrls: imageUrls,
    videoUrl: videoUrl,
    repoUrl: repoUrl,
    completedAt: completedAt,
    tags: tags,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'image_urls': imageUrls,
    'video_url': videoUrl,
    'repo_url': repoUrl,
    'completed_at': completedAt?.toIso8601String(),
    'tags': tags,
  };

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static List<String> _parseTags(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<String>()
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }
}

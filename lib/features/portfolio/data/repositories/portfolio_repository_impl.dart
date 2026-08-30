// Coordinates Edge Function project records and Supabase Storage media cleanup.
import 'package:abdelrhman_protfolio/features/portfolio/data/datasources/portfolio_remote_data_source.dart';
import 'package:abdelrhman_protfolio/features/portfolio/data/datasources/portfolio_storage_data_source.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project_draft.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/repositories/portfolio_repository.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  PortfolioRepositoryImpl(this._remote, this._storage);

  final PortfolioRemoteDataSource _remote;
  final PortfolioStorageDataSource _storage;

  @override
  Future<List<PortfolioProject>> getProjects() async =>
      (await _remote.getProjects())
          .map((project) => project.toDomain())
          .toList();

  @override
  Future<PortfolioProject> getProjectById(String id) async =>
      (await _remote.getProjectById(id)).toDomain();

  @override
  Future<PortfolioProject> createProject(PortfolioProjectDraft draft) async {
    final folderId = _storageFolderId();
    final uploadedUrls = <String>[];
    try {
      uploadedUrls.addAll(
        await _storage.uploadImages(folderId, draft.newImages),
      );
      final videoUrl = draft.video == null
          ? null
          : await _storage.uploadVideo(folderId, draft.video!);
      if (videoUrl != null) {
        uploadedUrls.add(videoUrl);
      }
      return (await _remote.createProject(
        _payload(
          name: draft.name,
          description: draft.description,
          imageUrls: uploadedUrls.where((url) => url != videoUrl).toList(),
          videoUrl: videoUrl,
          repoUrl: draft.repoUrl,
          completedAt: draft.completedAt,
          tags: draft.tags,
        ),
      )).toDomain();
    } catch (_) {
      await _storage.deleteUrls(uploadedUrls);
      rethrow;
    }
  }

  @override
  Future<PortfolioProject> updateProject(
    PortfolioProject project,
    PortfolioProjectDraft draft, {
    required List<String> retainedImageUrls,
    required bool retainVideo,
  }) async {
    final uploadedUrls = <String>[];
    try {
      final newVideoUrl = draft.video == null
          ? null
          : await _storage.uploadVideo(project.id, draft.video!);
      if (newVideoUrl != null) {
        uploadedUrls.add(newVideoUrl);
      }
      final newImages = await _storage.uploadImages(
        project.id,
        draft.newImages,
      );
      uploadedUrls.addAll(newImages);
      final finalVideoUrl = retainVideo ? project.videoUrl : newVideoUrl;
      final updated = await _remote.updateProject(
        _payload(
          id: project.id,
          name: draft.name,
          description: draft.description,
          imageUrls: [...retainedImageUrls, ...newImages],
          videoUrl: finalVideoUrl,
          repoUrl: draft.repoUrl,
          completedAt: draft.completedAt,
          tags: draft.tags,
        ),
      );
      final removedImages = project.imageUrls.where(
        (url) => !retainedImageUrls.contains(url),
      );
      await _storage.deleteUrls(removedImages);
      if (project.videoUrl != null && project.videoUrl != finalVideoUrl) {
        await _storage.deleteUrls([project.videoUrl!]);
      }
      return updated.toDomain();
    } catch (_) {
      await _storage.deleteUrls(uploadedUrls);
      rethrow;
    }
  }

  @override
  Future<void> deleteProject(PortfolioProject project) async {
    final mediaUrls = List<String>.from(project.imageUrls);
    final videoUrl = project.videoUrl;
    if (videoUrl != null) {
      mediaUrls.add(videoUrl);
    }
    await _storage.deleteUrls(mediaUrls);
    await _remote.deleteProject(project.id);
  }

  Map<String, dynamic> _payload({
    String? id,
    required String name,
    required String description,
    required List<String> imageUrls,
    required String? videoUrl,
    required String? repoUrl,
    required DateTime? completedAt,
    required List<String> tags,
  }) {
    final payload = <String, dynamic>{
      'name': name,
      'description': description,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'repoUrl': repoUrl,
      'completedAt': completedAt?.toIso8601String(),
      'tags': tags,
    };
    if (id != null) {
      payload['id'] = id;
    }
    return payload;
  }

  String _storageFolderId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${DateTime.now().hashCode}';
}

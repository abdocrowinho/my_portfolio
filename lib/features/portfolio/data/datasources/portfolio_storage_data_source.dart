// Defines isolated Storage operations required to manage portfolio project media.
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/project_media_file.dart';

abstract interface class PortfolioStorageDataSource {
  Future<List<String>> uploadImages(
    String folderId,
    List<ProjectMediaFile> files,
  );
  Future<String> uploadVideo(String folderId, ProjectMediaFile file);
  Future<void> deleteUrls(Iterable<String> urls);
}

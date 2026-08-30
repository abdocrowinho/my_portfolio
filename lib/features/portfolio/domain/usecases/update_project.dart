// Updates a project while preserving only the media selected for retention.
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project_draft.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/repositories/portfolio_repository.dart';

class UpdateProject {
  const UpdateProject(this._repository);
  final PortfolioRepository _repository;
  Future<PortfolioProject> call(
    PortfolioProject project,
    PortfolioProjectDraft draft, {
    required List<String> retainedImageUrls,
    required bool retainVideo,
  }) => _repository.updateProject(
    project,
    draft,
    retainedImageUrls: retainedImageUrls,
    retainVideo: retainVideo,
  );
}

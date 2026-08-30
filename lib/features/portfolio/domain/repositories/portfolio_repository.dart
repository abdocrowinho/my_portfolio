// Declares how the domain layer obtains portfolio projects.
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project_draft.dart';

abstract interface class PortfolioRepository {
  Future<List<PortfolioProject>> getProjects();
  Future<PortfolioProject> getProjectById(String id);
  Future<PortfolioProject> createProject(PortfolioProjectDraft draft);
  Future<PortfolioProject> updateProject(
    PortfolioProject project,
    PortfolioProjectDraft draft, {
    required List<String> retainedImageUrls,
    required bool retainVideo,
  });
  Future<void> deleteProject(PortfolioProject project);
}

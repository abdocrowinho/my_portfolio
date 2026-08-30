// Removes a project and its related Storage media through the repository.
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/repositories/portfolio_repository.dart';

class DeleteProject {
  const DeleteProject(this._repository);
  final PortfolioRepository _repository;
  Future<void> call(PortfolioProject project) =>
      _repository.deleteProject(project);
}

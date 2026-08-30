// Retrieves the projects that are available for public portfolio display.
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/repositories/portfolio_repository.dart';

class GetProjects {
  const GetProjects(this._repository);

  final PortfolioRepository _repository;

  Future<List<PortfolioProject>> call() => _repository.getProjects();
}

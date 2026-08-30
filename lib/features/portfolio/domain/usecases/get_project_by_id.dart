// Fetches the current full project record for details or editing.
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/repositories/portfolio_repository.dart';

class GetProjectById {
  const GetProjectById(this._repository);
  final PortfolioRepository _repository;
  Future<PortfolioProject> call(String id) => _repository.getProjectById(id);
}

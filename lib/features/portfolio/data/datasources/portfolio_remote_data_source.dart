// Defines remote CRUD operations implemented by the public portfolio Edge Functions.
import 'package:abdelrhman_protfolio/features/portfolio/data/models/portfolio_project_dto.dart';

abstract interface class PortfolioRemoteDataSource {
  Future<List<PortfolioProjectDto>> getProjects();
  Future<PortfolioProjectDto> getProjectById(String id);
  Future<PortfolioProjectDto> createProject(Map<String, dynamic> payload);
  Future<PortfolioProjectDto> updateProject(Map<String, dynamic> payload);
  Future<void> deleteProject(String id);
}

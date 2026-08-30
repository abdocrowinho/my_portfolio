// Creates a project after its selected media has been safely uploaded.
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project_draft.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/repositories/portfolio_repository.dart';

class CreateProject {
  const CreateProject(this._repository);
  final PortfolioRepository _repository;
  Future<PortfolioProject> call(PortfolioProjectDraft draft) =>
      _repository.createProject(draft);
}

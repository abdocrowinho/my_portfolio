// Models the explicit UI states required to render the featured projects area.
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project.dart';

sealed class PortfolioState {
  const PortfolioState();
}

class PortfolioInitial extends PortfolioState {
  const PortfolioInitial();
}

class PortfolioLoading extends PortfolioState {
  const PortfolioLoading();
}

class PortfolioLoaded extends PortfolioState {
  const PortfolioLoaded(this.projects);

  final List<PortfolioProject> projects;
}

class PortfolioEmpty extends PortfolioState {
  const PortfolioEmpty();
}

class PortfolioError extends PortfolioState {
  const PortfolioError(this.message);

  final String message;
}

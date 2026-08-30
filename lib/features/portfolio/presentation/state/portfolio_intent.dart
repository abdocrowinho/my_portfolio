// Lists user-triggered actions that can change the portfolio presentation state.
sealed class PortfolioIntent {
  const PortfolioIntent();
}

class LoadProjects extends PortfolioIntent {
  const LoadProjects();
}

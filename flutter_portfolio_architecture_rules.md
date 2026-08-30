# Flutter Portfolio --- Architecture & Coding Rules

## 1. Project Context

This project is a **responsive Flutter website / portfolio**, not a
mobile-only application.

The website must work correctly and look intentional on:

-   Small mobile screens
-   Large mobile screens
-   Tablets
-   Laptops
-   Desktop monitors
-   Very wide screens

Never build a layout that only looks correct at one fixed width.

Responsive behavior must be considered from the beginning of every
screen and reusable component.

Do not use hard-coded screen assumptions such as "the screen will always
be 390px wide".

Prefer Flutter's responsive layout tools and clear breakpoint-based
decisions when needed.

------------------------------------------------------------------------

# 2. Core Architecture

The project must follow:

-   Clean Architecture
-   MVI
-   Clean Code
-   SOLID principles
-   Reusable components
-   Clear separation of responsibilities

The dependency direction must remain:

``` text
Presentation
    ↓
Domain
    ↓
Data
```

The Domain layer must not depend on Flutter UI, Supabase, HTTP clients,
or concrete data implementations.

A feature should generally be organized like:

``` text
feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
└── presentation/
    ├── state/
    ├── pages/
    └── widgets/
```

Shared application infrastructure belongs under `core/`.

Example:

``` text
lib/
├── core/
│   ├── di/
│   ├── error/
│   ├── router/
│   ├── theme/
│   ├── responsive/
│   └── widgets/
│
├── features/
│   └── portfolio/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart
```

Do not create folders just to make the tree look "architectural". Every
folder must have a real responsibility.

------------------------------------------------------------------------

# 3. MVI Rules

The presentation layer must follow MVI.

The mental model is:

``` text
User Action
    ↓
Intent
    ↓
ViewModel / State Controller
    ↓
State
    ↓
UI
```

Use explicit names.

Examples:

``` text
PortfolioIntent
PortfolioState
PortfolioViewModel
```

or an equivalent naming scheme that is used consistently throughout the
project.

Do not mix several state-management patterns inside the same feature.

Do not put business logic inside widgets.

Widgets render state and send user intents/actions.

The state should represent what the UI needs to render.

Avoid scattered mutable state when the state belongs to the feature as a
whole.

------------------------------------------------------------------------

# 4. State Rules

States must be explicit and readable.

Prefer states such as:

``` text
Initial
Loading
Success
Empty
Error
```

When a feature needs more detailed states, model them clearly.

Do not create cryptic state names.

Bad:

``` text
PState
Loaded2
UiX
DataReadyFinal
```

Good:

``` text
PortfolioLoading
PortfolioLoaded
PortfolioEmpty
PortfolioError
```

The state must not contain responsibilities that belong to repositories
or use cases.

------------------------------------------------------------------------

# 5. Clean Architecture Rules

## Presentation

Responsible for:

-   Rendering UI
-   Receiving user interaction
-   Sending intents/actions
-   Observing state
-   Showing loading/error/empty states
-   Navigation triggers when appropriate

Presentation must not directly call Supabase or a remote API.

Bad:

``` dart
onPressed: () async {
  final data = await Supabase.instance.client
      .from('projects')
      .select();
}
```

Good:

``` text
UI
 ↓
Intent
 ↓
ViewModel
 ↓
UseCase
 ↓
Repository
 ↓
DataSource
```

## Domain

Contains business rules.

Typical contents:

-   Entities
-   Repository contracts
-   Use cases

Domain should be the most stable layer.

Do not import UI packages into Domain.

Do not make Domain know whether the data comes from:

-   Supabase
-   REST
-   Firebase
-   Local storage
-   Mock data

## Data

Responsible for obtaining and transforming data.

Typical contents:

-   Data sources
-   DTO/data models
-   Repository implementations
-   API/database mapping

The Data layer implements the interfaces defined by Domain.

------------------------------------------------------------------------

# 6. Use Cases

Use cases should represent meaningful actions.

Good:

``` text
GetProjects
GetFeaturedProjects
GetProjectById
UpdateProject
DeleteProject
```

Bad:

``` text
DoData
HandleStuff
ProcessEverything
Manager
Helper
Utils
```

Do not create a use case for every tiny line of code.

A use case should exist when it represents a meaningful business
operation or helps keep responsibilities clear.

------------------------------------------------------------------------

# 7. Repository Rules

Domain defines the contract:

``` text
PortfolioRepository
```

Data implements it:

``` text
PortfolioRepositoryImpl
```

The UI must never know about the implementation.

Example dependency flow:

``` text
PortfolioViewModel
        ↓
GetProjects
        ↓
PortfolioRepository
        ↓
PortfolioRepositoryImpl
        ↓
PortfolioRemoteDataSource
        ↓
Supabase
```

------------------------------------------------------------------------

# 8. Dependency Injection

Use Dependency Injection.

Dependencies must be registered in one clear location.

Prefer explicit registration over complicated magic.

The project should currently favor simple, readable DI.

Do not introduce code generation only because it is popular.

A developer reading the DI setup should immediately understand:

-   What is registered
-   Why it exists
-   What depends on it
-   Whether it is a singleton, lazy singleton, or factory

Avoid hidden service locators scattered throughout feature code.

------------------------------------------------------------------------

# 9. Clean Code Rules

The most important rule:

> Prefer code that is easy to understand over code that is clever.

Do not write difficult code simply because Flutter or Dart allows it.

Avoid:

-   Clever one-liners
-   Excessive chaining
-   Deep nesting
-   Unnecessary generics
-   Complex extensions
-   Magic values
-   Unclear callbacks
-   Huge conditional expressions
-   Premature abstractions
-   Unnecessary design patterns

If a simple `if` is clearer than a clever expression, use the `if`.

If a named variable makes the code easier to understand, create the
variable.

If a function is difficult to understand, split it into meaningful
functions.

------------------------------------------------------------------------

# 10. File Size Rule

**No production source file should exceed 200 lines.**

Treat 200 lines as a hard architectural warning.

If a file approaches 200 lines, stop and ask:

> Does this file have more than one responsibility?

Split it into smaller, meaningful files.

Do not bypass this rule by creating meaningless fragments.

Bad:

``` text
HugeWidget.dart
HugeWidgetPart1.dart
HugeWidgetPart2.dart
```

Good:

``` text
project_details_page.dart
project_header.dart
project_description.dart
project_links.dart
project_technology_list.dart
```

Each file should have one clear reason to exist.

------------------------------------------------------------------------

# 11. File Comments

**Every Dart source file must start with a short comment explaining why
the file exists.**

The comment should explain responsibility, not repeat the filename.

Example:

``` dart
// Displays the portfolio project details and coordinates the page-level UI state.
```

For a repository:

``` dart
// Implements the portfolio repository contract using the available data sources.
```

For a model:

``` dart
// Maps portfolio project data between the remote data source and the application model.
```

For a reusable widget:

``` dart
// Reusable responsive card used to present a single portfolio project.
```

Keep these comments short.

Do not write comments that explain obvious syntax.

Bad:

``` dart
// This is a class.
class Project {}
```

Good:

``` dart
// Represents a portfolio project used by the domain layer.
class Project {}
```

------------------------------------------------------------------------

# 12. Naming Rules

Naming is extremely important.

Names must be:

-   Explicit
-   Predictable
-   Searchable
-   Consistent
-   Boring when necessary

Do not invent terminology.

Use the simplest name that accurately describes the responsibility.

Prefer:

``` text
ProjectCard
ProjectDetailsPage
PortfolioRepository
PortfolioRepositoryImpl
GetProjects
PortfolioViewModel
PortfolioState
PortfolioIntent
```

Avoid:

``` text
ProjectTileX
ProjectPresenter
ProjectCoordinator
ProjectEngine
ProjectManager
ProjectHandler
```

unless those names describe a real responsibility.

Do not use `Manager`, `Helper`, `Utils`, `Service`, or `Processor` as
generic dumping grounds.

A name should tell another developer what the class actually does.

------------------------------------------------------------------------

# 13. Folder and File Naming

File names must use `snake_case`.

Examples:

``` text
project_card.dart
project_details_page.dart
portfolio_repository.dart
portfolio_repository_impl.dart
get_projects.dart
portfolio_view_model.dart
portfolio_state.dart
```

Class names use `PascalCase`.

Examples:

``` text
ProjectCard
ProjectDetailsPage
PortfolioRepository
PortfolioRepositoryImpl
GetProjects
PortfolioViewModel
PortfolioState
```

Do not abbreviate names unless the abbreviation is universally
understood.

Avoid:

``` text
proj.dart
repo.dart
vm.dart
ui.dart
comp.dart
```

Prefer:

``` text
project.dart
portfolio_repository.dart
portfolio_view_model.dart
```

------------------------------------------------------------------------

# 14. Reusable Components

Build reusable components when the component represents a real repeated
UI concept.

Examples:

``` text
AppButton
AppText
ProjectCard
TechnologyChip
ResponsiveContainer
SectionTitle
SocialLinkButton
```

Do not create a reusable component just to move five lines into another
file.

Reuse should improve:

-   Consistency
-   Readability
-   Maintainability
-   Responsive behavior

Do not create a giant `AppWidgets` file containing unrelated widgets.

------------------------------------------------------------------------

# 15. UI Composition

Pages should compose smaller widgets.

Avoid putting the entire website screen into one `build()` method.

Bad:

``` text
HomePage
 └── 500 lines of UI
```

Prefer:

``` text
HomePage
├── HeroSection
├── AboutSection
├── SkillsSection
├── ProjectsSection
├── ExperienceSection
└── ContactSection
```

Each section can then have its own internal reusable components.

The page should read almost like a description of the screen.

------------------------------------------------------------------------

# 16. Responsive Design

Responsive design is a first-class requirement.

Never assume:

``` text
mobile = scaled desktop
```

Instead, decide how the layout behaves at different sizes.

For example:

``` text
Mobile
- Single column
- Compact spacing
- Stacked content
- Simplified navigation

Tablet
- Wider content
- More horizontal arrangement
- Increased spacing

Desktop
- Multi-column layouts where appropriate
- Larger visual hierarchy
- Full navigation
- Wider content areas
```

Use clear responsive breakpoints.

Do not scatter arbitrary width checks throughout the project.

Prefer a centralized responsive system.

For example:

``` text
core/responsive/
```

can contain:

``` text
app_breakpoints.dart
responsive_layout.dart
```

The exact implementation can evolve, but responsive decisions should
remain understandable.

------------------------------------------------------------------------

# 17. Avoid Hard-Coded Layouts

Do not build the website around fixed values that only work on one
screen.

Avoid unnecessary:

``` dart
width: 390
height: 844
```

Prefer:

-   Constraints
-   `Expanded`
-   `Flexible`
-   `LayoutBuilder`
-   `ConstrainedBox`
-   `FractionallySizedBox`
-   Responsive breakpoints
-   Appropriate max content widths

Fixed values are acceptable when they represent intentional design
values, such as icon size, border radius, or spacing.

------------------------------------------------------------------------

# 18. Web-Specific Considerations

This is a Flutter Web project.

Do not assume mobile behavior.

Think about:

-   Mouse hover
-   Keyboard navigation
-   Pointer interaction
-   Browser viewport resizing
-   Large horizontal space
-   Small browser windows
-   Scroll behavior
-   Accessibility
-   Text wrapping
-   Focus states

Do not make interactions that only make sense on touch screens.

If a desktop interaction is useful, support it without breaking mobile
behavior.

------------------------------------------------------------------------

# 19. UI State vs Domain State

Keep UI-specific concerns in Presentation.

Examples of UI-specific state:

``` text
isMenuOpen
selectedTab
hoveredProjectId
isMobileMenuOpen
```

Business data belongs in Domain/Data.

Do not put UI concerns inside domain entities.

------------------------------------------------------------------------

# 20. Error Handling

Errors must be explicit.

Do not silently swallow exceptions.

Bad:

``` dart
try {
  ...
} catch (_) {}
```

Prefer converting technical exceptions into meaningful failures that
Presentation can understand.

For example:

``` text
NetworkFailure
ServerFailure
DatabaseFailure
UnknownFailure
```

Do not expose raw database or networking exceptions directly to the UI.

------------------------------------------------------------------------

# 21. Comments and Documentation

Comments should explain **why**, not **what**.

Bad:

``` dart
// Loop through projects.
for (final project in projects) {
```

Good:

``` dart
// Limit the visible projects on small screens to keep the first viewport focused.
```

Do not comment around bad code instead of making the code clearer.

Readable code is the first form of documentation.

------------------------------------------------------------------------

# 22. No Magic Numbers

Avoid unexplained values.

Bad:

``` dart
SizedBox(height: 37)
```

when `37` has no clear design reason.

Prefer named design values when a value is reused or meaningful.

Example:

``` text
AppSpacing.large
AppRadius.medium
```

But do not create constants for every single number.

The goal is clarity, not abstraction for its own sake.

------------------------------------------------------------------------

# 23. SOLID Principles

Apply SOLID practically.

## Single Responsibility

A class should have one clear responsibility.

A ViewModel should not:

-   Render widgets
-   Call Supabase directly
-   Parse JSON
-   Handle navigation
-   Contain design constants

## Open/Closed

Prefer designs that can be extended without rewriting unrelated code.

## Liskov Substitution

Implementations should respect the contracts they implement.

## Interface Segregation

Do not create huge interfaces when smaller focused contracts are enough.

## Dependency Inversion

High-level business logic depends on abstractions, not concrete data
implementations.

Do not force SOLID patterns where they make the code harder to
understand.

------------------------------------------------------------------------

# 24. No Over-Engineering

Clean Architecture does not mean creating 50 classes for a simple
feature.

Do not introduce:

-   Factories without a real need
-   Abstract classes without a real contract
-   Interfaces with one meaningless method
-   Generic base classes everywhere
-   Unnecessary wrappers
-   Unnecessary design patterns
-   Code generation just to reduce a few lines

Every abstraction must solve a real problem.

The project should remain understandable to a developer who has not seen
it before.

------------------------------------------------------------------------

# 25. Dependency Rules

Dependencies should be added only when they solve a real problem.

Before adding a package, ask:

1.  Do we actually need it?
2.  Can Flutter/Dart solve this cleanly?
3.  Will it make the project easier to maintain?
4.  Does it introduce unnecessary complexity?
5.  Does it fit the architecture?
6.  Is the package actively maintained?

Do not add packages just because another Flutter project uses them.

------------------------------------------------------------------------

# 26. Current Preferred Stack

The initial project should remain intentionally small.

Preferred core dependencies:

``` text
flutter_bloc
get_it
supabase_flutter
```

Additional packages should be introduced only when a real requirement
appears.

Examples:

``` text
go_router
url_launcher
cached_network_image
```

These should not be added until their functionality is actually needed.

------------------------------------------------------------------------

# 27. Data Must Not Be Hard-Coded

Portfolio content should not live as large constant lists inside UI
files.

Do not do:

``` dart
final projects = [
  ...
];
```

for production portfolio content.

The application should be designed so portfolio data can be added or
edited without changing UI source code.

The data source can later provide:

-   Projects
-   Skills
-   Experience
-   Social links
-   About information
-   Featured content

The UI should consume the domain models.

------------------------------------------------------------------------

# 28. UI Must Not Know the Data Source

The UI should not care whether the portfolio data comes from:

``` text
Supabase
REST API
Local database
JSON
Mock data
```

The UI only knows the domain contract and state.

This allows the data source to change without rewriting the UI.

------------------------------------------------------------------------

# 29. Readability Over Brevity

Do not optimize for the fewest lines.

Optimize for the easiest understanding.

This is preferred:

``` dart
final projects = await getProjects();
final featuredProjects = projects.where((project) => project.isFeatured);
```

over a compressed expression that technically works but requires mental
decoding.

Short code is not automatically clean code.

------------------------------------------------------------------------

# 30. Before Writing Code

Before implementing a feature:

1.  Understand the requirement.
2.  Decide which feature owns it.
3.  Identify the domain concept.
4.  Decide the state needed by the UI.
5.  Decide the user intents/actions.
6.  Decide the data source.
7.  Decide which files are necessary.
8.  Check whether an existing reusable component can be used.
9.  Check responsive behavior.
10. Then write the code.

Do not immediately create code before understanding where it belongs.

------------------------------------------------------------------------

# 31. Before Creating a New File

Ask:

> What single responsibility does this file have?

If the answer is unclear, do not create the file yet.

If an existing file already has the same responsibility, extend it
instead of creating a duplicate.

------------------------------------------------------------------------

# 32. Before Creating a New Component

Ask:

-   Is this reused?
-   Is it a meaningful UI concept?
-   Does extracting it improve readability?
-   Does it need its own responsive behavior?
-   Can another screen reasonably reuse it?

If not, keep the code local.

------------------------------------------------------------------------

# 33. Before Adding a Dependency

Ask:

> Can this be implemented clearly with the Flutter/Dart APIs we already
> have?

If yes, prefer the built-in solution.

------------------------------------------------------------------------

# 34. Definition of Done

A feature is not finished just because it works.

Before considering it complete, verify:

-   Architecture is respected.
-   MVI flow is clear.
-   Names are explicit.
-   Files have one responsibility.
-   No production file exceeds 200 lines.
-   Reusable components are used where appropriate.
-   Responsive behavior works on small and large screens.
-   No unnecessary hard-coded dimensions exist.
-   No business logic is hidden inside widgets.
-   No data-source code exists in Presentation.
-   Errors are handled.
-   Code is readable without requiring mental decoding.
-   Every Dart file starts with a short responsibility comment.
-   No unnecessary dependency was introduced.

------------------------------------------------------------------------

# 35. Most Important Rule

When there is a choice between:

``` text
clever + short + difficult
```

and:

``` text
simple + explicit + readable
```

**Always choose the second one.**

The project is being built to demonstrate engineering quality and to
remain maintainable.

Do not write code that merely works.

Write code that another developer can open six months later and
immediately understand.

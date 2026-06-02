---
trigger: model_decision
description: Use this when building UI and presentation layer
---

# State Management Rule: Use Bloc

- **Mandatory State Management**: Always use the Bloc library for managing state in this Flutter project.
- **Directory Structure**:
  - Blocs and Cubits must be placed in the `presentation/bloc/` directory of the relevant feature (e.g., `lib/features/news/presentation/bloc/`).
- **Clean Architecture**: Ensure that Blocs interact with **UseCases** from the domain layer and do not directly access repositories or data sources.
- **Naming Conventions**:
  - Events should follow the naming pattern: `FeatureEventName` (e.g., `NewsFetchStarted`).
  - States should follow the naming pattern: `FeatureStateName` (e.g., `NewsLoadSuccess`).
- **Dependency Injection**: Use `BlocProvider` to provide Blocs to the widget tree and `BlocBuilder`/`BlocListener`/`BlocConsumer` for UI updates.
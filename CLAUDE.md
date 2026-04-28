
# CLAUDE.md - Flutter + Riverpod 2.0 + Clean Architecture

You are an expert Flutter engineer specializing in Clean Architecture and Riverpod 2.0. Always follow these rules strictly.

## Project Overview
- **Framework**: Flutter (Dart) with full null safety
- **Architecture**: Clean Architecture (Domain-Driven Design inspired)
- **State Management**: Riverpod 2.0 (Notifiers + Providers)
- **Dependency Injection**: Riverpod (no GetIt or manual DI)
- **UI Design**: Material 3
- **Routing**: GoRouter (preferred)

## Core Principles
- Strictly separate layers: Presentation → Domain → Data
- Business logic belongs only in the Domain layer
- UI (widgets) must be as dumb as possible
- Use Riverpod for everything: state, dependency injection, and repositories
- Prefer functional programming style where it improves clarity

## Folder Structure (Strict)

```bash
lib/
├── core/
│   ├── di/                    # Riverpod providers setup
│   ├── error/                 # Failure classes & exceptions
│   ├── routes/                # GoRouter configuration
│   ├── theme/                 # AppTheme, colors, text styles
│   └── utils/                 # Extensions, constants, helpers
│
├── features/
│   └── [feature_name]/
│       ├── data/
│       │   ├── datasources/   # Remote & local data sources
│       │   ├── models/        # DTO / JSON models
│       │   └── repositories/  # Repository implementations
│       │
│       ├── domain/
│       │   ├── entities/      # Pure business entities
│       │   ├── repositories/  # Abstract repository interfaces
│       │   ├── usecases/      # Use cases / Interactors
│       │   └── failures/      # Domain-specific failures
│       │
│       └── presentation/
│           ├── controllers/   # StateNotifier / AsyncNotifier
│           ├── pages/         # Screens
│           ├── widgets/       # Feature-specific widgets
│           └── providers/     # Riverpod providers for this feature
│
├── shared/
│   ├── widgets/               # Reusable UI components
│   └── models/                # Shared models
│
└── main.dart
```

## Riverpod 2.0 Rules
- Use `AsyncNotifier` + `AsyncNotifierProvider` for complex state
- Use `Notifier` + `NotifierProvider` for simple mutable state
- Use `StateProvider` only for very simple primitive state
- Prefer `ref.watch`, `ref.read`, and `ref.listen` correctly
- Always dispose resources when necessary
- Name providers clearly: `userControllerProvider`, `authRepositoryProvider`, etc.
- Use `family` modifiers when parameters are needed

## Clean Architecture Rules
- **Entities**: Immutable, pure Dart classes (no dependencies)
- **Use Cases**: Single responsibility, receive parameters and return `Either<Failure, Success>`
- **Repositories**: Abstract in Domain, implemented in Data layer
- **Models**: Separate from Entities (use mappers/extension methods to convert)
- Never import Data or Presentation layer into Domain

## Coding Standards
- Use `const` constructors and widgets whenever possible
- Prefer `final` variables
- Use async/await and proper error handling
- Keep widgets small and reusable
- Use meaningful names following Dart conventions
- Add clear documentation for complex use cases and controllers

## UI & Theming
- Follow Material 3 design system
- Use `Theme.of(context)` and centralized `AppTheme`
- Make UI responsive using `MediaQuery`, `LayoutBuilder`, or `Responsive` helpers
- Handle loading, error, and empty states gracefully in every screen

## Best Practices
- Never perform business logic inside widgets or controllers
- Keep controllers thin — they should mostly call use cases
- Use freezed package for entities, models, and state classes when appropriate
- Use either `fpdart` or `dartz` for `Either` and `Option` (choose one consistently)
- Validate inputs at the domain level
- Write clean, readable code over clever code

## Response Format
Always structure your answers like this:

**1. Plan**
- Understanding of the requirement
- Which layers will be affected
- Architecture considerations and edge cases

**2. Proposed Changes**
- List of files to create/modify

**3. Code Implementation**
```dart
// Well-commented, production-ready code
```

**4. Explanation**
- Why this approach was chosen

**5. Testing & Next Steps**
- Suggested unit/widget tests
- Manual verification steps

## Important Reminders
- Always maintain strict layer separation.
- Never add new packages without explicit user approval.
- Stay consistent with existing code style and patterns in this project.
- Prefer Riverpod Notifiers over direct state mutation.
- Think about testability and maintainability.
- If the request violates Clean Architecture, suggest the correct approach and explain why.

You are expected to deliver clean, scalable, and production-grade Flutter code following modern best practices with Riverpod 2.0 and Clean Architecture.


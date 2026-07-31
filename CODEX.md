
# CODEX.md - Project Rules & Guidelines for ChatGPT / Codex

You are an expert Flutter developer working inside this project. Always follow these rules strictly for every coding task.

## Project Overview
- **Framework**: Flutter (Dart) with full null safety
- **Architecture**: Clean Architecture
- **State Management**: Riverpod 2.0 (Notifiers + Providers)
- **Dependency Injection**: Riverpod
- **Routing**: GoRouter
- **UI**: Material 3 Design
- **Target Platforms**: Android & iOS (Web/Desktop if mentioned)

## Strict Folder Structure

```bash
lib/
├── core/
│   ├── di/                    # Riverpod providers configuration
│   ├── error/                 # Failures and exceptions
│   ├── routes/                # GoRouter setup
│   ├── theme/                 # AppTheme, colors, typography
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
│           ├── controllers/   # AsyncNotifier / Notifier classes
│           ├── pages/         # Screens
│           ├── widgets/       # Feature-specific UI widgets
│           └── providers/     # Riverpod providers
│
├── shared/
│   ├── widgets/               # Reusable components
│   └── models/                # Shared models
│
└── main.dart
```

## Key Rules You Must Follow

### Architecture Rules
- Strictly maintain Clean Architecture layer separation:
  - **Domain** → Pure business logic (no Flutter or external dependencies)
  - **Data** → Handles API, local storage, mapping
  - **Presentation** → UI + Controllers only
- Never import Data or Presentation code into the Domain layer.
- Use Cases should return `Either<Failure, Success>` (using fpdart or dartz).

### Riverpod 2.0 Rules
- Use `AsyncNotifierProvider` + `AsyncNotifier` for async state
- Use `NotifierProvider` + `Notifier` for synchronous state
- Use `StateProvider` sparingly, only for simple values
- Prefer `ref.watch` / `ref.read` / `ref.listen` appropriately
- Name providers clearly and consistently (e.g. `authControllerProvider`, `userRepositoryProvider`)

### Coding Standards
- Use `const` constructors and widgets aggressively for performance
- Prefer `final` variables
- Use async/await instead of `.then()`
- Keep widgets small and reusable
- Follow official Dart/Flutter style guide
- Use meaningful, descriptive names
- Add comments only for complex logic

### UI & Theming
- Use Material 3 (`Theme.of(context)`)
- Centralize theming in `core/theme/`
- Handle loading, error, and empty states in every screen
- Make UI responsive

## Response Format (Always Use This Structure)

**1. Plan**
- Brief understanding of the task
- Which layers and files will be affected
- Important considerations and edge cases

**2. Files to Change**
- List all files that need to be created or modified

**3. Code Implementation**
Provide clean, well-formatted code with proper comments:

```dart
// Your code here
```

**4. Explanation**
- Why this design/approach was chosen
- Any trade-offs considered

**5. Testing & Verification**
- Suggested unit or widget tests
- Manual testing steps

## Important Reminders
- Do not add any new packages without explicit user approval.
- Never break Clean Architecture rules.
- Stay consistent with the existing code style and patterns in this project.
- Prioritize readability, maintainability, and performance.
- Think step-by-step before writing code.
- If anything is ambiguous or violates the architecture, ask clarifying questions first.
- Always write production-ready, clean, and testable code.

You are now operating under these project-specific rules. Follow them rigorously in every response.


---

### How to Use with ChatGPT / Codex:

1. Create a file named `CODEX.md` in your project root.
2. Copy and paste the content above.
3. When starting a new chat in ChatGPT, upload the `CODEX.md` file or paste its content at the beginning of the conversation.
4. Then ask your coding questions normally (ChatGPT will follow these rules).

### Quick Usage Tip:
At the start of each new ChatGPT session, you can say:

> "Follow the rules in CODEX.md for this Flutter project."

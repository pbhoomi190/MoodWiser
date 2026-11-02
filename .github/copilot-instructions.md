# Project Guidelines

## Code Style
- Use Dart and Flutter conventions, and follow the lints in `analysis_options.yaml`.
- Format changed Dart files with `dart format`.
- Keep changes focused and follow the existing structure under `lib/`.
- Declare single-purpose service and helper classes, including singletons, as `final` when they are not intended to be subclassed.
- Do not inline keys, string identifiers, or other fixed values. Define shared values in a constants file under `lib/core/utilities/` (create one there if needed) and reference them from code.
- Do not hardcode colors in widgets or styles. Define the app palette in `lib/core/utilities/app_colors.dart` and reference those color constants.
- Do not hardcode layout spacing in pages or widgets. Define and reuse spacing tokens from `lib/core/utilities/app_spacing.dart` for gaps, padding, and margins; use the named scale `xxs`, `xs`, `sm`, `md`, `lg`, `xlg`, and `xxlg` (4, 6, 8, 12, 16, 24, and 32 pixels). If a design needs another spacing value, add or agree on a shared token instead of using a literal in a widget.

## Architecture and Persistence
- Keep Hive initialization and box access in `lib/core/database/hive_service.dart`; avoid direct Hive access from widgets.
- When changing Hive models, preserve existing `typeId` and field indexes. Regenerate adapters with build_runner after model changes.
- Keep widgets focused on presentation and move reusable persistence or domain logic out of `build` methods.
- Extract common or reusable UI into separate widget classes, keeping `build` methods concise and avoiding deeply nested or overly complex widget trees. Prefer composing small, focused widgets where practical.
- Choose state management based on UI complexity: use streams and `StreamController` for simple UI updates, BLoC for event-driven state changes, and Riverpod for state shared across nested UI. Avoid `setState` when update logic is more than a trivial local change, and dispose stream controllers when their owner is disposed.

## Build and Test
- Fetch dependencies with `flutter pub get`.
- Run `dart run build_runner build --delete-conflicting-outputs` after changing generated Hive model code.
- Do not automatically run tests or launch the app after code changes. Ask the user first; otherwise, only update the code.
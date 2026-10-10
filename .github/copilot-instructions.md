# Project Guidelines

## Code Style
- Use Dart and Flutter conventions, and follow the lints in `analysis_options.yaml`.
- Format changed Dart files with `dart format`.
- Keep changes focused and follow the existing structure under `lib/`.
- Declare single-purpose service and helper classes, including singletons, as `final` when they are not intended to be subclassed.
- Do not inline keys, string identifiers, or other fixed values. Define shared values in a constants file under `lib/core/utilities/` (create one there if needed) and reference them from code.
- Do not hardcode colors in widgets or styles. Define the app palette in `lib/core/utilities/app_colors.dart` and reference those color constants.

## Architecture and Persistence
- Keep Hive initialization and box access in `lib/core/database/hive_service.dart`; avoid direct Hive access from widgets.
- When changing Hive models, preserve existing `typeId` and field indexes. Regenerate adapters with build_runner after model changes.
- Keep widgets focused on presentation and move reusable persistence or domain logic out of `build` methods.

## Build and Test
- Fetch dependencies with `flutter pub get`.
- Run `dart run build_runner build --delete-conflicting-outputs` after changing generated Hive model code.
- Do not automatically run tests or launch the app after code changes. Ask the user first; otherwise, only update the code.
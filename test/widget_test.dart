// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mood_wiser/core/utilities/app_strings.dart';
import 'package:mood_wiser/features/mood_tracking/domain/entities/mood_entry.dart';
import 'package:mood_wiser/features/mood_tracking/domain/repositories/mood_entry_repository.dart';
import 'package:mood_wiser/features/mood_tracking/domain/use_cases/save_mood_entry.dart';
import 'package:mood_wiser/features/mood_tracking/presentation/pages/track_mood_page.dart';

void main() {
  testWidgets('saves the entered mood through the use case', (
    WidgetTester tester,
  ) async {
    final FakeMoodEntryRepository repository = FakeMoodEntryRepository();
    final SaveMoodEntry saveMoodEntry = SaveMoodEntry(repository);

    await tester.pumpWidget(
      MaterialApp(home: TrackMoodPage(saveMoodEntry: saveMoodEntry)),
    );

    await tester.tap(find.text('Calm'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).first, 'A quiet walk');
    await tester.scrollUntilVisible(
      find.text(AppStrings.saveMood),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(AppStrings.saveMood));
    await tester.pumpAndSettle();

    expect(repository.savedEntry, isNotNull);
    expect(repository.savedEntry!.feeling, 'Calm');
    expect(repository.savedEntry!.trigger, 'A quiet walk');
    expect(repository.savedEntry!.score, 5);
    expect(find.text(AppStrings.savedMessage), findsOneWidget);
  });
}

final class FakeMoodEntryRepository implements MoodEntryRepository {
  MoodEntry? savedEntry;

  @override
  Future<void> save(MoodEntry entry) async {
    savedEntry = entry;
  }
}

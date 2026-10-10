import 'package:flutter/material.dart';
import 'package:mood_wiser/core/initialization/initial_setup.dart';
import 'package:mood_wiser/core/utilities/app_colors.dart';
import 'package:mood_wiser/features/mood_tracking/data/data_sources/hive_mood_entry_local_data_source.dart';
import 'package:mood_wiser/features/mood_tracking/data/repositories/mood_entry_repository_impl.dart';
import 'package:mood_wiser/features/mood_tracking/domain/use_cases/save_mood_entry.dart';
import 'package:mood_wiser/features/mood_tracking/presentation/pages/track_mood_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InitialSetup.instance.init();
  final localDataSource = HiveMoodEntryLocalDataSource();
  final repository = MoodEntryRepositoryImpl(localDataSource);
  runApp(MyApp(saveMoodEntry: SaveMoodEntry(repository)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.saveMoodEntry});

  final SaveMoodEntry saveMoodEntry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodWiser',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.ink,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
      home: TrackMoodPage(saveMoodEntry: saveMoodEntry),
    );
  }
}

import 'package:mood_wiser/core/database/hive_service.dart';

final class InitialSetup {
  InitialSetup._();

  static final InitialSetup instance = InitialSetup._();

  Future<void> init() async {
    await HiveService.init();
  }
}

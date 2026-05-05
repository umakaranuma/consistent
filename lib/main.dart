import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/router.dart';
import 'constants/colors.dart';
import 'store/types.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(AppModeAdapter());
  Hive.registerAdapter(BmiCategoryAdapter());
  Hive.registerAdapter(GymGoalAdapter());
  Hive.registerAdapter(ScheduleItemTypeAdapter());
  Hive.registerAdapter(ScheduleItemAdapter());
  Hive.registerAdapter(MacroTargetsAdapter());
  Hive.registerAdapter(WaterConfigAdapter());
  Hive.registerAdapter(WeightEntryAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(ReminderAdapter());
  Hive.registerAdapter(LogEntryAdapter());
  Hive.registerAdapter(DayRecordAdapter());

  await Hive.openBox('vitatrack_data');

  runApp(
    const ProviderScope(
      child: VitaTrackApp(),
    ),
  );
}

class VitaTrackApp extends StatelessWidget {
  const VitaTrackApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final router = buildRouter();
    return MaterialApp.router(
      title: 'VitaTrack: Daily Health Planner',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg0,
        primaryColor: AppColors.accent,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.accentSoft,
          surface: AppColors.bg1,
          background: AppColors.bg0,
        ),
      ),
      routerConfig: router,
    );
  }
}

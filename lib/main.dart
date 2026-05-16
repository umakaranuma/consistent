import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/router.dart';
import 'constants/colors.dart';
import 'store/types.dart';
import 'utils/notification_service.dart';

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

  // Initialize notifications
  await NotificationService.instance.initialize();

  runApp(
    ProviderScope(
      child: VitaTrackApp(),
    ),
  );
}

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final box = Hive.box('vitatrack_data');
    final val = box.get('themeMode', defaultValue: 'system');
    if (val == 'light') return ThemeMode.light;
    if (val == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    final box = Hive.box('vitatrack_data');
    if (mode == ThemeMode.light) box.put('themeMode', 'light');
    else if (mode == ThemeMode.dark) box.put('themeMode', 'dark');
    else box.put('themeMode', 'system');
  }
}

final themeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

class VitaTrackApp extends ConsumerWidget {
  VitaTrackApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = buildRouter();
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp.router(
      title: 'VitaTrack: Daily Health Planner',
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        primaryColor: AppColors.accent,
        colorScheme: ColorScheme.light(
          primary: AppColors.accent,
          secondary: AppColors.accentSoft,
          surface: const Color(0xFFFFFFFF),
          // ignore: deprecated_member_use
          background: const Color(0xFFF5F5F7),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080810),
        primaryColor: AppColors.accent,
        colorScheme: ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.accentSoft,
          surface: const Color(0xFF0C0C1A),
          // ignore: deprecated_member_use
          background: const Color(0xFF080810),
        ),
      ),
      builder: (context, child) {
        final brightness = MediaQuery.platformBrightnessOf(context);
        AppThemeState.isDark = (themeMode == ThemeMode.dark) || 
            (themeMode == ThemeMode.system && brightness == Brightness.dark);
        return child!;
      },
      routerConfig: router,
    );
  }
}

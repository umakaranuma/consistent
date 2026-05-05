import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'constants/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase initialization etc. will go here

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

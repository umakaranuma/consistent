import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/onboarding_screen.dart';
import 'screens/today_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/profile_screen.dart';
import '../constants/colors.dart';

const String routeOnboarding = '/onboarding';
const String routeToday = '/today';
const String routeCalendar = '/calendar';
const String routeReminders = '/reminders';
const String routeProfile = '/profile';

class MainTabScaffold extends StatelessWidget {
  final Widget child;

  const MainTabScaffold({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.bg1,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textMuted,
        selectedFontSize: 9,
        unselectedFontSize: 9,
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(routeToday)) return 0;
    if (location.startsWith(routeCalendar)) return 1;
    if (location.startsWith(routeReminders)) return 2;
    if (location.startsWith(routeProfile)) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go(routeToday);
        break;
      case 1:
        GoRouter.of(context).go(routeCalendar);
        break;
      case 2:
        GoRouter.of(context).go(routeReminders);
        break;
      case 3:
        GoRouter.of(context).go(routeProfile);
        break;
    }
  }
}

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: routeToday,
    redirect: (context, state) {
      final box = Hive.box('vitatrack_data');
      final profile = box.get('profile');
      if (profile == null && state.matchedLocation != routeOnboarding) {
        return routeOnboarding;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: routeOnboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainTabScaffold(child: child),
        routes: [
          GoRoute(
            path: routeToday,
            builder: (context, state) => const TodayScreen(),
          ),
          GoRoute(
            path: routeCalendar,
            builder: (context, state) => const CalendarScreen(),
          ),
          GoRoute(
            path: routeReminders,
            builder: (context, state) => const RemindersScreen(),
          ),
          GoRoute(
            path: routeProfile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}

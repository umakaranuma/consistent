import 'dart:io';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

/// Centralized notification service for VitaTrack.
/// Handles permission requests, scheduling, and context-aware messages.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ─── Notification Channels ──────────────────────────────────
  static const _scheduleChannel = AndroidNotificationDetails(
    'vitatrack_schedule', 'VitaTrack Reminders',
    channelDescription: 'Health and wellness reminders',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  static const _alertChannel = AndroidNotificationDetails(
    'vitatrack_alerts', 'VitaTrack Alerts',
    channelDescription: 'Smart health alerts',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  static const _instantChannel = AndroidNotificationDetails(
    'vitatrack_instant', 'VitaTrack',
    channelDescription: 'Instant notifications',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  static const _overdueChannel = AndroidNotificationDetails(
    'vitatrack_overdue', 'VitaTrack Overdue Reminders',
    channelDescription: 'Reminders for overdue or skipped activities',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    styleInformation: BigTextStyleInformation(''),
  );

  // ─── Initialization ────────────────────────────────────────
  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    
    // Set device local timezone for correct scheduling
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings: initSettings);
    _initialized = true;
  }

  // ─── Permission ────────────────────────────────────────────
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  Future<bool> isPermissionGranted() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isGranted;
    }
    return true;
  }

  // ─── Schedule Daily Notification ───────────────────────────
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) await initialize();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(android: _scheduleChannel),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ─── Schedule One-Time Notification ────────────────────────
  Future<void> scheduleOneTimeNotification({
    required int id,
    required String title,
    required String body,
    required Duration delay,
  }) async {
    if (!_initialized) await initialize();

    final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(android: _alertChannel),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // ─── Cancel Notification ───────────────────────────────────
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id: id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ─── Show Immediate Notification ───────────────────────────
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: _instantChannel),
    );
  }

  // ─── Show Overdue Notification ─────────────────────────────
  Future<void> showOverdueNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: _overdueChannel),
    );
  }

  // ─── Smart Contextual Messages ─────────────────────────────
  /// Returns a context-aware notification body for a given type.
  static String getSmartMessage(String type, {String? extra}) {
    switch (type) {
      case 'water':
        final msgs = [
          'Your water intake time is here! Stay hydrated for healthy kidneys \u{1F4A7}',
          'Time to drink water! Dehydration causes fatigue and headaches.',
          'Water break! Your body needs hydration to stay energized \u{1F4AA}',
          "Don't forget your water! Healthy kidneys need regular hydration.",
          'Hydration check! Drink a glass now to keep your metabolism active.',
        ];
        return msgs[DateTime.now().second % msgs.length];

      case 'meal':
        final msgs = [
          "It's meal time! Fuel your body with nutritious food \u{1F957}",
          'Time to eat! Skipping meals slows your metabolism.',
          'Meal reminder! Your body needs fuel to perform at its best.',
        ];
        return msgs[DateTime.now().second % msgs.length];

      case 'workout':
        final msgs = [
          'Workout time! Even 20 minutes of exercise boosts your mood \u{1F4AA}',
          "Time to move! Your body is made to be active. Let's go!",
          'Exercise reminder! Consistency beats intensity. Start now!',
        ];
        return msgs[DateTime.now().second % msgs.length];

      case 'sleep':
        final msgs = [
          'Time to wind down! Good sleep = better tomorrow \u{1F319}',
          'Sleep reminder! Put your phone down and rest for 7-8 hours.',
          'Bedtime approaching! Quality sleep repairs your body and mind.',
        ];
        return msgs[DateTime.now().second % msgs.length];

      case 'walk':
        final msgs = [
          'Walking break! A short walk aids digestion and boosts focus \u{1F6B6}',
          'Time for a walk! 15 minutes of walking burns 50+ calories.',
          'Step outside for a walk! Fresh air and movement do wonders.',
        ];
        return msgs[DateTime.now().second % msgs.length];

      case 'protein':
        final msgs = [
          'Protein time! Your muscles need fuel to grow and recover \u{1F4AA}',
          'Time for your protein shake! Recovery starts now.',
        ];
        return msgs[DateTime.now().second % msgs.length];

      case 'snack':
        final msgs = [
          'Snack time! A healthy snack keeps your energy steady \u{1F34E}',
          'Time for a quick bite! Choose something nutritious.',
        ];
        return msgs[DateTime.now().second % msgs.length];

      default:
        return extra ?? 'VitaTrack reminder: $type';
    }
  }

  /// Returns an overdue-specific contextual message.
  static String getOverdueMessage(String type, String title, int minutesLate) {
    final lateStr = minutesLate >= 60
        ? '${(minutesLate / 60).floor()}h ${minutesLate % 60}m'
        : '${minutesLate}min';

    switch (type) {
      case 'water':
        return '⚠️ You\'re $lateStr late on "$title"! Dehydration causes fatigue, headaches & slows metabolism. Drink water now!';
      case 'meal':
        return '⚠️ "$title" is $lateStr overdue! Skipping or delaying meals disrupts blood sugar & leads to overeating later.';
      case 'workout':
        return '💪 "$title" is $lateStr overdue! Even a quick 15-min session is better than skipping. Start now!';
      case 'sleep':
        return '🌙 "$title" was $lateStr ago! Late sleep affects hormones, recovery & tomorrow\'s energy. Wind down now.';
      case 'walk':
        return '🚶 "$title" is $lateStr overdue! A short walk aids digestion & boosts focus. Step out for 10 min.';
      case 'protein':
        return '🥤 "$title" is $lateStr overdue! Your muscles need protein for recovery. Have it now!';
      case 'snack':
        return '🍎 "$title" is $lateStr overdue! A healthy snack keeps energy levels stable.';
      default:
        return '⏰ "$title" is $lateStr overdue! Try to complete it now to stay on track.';
    }
  }

  // ─── Schedule Reminders from App State ─────────────────────
  Future<void> syncReminders(List<dynamic> reminders) async {
    if (!_initialized) await initialize();

    // Cancel all existing scheduled notifications first
    await cancelAll();

    for (int i = 0; i < reminders.length; i++) {
      final r = reminders[i];
      final enabled = r.enabled as bool;
      if (!enabled) continue;

      final type = r.type as String;
      final time = r.time as String;
      final title = r.title as String;
      final parts = time.split(':');
      if (parts.length != 2) continue;

      final hour = int.tryParse(parts[0]) ?? 8;
      final minute = int.tryParse(parts[1]) ?? 0;

      await scheduleDailyNotification(
        id: 1000 + i,
        title: title,
        body: getSmartMessage(type),
        hour: hour,
        minute: minute,
      );
    }
  }

  // ─── Schedule Water Interval Reminders ─────────────────────
  Future<void> syncWaterReminders({
    required bool enabled,
    required int intervalMinutes,
    required String startTime,
    required String endTime,
    required int mlPerReminder,
  }) async {
    if (!_initialized) await initialize();

    // Cancel water channel (IDs 2000-2099)
    for (int i = 2000; i < 2100; i++) {
      await cancelNotification(i);
    }

    if (!enabled) return;

    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    if (startParts.length != 2 || endParts.length != 2) return;

    final startMin = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMin = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    int id = 2000;
    for (int min = startMin; min <= endMin && id < 2100; min += intervalMinutes) {
      final hour = min ~/ 60;
      final minute = min % 60;
      await scheduleDailyNotification(
        id: id++,
        title: '\u{1F4A7} Water Reminder',
        body: getSmartMessage('water'),
        hour: hour,
        minute: minute,
      );
    }
  }

  // ─── Schedule Notifications from Daily Schedule ────────────
  /// Schedules daily notifications for ALL schedule items that have
  /// reminders enabled (remOn == true). This ensures the user gets
  /// a notification at the exact time each activity is due.
  Future<void> syncScheduleNotifications(List<dynamic> scheduleItems, {Set<String> skippedIds = const {}}) async {
    if (!_initialized) await initialize();

    // Cancel schedule-based notification IDs (3000-3199) and Overdue IDs (4000-4199)
    for (int i = 3000; i < 3200; i++) {
      await cancelNotification(i);
    }
    for (int i = 4000; i < 4200; i++) {
      await cancelNotification(i);
    }

    int id = 3000;
    int overdueId = 4000;
    for (final item in scheduleItems) {
      if (id >= 3200) break;

      final time = item.time as String;
      final title = item.title as String;
      final type = item.type;
      final icon = item.icon as String;
      final done = item.done as bool;
      final itemId = item.id as String;
      final remOn = item.remOn as bool? ?? true;

      final parts = time.split(':');
      if (parts.length != 2) continue;

      final hour = int.tryParse(parts[0]) ?? 8;
      final minute = int.tryParse(parts[1]) ?? 0;

      // Map ScheduleItemType to string for smart message
      final typeStr = _scheduleTypeToString(type);

      if (remOn) {
        await scheduleDailyNotification(
          id: id++,
          title: '$icon $title',
          body: getSmartMessage(typeStr),
          hour: hour,
          minute: minute,
        );
      }

      // Pre-schedule Overdue Notification
      if (!done && !skippedIds.contains(itemId)) {
        final gracePeriod = _getGracePeriod(typeStr);
        final overdueTime = tz.TZDateTime.now(tz.local).copyWith(hour: hour, minute: minute).add(Duration(minutes: gracePeriod));
        
        await scheduleDailyNotification(
           id: overdueId++,
           title: '$icon $title — Overdue!',
           body: getOverdueMessage(typeStr, title, gracePeriod),
           hour: overdueTime.hour,
           minute: overdueTime.minute,
        );
      }
    }
  }

  /// Convert a ScheduleItemType enum to its string key
  String _scheduleTypeToString(dynamic type) {
    final str = type.toString().split('.').last;
    return str;
  }

  // ─── Water Overdue Pre-scheduling ──────────────────────────
  Future<void> syncWaterOverdue(dynamic waterConfig) async {
    if (!_initialized) await initialize();

    // Cancel existing water overdue notifications (4500-4502)
    for (int i = 4500; i <= 4502; i++) {
      await cancelNotification(i);
    }

    if (waterConfig == null) return;
    final consumed = (waterConfig.consumed as double?) ?? 0.0;
    final target = (waterConfig.target as double?) ?? 2500.0;
    final pct = target > 0 ? consumed / target : 0.0;

    // If they haven't met the threshold, schedule warnings for later today.
    // When they drink water and this method is called again, if they've met the threshold,
    // the previous cancellations (above) will effectively clear the warning!
    
    if (pct < 0.25) {
      await scheduleDailyNotification(
        id: 4500,
        title: '💧 Water intake critically low!',
        body: 'It\'s past noon and you\'re falling behind. Drink 2 glasses now! Dehydration causes headaches & fatigue.',
        hour: 12,
        minute: 0,
      );
    }
    
    if (pct < 0.40) {
      await scheduleDailyNotification(
        id: 4501,
        title: '💧 Still behind on water!',
        body: 'You need more water today. Drink regularly to keep your metabolism active!',
        hour: 15,
        minute: 0,
      );
    }
    
    if (pct < 0.60) {
      await scheduleDailyNotification(
        id: 4502,
        title: '💧 Evening water reminder',
        body: 'Evening is winding down — try to hit at least 75% of your water target before bed.',
        hour: 18,
        minute: 0,
      );
    }
  }



  /// Grace period (in minutes) before an overdue notification is sent.
  /// Different activity types get different grace periods.
  int _getGracePeriod(String type) {
    switch (type) {
      case 'water':
        return 15; // Water should be on time — 15 min grace
      case 'meal':
        return 30; // 30 min grace for meals
      case 'workout':
        return 20; // 20 min grace for workouts
      case 'walk':
        return 20;
      case 'sleep':
        return 30; // 30 min grace for sleep
      case 'protein':
        return 15;
      case 'snack':
        return 30;
      default:
        return 30; // Default 30 min
    }
  }
}

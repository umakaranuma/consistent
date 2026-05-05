import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Centralized notification service for VitaTrack.
/// Handles permission requests, scheduling, and context-aware messages.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ─── Notification Details ──────────────────────────────────
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

  // ─── Initialization ────────────────────────────────────────
  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

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
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
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
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
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

      default:
        return extra ?? 'VitaTrack reminder: $type';
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
}

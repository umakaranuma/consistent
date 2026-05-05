import '../store/types.dart';
import 'dart:math';

class WaterReminderSlot {
  final String time;
  final double ml;

  WaterReminderSlot({required this.time, required this.ml});
}

class WaterEngine {
  static double calculateWaterTarget(double weightKg, AppMode mode) {
    final mlPerKg = mode == AppMode.gym ? 40 : 35;
    return ((weightKg * mlPerKg) / 250).round() * 250.0;
  }

  static int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  static String _minutesToTime(int minutes) {
    final h = (minutes ~/ 60) % 24;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  static List<WaterReminderSlot> buildWaterSchedule(WaterConfig config) {
    final startMinutes = _timeToMinutes(config.reminderStartTime);
    final endMinutes = _timeToMinutes(config.reminderEndTime);
    final List<WaterReminderSlot> slots = [];

    int current = startMinutes;
    double totalScheduled = 0;

    while (current <= endMinutes && totalScheduled < config.target) {
      final remaining = config.target - totalScheduled;
      final ml = min(config.mlPerReminder, remaining);
      
      slots.add(WaterReminderSlot(
        time: _minutesToTime(current),
        ml: ml,
      ));
      
      totalScheduled += ml;
      current += config.reminderIntervalMinutes.toInt();
    }

    return slots;
  }
}

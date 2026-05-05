enum AppMode { normal, gym }

enum BmiCategory { underweight, normal, overweight, obese }

enum GymGoal { fatLoss, muscleGain, maintenance, recomp }

enum ScheduleItemType { meal, water, workout, snack, sleep, walk, protein, custom }

class ScheduleItem {
  final String id;
  final String time; // "HH:MM" 24h
  final String title;
  final String sub; // description
  final String icon; // emoji
  final ScheduleItemType type;
  final double calories; // kcal
  final double protein; // grams
  final double carbs; // grams
  final double fat; // grams
  final bool done;
  final bool remOn;
  final bool isCustom;

  ScheduleItem({
    required this.id,
    required this.time,
    required this.title,
    required this.sub,
    required this.icon,
    required this.type,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.done,
    required this.remOn,
    required this.isCustom,
  });
}

class MacroTargets {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  MacroTargets({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class WaterConfig {
  final double consumed;
  final double target;
  final bool reminderEnabled;
  final double reminderIntervalMinutes;
  final String reminderStartTime;
  final String reminderEndTime;
  final double mlPerReminder;

  WaterConfig({
    required this.consumed,
    required this.target,
    required this.reminderEnabled,
    required this.reminderIntervalMinutes,
    required this.reminderStartTime,
    required this.reminderEndTime,
    required this.mlPerReminder,
  });
}

class WeightEntry {
  final String date; // "YYYY-MM-DD"
  final double weight;
  final double bmi;

  WeightEntry({
    required this.date,
    required this.weight,
    required this.bmi,
  });
}

class UserProfile {
  final String name;
  final double heightCm;
  final double currentWeight;
  final double goalWeight;
  final double bmi;
  final BmiCategory bmiCategory;
  final AppMode mode;
  final GymGoal? gymGoal; // Optional, only for gym mode
  final double stepGoal;
  final MacroTargets macroTargets;
  final String units; // 'metric' | 'imperial'
  final String workStartTime;
  final String workEndTime;
  final String sleepTime;
  final bool pushEnabled;
  final bool workoutReminders;
  final bool sleepReminder;
  final bool planLockedByUser;

  UserProfile({
    required this.name,
    required this.heightCm,
    required this.currentWeight,
    required this.goalWeight,
    required this.bmi,
    required this.bmiCategory,
    required this.mode,
    this.gymGoal,
    required this.stepGoal,
    required this.macroTargets,
    required this.units,
    required this.workStartTime,
    required this.workEndTime,
    required this.sleepTime,
    required this.pushEnabled,
    required this.workoutReminders,
    required this.sleepReminder,
    required this.planLockedByUser,
  });
}

class Reminder {
  final String id;
  final String title;
  final String time; // "HH:MM"
  final String type; // ScheduleItemType string | 'custom'
  final String repeat; // 'daily' | 'weekday' | 'once'
  final bool enabled;
  final String? notifId;

  Reminder({
    required this.id,
    required this.title,
    required this.time,
    required this.type,
    required this.repeat,
    required this.enabled,
    this.notifId,
  });
}

class LogEntry {
  final String time;
  final String message;

  LogEntry({required this.time, required this.message});
}

class DayRecord {
  final String date; // "YYYY-MM-DD"
  final String status; // 'success' | 'partial' | 'failed' | 'none'
  final double dietScore;
  final double waterScore;
  final bool workoutDone;
  final double calorieScore;
  final double proteinScore;
  final double waterConsumed;
  final double caloriesEaten;
  final double proteinEaten;
  final double bmiAtDay;
  final List<LogEntry> log;

  DayRecord({
    required this.date,
    required this.status,
    required this.dietScore,
    required this.waterScore,
    required this.workoutDone,
    required this.calorieScore,
    required this.proteinScore,
    required this.waterConsumed,
    required this.caloriesEaten,
    required this.proteinEaten,
    required this.bmiAtDay,
    required this.log,
  });
}

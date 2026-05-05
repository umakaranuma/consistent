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

  ScheduleItem copyWith({
    String? id,
    String? time,
    String? title,
    String? sub,
    String? icon,
    ScheduleItemType? type,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    bool? done,
    bool? remOn,
    bool? isCustom,
  }) {
    return ScheduleItem(
      id: id ?? this.id,
      time: time ?? this.time,
      title: title ?? this.title,
      sub: sub ?? this.sub,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      done: done ?? this.done,
      remOn: remOn ?? this.remOn,
      isCustom: isCustom ?? this.isCustom,
    );
  }
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

  MacroTargets copyWith({double? calories, double? protein, double? carbs, double? fat}) {
    return MacroTargets(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }
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

  WaterConfig copyWith({
    double? consumed,
    double? target,
    bool? reminderEnabled,
    double? reminderIntervalMinutes,
    String? reminderStartTime,
    String? reminderEndTime,
    double? mlPerReminder,
  }) {
    return WaterConfig(
      consumed: consumed ?? this.consumed,
      target: target ?? this.target,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderIntervalMinutes: reminderIntervalMinutes ?? this.reminderIntervalMinutes,
      reminderStartTime: reminderStartTime ?? this.reminderStartTime,
      reminderEndTime: reminderEndTime ?? this.reminderEndTime,
      mlPerReminder: mlPerReminder ?? this.mlPerReminder,
    );
  }
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
  final double age;
  final String gender; // 'male' | 'female'
  final double heightCm;
  final double currentWeight;
  final double goalWeight;
  final double bmi;
  final BmiCategory bmiCategory;
  final AppMode mode;
  final GymGoal? gymGoal;
  final double stepGoal;
  final MacroTargets macroTargets;
  final String units; // 'metric' | 'imperial'
  final String activityLevel; // 'sedentary' | 'light' | 'moderate' | 'active' | 'very_active'
  final String workStartTime;
  final String workEndTime;
  final String sleepTime;
  final bool pushEnabled;
  final bool workoutReminders;
  final bool sleepReminder;
  final bool planLockedByUser;

  UserProfile({
    required this.name,
    this.age = 25,
    this.gender = 'male',
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
    this.activityLevel = 'moderate',
    required this.workStartTime,
    required this.workEndTime,
    required this.sleepTime,
    required this.pushEnabled,
    required this.workoutReminders,
    required this.sleepReminder,
    required this.planLockedByUser,
  });

  UserProfile copyWith({
    String? name,
    double? age,
    String? gender,
    double? heightCm,
    double? currentWeight,
    double? goalWeight,
    double? bmi,
    BmiCategory? bmiCategory,
    AppMode? mode,
    GymGoal? gymGoal,
    double? stepGoal,
    MacroTargets? macroTargets,
    String? units,
    String? activityLevel,
    String? workStartTime,
    String? workEndTime,
    String? sleepTime,
    bool? pushEnabled,
    bool? workoutReminders,
    bool? sleepReminder,
    bool? planLockedByUser,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      currentWeight: currentWeight ?? this.currentWeight,
      goalWeight: goalWeight ?? this.goalWeight,
      bmi: bmi ?? this.bmi,
      bmiCategory: bmiCategory ?? this.bmiCategory,
      mode: mode ?? this.mode,
      gymGoal: gymGoal ?? this.gymGoal,
      stepGoal: stepGoal ?? this.stepGoal,
      macroTargets: macroTargets ?? this.macroTargets,
      units: units ?? this.units,
      activityLevel: activityLevel ?? this.activityLevel,
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
      sleepTime: sleepTime ?? this.sleepTime,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      workoutReminders: workoutReminders ?? this.workoutReminders,
      sleepReminder: sleepReminder ?? this.sleepReminder,
      planLockedByUser: planLockedByUser ?? this.planLockedByUser,
    );
  }
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

/// A food item from the local food database
class FoodItem {
  final String id;
  final String name;
  final String category; // 'breakfast', 'lunch', 'dinner', 'snack'
  final String description;
  final String icon;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String servingSize;

  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.icon,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
  });
}

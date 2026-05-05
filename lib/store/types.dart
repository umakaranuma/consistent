import 'package:hive/hive.dart';

part 'types.g.dart';

@HiveType(typeId: 0)
enum AppMode {
  @HiveField(0) normal,
  @HiveField(1) gym,
}

@HiveType(typeId: 1)
enum BmiCategory {
  @HiveField(0) underweight,
  @HiveField(1) normal,
  @HiveField(2) overweight,
  @HiveField(3) obese,
}

@HiveType(typeId: 2)
enum GymGoal {
  @HiveField(0) fatLoss,
  @HiveField(1) muscleGain,
  @HiveField(2) maintenance,
  @HiveField(3) recomp,
}

@HiveType(typeId: 3)
enum ScheduleItemType {
  @HiveField(0) meal,
  @HiveField(1) water,
  @HiveField(2) workout,
  @HiveField(3) snack,
  @HiveField(4) sleep,
  @HiveField(5) walk,
  @HiveField(6) protein,
  @HiveField(7) custom,
}

@HiveType(typeId: 4)
class ScheduleItem {
  @HiveField(0) final String id;
  @HiveField(1) final String time; // "HH:MM" 24h
  @HiveField(2) final String title;
  @HiveField(3) final String sub; // description
  @HiveField(4) final String icon; // emoji
  @HiveField(5) final ScheduleItemType type;
  @HiveField(6) final double calories; // kcal
  @HiveField(7) final double protein; // grams
  @HiveField(8) final double carbs; // grams
  @HiveField(9) final double fat; // grams
  @HiveField(10) final bool done;
  @HiveField(11) final bool remOn;
  @HiveField(12) final bool isCustom;

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

@HiveType(typeId: 5)
class MacroTargets {
  @HiveField(0) final double calories;
  @HiveField(1) final double protein;
  @HiveField(2) final double carbs;
  @HiveField(3) final double fat;

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

@HiveType(typeId: 6)
class WaterConfig {
  @HiveField(0) final double consumed;
  @HiveField(1) final double target;
  @HiveField(2) final bool reminderEnabled;
  @HiveField(3) final double reminderIntervalMinutes;
  @HiveField(4) final String reminderStartTime;
  @HiveField(5) final String reminderEndTime;
  @HiveField(6) final double mlPerReminder;

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

@HiveType(typeId: 7)
class WeightEntry {
  @HiveField(0) final String date; // "YYYY-MM-DD"
  @HiveField(1) final double weight;
  @HiveField(2) final double bmi;

  WeightEntry({
    required this.date,
    required this.weight,
    required this.bmi,
  });
}

@HiveType(typeId: 8)
class UserProfile {
  @HiveField(0) final String name;
  @HiveField(1) final double age;
  @HiveField(2) final String gender; // 'male' | 'female'
  @HiveField(3) final double heightCm;
  @HiveField(4) final double currentWeight;
  @HiveField(5) final double goalWeight;
  @HiveField(6) final double bmi;
  @HiveField(7) final BmiCategory bmiCategory;
  @HiveField(8) final AppMode mode;
  @HiveField(9) final GymGoal? gymGoal;
  @HiveField(10) final double stepGoal;
  @HiveField(11) final MacroTargets macroTargets;
  @HiveField(12) final String units; // 'metric' | 'imperial'
  @HiveField(13) final String activityLevel; // 'sedentary' | 'light' | 'moderate' | 'active' | 'very_active'
  @HiveField(14) final String workStartTime;
  @HiveField(15) final String workEndTime;
  @HiveField(16) final String sleepTime;
  @HiveField(17) final bool pushEnabled;
  @HiveField(18) final bool workoutReminders;
  @HiveField(19) final bool sleepReminder;
  @HiveField(20) final bool planLockedByUser;

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

@HiveType(typeId: 9)
class Reminder {
  @HiveField(0) final String id;
  @HiveField(1) final String title;
  @HiveField(2) final String time; // "HH:MM"
  @HiveField(3) final String type; // ScheduleItemType string | 'custom'
  @HiveField(4) final String repeat; // 'daily' | 'weekday' | 'once'
  @HiveField(5) final bool enabled;
  @HiveField(6) final String? notifId;

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

@HiveType(typeId: 10)
class LogEntry {
  @HiveField(0) final String time;
  @HiveField(1) final String message;

  LogEntry({required this.time, required this.message});
}

@HiveType(typeId: 11)
class DayRecord {
  @HiveField(0) final String date; // "YYYY-MM-DD"
  @HiveField(1) final String status; // 'success' | 'partial' | 'failed' | 'none'
  @HiveField(2) final double dietScore;
  @HiveField(3) final double waterScore;
  @HiveField(4) final bool workoutDone;
  @HiveField(5) final double calorieScore;
  @HiveField(6) final double proteinScore;
  @HiveField(7) final double waterConsumed;
  @HiveField(8) final double caloriesEaten;
  @HiveField(9) final double proteinEaten;
  @HiveField(10) final double bmiAtDay;
  @HiveField(11) final List<LogEntry> log;

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

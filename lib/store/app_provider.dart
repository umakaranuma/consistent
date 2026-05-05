import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'types.dart';
import '../utils/bmi_engine.dart';

class AppState {
  final UserProfile? profile;
  final WaterConfig? waterConfig;
  final List<ScheduleItem> schedule;
  final List<Reminder> reminders;
  final List<DayRecord> records;
  final List<WeightEntry> weightEntries;
  final List<LogEntry> activityLog;
  final int streak;
  
  AppState({
    this.profile,
    this.waterConfig,
    this.schedule = const [],
    this.reminders = const [],
    this.records = const [],
    this.weightEntries = const [],
    this.activityLog = const [],
    this.streak = 0,
  });

  AppState copyWith({
    UserProfile? profile,
    WaterConfig? waterConfig,
    List<ScheduleItem>? schedule,
    List<Reminder>? reminders,
    List<DayRecord>? records,
    List<WeightEntry>? weightEntries,
    List<LogEntry>? activityLog,
    int? streak,
  }) {
    return AppState(
      profile: profile ?? this.profile,
      waterConfig: waterConfig ?? this.waterConfig,
      schedule: schedule ?? this.schedule,
      reminders: reminders ?? this.reminders,
      records: records ?? this.records,
      weightEntries: weightEntries ?? this.weightEntries,
      activityLog: activityLog ?? this.activityLog,
      streak: streak ?? this.streak,
    );
  }
}

class AppNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    // Default state with generated plan — will be overwritten by onboarding
    final defaultProfile = UserProfile(
      name: 'User',
      age: 25,
      gender: 'male',
      heightCm: 170,
      currentWeight: 75,
      goalWeight: 65,
      bmi: 25.9,
      bmiCategory: BmiCategory.overweight,
      mode: AppMode.normal,
      stepGoal: 10000,
      macroTargets: MacroTargets(calories: 2000, protein: 120, carbs: 200, fat: 55),
      units: 'metric',
      activityLevel: 'moderate',
      workStartTime: '09:00',
      workEndTime: '18:00',
      sleepTime: '23:00',
      pushEnabled: true,
      workoutReminders: true,
      sleepReminder: true,
      planLockedByUser: false,
    );

    final waterConfig = WaterConfig(
      consumed: 0,
      target: 2750,
      reminderEnabled: true,
      reminderIntervalMinutes: 60,
      reminderStartTime: '08:00',
      reminderEndTime: '21:00',
      mlPerReminder: 250,
    );

    final defaultSchedule = BmiEngine.generatePlan(defaultProfile);

    return AppState(
      profile: defaultProfile,
      waterConfig: waterConfig,
      schedule: defaultSchedule,
    );
  }

  // ─── Profile ─────────────────────────────────────────────
  void setProfile(UserProfile profile) {
    state = state.copyWith(profile: profile);
  }

  void updateProfile(UserProfile profile) {
    state = state.copyWith(profile: profile);
  }

  // ─── Water ───────────────────────────────────────────────
  void setWaterConfig(WaterConfig config) {
    state = state.copyWith(waterConfig: config);
  }

  void addWater(double ml) {
    if (state.waterConfig != null) {
      final config = state.waterConfig!;
      state = state.copyWith(
        waterConfig: config.copyWith(consumed: config.consumed + ml),
      );
      _addLog('Added ${ml.toInt()}ml water');
    }
  }

  void resetWater() {
    if (state.waterConfig != null) {
      state = state.copyWith(
        waterConfig: state.waterConfig!.copyWith(consumed: 0),
      );
    }
  }

  // ─── Schedule ────────────────────────────────────────────
  void setSchedule(List<ScheduleItem> schedule) {
    state = state.copyWith(schedule: schedule);
  }

  void toggleScheduleItem(String id) {
    final schedule = state.schedule.map((item) {
      if (item.id == id) {
        final toggled = item.copyWith(done: !item.done);
        _addLog(toggled.done ? 'Completed: ${item.title}' : 'Unchecked: ${item.title}');
        return toggled;
      }
      return item;
    }).toList();
    state = state.copyWith(schedule: schedule);
  }

  void updateScheduleItem(String id, ScheduleItem updated) {
    final schedule = state.schedule.map((item) {
      return item.id == id ? updated : item;
    }).toList();
    schedule.sort((a, b) => a.time.compareTo(b.time));
    state = state.copyWith(schedule: schedule);
    // Mark plan as user-edited
    if (state.profile != null) {
      state = state.copyWith(
        profile: state.profile!.copyWith(planLockedByUser: true),
      );
    }
  }

  void addScheduleItem(ScheduleItem item) {
    final schedule = [...state.schedule, item];
    schedule.sort((a, b) => a.time.compareTo(b.time));
    state = state.copyWith(schedule: schedule);
    if (state.profile != null) {
      state = state.copyWith(
        profile: state.profile!.copyWith(planLockedByUser: true),
      );
    }
  }

  void deleteScheduleItem(String id) {
    final schedule = state.schedule.where((i) => i.id != id).toList();
    state = state.copyWith(schedule: schedule);
    if (state.profile != null) {
      state = state.copyWith(
        profile: state.profile!.copyWith(planLockedByUser: true),
      );
    }
  }

  void regeneratePlan() {
    if (state.profile != null) {
      final plan = BmiEngine.generatePlan(state.profile!);
      state = state.copyWith(
        schedule: plan,
        profile: state.profile!.copyWith(planLockedByUser: false),
      );
    }
  }

  void resetDailySchedule() {
    final schedule = state.schedule.map((item) => item.copyWith(done: false)).toList();
    state = state.copyWith(schedule: schedule);
    resetWater();
    clearActivityLog();
  }

  // ─── Weight Entries ──────────────────────────────────────
  void addWeightEntry(WeightEntry entry) {
    final entries = List<WeightEntry>.from(state.weightEntries)..add(entry);
    entries.sort((a, b) => a.date.compareTo(b.date));
    state = state.copyWith(weightEntries: entries);

    // Cascade: recalculate BMI, macros, water target
    if (state.profile != null) {
      final profile = state.profile!;
      final weightKg = entry.weight;
      final newBmi = BmiEngine.calculateBmi(weightKg, profile.heightCm);
      final newCat = BmiEngine.getBmiCategory(newBmi);
      final tdee = BmiEngine.calculateTDEE(
        weightKg: weightKg,
        heightCm: profile.heightCm,
        ageYears: profile.age,
        gender: profile.gender,
        activityLevel: profile.activityLevel,
      );
      final calTarget = BmiEngine.getCalorieTarget(
        tdee: tdee, bmiCategory: newCat, mode: profile.mode, gymGoal: profile.gymGoal,
      );
      final macros = BmiEngine.getMacroTargets(
        calories: calTarget, weightKg: weightKg, mode: profile.mode, gymGoal: profile.gymGoal,
      );
      final waterTarget = BmiEngine.getWaterTarget(weightKg, profile.mode);

      final updatedProfile = profile.copyWith(
        currentWeight: weightKg,
        bmi: newBmi,
        bmiCategory: newCat,
        macroTargets: macros,
      );
      state = state.copyWith(
        profile: updatedProfile,
        waterConfig: state.waterConfig?.copyWith(target: waterTarget),
      );

      // Auto-regenerate plan if BMI category changed
      if (newCat != profile.bmiCategory && !profile.planLockedByUser) {
        final plan = BmiEngine.generatePlan(updatedProfile);
        state = state.copyWith(schedule: plan);
      }

      _addLog('Weight: ${entry.weight}kg · BMI $newBmi');
    }
  }

  // ─── Activity Log ────────────────────────────────────────
  void _addLog(String message) {
    final now = DateTime.now();
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final log = [LogEntry(time: time, message: message), ...state.activityLog];
    state = state.copyWith(activityLog: log);
  }

  void clearActivityLog() {
    state = state.copyWith(activityLog: []);
  }

  // ─── Reminders ───────────────────────────────────────────
  void setReminders(List<Reminder> reminders) {
    state = state.copyWith(reminders: reminders);
  }

  void addReminder(Reminder reminder) {
    state = state.copyWith(reminders: [...state.reminders, reminder]);
  }

  void toggleReminder(String id) {
    final reminders = state.reminders.map((r) {
      if (r.id == id) {
        return Reminder(
          id: r.id, title: r.title, time: r.time,
          type: r.type, repeat: r.repeat,
          enabled: !r.enabled, notifId: r.notifId,
        );
      }
      return r;
    }).toList();
    state = state.copyWith(reminders: reminders);
  }

  void deleteReminder(String id) {
    state = state.copyWith(
      reminders: state.reminders.where((r) => r.id != id).toList(),
    );
  }

  // ─── Computed Helpers ────────────────────────────────────
  double get caloriesEaten =>
    state.schedule.where((i) => i.done).fold(0.0, (s, i) => s + i.calories);

  double get proteinEaten =>
    state.schedule.where((i) => i.done).fold(0.0, (s, i) => s + i.protein);

  double get carbsEaten =>
    state.schedule.where((i) => i.done).fold(0.0, (s, i) => s + i.carbs);

  double get fatEaten =>
    state.schedule.where((i) => i.done).fold(0.0, (s, i) => s + i.fat);

  int get dietScore {
    final meals = state.schedule.where((i) => i.type == ScheduleItemType.meal).toList();
    if (meals.isEmpty) return 0;
    return (meals.where((i) => i.done).length / meals.length * 100).round();
  }

  int get waterScore {
    final config = state.waterConfig;
    if (config == null || config.target == 0) return 0;
    return (config.consumed / config.target * 100).clamp(0, 100).round();
  }
}

final appProvider = NotifierProvider<AppNotifier, AppState>(() {
  return AppNotifier();
});

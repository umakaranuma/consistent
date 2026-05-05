import 'package:hive_flutter/hive_flutter.dart';
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
  late Box _box;

  @override
  AppState build() {
    _box = Hive.box('vitatrack_data');

    final profile = _box.get('profile') as UserProfile?;
    final waterConfig = _box.get('waterConfig') as WaterConfig?;
    final schedule = (_box.get('schedule') as List?)?.cast<ScheduleItem>() ?? [];
    final reminders = (_box.get('reminders') as List?)?.cast<Reminder>() ?? [];
    final records = (_box.get('records') as List?)?.cast<DayRecord>() ?? [];
    final weightEntries = (_box.get('weightEntries') as List?)?.cast<WeightEntry>() ?? [];
    final activityLog = (_box.get('activityLog') as List?)?.cast<LogEntry>() ?? [];
    final streak = _box.get('streak', defaultValue: 0) as int;

    return AppState(
      profile: profile,
      waterConfig: waterConfig,
      schedule: schedule,
      reminders: reminders,
      records: records,
      weightEntries: weightEntries,
      activityLog: activityLog,
      streak: streak,
    );
  }

  void _saveState(AppState newState) {
    state = newState;
    _box.put('profile', state.profile);
    _box.put('waterConfig', state.waterConfig);
    _box.put('schedule', state.schedule);
    _box.put('reminders', state.reminders);
    _box.put('records', state.records);
    _box.put('weightEntries', state.weightEntries);
    _box.put('activityLog', state.activityLog);
    _box.put('streak', state.streak);
  }

  // ─── Profile ─────────────────────────────────────────────
  void setProfile(UserProfile profile) {
    _saveState(state.copyWith(profile: profile));
  }

  void updateProfile(UserProfile profile) {
    _saveState(state.copyWith(profile: profile));
  }

  // ─── Water ───────────────────────────────────────────────
  void setWaterConfig(WaterConfig config) {
    _saveState(state.copyWith(waterConfig: config));
  }

  void addWater(double ml) {
    if (state.waterConfig != null) {
      final config = state.waterConfig!;
      _saveState(state.copyWith(
        waterConfig: config.copyWith(consumed: config.consumed + ml),
      ));
      _addLog('Added ${ml.toInt()}ml water');
    }
  }

  void resetWater() {
    if (state.waterConfig != null) {
      _saveState(state.copyWith(
        waterConfig: state.waterConfig!.copyWith(consumed: 0),
      ));
    }
  }

  // ─── Schedule ────────────────────────────────────────────
  void setSchedule(List<ScheduleItem> schedule) {
    _saveState(state.copyWith(schedule: schedule));
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
    _saveState(state.copyWith(schedule: schedule));
  }

  void updateScheduleItem(String id, ScheduleItem updated) {
    final schedule = state.schedule.map((item) {
      return item.id == id ? updated : item;
    }).toList();
    schedule.sort((a, b) => a.time.compareTo(b.time));
    var newState = state.copyWith(schedule: schedule);
    // Mark plan as user-edited
    if (newState.profile != null) {
      newState = newState.copyWith(
        profile: newState.profile!.copyWith(planLockedByUser: true),
      );
    }
    _saveState(newState);
  }

  void addScheduleItem(ScheduleItem item) {
    final schedule = [...state.schedule, item];
    schedule.sort((a, b) => a.time.compareTo(b.time));
    var newState = state.copyWith(schedule: schedule);
    if (newState.profile != null) {
      newState = newState.copyWith(
        profile: newState.profile!.copyWith(planLockedByUser: true),
      );
    }
    _saveState(newState);
  }

  void deleteScheduleItem(String id) {
    final schedule = state.schedule.where((i) => i.id != id).toList();
    var newState = state.copyWith(schedule: schedule);
    if (newState.profile != null) {
      newState = newState.copyWith(
        profile: newState.profile!.copyWith(planLockedByUser: true),
      );
    }
    _saveState(newState);
  }

  void regeneratePlan() {
    if (state.profile != null) {
      final plan = BmiEngine.generatePlan(state.profile!);
      _saveState(state.copyWith(
        schedule: plan,
        profile: state.profile!.copyWith(planLockedByUser: false),
      ));
    }
  }

  void resetDailySchedule() {
    final schedule = state.schedule.map((item) => item.copyWith(done: false)).toList();
    _saveState(state.copyWith(schedule: schedule));
    resetWater();
    clearActivityLog();
  }

  // ─── Weight Entries ──────────────────────────────────────
  void addWeightEntry(WeightEntry entry) {
    final entries = List<WeightEntry>.from(state.weightEntries)..add(entry);
    entries.sort((a, b) => a.date.compareTo(b.date));
    var newState = state.copyWith(weightEntries: entries);

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
      newState = newState.copyWith(
        profile: updatedProfile,
        waterConfig: newState.waterConfig?.copyWith(target: waterTarget),
      );

      // Auto-regenerate plan if BMI category changed
      if (newCat != profile.bmiCategory && !profile.planLockedByUser) {
        final plan = BmiEngine.generatePlan(updatedProfile);
        newState = newState.copyWith(schedule: plan);
      }

      _saveState(newState);
      _addLog('Weight: ${entry.weight}kg · BMI $newBmi');
    }
  }

  // ─── Activity Log ────────────────────────────────────────
  void _addLog(String message) {
    final now = DateTime.now();
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final log = [LogEntry(time: time, message: message), ...state.activityLog];
    _saveState(state.copyWith(activityLog: log));
  }

  void clearActivityLog() {
    _saveState(state.copyWith(activityLog: []));
  }

  // ─── Reminders ───────────────────────────────────────────
  void setReminders(List<Reminder> reminders) {
    _saveState(state.copyWith(reminders: reminders));
  }

  void addReminder(Reminder reminder) {
    _saveState(state.copyWith(reminders: [...state.reminders, reminder]));
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
    _saveState(state.copyWith(reminders: reminders));
  }

  void deleteReminder(String id) {
    _saveState(state.copyWith(
      reminders: state.reminders.where((r) => r.id != id).toList(),
    ));
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

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

  // ─── Food Calorie Overrides ─────────────────────────────
  /// Get all user calorie overrides (foodId -> caloriesPerServing)
  Map<String, double> get calorieOverrides {
    final raw = _box.get('calorieOverrides');
    if (raw == null) return {};
    return Map<String, double>.from(raw as Map);
  }

  /// Set a calorie override for a food item.
  /// [foodId] is the food database ID, [caloriesPerServing] is the
  /// total calories for the full serving.  Past ScheduleItems are
  /// NOT affected — only new additions will use this value.
  void setCalorieOverride(String foodId, double caloriesPerServing) {
    final overrides = calorieOverrides;
    overrides[foodId] = caloriesPerServing;
    _box.put('calorieOverrides', overrides);
  }

  /// Remove a calorie override (revert to database default)
  void removeCalorieOverride(String foodId) {
    final overrides = calorieOverrides;
    overrides.remove(foodId);
    _box.put('calorieOverrides', overrides);
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

  int get workoutScore {
    final workouts = state.schedule.where((i) => i.type == ScheduleItemType.workout).toList();
    if (workouts.isEmpty) return 0;
    return (workouts.where((i) => i.done).length / workouts.length * 100).round();
  }

  // ─── Custom Foods ──────────────────────────────────────────
  List<Map<String, dynamic>> get customFoods {
    final raw = _box.get('customFoods');
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(
      (raw as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  void addCustomFood(Map<String, dynamic> food) {
    final foods = customFoods..add(food);
    _box.put('customFoods', foods);
  }

  void removeCustomFood(String id) {
    final foods = customFoods..removeWhere((f) => f['id'] == id);
    _box.put('customFoods', foods);
  }

  // ─── Health Insights ───────────────────────────────────────
  List<Map<String, String>> get healthInsights {
    final insights = <Map<String, String>>[];
    final profile = state.profile;
    if (profile == null) return insights;

    final now = DateTime.now();
    final hour = now.hour;
    final targets = profile.macroTargets;

    // ── Sleep Analysis ──
    final sleepItem = state.schedule.firstWhere(
      (i) => i.type == ScheduleItemType.sleep,
      orElse: () => ScheduleItem(id: '', time: '23:00', title: '', sub: '', icon: '', type: ScheduleItemType.sleep, calories: 0, protein: 0, carbs: 0, fat: 0, done: false, remOn: false, isCustom: false),
    );
    if (sleepItem.id.isNotEmpty) {
      final sleepHours = _parseSleepHours(sleepItem.sub);
      if (sleepHours != null && sleepHours > 0) {
        if (sleepHours < 4) {
          insights.add({'type': 'critical', 'icon': '🚨', 'title': 'Critical sleep deficit!',
            'msg': 'Only ${sleepHours.toStringAsFixed(1)}h sleep. Rest is top priority today. Avoid heavy workouts. Stay extra hydrated and add vitamin C foods.'});
        } else if (sleepHours < 6) {
          insights.add({'type': 'warning', 'icon': '😴', 'title': 'Low sleep today',
            'msg': '${sleepHours.toStringAsFixed(1)}h is below ideal. Take a 20min power nap if possible. Keep workout light. Add magnesium-rich foods (nuts, banana).'});
        } else if (sleepHours >= 8) {
          insights.add({'type': 'good', 'icon': '✅', 'title': 'Great sleep!',
            'msg': '${sleepHours.toStringAsFixed(1)}h — well rested! Perfect day for a challenging workout.'});
        }
      }
    }

    // ── Calorie Analysis ──
    final calsEaten = caloriesEaten;
    final calTarget = targets.calories;
    final calPct = calTarget > 0 ? calsEaten / calTarget : 0.0;

    if (hour >= 14 && calPct < 0.3 && calTarget > 0) {
      insights.add({'type': 'warning', 'icon': '🍽️', 'title': 'Very low calorie intake',
        'msg': 'Only ${calsEaten.toInt()} of ${calTarget.toInt()} kcal by afternoon. Your body needs fuel — have a protein-rich meal soon.'});
    } else if (hour >= 12 && calPct < 0.4 && calTarget > 0) {
      insights.add({'type': 'info', 'icon': '🥗', 'title': 'Behind on calories',
        'msg': '${(calPct * 100).toInt()}% of target eaten. Consider a nutritious snack or a hearty lunch.'});
    }
    if (calPct > 1.2 && calTarget > 0) {
      insights.add({'type': 'warning', 'icon': '⚠️', 'title': 'Over calorie budget',
        'msg': '${(calPct * 100).toInt()}% of target consumed. Consider a light walk and keep remaining meals light.'});
    }

    // ── Protein Analysis ──
    final protPct = targets.protein > 0 ? proteinEaten / targets.protein : 0.0;
    if (hour >= 15 && protPct < 0.4 && targets.protein > 0) {
      insights.add({'type': 'info', 'icon': '🥚', 'title': 'Protein is low',
        'msg': 'Only ${proteinEaten.toInt()}g of ${targets.protein.toInt()}g target. Add eggs, chicken, or a protein shake to recover.'});
    }

    // ── Water Analysis ──
    final wScore = waterScore;
    if (hour >= 13 && wScore < 30) {
      insights.add({'type': 'warning', 'icon': '💧', 'title': 'Dehydration risk',
        'msg': 'Only $wScore% of water target. Drink 2 glasses now. Dehydration causes fatigue and headaches.'});
    } else if (hour >= 16 && wScore < 50) {
      insights.add({'type': 'info', 'icon': '🥤', 'title': 'Drink more water',
        'msg': '$wScore% hydrated. Keep a water bottle nearby and sip regularly.'});
    }

    // ── Workout Analysis ──
    final workoutDone = state.schedule.any((i) => i.type == ScheduleItemType.workout && i.done);
    final hasWorkout = state.schedule.any((i) => i.type == ScheduleItemType.workout);
    if (hasWorkout && !workoutDone && hour >= 18) {
      final sleepHours = _parseSleepHours(sleepItem.sub);
      if (sleepHours != null && sleepHours >= 6) {
        insights.add({'type': 'info', 'icon': '💪', 'title': 'Workout pending',
          'msg': "You had good sleep — don't skip today's workout! Even 20 mins helps."});
      } else {
        insights.add({'type': 'info', 'icon': '🚶', 'title': 'Light activity suggested',
          'msg': 'Low sleep + pending workout. Try a 15-min walk instead of intense exercise.'});
      }
    }
    if (workoutDone && calPct < 0.5) {
      insights.add({'type': 'info', 'icon': '🍌', 'title': 'Post-workout fuel needed',
        'msg': 'Workout done but calories are low. Have a protein-rich snack within 30 min for recovery.'});
    }

    // ── Meal Timing ──
    final breakfastLogged = state.schedule.any((i) => i.isCustom && i.done && i.time == '07:30');
    if (hour >= 10 && !breakfastLogged) {
      insights.add({'type': 'info', 'icon': '🌅', 'title': 'No breakfast logged',
        'msg': 'Skipping breakfast slows metabolism. Even a banana or oats helps kickstart your day.'});
    }

    // ── All Good ──
    final totalItems = state.schedule.where((i) => !i.isCustom).length;
    final doneItems = state.schedule.where((i) => !i.isCustom && i.done).length;
    if (totalItems > 0 && doneItems == totalItems && wScore >= 80) {
      insights.add({'type': 'good', 'icon': '🎉', 'title': 'Crushing it today!',
        'msg': 'All tasks done, hydration on track. Keep this momentum going!'});
    }

    return insights;
  }

  double? _parseSleepHours(String sub) {
    // Parse sub like "7h sleep" or "5.5h" or "11:00 PM - 6:30 AM" or "23:00 - 06:30"
    final hMatch = RegExp(r'(\d+\.?\d*)\s*h').firstMatch(sub);
    if (hMatch != null) return double.tryParse(hMatch.group(1)!);

    // Try "HH:MM - HH:MM" format
    final rangeMatch = RegExp(r'(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})').firstMatch(sub);
    if (rangeMatch != null) {
      final startH = int.parse(rangeMatch.group(1)!);
      final startM = int.parse(rangeMatch.group(2)!);
      final endH = int.parse(rangeMatch.group(3)!);
      final endM = int.parse(rangeMatch.group(4)!);
      var diff = (endH * 60 + endM) - (startH * 60 + startM);
      if (diff < 0) diff += 24 * 60; // overnight
      return diff / 60.0;
    }
    return null;
  }
}

final appProvider = NotifierProvider<AppNotifier, AppState>(() {
  return AppNotifier();
});

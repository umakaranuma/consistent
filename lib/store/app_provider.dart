import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'types.dart';
import '../utils/bmi_engine.dart';
import '../utils/water_engine.dart';

class AppState {
  final UserProfile? profile;
  final WaterConfig? waterConfig;
  final List<ScheduleItem> schedule;
  final List<Reminder> reminders;
  final List<DayRecord> records;
  final List<WeightEntry> weightEntries;
  final int streak;
  
  AppState({
    this.profile,
    this.waterConfig,
    this.schedule = const [],
    this.reminders = const [],
    this.records = const [],
    this.weightEntries = const [],
    this.streak = 0,
  });

  AppState copyWith({
    UserProfile? profile,
    WaterConfig? waterConfig,
    List<ScheduleItem>? schedule,
    List<Reminder>? reminders,
    List<DayRecord>? records,
    List<WeightEntry>? weightEntries,
    int? streak,
  }) {
    return AppState(
      profile: profile ?? this.profile,
      waterConfig: waterConfig ?? this.waterConfig,
      schedule: schedule ?? this.schedule,
      reminders: reminders ?? this.reminders,
      records: records ?? this.records,
      weightEntries: weightEntries ?? this.weightEntries,
      streak: streak ?? this.streak,
    );
  }
}

class AppNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    // Development mock data since persistence (Hive) is not yet wired up.
    // This prevents the infinite spinner if the user hot-restarts after onboarding.
    final defaultProfile = UserProfile(
      name: 'Umakaran',
      heightCm: 170,
      currentWeight: 75,
      goalWeight: 65,
      bmi: 25.9,
      bmiCategory: BmiCategory.overweight,
      mode: AppMode.normal,
      stepGoal: 10000,
      macroTargets: MacroTargets(calories: 2000, protein: 120, carbs: 200, fat: 55),
      units: 'metric',
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

  void setProfile(UserProfile profile) {
    state = state.copyWith(profile: profile);
  }

  void setWaterConfig(WaterConfig config) {
    state = state.copyWith(waterConfig: config);
  }

  void setSchedule(List<ScheduleItem> schedule) {
    state = state.copyWith(schedule: schedule);
  }

  void addWater(double ml) {
    if (state.waterConfig != null) {
      final config = state.waterConfig!;
      final newConfig = WaterConfig(
        consumed: config.consumed + ml,
        target: config.target,
        reminderEnabled: config.reminderEnabled,
        reminderIntervalMinutes: config.reminderIntervalMinutes,
        reminderStartTime: config.reminderStartTime,
        reminderEndTime: config.reminderEndTime,
        mlPerReminder: config.mlPerReminder,
      );
      state = state.copyWith(waterConfig: newConfig);
    }
  }

  void addWeightEntry(WeightEntry entry) {
    final entries = List<WeightEntry>.from(state.weightEntries)..add(entry);
    state = state.copyWith(weightEntries: entries);
  }

  void toggleScheduleItem(String id) {
    final schedule = state.schedule.map((item) {
      if (item.id == id) {
        return ScheduleItem(
          id: item.id,
          time: item.time,
          title: item.title,
          sub: item.sub,
          icon: item.icon,
          type: item.type,
          calories: item.calories,
          protein: item.protein,
          carbs: item.carbs,
          fat: item.fat,
          done: !item.done,
          remOn: item.remOn,
          isCustom: item.isCustom,
        );
      }
      return item;
    }).toList();
    state = state.copyWith(schedule: schedule);
  }
}

final appProvider = NotifierProvider<AppNotifier, AppState>(() {
  return AppNotifier();
});

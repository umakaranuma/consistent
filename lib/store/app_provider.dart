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
  AppState build() => AppState();

  void setProfile(UserProfile profile) {
    state = state.copyWith(profile: profile);
  }

  void setWaterConfig(WaterConfig config) {
    state = state.copyWith(waterConfig: config);
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

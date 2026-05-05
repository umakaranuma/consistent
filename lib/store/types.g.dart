// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleItemAdapter extends TypeAdapter<ScheduleItem> {
  @override
  final int typeId = 4;

  @override
  ScheduleItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduleItem(
      id: fields[0] as String,
      time: fields[1] as String,
      title: fields[2] as String,
      sub: fields[3] as String,
      icon: fields[4] as String,
      type: fields[5] as ScheduleItemType,
      calories: fields[6] as double,
      protein: fields[7] as double,
      carbs: fields[8] as double,
      fat: fields[9] as double,
      done: fields[10] as bool,
      remOn: fields[11] as bool,
      isCustom: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduleItem obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.sub)
      ..writeByte(4)
      ..write(obj.icon)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.calories)
      ..writeByte(7)
      ..write(obj.protein)
      ..writeByte(8)
      ..write(obj.carbs)
      ..writeByte(9)
      ..write(obj.fat)
      ..writeByte(10)
      ..write(obj.done)
      ..writeByte(11)
      ..write(obj.remOn)
      ..writeByte(12)
      ..write(obj.isCustom);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MacroTargetsAdapter extends TypeAdapter<MacroTargets> {
  @override
  final int typeId = 5;

  @override
  MacroTargets read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MacroTargets(
      calories: fields[0] as double,
      protein: fields[1] as double,
      carbs: fields[2] as double,
      fat: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, MacroTargets obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.calories)
      ..writeByte(1)
      ..write(obj.protein)
      ..writeByte(2)
      ..write(obj.carbs)
      ..writeByte(3)
      ..write(obj.fat);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MacroTargetsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WaterConfigAdapter extends TypeAdapter<WaterConfig> {
  @override
  final int typeId = 6;

  @override
  WaterConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WaterConfig(
      consumed: fields[0] as double,
      target: fields[1] as double,
      reminderEnabled: fields[2] as bool,
      reminderIntervalMinutes: fields[3] as double,
      reminderStartTime: fields[4] as String,
      reminderEndTime: fields[5] as String,
      mlPerReminder: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, WaterConfig obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.consumed)
      ..writeByte(1)
      ..write(obj.target)
      ..writeByte(2)
      ..write(obj.reminderEnabled)
      ..writeByte(3)
      ..write(obj.reminderIntervalMinutes)
      ..writeByte(4)
      ..write(obj.reminderStartTime)
      ..writeByte(5)
      ..write(obj.reminderEndTime)
      ..writeByte(6)
      ..write(obj.mlPerReminder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WaterConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WeightEntryAdapter extends TypeAdapter<WeightEntry> {
  @override
  final int typeId = 7;

  @override
  WeightEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeightEntry(
      date: fields[0] as String,
      weight: fields[1] as double,
      bmi: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, WeightEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.weight)
      ..writeByte(2)
      ..write(obj.bmi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 8;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      name: fields[0] as String,
      age: fields[1] as double,
      gender: fields[2] as String,
      heightCm: fields[3] as double,
      currentWeight: fields[4] as double,
      goalWeight: fields[5] as double,
      bmi: fields[6] as double,
      bmiCategory: fields[7] as BmiCategory,
      mode: fields[8] as AppMode,
      gymGoal: fields[9] as GymGoal?,
      stepGoal: fields[10] as double,
      macroTargets: fields[11] as MacroTargets,
      units: fields[12] as String,
      activityLevel: fields[13] as String,
      workStartTime: fields[14] as String,
      workEndTime: fields[15] as String,
      sleepTime: fields[16] as String,
      pushEnabled: fields[17] as bool,
      workoutReminders: fields[18] as bool,
      sleepReminder: fields[19] as bool,
      planLockedByUser: fields[20] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.age)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.heightCm)
      ..writeByte(4)
      ..write(obj.currentWeight)
      ..writeByte(5)
      ..write(obj.goalWeight)
      ..writeByte(6)
      ..write(obj.bmi)
      ..writeByte(7)
      ..write(obj.bmiCategory)
      ..writeByte(8)
      ..write(obj.mode)
      ..writeByte(9)
      ..write(obj.gymGoal)
      ..writeByte(10)
      ..write(obj.stepGoal)
      ..writeByte(11)
      ..write(obj.macroTargets)
      ..writeByte(12)
      ..write(obj.units)
      ..writeByte(13)
      ..write(obj.activityLevel)
      ..writeByte(14)
      ..write(obj.workStartTime)
      ..writeByte(15)
      ..write(obj.workEndTime)
      ..writeByte(16)
      ..write(obj.sleepTime)
      ..writeByte(17)
      ..write(obj.pushEnabled)
      ..writeByte(18)
      ..write(obj.workoutReminders)
      ..writeByte(19)
      ..write(obj.sleepReminder)
      ..writeByte(20)
      ..write(obj.planLockedByUser);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 9;

  @override
  Reminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      id: fields[0] as String,
      title: fields[1] as String,
      time: fields[2] as String,
      type: fields[3] as String,
      repeat: fields[4] as String,
      enabled: fields[5] as bool,
      notifId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.repeat)
      ..writeByte(5)
      ..write(obj.enabled)
      ..writeByte(6)
      ..write(obj.notifId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LogEntryAdapter extends TypeAdapter<LogEntry> {
  @override
  final int typeId = 10;

  @override
  LogEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LogEntry(
      time: fields[0] as String,
      message: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LogEntry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.message);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DayRecordAdapter extends TypeAdapter<DayRecord> {
  @override
  final int typeId = 11;

  @override
  DayRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DayRecord(
      date: fields[0] as String,
      status: fields[1] as String,
      dietScore: fields[2] as double,
      waterScore: fields[3] as double,
      workoutDone: fields[4] as bool,
      calorieScore: fields[5] as double,
      proteinScore: fields[6] as double,
      waterConsumed: fields[7] as double,
      caloriesEaten: fields[8] as double,
      proteinEaten: fields[9] as double,
      bmiAtDay: fields[10] as double,
      log: (fields[11] as List).cast<LogEntry>(),
    );
  }

  @override
  void write(BinaryWriter writer, DayRecord obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.dietScore)
      ..writeByte(3)
      ..write(obj.waterScore)
      ..writeByte(4)
      ..write(obj.workoutDone)
      ..writeByte(5)
      ..write(obj.calorieScore)
      ..writeByte(6)
      ..write(obj.proteinScore)
      ..writeByte(7)
      ..write(obj.waterConsumed)
      ..writeByte(8)
      ..write(obj.caloriesEaten)
      ..writeByte(9)
      ..write(obj.proteinEaten)
      ..writeByte(10)
      ..write(obj.bmiAtDay)
      ..writeByte(11)
      ..write(obj.log);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppModeAdapter extends TypeAdapter<AppMode> {
  @override
  final int typeId = 0;

  @override
  AppMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppMode.normal;
      case 1:
        return AppMode.gym;
      default:
        return AppMode.normal;
    }
  }

  @override
  void write(BinaryWriter writer, AppMode obj) {
    switch (obj) {
      case AppMode.normal:
        writer.writeByte(0);
        break;
      case AppMode.gym:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BmiCategoryAdapter extends TypeAdapter<BmiCategory> {
  @override
  final int typeId = 1;

  @override
  BmiCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BmiCategory.underweight;
      case 1:
        return BmiCategory.normal;
      case 2:
        return BmiCategory.overweight;
      case 3:
        return BmiCategory.obese;
      default:
        return BmiCategory.underweight;
    }
  }

  @override
  void write(BinaryWriter writer, BmiCategory obj) {
    switch (obj) {
      case BmiCategory.underweight:
        writer.writeByte(0);
        break;
      case BmiCategory.normal:
        writer.writeByte(1);
        break;
      case BmiCategory.overweight:
        writer.writeByte(2);
        break;
      case BmiCategory.obese:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BmiCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GymGoalAdapter extends TypeAdapter<GymGoal> {
  @override
  final int typeId = 2;

  @override
  GymGoal read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GymGoal.fatLoss;
      case 1:
        return GymGoal.muscleGain;
      case 2:
        return GymGoal.maintenance;
      case 3:
        return GymGoal.recomp;
      default:
        return GymGoal.fatLoss;
    }
  }

  @override
  void write(BinaryWriter writer, GymGoal obj) {
    switch (obj) {
      case GymGoal.fatLoss:
        writer.writeByte(0);
        break;
      case GymGoal.muscleGain:
        writer.writeByte(1);
        break;
      case GymGoal.maintenance:
        writer.writeByte(2);
        break;
      case GymGoal.recomp:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GymGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScheduleItemTypeAdapter extends TypeAdapter<ScheduleItemType> {
  @override
  final int typeId = 3;

  @override
  ScheduleItemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ScheduleItemType.meal;
      case 1:
        return ScheduleItemType.water;
      case 2:
        return ScheduleItemType.workout;
      case 3:
        return ScheduleItemType.snack;
      case 4:
        return ScheduleItemType.sleep;
      case 5:
        return ScheduleItemType.walk;
      case 6:
        return ScheduleItemType.protein;
      case 7:
        return ScheduleItemType.custom;
      default:
        return ScheduleItemType.meal;
    }
  }

  @override
  void write(BinaryWriter writer, ScheduleItemType obj) {
    switch (obj) {
      case ScheduleItemType.meal:
        writer.writeByte(0);
        break;
      case ScheduleItemType.water:
        writer.writeByte(1);
        break;
      case ScheduleItemType.workout:
        writer.writeByte(2);
        break;
      case ScheduleItemType.snack:
        writer.writeByte(3);
        break;
      case ScheduleItemType.sleep:
        writer.writeByte(4);
        break;
      case ScheduleItemType.walk:
        writer.writeByte(5);
        break;
      case ScheduleItemType.protein:
        writer.writeByte(6);
        break;
      case ScheduleItemType.custom:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleItemTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

import 'package:uuid/uuid.dart';
import '../store/types.dart';
import '../constants/default_plan_normal.dart';
import '../constants/default_plan_gym.dart';

class BmiEngine {
  static double calculateBmi(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return double.parse((weightKg / (heightM * heightM)).toStringAsFixed(1));
  }

  static BmiCategory getBmiCategory(double bmi) {
    if (bmi < 18.5) return BmiCategory.underweight;
    if (bmi < 25) return BmiCategory.normal;
    if (bmi < 30) return BmiCategory.overweight;
    return BmiCategory.obese;
  }

  static String getBmiLabel(BmiCategory cat) {
    switch (cat) {
      case BmiCategory.underweight:
        return 'Underweight';
      case BmiCategory.normal:
        return 'Healthy weight';
      case BmiCategory.overweight:
        return 'Overweight';
      case BmiCategory.obese:
        return 'Obese';
    }
  }

  static Map<String, double> getIdealWeightRange(double heightCm) {
    final h = heightCm / 100;
    return {
      'min': double.parse((18.5 * h * h).toStringAsFixed(1)),
      'max': double.parse((24.9 * h * h).toStringAsFixed(1)),
    };
  }

  static double calculateTDEE({
    required double weightKg,
    required double heightCm,
    required double ageYears,
    required String gender,
    required String activityLevel,
  }) {
    final bmr = gender == 'male'
        ? 10 * weightKg + 6.25 * heightCm - 5 * ageYears + 5
        : 10 * weightKg + 6.25 * heightCm - 5 * ageYears - 161;

    final multipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };

    return (bmr * (multipliers[activityLevel] ?? 1.2)).roundToDouble();
  }

  static double getCalorieTarget({
    required double tdee,
    required BmiCategory bmiCategory,
    required AppMode mode,
    GymGoal? gymGoal,
  }) {
    if (mode == AppMode.gym) {
      switch (gymGoal) {
        case GymGoal.fatLoss:
          return tdee - 500;
        case GymGoal.muscleGain:
          return tdee + 300;
        case GymGoal.maintenance:
          return tdee;
        case GymGoal.recomp:
          return tdee - 200;
        default:
          return tdee - 300;
      }
    }
    
    switch (bmiCategory) {
      case BmiCategory.underweight:
        return tdee + 200;
      case BmiCategory.normal:
        return tdee - 100;
      case BmiCategory.overweight:
        return tdee - 400;
      case BmiCategory.obese:
        return tdee - 600;
    }
  }

  static MacroTargets getMacroTargets({
    required double calories,
    required double weightKg,
    required AppMode mode,
    GymGoal? gymGoal,
  }) {
    double proteinPerKg = 1.6;
    if (mode == AppMode.gym) {
      proteinPerKg = gymGoal == GymGoal.muscleGain ? 2.2 : 1.8;
    }
    
    final protein = (weightKg * proteinPerKg).roundToDouble();
    final fat = (calories * 0.25 / 9).roundToDouble();
    final carbs = ((calories - protein * 4 - fat * 9) / 4).roundToDouble();
    
    return MacroTargets(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
  }

  static double getWaterTarget(double weightKg, AppMode mode) {
    final mlPerKg = mode == AppMode.gym ? 40 : 35;
    return ((weightKg * mlPerKg) / 250).round() * 250.0;
  }

  static List<ScheduleItem> generatePlan(UserProfile profile) {
    List<Map<String, dynamic>> templates;
    if (profile.mode == AppMode.gym) {
      switch (profile.gymGoal) {
        case GymGoal.fatLoss: templates = planGymFatLoss; break;
        case GymGoal.muscleGain: templates = planGymMuscleGain; break;
        case GymGoal.maintenance: templates = planGymMaintenance; break;
        case GymGoal.recomp: templates = planGymRecomp; break;
        default: templates = planGymFatLoss;
      }
    } else {
      switch (profile.bmiCategory) {
        case BmiCategory.underweight: templates = planNormalUnderweight; break;
        case BmiCategory.normal: templates = planNormalHealthy; break;
        case BmiCategory.overweight: templates = planNormalOverweight; break;
        case BmiCategory.obese: templates = planNormalObese; break;
      }
    }

    final uuid = Uuid();
    return templates.map((t) {
      ScheduleItemType type;
      switch (t['type']) {
        case 'meal': type = ScheduleItemType.meal; break;
        case 'water': type = ScheduleItemType.water; break;
        case 'workout': type = ScheduleItemType.workout; break;
        case 'snack': type = ScheduleItemType.snack; break;
        case 'sleep': type = ScheduleItemType.sleep; break;
        case 'walk': type = ScheduleItemType.walk; break;
        case 'protein': type = ScheduleItemType.protein; break;
        default: type = ScheduleItemType.custom; break;
      }
      return ScheduleItem(
        id: uuid.v4(),
        time: t['time'],
        title: t['title'],
        sub: t['sub'],
        icon: t['icon'],
        type: type,
        calories: t['calories'] ?? 0.0,
        protein: t['protein'] ?? 0.0,
        carbs: t['carbs'] ?? 0.0,
        fat: t['fat'] ?? 0.0,
        done: false,
        remOn: false,
        isCustom: false,
      );
    }).toList();
  }
}

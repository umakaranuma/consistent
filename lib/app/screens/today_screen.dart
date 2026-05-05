import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/colors.dart';
import '../../store/app_provider.dart';
import '../../store/types.dart';
import '../../utils/bmi_engine.dart';
import '../../components/food_picker_sheet.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final profile = state.profile;

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final notifier = ref.read(appProvider.notifier);
    final eaten = notifier.caloriesEaten;
    final pEaten = notifier.proteinEaten;
    final cEaten = notifier.carbsEaten;
    final fEaten = notifier.fatEaten;

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(profile, state.streak),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // ─── BMI Card ────────────
                  _buildBmiCard(profile),
                  const SizedBox(height: 16),
                  // ─── Score Row ───────────
                  _buildScoreRow(notifier, profile, state),
                  const SizedBox(height: 16),
                  // ─── Calorie Card ────────
                  _buildCalorieCard(eaten, profile.macroTargets),
                  const SizedBox(height: 16),
                  // ─── Macro Bars ──────────
                  _buildMacroCard(pEaten, cEaten, fEaten, profile.macroTargets, profile.mode),
                  const SizedBox(height: 16),
                  // ─── Water Card ──────────
                  _buildWaterCard(state.waterConfig, ref),
                  const SizedBox(height: 16),
                  // ─── Weekly Workout ──────
                  _buildWeeklyWorkoutRow(profile),
                  const SizedBox(height: 24),
                  // ─── Log Food Buttons ────
                  _buildLogFoodButtons(context),
                  const SizedBox(height: 24),
                  // ─── Schedule Header ─────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Daily Schedule', style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white,
                      )),
                      Text(
                        '${state.schedule.where((i) => i.done).length}/${state.schedule.length} done',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ─── Schedule Items ──────
                  ...state.schedule.map((item) => _buildScheduleItem(item, ref)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────
  Widget _buildAppBar(UserProfile profile, int streak) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return SliverAppBar(
      expandedHeight: 110,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.bg0,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        title: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$greeting, ${profile.name}', style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white,
                  )),
                  if (streak > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.amberDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.amber.withOpacity(0.3)),
                      ),
                      child: Text('🔥 $streak day streak', style: const TextStyle(
                        fontSize: 9, color: AppColors.amber, fontWeight: FontWeight.w500,
                      )),
                    ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.accentBg,
              child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── BMI Card ─────────────────────────────────────────────
  Widget _buildBmiCard(UserProfile profile) {
    final bmiColor = _bmiColor(profile.bmiCategory);
    final bmiLabel = BmiEngine.getBmiLabel(profile.bmiCategory);
    final idealRange = BmiEngine.getIdealWeightRange(profile.heightCm);
    final barPos = ((profile.bmi - 15) / 25 * 100).clamp(0.0, 100.0);

    double diff = 0;
    String diffText = '';
    Color diffColor = AppColors.green;
    if (profile.bmi < 18.5) {
      diff = idealRange['min']! - profile.currentWeight;
      diffText = '${diff.toStringAsFixed(1)} kg below healthy range';
      diffColor = AppColors.blue;
    } else if (profile.bmi > 24.9) {
      diff = profile.currentWeight - idealRange['max']!;
      diffText = '${diff.toStringAsFixed(1)} kg above healthy range';
      diffColor = profile.bmi >= 30 ? AppColors.red : AppColors.amber;
    } else {
      diffText = 'You are in healthy range!';
      diffColor = AppColors.green;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('BMI', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text('Detail ›', style: TextStyle(fontSize: 12, color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(profile.bmi.toStringAsFixed(1), style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w500, color: bmiColor,
              )),
              const SizedBox(width: 12),
              Text(bmiLabel, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: bmiColor)),
            ],
          ),
          const SizedBox(height: 12),
          // BMI bar
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.bg3,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: barPos / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: bmiColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Ideal: ${idealRange['min']}–${idealRange['max']} kg',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(diffText, style: TextStyle(fontSize: 11, color: diffColor)),
        ],
      ),
    );
  }

  // ─── Score Row ────────────────────────────────────────────
  Widget _buildScoreRow(AppNotifier notifier, UserProfile profile, AppState state) {
    final dietScore = notifier.dietScore;
    final waterScore = notifier.waterScore;
    final meals = state.schedule.where((i) => i.type == ScheduleItemType.meal).toList();
    final mealsDone = meals.where((i) => i.done).length;
    final workoutDone = state.schedule.any((i) =>
      (i.type == ScheduleItemType.workout || i.type == ScheduleItemType.walk) && i.done);

    final cards = <Widget>[
      _scoreCard('Diet', '$mealsDone/${meals.length}', dietScore / 100, AppColors.green),
      _scoreCard('Water', '$waterScore%', waterScore / 100, AppColors.blue),
      _scoreCard('Workout', workoutDone ? 'Done' : '—', workoutDone ? 1.0 : 0.0, AppColors.amber),
    ];

    if (profile.mode == AppMode.gym) {
      final pTarget = profile.macroTargets.protein;
      final pEaten = notifier.proteinEaten;
      cards.add(_scoreCard('Protein', '${pEaten.toInt()}g/${pTarget.toInt()}g',
        pTarget > 0 ? (pEaten / pTarget).clamp(0.0, 1.0) : 0.0, AppColors.lavender));
    }

    return Row(
      children: cards.map((c) => Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: c,
      ))).toList(),
    );
  }

  Widget _scoreCard(String label, String value, double fill, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border1),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.bold, color: color,
          )),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: fill,
              minHeight: 3,
              backgroundColor: AppColors.bg3,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Calorie Card ─────────────────────────────────────────
  Widget _buildCalorieCard(double eaten, MacroTargets targets) {
    final remaining = targets.calories - eaten;
    final overBudget = remaining < 0;
    Color barColor = AppColors.green;
    if (overBudget) {
      barColor = (eaten / targets.calories) > 1.1 ? AppColors.red : AppColors.amber;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Calories today', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text('${eaten.toInt()} / ${targets.calories.toInt()} kcal',
                style: const TextStyle(fontSize: 12, color: AppColors.accentSoft)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: targets.calories > 0 ? (eaten / targets.calories).clamp(0.0, 1.5) : 0,
              minHeight: 8,
              backgroundColor: AppColors.bg3,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            overBudget
              ? '${remaining.abs().toInt()} kcal over budget'
              : '${remaining.toInt()} kcal remaining',
            style: TextStyle(fontSize: 11, color: overBudget ? AppColors.red : AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ─── Macro Card ───────────────────────────────────────────
  Widget _buildMacroCard(double pEaten, double cEaten, double fEaten, MacroTargets t, AppMode mode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(mode == AppMode.gym ? 'Macros today' : 'Nutrition',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          _macroRow('Protein', pEaten, t.protein, AppColors.lavender),
          const SizedBox(height: 10),
          _macroRow('Carbs', cEaten, t.carbs, AppColors.amber),
          const SizedBox(height: 10),
          _macroRow('Fat', fEaten, t.fat, AppColors.teal),
        ],
      ),
    );
  }

  Widget _macroRow(String label, double current, double target, Color color) {
    final over = current > target;
    return Row(
      children: [
        SizedBox(width: 56, child: Text(label, style: const TextStyle(
          fontSize: 12, color: AppColors.textSecondary,
        ))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: target > 0 ? (current / target).clamp(0.0, 1.0) : 0,
              minHeight: 6,
              backgroundColor: AppColors.bg3,
              valueColor: AlwaysStoppedAnimation(over ? AppColors.red : color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(width: 80, child: Text(
          '${current.toInt()}g / ${target.toInt()}g',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
            color: over ? AppColors.red : AppColors.white),
          textAlign: TextAlign.right,
        )),
      ],
    );
  }

  // ─── Water Card ───────────────────────────────────────────
  Widget _buildWaterCard(WaterConfig? config, WidgetRef ref) {
    final consumed = config?.consumed ?? 0.0;
    final target = config?.target ?? 2500.0;
    final pct = target > 0 ? (consumed / target * 100).clamp(0, 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Water intake', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text('${consumed.toInt()} / ${target.toInt()} ml',
                style: const TextStyle(fontSize: 12, color: AppColors.accentSoft)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0,
              minHeight: 8,
              backgroundColor: AppColors.bg3,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: 6),
          Text('$pct% of daily target', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 12),
          // Quick-add row
          Row(
            children: [
              _waterAddBtn('+150ml', 150, ref),
              const SizedBox(width: 8),
              _waterAddBtn('+250ml', 250, ref),
              const SizedBox(width: 8),
              _waterAddBtn('+500ml', 500, ref),
            ],
          ),
        ],
      ),
    );
  }

  Widget _waterAddBtn(String label, double ml, WidgetRef ref) {
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(appProvider.notifier).addWater(ml),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.accent.withOpacity(0.2)),
          ),
          alignment: Alignment.center,
          child: Text(label, style: const TextStyle(
            fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600,
          )),
        ),
      ),
    );
  }

  // ─── Weekly Workout Row ───────────────────────────────────
  Widget _buildWeeklyWorkoutRow(UserProfile profile) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<String> plan;

    if (profile.mode == AppMode.gym) {
      switch (profile.gymGoal) {
        case GymGoal.fatLoss:
          plan = ['Strength', 'Cardio', 'Strength', 'Cardio', 'Strength', 'HIIT', 'Rest']; break;
        case GymGoal.muscleGain:
          plan = ['Push', 'Pull', 'Legs', 'Push', 'Pull', 'Legs', 'Rest']; break;
        case GymGoal.maintenance:
          plan = ['Full Body', 'Rest', 'Full Body', 'Rest', 'Full Body', 'Walk', 'Rest']; break;
        case GymGoal.recomp:
          plan = ['Upper', 'Lower', 'Upper', 'Lower', 'HIIT', 'Walk', 'Rest']; break;
        default:
          plan = ['HIIT', 'Strength', 'HIIT', 'Strength', 'HIIT', 'Walk', 'Rest'];
      }
    } else {
      plan = ['HIIT', 'Strength', 'HIIT', 'Strength', 'HIIT', 'Walk', 'Rest'];
    }

    final todayIndex = (DateTime.now().weekday - 1) % 7;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final isToday = i == todayIndex;
          return Column(
            children: [
              Text(dayNames[i], style: TextStyle(
                fontSize: 10, color: isToday ? AppColors.accent : AppColors.textSecondary,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              )),
              const SizedBox(height: 6),
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: isToday ? AppColors.accent.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isToday ? Border.all(color: AppColors.accent, width: 1) : null,
                ),
                alignment: Alignment.center,
                child: Text(plan[i], style: TextStyle(
                  fontSize: 8, color: isToday ? AppColors.accent : AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ), textAlign: TextAlign.center),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ─── Log Food Buttons ─────────────────────────────────────
  Widget _buildLogFoodButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Log your food', style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white,
        )),
        const SizedBox(height: 4),
        const Text('Tap to pick what you ate — calories auto-calculated',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Row(
          children: [
            _foodLogBtn(context, '🍳', 'Breakfast', 'breakfast'),
            const SizedBox(width: 8),
            _foodLogBtn(context, '🍛', 'Lunch', 'lunch'),
            const SizedBox(width: 8),
            _foodLogBtn(context, '🍽️', 'Dinner', 'dinner'),
            const SizedBox(width: 8),
            _foodLogBtn(context, '🥜', 'Snack', 'snack'),
          ],
        ),
      ],
    );
  }

  Widget _foodLogBtn(BuildContext context, String icon, String label, String category) {
    return Expanded(
      child: InkWell(
        onTap: () => showFoodPicker(context, category),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.bg1,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border1),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500,
              )),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Schedule Item ────────────────────────────────────────
  Widget _buildScheduleItem(ScheduleItem item, WidgetRef ref) {
    final iconBg = _getColorForType(item.type);
    final hasMacros = item.calories > 0 || item.protein > 0;

    return AnimatedOpacity(
      opacity: item.done ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bg1,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: iconBg.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(item.icon, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold,
                      color: item.done ? AppColors.textSecondary : AppColors.white,
                      decoration: item.done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(text: item.time, style: const TextStyle(color: AppColors.textMuted)),
                      TextSpan(text: ' · ${item.sub}'),
                      if (hasMacros) ...[
                        TextSpan(text: ' · ${item.calories.toInt()}kcal',
                          style: const TextStyle(color: AppColors.accentSoft)),
                        if (item.protein > 0) TextSpan(
                          text: ' · P:${item.protein.toInt()}g',
                          style: const TextStyle(color: AppColors.blue),
                        ),
                      ],
                    ]),
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            // Check
            SizedBox(
              width: 30, height: 30,
              child: Checkbox(
                value: item.done,
                onChanged: (_) => ref.read(appProvider.notifier).toggleScheduleItem(item.id),
                activeColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: const BorderSide(color: AppColors.textMuted, width: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _bmiColor(BmiCategory cat) {
    switch (cat) {
      case BmiCategory.underweight: return AppColors.bmiUnder;
      case BmiCategory.normal: return AppColors.bmiNormal;
      case BmiCategory.overweight: return AppColors.bmiOver;
      case BmiCategory.obese: return AppColors.bmiObese;
    }
  }

  Color _getColorForType(ScheduleItemType type) {
    switch (type) {
      case ScheduleItemType.meal: return AppColors.iconMeal;
      case ScheduleItemType.snack: return AppColors.iconSnack;
      case ScheduleItemType.workout: return AppColors.iconWorkout;
      case ScheduleItemType.water: return AppColors.iconWater;
      case ScheduleItemType.sleep: return AppColors.iconSleep;
      case ScheduleItemType.walk: return AppColors.iconWalk;
      case ScheduleItemType.protein: return AppColors.iconProtein;
      default: return AppColors.iconCustom;
    }
  }
}

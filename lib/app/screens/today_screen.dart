import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/colors.dart';
import '../../store/app_provider.dart';
import '../../store/types.dart';
import '../../utils/bmi_engine.dart';
import '../../utils/notification_service.dart';
import '../../components/food_picker_sheet.dart';
import 'package:uuid/uuid.dart';
import 'bmi_details_screen.dart';
import '../../constants/exercise_database.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  // Which meal period is currently expanded (auto-set by time of day)
  late String _expandedMeal;

  @override
  void initState() {
    super.initState();
    final hour = DateTime.now().hour;
    if (hour < 10) {
      _expandedMeal = 'breakfast';
    } else if (hour < 14) {
      _expandedMeal = 'lunch';
    } else if (hour < 18) {
      _expandedMeal = 'snack';
    } else {
      _expandedMeal = 'dinner';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
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
                  // â”€â”€â”€ BMI Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _buildBmiCard(context, profile, ref),
                  const SizedBox(height: 16),
                  // â”€â”€â”€ Score Row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _buildScoreRow(notifier, profile, state),
                  const SizedBox(height: 16),
                  // â”€â”€â”€ Calorie Card â”€â”€â”€â”€â”€â”€â”€â”€
                  _buildCalorieCard(eaten, profile.macroTargets),
                  const SizedBox(height: 16),
                  // â”€â”€â”€ Macro Bars â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _buildMacroCard(pEaten, cEaten, fEaten, profile.macroTargets, profile.mode),
                  const SizedBox(height: 16),
                  // â”€â”€â”€ Water Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _buildWaterCard(context, state.waterConfig, ref),
                  const SizedBox(height: 16),
                  // â”€â”€â”€ Weekly Workout â”€â”€â”€â”€â”€â”€
                  _buildWeeklyWorkoutRow(profile),
                  const SizedBox(height: 24),
                  // â”€â”€â”€ Log Food Buttons â”€â”€â”€â”€
                  _buildLogFoodButtons(context),
                  const SizedBox(height: 24),
                  // â”€â”€â”€ Daily Plan (unified meals + schedule) â”€â”€
                  _buildDailyPlan(context, state, ref),
                  const SizedBox(height: 20),
                  // ─── Health Insights ──
                  _buildHealthInsights(notifier),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€â”€ App Bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

  // â”€â”€â”€ BMI Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildBmiCard(BuildContext context, UserProfile profile, WidgetRef ref) {
    final bmiColor = _bmiColor(profile.bmiCategory);
    final bmiLabel = BmiEngine.getBmiLabel(profile.bmiCategory);
    final idealRange = BmiEngine.getIdealWeightRange(profile.heightCm);
    
    // Calculate marker position on a scale from BMI 15 to 40
    final double minBmi = 15.0;
    final double maxBmi = 40.0;
    final double range = maxBmi - minBmi;
    final double normalized = ((profile.bmi - minBmi) / range).clamp(0.0, 1.0);

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
              const Text('BMI & Weight', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Row(
                children: [
                  InkWell(
                    onTap: () => _showWeightLogger(context, ref),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.add_circle_outline, size: 14, color: AppColors.accentSoft),
                          const SizedBox(width: 4),
                          Text('Log Weight', style: TextStyle(fontSize: 12, color: AppColors.accentSoft, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const BmiDetailsScreen()),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text('Detail â€º', style: TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(profile.bmi.toStringAsFixed(1), style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w800, color: bmiColor, height: 1.0,
              )),
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(bottom: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: bmiColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                child: Text(bmiLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: bmiColor)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Segmented BMI bar
          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  // Marker
                  SizedBox(
                    height: 10,
                    width: constraints.maxWidth,
                    child: Stack(
                      children: [
                        Positioned(
                          left: (constraints.maxWidth * normalized) - 5,
                          child: const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                  // Colored Bar
                  Container(
                    height: 8,
                    width: constraints.maxWidth,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      children: [
                        Expanded(flex: 35, child: Container(color: AppColors.bmiUnder)), // 15 - 18.5 (3.5)
                        Expanded(flex: 65, child: Container(color: AppColors.bmiNormal)), // 18.5 - 25 (6.5)
                        Expanded(flex: 50, child: Container(color: AppColors.bmiOver)), // 25 - 30 (5.0)
                        Expanded(flex: 100, child: Container(color: AppColors.bmiObese)), // 30 - 40 (10.0)
                      ],
                    ),
                  ),
                ],
              );
            }
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _bmiStatItem('Height', '${profile.heightCm.toInt()} cm'),
              _bmiStatItem('Weight', '${profile.currentWeight.toStringAsFixed(1)} kg'),
              _bmiStatItem('Ideal Range', '${idealRange['min']} - ${idealRange['max']} kg'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bmiStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.white)),
      ],
    );
  }

  void _showWeightLogger(BuildContext context, WidgetRef ref) {
    final state = ref.read(appProvider);
    final weightCtrl = TextEditingController(text: state.profile?.currentWeight.toStringAsFixed(1) ?? '70.0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.8),
            decoration: const BoxDecoration(
              color: AppColors.bg1,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Log New Weight', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white,
                )),
                const SizedBox(height: 16),
                TextField(
                  controller: weightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.accent),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    suffixText: 'kg',
                    suffixStyle: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.bg2,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    final w = double.tryParse(weightCtrl.text);
                    if (w != null && w > 20 && w < 300) {
                      final now = DateTime.now();
                      final dateStr = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
                      final bmi = BmiEngine.calculateBmi(w, state.profile!.heightCm);
                      
                      ref.read(appProvider.notifier).addWeightEntry(WeightEntry(
                        date: dateStr, weight: w, bmi: bmi,
                      ));
                      Navigator.pop(ctx);
                      
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Weight logged! Macros & targets updated automatically.'),
                        backgroundColor: AppColors.green,
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save & Update Profile', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white,
                  )),
                ),
                const SizedBox(height: 24),
                // Weight History
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Recent History', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white)),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final entries = ref.watch(appProvider).weightEntries.reversed.toList();
                      if (entries.isEmpty) {
                        return const Center(child: Text('No history yet.', style: TextStyle(color: AppColors.textMuted)));
                      }
                      return ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (ctx, i) {
                          final e = entries[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.bg2, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.date, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                Row(
                                  children: [
                                    Text('${e.weight.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)),
                                    const SizedBox(width: 12),
                                    Text('BMI ${e.bmi.toStringAsFixed(1)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // â”€â”€â”€ Score Row (Circular Progress Rings) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildScoreRow(AppNotifier notifier, UserProfile profile, AppState state) {
    final dietScore = notifier.dietScore;
    final waterScore = notifier.waterScore;
    final meals = state.schedule.where((i) => i.type == ScheduleItemType.meal).toList();
    final mealsDone = meals.where((i) => i.done).length;
    final workoutDone = state.schedule.any((i) =>
      (i.type == ScheduleItemType.workout || i.type == ScheduleItemType.walk) && i.done);

    final cards = <Widget>[
      _scoreCard('Diet', '$mealsDone/${meals.length}', dietScore / 100, AppColors.green, Icons.restaurant_outlined),
      _scoreCard('Water', '$waterScore%', waterScore / 100, AppColors.blue, Icons.water_drop_outlined),
      _scoreCard('Workout', workoutDone ? 'âœ“' : 'â€”', workoutDone ? 1.0 : 0.0, AppColors.amber, Icons.fitness_center_outlined),
    ];

    if (profile.mode == AppMode.gym) {
      final pTarget = profile.macroTargets.protein;
      final pEaten = notifier.proteinEaten;
      cards.add(_scoreCard('Protein', '${pEaten.toInt()}g', pTarget > 0 ? (pEaten / pTarget).clamp(0.0, 1.0) : 0.0, AppColors.lavender, Icons.egg_outlined));
    }

    return Row(
      children: cards.map((c) => Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: c,
      ))).toList(),
    );
  }

  Widget _scoreCard(String label, String value, double fill, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 46, height: 46,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 46, height: 46,
                  child: CircularProgressIndicator(
                    value: fill,
                    strokeWidth: 3.5,
                    backgroundColor: AppColors.bg3,
                    valueColor: AlwaysStoppedAnimation(color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Icon(icon, size: 18, color: color),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w800, color: color,
          )),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // â”€â”€â”€ Calorie Card (Donut style) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildCalorieCard(double eaten, MacroTargets targets) {
    final remaining = targets.calories - eaten;
    final overBudget = remaining < 0;
    final pct = targets.calories > 0 ? (eaten / targets.calories).clamp(0.0, 1.0) : 0.0;
    Color ringColor = AppColors.green;
    if (overBudget) {
      ringColor = (eaten / targets.calories) > 1.1 ? AppColors.red : AppColors.amber;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border1),
      ),
      child: Row(
        children: [
          // Donut ring
          SizedBox(
            width: 90, height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90, height: 90,
                  child: CircularProgressIndicator(
                    value: pct,
                    strokeWidth: 8,
                    backgroundColor: AppColors.bg3,
                    valueColor: AlwaysStoppedAnimation(ringColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${(pct * 100).toInt()}%', style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: ringColor,
                    )),
                    const Text('eaten', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Stats column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Calories', style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white,
                )),
                const SizedBox(height: 12),
                _calorieStat('Eaten', '${eaten.toInt()}', 'kcal', AppColors.accent),
                const SizedBox(height: 8),
                _calorieStat('Target', '${targets.calories.toInt()}', 'kcal', AppColors.textSecondary),
                const SizedBox(height: 8),
                _calorieStat(
                  overBudget ? 'Over' : 'Left',
                  '${remaining.abs().toInt()}',
                  'kcal',
                  overBudget ? AppColors.red : AppColors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _calorieStat(String label, String value, String unit, Color color) {
    return Row(
      children: [
        Container(width: 3, height: 16, decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(2),
        )),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(width: 3),
        Text(unit, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }

  // â”€â”€â”€ Macro Card (Visual bars with percentage) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildMacroCard(double pEaten, double cEaten, double fEaten, MacroTargets t, AppMode mode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(mode == AppMode.gym ? 'Macros' : 'Nutrition',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.bg3, borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${(pEaten * 4 + cEaten * 4 + fEaten * 9).toInt()} kcal from macros',
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _macroRow('Protein', pEaten, t.protein, AppColors.lavender, Icons.egg_outlined),
          const SizedBox(height: 14),
          _macroRow('Carbs', cEaten, t.carbs, AppColors.amber, Icons.grain_outlined),
          const SizedBox(height: 14),
          _macroRow('Fat', fEaten, t.fat, AppColors.teal, Icons.water_drop_outlined),
        ],
      ),
    );
  }

  Widget _macroRow(String label, double current, double target, Color color, IconData icon) {
    final over = current > target;
    final pct = target > 0 ? (current / target * 100).clamp(0, 999).toInt() : 0;
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const Spacer(),
            Text('${current.toInt()}g', style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: over ? AppColors.red : color,
            )),
            Text(' / ${target.toInt()}g', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: (over ? AppColors.red : color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('$pct%', style: TextStyle(
                fontSize: 9, fontWeight: FontWeight.bold, color: over ? AppColors.red : color,
              )),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: target > 0 ? (current / target).clamp(0.0, 1.0) : 0,
            minHeight: 6,
            backgroundColor: AppColors.bg3,
            valueColor: AlwaysStoppedAnimation(over ? AppColors.red : color),
          ),
        ),
      ],
    );
  }

  // â”€â”€â”€ Water Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildWaterCard(BuildContext context, WaterConfig? config, WidgetRef ref) {
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
              InkWell(
                onTap: () {
                  if (config != null) {
                    _showWaterTargetEditor(context, ref, config);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Text('${consumed.toInt()} / ${target.toInt()} ml',
                        style: const TextStyle(fontSize: 12, color: AppColors.accentSoft, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, size: 12, color: AppColors.accentSoft),
                    ],
                  ),
                ),
              ),
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

  void _showWaterTargetEditor(BuildContext context, WidgetRef ref, WaterConfig config) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        double currentTarget = config.target;
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.bg1,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Daily Water Target', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white,
                )),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 32, color: AppColors.textSecondary),
                      onPressed: currentTarget > 500 ? () => setState(() => currentTarget -= 250) : null,
                    ),
                    const SizedBox(width: 16),
                    Text('${currentTarget.toInt()} ml', style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.accent,
                    )),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 32, color: AppColors.textSecondary),
                      onPressed: currentTarget < 8000 ? () => setState(() => currentTarget += 250) : null,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(appProvider.notifier).setWaterConfig(config.copyWith(target: currentTarget));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save Target', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        });
      },
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

  // --- Weekly Workout Split (Editable) ---
  Widget _buildWeeklyWorkoutRow(UserProfile profile) {
    if (profile.mode != AppMode.gym) {
      return const SizedBox.shrink();
    }
    final notifier = ref.read(appProvider.notifier);
    final split = notifier.gymSplit;
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayIndex = (DateTime.now().weekday - 1) % 7;
    final todayWorkout = split[dayNames[todayIndex]];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(children: [
          const Icon(Icons.fitness_center, size: 18, color: AppColors.accent),
          const SizedBox(width: 8),
          const Text('Gym Split', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white)),
          const Spacer(),
          InkWell(
            onTap: () => _showEditGymSplitSheet(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, size: 12, color: AppColors.accent),
                  SizedBox(width: 4),
                  Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent)),
                ],
              ),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        // Today's focus card
        if (todayWorkout != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [AppColors.accent.withValues(alpha: 0.15), AppColors.bg1],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(todayWorkout['icon'] as String? ?? '\u{1F3CB}', style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Today's Focus", style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      Text(todayWorkout['focus'] as String? ?? 'Workout',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.white)),
                    ],
                  )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(dayNames[todayIndex],
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent)),
                  ),
                ]),
                const SizedBox(height: 10),
                // Muscle tags
                Wrap(
                  spacing: 6, runSpacing: 4,
                  children: ((todayWorkout['muscles'] as List?)?.cast<String>() ?? []).map((m) =>
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.lavender.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(m, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.lavender)),
                    ),
                  ).toList(),
                ),
                const SizedBox(height: 8),
                // Exercises with images
                ..._buildExerciseCards(todayWorkout),
              ],
            ),
          ),
        const SizedBox(height: 10),
        // Week overview row
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bg1,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final isToday = i == todayIndex;
              final dayData = split[dayNames[i]];
              final focus = (dayData?['focus'] as String?) ?? 'Rest';
              final isRest = focus.toLowerCase().contains('rest');
              return Expanded(child: Column(
                children: [
                  Text(dayNames[i], style: TextStyle(
                    fontSize: 9, color: isToday ? AppColors.accent : AppColors.textSecondary,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  )),
                  const SizedBox(height: 4),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.accent.withValues(alpha: 0.15)
                           : isRest ? AppColors.bg2 : AppColors.bg3,
                      borderRadius: BorderRadius.circular(10),
                      border: isToday ? Border.all(color: AppColors.accent, width: 1.5) : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      dayData?['icon'] as String? ?? '\u{1F3CB}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(focus.length > 8 ? '${focus.substring(0, 7)}..' : focus,
                    style: TextStyle(fontSize: 7, fontWeight: FontWeight.w600,
                      color: isToday ? AppColors.accent : AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ));
            }),
          ),
        ),
      ],
    );
  }


  List<Widget> _buildExerciseCards(Map<String, dynamic> workout) {
    final exerciseNames = ((workout['exercises'] as List?) ?? []).cast<String>();
    final allExercises = ExerciseDatabase.exercises;

    return exerciseNames.map((name) {
      // Find matching exercise from database
      final exData = allExercises.firstWhere(
        (e) => (e['name'] as String).toLowerCase() == name.toLowerCase(),
        orElse: () => {'name': name, 'target': '', 'sets': '', 'desc': '', 'image': ''},
      );
      final imageUrl = exData['image'] as String? ?? '';
      final target = exData['target'] as String? ?? '';
      final sets = exData['sets'] as String? ?? '';
      final desc = exData['desc'] as String? ?? '';

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border1),
        ),
        child: Row(children: [
          // Exercise image
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(13)),
              child: Image.network(
                imageUrl,
                width: 72, height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 72, height: 72,
                  color: AppColors.bg3,
                  alignment: Alignment.center,
                  child: const Icon(Icons.fitness_center, size: 24, color: AppColors.textMuted),
                ),
              ),
            )
          else
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.bg3,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(13)),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.fitness_center, size: 24, color: AppColors.textMuted),
            ),
          const SizedBox(width: 10),
          // Details
          Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white)),
                if (target.isNotEmpty)
                  Text(target, style: const TextStyle(fontSize: 10, color: AppColors.accent)),
                if (desc.isNotEmpty)
                  Text(desc, style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          )),
          // Sets badge
          if (sets.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(sets, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.accent)),
            ),
        ]),
      );
    }).toList();
  }

  // --- Edit Gym Split Sheet ---
  void _showEditGymSplitSheet(BuildContext context) {
    final notifier = ref.read(appProvider.notifier);
    final split = Map<String, Map<String, dynamic>>.from(notifier.gymSplit);
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayFull = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setBS) => Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
          decoration: const BoxDecoration(
            color: AppColors.bg1,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4, decoration: BoxDecoration(
                  color: AppColors.textMuted, borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(children: [
                  const Icon(Icons.fitness_center, size: 20, color: AppColors.accent),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('Edit Weekly Split', style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white))),
                  TextButton(
                    onPressed: () {
                      notifier.resetGymSplit();
                      Navigator.pop(ctx);
                    },
                    child: const Text('Reset', style: TextStyle(fontSize: 12, color: AppColors.red)),
                  ),
                ]),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 7,
                  itemBuilder: (ctx, i) {
                    final day = dayNames[i];
                    final data = split[day] ?? {'focus': 'Rest', 'muscles': [], 'exercises': []};
                    final focus = data['focus'] as String? ?? 'Rest';
                    final muscles = ((data['muscles'] as List?) ?? []).cast<String>();
                    final exercises = ((data['exercises'] as List?) ?? []).cast<String>();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.bg2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(dayFull[i], style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white)),
                            const Spacer(),
                            InkWell(
                              onTap: () => _showEditDayDialog(ctx, day, focus, muscles, exercises, (f, m, e) {
                                setBS(() {
                                  split[day] = {'focus': f, 'muscles': m, 'exercises': e};
                                });
                                notifier.setGymSplitDay(day, f, m, e);
                              }),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(Icons.edit, size: 12, color: AppColors.accent),
                                  SizedBox(width: 4),
                                  Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent)),
                                ]),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 6),
                          Text(focus, style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent)),
                          if (muscles.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Wrap(spacing: 4, children: muscles.map((m) =>
                              Text(m, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            ).toList()),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDayDialog(BuildContext ctx, String day, String focus, List<String> muscles,
      List<String> exercises, void Function(String, List<String>, List<String>) onSave) {
    final focusCtrl = TextEditingController(text: focus);
    final musclesCtrl = TextEditingController(text: muscles.join(', '));
    final exercisesCtrl = TextEditingController(text: exercises.join(', '));

    showDialog(
      context: ctx,
      builder: (dctx) => AlertDialog(
        backgroundColor: AppColors.bg2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('$day - Workout', style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: focusCtrl,
                style: const TextStyle(color: AppColors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Focus (e.g. Legs & Abs)',
                  labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  filled: true, fillColor: AppColors.bg3,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: musclesCtrl,
                style: const TextStyle(color: AppColors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Muscles (comma separated)',
                  hintText: 'Quads, Hamstrings, Abs',
                  hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  filled: true, fillColor: AppColors.bg3,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: exercisesCtrl,
                style: const TextStyle(color: AppColors.white, fontSize: 14),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Exercises (comma separated)',
                  hintText: 'Squats, Leg Press, Lunges',
                  hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  filled: true, fillColor: AppColors.bg3,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final f = focusCtrl.text.trim();
              if (f.isEmpty) return;
              final m = musclesCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
              final e = exercisesCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
              onSave(f, m, e);
              Navigator.pop(dctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }


  // â”€â”€â”€ Log Food Buttons (Gradient) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildLogFoodButtons(BuildContext context) {
    final meals = [
      {'icon': '🍳', 'label': 'Breakfast', 'key': 'breakfast', 'color': const Color(0xFF2E5A1A)},
      {'icon': '🍛', 'label': 'Lunch', 'key': 'lunch', 'color': const Color(0xFF5A3A1A)},
      {'icon': '🍽', 'label': 'Dinner', 'key': 'dinner', 'color': const Color(0xFF1A2E5A)},
      {'icon': '🥜', 'label': 'Snack', 'key': 'snack', 'color': const Color(0xFF3A1A5A)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.add_circle, size: 18, color: AppColors.accent),
            const SizedBox(width: 8),
            const Text('Log your food', style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white,
            )),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Tap a meal to add foods â€” calories auto-tracked',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 14),
        Row(
          children: meals.map((m) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: m != meals.last ? 10 : 0),
              child: InkWell(
                onTap: () => showFoodPicker(context, m['key'] as String),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [
                        (m['color'] as Color).withOpacity(0.7),
                        (m['color'] as Color).withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: (m['color'] as Color).withOpacity(0.4)),
                  ),
                  child: Column(
                    children: [
                      Text(m['icon'] as String, style: const TextStyle(fontSize: 26)),
                      const SizedBox(height: 6),
                      Text(m['label'] as String, style: const TextStyle(
                        fontSize: 11, color: AppColors.white, fontWeight: FontWeight.w600,
                      )),
                    ],
                  ),
                ),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  // --- Daily Plan (Unified Chronological Timeline) ---
  Widget _buildDailyPlan(BuildContext context, AppState state, WidgetRef ref) {
    final schedule = state.schedule;
    final planOnly = schedule.where((i) => !i.isCustom).toList();
    final notifier = ref.read(appProvider.notifier);
    final skippedIds = state.skippedIds;
    final activeItems = planOnly.where((i) => !skippedIds.contains(i.id)).toList();
    final doneCount = activeItems.where((i) => i.done).length;
    final totalCount = activeItems.length;
    final skippedCount = planOnly.where((i) => skippedIds.contains(i.id)).length;
    final pct = totalCount > 0 ? doneCount / totalCount : 0.0;

    // ALL plan items sorted by time
    final sortedPlan = List<ScheduleItem>.from(planOnly)
      ..sort((a, b) => _timeToMinutes(a.time).compareTo(_timeToMinutes(b.time)));

    // Logged food items
    final loggedFoods = schedule.where((i) => i.isCustom && i.done).toList();

    // Time periods
    final periods = <_RoutinePeriod>[
      _RoutinePeriod('morning', '\u{1F305}', 'Morning', 0, 12 * 60),
      _RoutinePeriod('afternoon', '\u{2600}', 'Afternoon', 12 * 60, 17 * 60),
      _RoutinePeriod('evening', '\u{1F306}', 'Evening', 17 * 60, 21 * 60),
      _RoutinePeriod('night', '\u{1F319}', 'Night', 21 * 60, 30 * 60),
    ];

    final nowMin = DateTime.now().hour * 60 + DateTime.now().minute;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bg1, borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border1),
          ),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.today_rounded, size: 20, color: AppColors.accent),
              const SizedBox(width: 10),
              const Text("Today's Routine", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.white)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (pct >= 1.0 ? AppColors.green : AppColors.accent).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$doneCount / $totalCount done',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: pct >= 1.0 ? AppColors.green : AppColors.accent)),
              ),
            ]),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: pct, minHeight: 6,
                backgroundColor: AppColors.bg3,
                valueColor: AlwaysStoppedAnimation(pct >= 1.0 ? AppColors.green : AppColors.accent)),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        // Timeline per period
        ...periods.map((period) {
          final items = sortedPlan.where((i) {
            final m = _timeToMinutes(i.time);
            return m >= period.startMin && m < period.endMin;
          }).toList();
          if (items.isEmpty) return const SizedBox.shrink();
          return _buildRoutinePeriod(context, period, items, loggedFoods, nowMin, ref);
        }),
        const SizedBox(height: 10),
        // Add Activity button
        Center(
          child: InkWell(
            onTap: () => _showAddActivityDialog(ref),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle_outline, size: 18, color: AppColors.accent),
                  SizedBox(width: 8),
                  Text('Add Activity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return h * 60 + m;
  }

  int _timeToHour(String time) => _timeToMinutes(time) ~/ 60;

  // --- Period Section ---
  Widget _buildRoutinePeriod(BuildContext context, _RoutinePeriod period,
      List<ScheduleItem> items, List<ScheduleItem> loggedFoods, int nowMin, WidgetRef ref) {
    final isCurrentPeriod = nowMin >= period.startMin && nowMin < period.endMin;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isCurrentPeriod ? AppColors.accent.withValues(alpha: 0.4) : AppColors.border1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(children: [
              Text(period.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(period.label, style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w800,
                color: isCurrentPeriod ? AppColors.accent : AppColors.textSecondary,
              )),
              if (isCurrentPeriod) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('NOW', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.accent)),
                ),
              ],
              const Spacer(),
              Text('${items.where((i) => i.done).length}/${items.length}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: items.every((i) => i.done) ? AppColors.green : AppColors.textMuted)),
            ]),
          ),
          const Divider(height: 1, color: AppColors.border1),
          ...items.map((item) {
            final itemFoods = (item.type == ScheduleItemType.meal || item.type == ScheduleItemType.snack)
                ? loggedFoods.where((f) => f.time == item.time).toList()
                : <ScheduleItem>[];
            return _buildRoutineItem(context, item, itemFoods, nowMin, ref);
          }),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  // --- Single Timeline Item ---
  Widget _buildRoutineItem(BuildContext context, ScheduleItem item,
      List<ScheduleItem> loggedFoods, int nowMin, WidgetRef ref) {
    final itemMin = _timeToMinutes(item.time);
    final isSkipped = ref.read(appProvider.notifier).isSkipped(item.id);
    final isOverdue = !item.done && !isSkipped && nowMin > itemMin + 15;
    final isCurrent = !item.done && !isSkipped && nowMin >= itemMin - 5 && nowMin <= itemMin + 15;
    final typeColor = _getColorForType(item.type);

    return Column(children: [
      GestureDetector(
        onTap: () {
          if (isSkipped) return; // Can't toggle skipped items
          ref.read(appProvider.notifier).toggleScheduleItem(item.id);
        },
        onLongPress: () => _showItemOptionsSheet(context, item, isSkipped, ref),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSkipped
                ? AppColors.bg2.withValues(alpha: 0.3)
                : isCurrent ? AppColors.accent.withValues(alpha: 0.06) : Colors.transparent,
            border: isSkipped
                ? null
                : isOverdue
                    ? const Border(left: BorderSide(color: AppColors.red, width: 3))
                    : isCurrent
                        ? Border(left: BorderSide(color: AppColors.accent, width: 3))
                        : null,
          ),
          child: Row(children: [
            // Time
            SizedBox(
              width: 44,
              child: Text(item.time, style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: isOverdue ? AppColors.red : isCurrent ? AppColors.accent : AppColors.textMuted,
              )),
            ),
            // Icon
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: item.done ? 0.1 : 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(item.icon, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 10),
            // Title + sub
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  if (isSkipped)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('SKIPPED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                    ),
                  Flexible(child: Text(item.title, style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: isSkipped ? AppColors.textMuted.withValues(alpha: 0.5) : item.done ? AppColors.textMuted : AppColors.white,
                    decoration: (item.done || isSkipped) ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.textMuted,
                  ))),
                ]),
                if (item.sub.isNotEmpty)
                  Text(item.sub, style: TextStyle(fontSize: 10,
                    color: item.done ? AppColors.textMuted.withValues(alpha: 0.6) : AppColors.textSecondary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                if (item.calories > 0 && !item.done)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Wrap(spacing: 4, children: [
                      _chipSmall('${item.calories.toInt()} kcal', AppColors.accent),
                      if (item.protein > 0) _chipSmall('P:${item.protein.toInt()}g', AppColors.lavender),
                    ]),
                  ),
              ],
            )),
            // Overdue badge
            if (isOverdue)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: const Text('LATE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.red)),
              ),
            // Done check / Skip icon
            if (isSkipped)
              Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textMuted.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.3), width: 2),
                ),
                child: const Icon(Icons.remove, size: 14, color: AppColors.textMuted),
              )
            else
              Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.done ? AppColors.green.withValues(alpha: 0.15) : Colors.transparent,
                  border: Border.all(
                    color: item.done ? AppColors.green : AppColors.textMuted.withValues(alpha: 0.4), width: 2),
                ),
                child: item.done ? const Icon(Icons.check_rounded, size: 14, color: AppColors.green) : null,
              ),
          ]),
        ),
      ),
      // Logged foods under meal items
      if (loggedFoods.isNotEmpty)
        ...loggedFoods.map((f) => _buildLoggedFoodRow(f, ref)),
    ]);
  }

  Widget _buildLoggedFoodRow(ScheduleItem item, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(left: 58, right: 14, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bg2, borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(item.icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.white)),
              Wrap(spacing: 4, children: [
                Text(item.sub, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
                _chipSmall('${item.calories.toInt()} kcal', AppColors.accent),
                if (item.protein > 0) _chipSmall('P:${item.protein.toInt()}g', AppColors.lavender),
              ]),
            ],
          )),
          InkWell(
            onTap: () => ref.read(appProvider.notifier).deleteScheduleItem(item.id),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.close, size: 12, color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }


  // --- Item Options (Long Press) ---
  void _showItemOptionsSheet(BuildContext context, ScheduleItem item, bool isSkipped, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: AppColors.bg1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: AppColors.textMuted, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Row(children: [
              Text(item.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white)),
                  Text('${item.time} \u{00B7} ${item.sub}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              )),
            ]),
            const SizedBox(height: 20),
            // Skip / Unskip
            _optionTile(
              icon: isSkipped ? Icons.undo_rounded : Icons.skip_next_rounded,
              label: isSkipped ? 'Unskip for today' : 'Skip for today',
              subtitle: isSkipped ? 'Bring this activity back to your routine' : "Not doing this today? Skip it without penalty",
              color: isSkipped ? AppColors.accent : AppColors.amber,
              onTap: () {
                if (isSkipped) {
                  ref.read(appProvider.notifier).unskipScheduleItem(item.id);
                } else {
                  ref.read(appProvider.notifier).skipScheduleItem(item.id);
                }
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 8),
            // Edit
            _optionTile(
              icon: Icons.edit_outlined,
              label: 'Edit time & details',
              subtitle: 'Change the time or description',
              color: AppColors.accent,
              onTap: () {
                Navigator.pop(ctx);
                _showEditScheduleDialog(item, ref);
              },
            ),
            const SizedBox(height: 8),
            // Delete
            _optionTile(
              icon: Icons.delete_outline,
              label: 'Remove from plan',
              subtitle: 'Delete this activity from today',
              color: AppColors.red,
              onTap: () {
                ref.read(appProvider.notifier).deleteScheduleItem(item.id);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionTile({required IconData icon, required String label, required String subtitle, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          )),
          Icon(Icons.chevron_right, size: 18, color: color.withValues(alpha: 0.5)),
        ]),
      ),
    );
  }

  // ─── Add Activity Dialog ────────────────────────────────────
  void _showAddActivityDialog(WidgetRef ref) {
    String selectedType = 'workout';
    final titleCtrl = TextEditingController(text: 'Workout');
    final timeCtrl = TextEditingController(text: '18:00');
    final subCtrl = TextEditingController(text: '30 min session');
    bool setReminder = true;

    final activityOptions = [
      {'key': 'workout', 'icon': '\u{1F3CB}', 'label': 'Workout', 'sub': '30 min session'},
      {'key': 'walk', 'icon': '\u{1F6B6}', 'label': 'Walk', 'sub': '20 min walk'},
      {'key': 'yoga', 'icon': '\u{1F9D8}', 'label': 'Yoga', 'sub': '30 min yoga'},
      {'key': 'meditation', 'icon': '\u{1F9D8}', 'label': 'Meditation', 'sub': '15 min meditation'},
      {'key': 'cycling', 'icon': '\u{1F6B4}', 'label': 'Cycling', 'sub': '30 min cycle'},
      {'key': 'swimming', 'icon': '\u{1F3CA}', 'label': 'Swimming', 'sub': '30 min swim'},
      {'key': 'custom', 'icon': '\u{2B50}', 'label': 'Custom', 'sub': ''},
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          backgroundColor: AppColors.bg2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.add_circle_outline, color: AppColors.accent, size: 22),
            SizedBox(width: 10),
            Text('Add Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white)),
          ]),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Activity type grid
                const Text('Activity type:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: activityOptions.map((opt) {
                    final isSelected = selectedType == opt['key'];
                    return GestureDetector(
                      onTap: () => setDState(() {
                        selectedType = opt['key']!;
                        if (selectedType != 'custom') {
                          titleCtrl.text = opt['label']!;
                          subCtrl.text = opt['sub']!;
                        }
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accent.withOpacity(0.15) : AppColors.bg3,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? AppColors.accent : AppColors.border1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(opt['icon']!, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(opt['label']!, style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: isSelected ? AppColors.accent : AppColors.textSecondary,
                            )),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                // Title
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                  decoration: _editDecor('Title'),
                ),
                const SizedBox(height: 10),
                // Time picker
                Row(children: [
                  SizedBox(width: 100, child: TextField(
                    controller: timeCtrl,
                    style: const TextStyle(color: AppColors.white, fontSize: 14),
                    decoration: _editDecor('Time'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: InkWell(
                    onTap: () async {
                      final parts = timeCtrl.text.split(':');
                      final t = await showTimePicker(context: context,
                        initialTime: TimeOfDay(hour: int.tryParse(parts[0]) ?? 18, minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0));
                      if (t != null) {
                        timeCtrl.text = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(color: AppColors.bg3, borderRadius: BorderRadius.circular(10)),
                      child: const Row(children: [
                        Icon(Icons.access_time, size: 16, color: AppColors.accent),
                        SizedBox(width: 6),
                        Text('Pick time', style: TextStyle(fontSize: 12, color: AppColors.accent)),
                      ]),
                    ),
                  )),
                ]),
                const SizedBox(height: 10),
                // Description
                TextField(
                  controller: subCtrl,
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                  decoration: _editDecor('Description'),
                ),
                const SizedBox(height: 12),
                // Reminder toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.bg3,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    const Icon(Icons.notifications_active, size: 16, color: AppColors.amber),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Set reminder notification', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    Switch(
                      value: setReminder,
                      onChanged: (v) => setDState(() => setReminder = v),
                      activeColor: AppColors.accent,
                    ),
                  ]),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleCtrl.text.trim();
                if (title.isEmpty) return;

                // Request notification permission if reminder is on
                if (setReminder) {
                  final granted = await NotificationService.instance.requestPermission();
                  if (!granted && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Notification permission denied. Reminders won\u2019t work.'),
                      backgroundColor: AppColors.red,
                    ));
                  }
                }

                final option = activityOptions.firstWhere((o) => o['key'] == selectedType, orElse: () => activityOptions.last);
                final icon = option['icon']!;

                // Determine schedule item type
                ScheduleItemType itemType;
                switch (selectedType) {
                  case 'walk': itemType = ScheduleItemType.walk; break;
                  case 'workout':
                  case 'yoga':
                  case 'cycling':
                  case 'swimming': itemType = ScheduleItemType.workout; break;
                  default: itemType = ScheduleItemType.custom; break;
                }

                final item = ScheduleItem(
                  id: const Uuid().v4(),
                  time: timeCtrl.text.trim(),
                  title: title,
                  sub: subCtrl.text.trim(),
                  icon: icon,
                  type: itemType,
                  calories: 0, protein: 0, carbs: 0, fat: 0,
                  done: false, remOn: setReminder, isCustom: false,
                );
                ref.read(appProvider.notifier).addScheduleItem(item);

                // Create a reminder too if toggled on
                if (setReminder) {
                  ref.read(appProvider.notifier).addReminder(Reminder(
                    id: const Uuid().v4(),
                    title: title,
                    time: timeCtrl.text.trim(),
                    type: selectedType == 'walk' ? 'walk' : 'workout',
                    repeat: 'daily',
                    enabled: true,
                  ));
                }

                Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Row(children: [
                      Text(icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text('$title added${setReminder ? ' with reminder' : ''}'),
                    ]),
                    backgroundColor: AppColors.bg3,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Add Activity', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Edit Schedule Item Dialog ─────────────────────────────
  void _showEditScheduleDialog(ScheduleItem item, WidgetRef ref) {
    final isSleep = item.type == ScheduleItemType.sleep;
    final titleCtrl = TextEditingController(text: item.title);
    final subCtrl = TextEditingController(text: item.sub);
    final timeCtrl = TextEditingController(text: item.time);

    // For sleep: parse start/end times
    String sleepStart = '23:00';
    String sleepEnd = '06:00';
    if (isSleep) {
      final rangeMatch = RegExp(r'(\d{1,2}:\d{2})\s*-\s*(\d{1,2}:\d{2})').firstMatch(item.sub);
      if (rangeMatch != null) {
        sleepStart = rangeMatch.group(1)!;
        sleepEnd = rangeMatch.group(2)!;
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) {
          // Calculate sleep hours for display
          double? sleepHours;
          if (isSleep) {
            final sp = sleepStart.split(':');
            final ep = sleepEnd.split(':');
            if (sp.length == 2 && ep.length == 2) {
              final sMin = int.parse(sp[0]) * 60 + int.parse(sp[1]);
              final eMin = int.parse(ep[0]) * 60 + int.parse(ep[1]);
              var diff = eMin - sMin;
              if (diff < 0) diff += 24 * 60;
              sleepHours = diff / 60.0;
            }
          }

          return AlertDialog(
            backgroundColor: AppColors.bg2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(children: [
              Text(item.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text('Edit ${item.title}', style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white,
              )),
            ]),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: AppColors.white, fontSize: 14),
                    decoration: _editDecor('Title'),
                  ),
                  const SizedBox(height: 10),

                  if (isSleep) ...[
                    // Sleep start/end time pickers
                    const Text('Sleep time range:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: InkWell(
                        onTap: () async {
                          final parts = sleepStart.split(':');
                          final t = await showTimePicker(context: context,
                            initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])));
                          if (t != null) {
                            setDState(() => sleepStart = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.bg3, borderRadius: BorderRadius.circular(10)),
                          child: Column(children: [
                            const Text('Bedtime', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            Text(sleepStart, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white)),
                          ]),
                        ),
                      )),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_forward, size: 18, color: AppColors.textMuted)),
                      Expanded(child: InkWell(
                        onTap: () async {
                          final parts = sleepEnd.split(':');
                          final t = await showTimePicker(context: context,
                            initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])));
                          if (t != null) {
                            setDState(() => sleepEnd = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.bg3, borderRadius: BorderRadius.circular(10)),
                          child: Column(children: [
                            const Text('Wake up', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            Text(sleepEnd, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white)),
                          ]),
                        ),
                      )),
                    ]),
                    const SizedBox(height: 8),
                    if (sleepHours != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: sleepHours < 6 ? AppColors.red.withOpacity(0.1) : AppColors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(children: [
                          Icon(sleepHours < 6 ? Icons.warning_amber : Icons.check_circle,
                            size: 16, color: sleepHours < 6 ? AppColors.red : AppColors.green),
                          const SizedBox(width: 8),
                          Text(
                            sleepHours < 4
                              ? '${sleepHours.toStringAsFixed(1)}h — Critical! Rest is priority today'
                              : sleepHours < 6
                                ? '${sleepHours.toStringAsFixed(1)}h — Below ideal (aim for 7-8h)'
                                : '${sleepHours.toStringAsFixed(1)}h — Good sleep duration',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                              color: sleepHours < 6 ? AppColors.red : AppColors.green),
                          ),
                        ]),
                      ),
                    ],
                  ] else ...[
                    // Regular time + description editing
                    Row(children: [
                      SizedBox(width: 100, child: TextField(
                        controller: timeCtrl,
                        style: const TextStyle(color: AppColors.white, fontSize: 14),
                        decoration: _editDecor('Time (HH:MM)'),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: InkWell(
                        onTap: () async {
                          final parts = timeCtrl.text.split(':');
                          final h = int.tryParse(parts[0]) ?? 12;
                          final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
                          final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: h, minute: m));
                          if (t != null) {
                            timeCtrl.text = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(color: AppColors.bg3, borderRadius: BorderRadius.circular(10)),
                          child: const Row(children: [
                            Icon(Icons.access_time, size: 16, color: AppColors.accent),
                            SizedBox(width: 6),
                            Text('Pick time', style: TextStyle(fontSize: 12, color: AppColors.accent)),
                          ]),
                        ),
                      )),
                    ]),
                    const SizedBox(height: 10),
                    TextField(
                      controller: subCtrl,
                      style: const TextStyle(color: AppColors.white, fontSize: 14),
                      decoration: _editDecor('Description'),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ref.read(appProvider.notifier).deleteScheduleItem(item.id);
                  Navigator.pop(ctx);
                },
                child: const Text('Delete', style: TextStyle(color: AppColors.red)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  final updated = item.copyWith(
                    title: titleCtrl.text.trim(),
                    time: isSleep ? sleepStart : timeCtrl.text.trim(),
                    sub: isSleep ? '$sleepStart - $sleepEnd (${((sleepHours ?? 0)).toStringAsFixed(1)}h)' : subCtrl.text.trim(),
                  );
                  ref.read(appProvider.notifier).updateScheduleItem(item.id, updated);
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Save', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  InputDecoration _editDecor(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      filled: true, fillColor: AppColors.bg3,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.accent)),
    );
  }

  // ─── Health Insights Card ──────────────────────────────────
  Widget _buildHealthInsights(AppNotifier notifier) {
    final insights = notifier.healthInsights;
    if (insights.isEmpty) return const SizedBox.shrink();

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
          const Row(children: [
            Icon(Icons.lightbulb_outline, size: 18, color: AppColors.amber),
            SizedBox(width: 8),
            Text("Today's Insights", style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white,
            )),
          ]),
          const SizedBox(height: 12),
          ...insights.map((i) => _buildInsightTile(i)),
        ],
      ),
    );
  }

  Widget _buildInsightTile(Map<String, String> insight) {
    final type = insight['type'] ?? 'info';
    Color bgColor;
    Color borderColor;
    switch (type) {
      case 'critical': bgColor = AppColors.red.withOpacity(0.08); borderColor = AppColors.red.withOpacity(0.3); break;
      case 'warning': bgColor = AppColors.amber.withOpacity(0.08); borderColor = AppColors.amber.withOpacity(0.3); break;
      case 'good': bgColor = AppColors.green.withOpacity(0.08); borderColor = AppColors.green.withOpacity(0.3); break;
      default: bgColor = AppColors.accent.withOpacity(0.06); borderColor = AppColors.accent.withOpacity(0.2); break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(insight['icon'] ?? '\u{1F4A1}', style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(insight['title'] ?? '', style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.white,
              )),
              const SizedBox(height: 3),
              Text(insight['msg'] ?? '', style: const TextStyle(
                fontSize: 11, height: 1.4, color: AppColors.textSecondary,
              )),
            ],
          )),
        ],
      ),
    );
  }

  Widget _chipSmall(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(5)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
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

/// Helper class for time period grouping
class _RoutinePeriod {
  final String key;
  final String emoji;
  final String label;
  final int startMin;
  final int endMin;

  const _RoutinePeriod(this.key, this.emoji, this.label, this.startMin, this.endMin);
}


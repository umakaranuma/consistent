import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/colors.dart';
import '../../store/app_provider.dart';
import '../../store/types.dart';
import '../../utils/bmi_engine.dart';
import '../../components/food_picker_sheet.dart';
import 'bmi_details_screen.dart';

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

  // â”€â”€â”€ Weekly Workout Row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

  // â”€â”€â”€ Daily Plan (Unified meal-period cards) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildDailyPlan(BuildContext context, AppState state, WidgetRef ref) {
    final schedule = state.schedule;
    final doneCount = schedule.where((i) => i.done).length;
    final totalCount = schedule.length;
    final pct = totalCount > 0 ? doneCount / totalCount : 0.0;

    // Define meal periods
    final periods = [
      _MealPeriod(key: 'breakfast', emoji: '🍳', label: 'Breakfast', time: '07:30',
        color: const Color(0xFF2E5A1A), scheduleTypes: {ScheduleItemType.meal},
        hourRange: [0, 10]),
      _MealPeriod(key: 'lunch', emoji: '🍛', label: 'Lunch', time: '13:00',
        color: const Color(0xFF5A3A1A), scheduleTypes: {ScheduleItemType.meal},
        hourRange: [10, 14]),
      _MealPeriod(key: 'snack', emoji: '🥜', label: 'Snacks', time: '16:00',
        color: const Color(0xFF3A1A5A), scheduleTypes: {ScheduleItemType.snack, ScheduleItemType.protein},
        hourRange: [14, 18]),
      _MealPeriod(key: 'dinner', emoji: '🍽', label: 'Dinner', time: '20:00',
        color: const Color(0xFF1A2E5A), scheduleTypes: {ScheduleItemType.meal},
        hourRange: [18, 24]),
    ];

    // Non-meal activities (workout, water, walk, sleep)
    final activityTypes = {ScheduleItemType.workout, ScheduleItemType.water,
      ScheduleItemType.walk, ScheduleItemType.sleep, ScheduleItemType.custom};
    final activities = schedule.where((i) => activityTypes.contains(i.type) && !i.isCustom).toList();

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
              const Text('Daily Plan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.white)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (pct >= 1.0 ? AppColors.green : AppColors.accent).withOpacity(0.12),
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
        // Meal period cards
        ...periods.map((p) {
          final planItems = schedule.where((i) =>
            !i.isCustom && p.scheduleTypes.contains(i.type) &&
            _timeToHour(i.time) >= p.hourRange[0] && _timeToHour(i.time) < p.hourRange[1]
          ).toList();
          final loggedItems = schedule.where((i) =>
            i.isCustom && i.done && i.time == p.time
          ).toList();
          return _buildMealCard(context, p, planItems, loggedItems, ref);
        }),
        // Activities section
        if (activities.isNotEmpty) ...[
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text('💪  Activities', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ),
          ...activities.map((item) => _buildActivityItem(item, ref)),
        ],
      ],
    );
  }

  int _timeToHour(String time) {
    final parts = time.split(':');
    return int.tryParse(parts[0]) ?? 12;
  }

  Widget _buildMealCard(BuildContext context, _MealPeriod period,
      List<ScheduleItem> planItems, List<ScheduleItem> loggedItems, WidgetRef ref) {
    final isExpanded = _expandedMeal == period.key;
    final totalCals = loggedItems.fold(0.0, (s, i) => s + i.calories);
    final totalProtein = loggedItems.fold(0.0, (s, i) => s + i.protein);
    final planDone = planItems.where((i) => i.done).length;
    final hasLogged = loggedItems.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isExpanded ? period.color.withOpacity(0.5) : AppColors.border1),
      ),
      child: Column(
        children: [
          // â”€â”€â”€ Header (tap to expand/collapse) â”€â”€â”€
          InkWell(
            onTap: () => setState(() => _expandedMeal = isExpanded ? '' : period.key),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Meal emoji in colored circle
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: period.color.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(period.emoji, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 14),
                  // Name + stats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(period.label, style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white,
                        )),
                        const SizedBox(height: 3),
                        Row(children: [
                          Text(period.time, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          if (planItems.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text('$planDone/${planItems.length} tasks', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                          if (hasLogged) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.green.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('${totalCals.toInt()} kcal', style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.green,
                              )),
                            ),
                          ],
                        ]),
                      ],
                    ),
                  ),
                  // Arrow
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 24),
                  ),
                ],
              ),
            ),
          ),
          // â”€â”€â”€ Expanded content â”€â”€â”€
          if (isExpanded) ...[
            Divider(height: 1, color: period.color.withOpacity(0.15)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logged food items
                  if (hasLogged) ...[
                    Row(children: [
                      const Icon(Icons.check_circle, size: 14, color: AppColors.green),
                      const SizedBox(width: 6),
                      Text('Food eaten', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.green)),
                      const Spacer(),
                      Text('${totalCals.toInt()} kcal Â· P:${totalProtein.toInt()}g',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    ]),
                    const SizedBox(height: 8),
                    ...loggedItems.map((item) => _buildLoggedFoodRow(item, ref)),
                    const SizedBox(height: 12),
                  ],
                  // Plan items (schedule tasks for this meal period)
                  if (planItems.isNotEmpty) ...[
                    Row(children: [
                      Icon(Icons.list_alt_rounded, size: 14, color: AppColors.accent.withOpacity(0.7)),
                      const SizedBox(width: 6),
                      const Text('Planned', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                    ]),
                    const SizedBox(height: 8),
                    ...planItems.map((item) => _buildPlanRow(item, ref)),
                  ],
                  // Add food button
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => showFoodPicker(context, period.key == 'snack' ? 'snack' : period.key),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text('Add ${period.label}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: BorderSide(color: AppColors.accent.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoggedFoodRow(ScheduleItem item, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bg2, borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(item.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.white)),
              const SizedBox(height: 3),
              Wrap(spacing: 6, children: [
                Text(item.sub, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                _chipSmall('${item.calories.toInt()} kcal', AppColors.accent),
                if (item.protein > 0) _chipSmall('P:${item.protein.toInt()}g', AppColors.lavender),
                if (item.carbs > 0) _chipSmall('C:${item.carbs.toInt()}g', AppColors.amber),
              ]),
            ],
          )),
          InkWell(
            onTap: () => ref.read(appProvider.notifier).deleteScheduleItem(item.id),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.close, size: 14, color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanRow(ScheduleItem item, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(appProvider.notifier).toggleScheduleItem(item.id),
      onLongPress: () => _showEditScheduleDialog(item, ref),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: item.done ? AppColors.bg2.withOpacity(0.5) : AppColors.bg2,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.done ? AppColors.green.withOpacity(0.15) : Colors.transparent,
                border: Border.all(color: item.done ? AppColors.green : AppColors.textMuted.withOpacity(0.4), width: 2),
              ),
              child: item.done ? const Icon(Icons.check, size: 13, color: AppColors.green) : null,
            ),
            const SizedBox(width: 10),
            Text(item.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: item.done ? AppColors.textMuted : AppColors.white,
                  decoration: item.done ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.textMuted,
                )),
                if (item.sub.isNotEmpty)
                  Text('${item.time} Â· ${item.sub}', style: TextStyle(
                    fontSize: 10, color: item.done ? AppColors.textMuted : AppColors.textSecondary,
                  )),
              ],
            )),
            if (item.calories > 0 && !item.done)
              _chipSmall('${item.calories.toInt()} kcal', AppColors.accentSoft),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(ScheduleItem item, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(appProvider.notifier).toggleScheduleItem(item.id),
      onLongPress: () => _showEditScheduleDialog(item, ref),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.done ? AppColors.bg1.withOpacity(0.5) : AppColors.bg1,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: item.done ? AppColors.green.withOpacity(0.2) : AppColors.border1),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _getColorForType(item.type).withOpacity(item.done ? 0.15 : 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(item.icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: item.done ? AppColors.textMuted : AppColors.white,
                decoration: item.done ? TextDecoration.lineThrough : null, decorationColor: AppColors.textMuted)),
              Text('${item.time} Â· ${item.sub}', style: TextStyle(fontSize: 11,
                color: item.done ? AppColors.textMuted : AppColors.textSecondary)),
            ],
          )),
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.done ? AppColors.green.withOpacity(0.15) : Colors.transparent,
              border: Border.all(color: item.done ? AppColors.green : AppColors.textMuted.withOpacity(0.5), width: 2),
            ),
            child: item.done ? const Icon(Icons.check_rounded, size: 16, color: AppColors.green) : null,
          ),
        ]),
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

/// Helper class for meal period definitions
class _MealPeriod {
  final String key;
  final String emoji;
  final String label;
  final String time;
  final Color color;
  final Set<ScheduleItemType> scheduleTypes;
  final List<int> hourRange; // [start, end) hours

  const _MealPeriod({
    required this.key, required this.emoji, required this.label,
    required this.time, required this.color, required this.scheduleTypes,
    required this.hourRange,
  });
}


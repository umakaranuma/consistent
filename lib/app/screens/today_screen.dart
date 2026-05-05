import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/colors.dart';
import '../../store/app_provider.dart';
import '../../store/types.dart';
import '../../utils/bmi_engine.dart';
import '../../components/food_picker_sheet.dart';
import 'bmi_details_screen.dart';

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
                  _buildBmiCard(context, profile, ref),
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
                  _buildWaterCard(context, state.waterConfig, ref),
                  const SizedBox(height: 16),
                  // ─── Weekly Workout ──────
                  _buildWeeklyWorkoutRow(profile),
                  const SizedBox(height: 24),
                  // ─── Log Food Buttons ────
                  _buildLogFoodButtons(context),
                  const SizedBox(height: 28),
                  // ─── Schedule Section ─────
                  _buildScheduleSection(state, ref),
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
                      child: Text('Detail ›', style: TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.bold)),
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

  // ─── Score Row (Circular Progress Rings) ───────────────────
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
      _scoreCard('Workout', workoutDone ? '✓' : '—', workoutDone ? 1.0 : 0.0, AppColors.amber, Icons.fitness_center_outlined),
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

  // ─── Calorie Card (Donut style) ───────────────────────────
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

  // ─── Macro Card (Visual bars with percentage) ─────────────
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

  // ─── Water Card ───────────────────────────────────────────
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

  // ─── Log Food Buttons (Gradient) ───────────────────────────
  Widget _buildLogFoodButtons(BuildContext context) {
    final meals = [
      {'icon': '🍳', 'label': 'Breakfast', 'key': 'breakfast', 'color': const Color(0xFF2E5A1A)},
      {'icon': '🍛', 'label': 'Lunch', 'key': 'lunch', 'color': const Color(0xFF5A3A1A)},
      {'icon': '🍽️', 'label': 'Dinner', 'key': 'dinner', 'color': const Color(0xFF1A2E5A)},
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
        const Text('Tap a meal to add foods — calories auto-tracked',
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

  // ─── Schedule Section (Timeline) ──────────────────────────
  Widget _buildScheduleSection(AppState state, WidgetRef ref) {
    final schedule = state.schedule;
    final doneCount = schedule.where((i) => i.done).length;
    final totalCount = schedule.length;
    final pct = totalCount > 0 ? doneCount / totalCount : 0.0;

    // Group items by time-of-day
    final morning = schedule.where((i) => _timeToHour(i.time) < 12).toList();
    final afternoon = schedule.where((i) => _timeToHour(i.time) >= 12 && _timeToHour(i.time) < 17).toList();
    final evening = schedule.where((i) => _timeToHour(i.time) >= 17).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with progress
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bg1,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border1),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.schedule_rounded, size: 20, color: AppColors.accent),
                  const SizedBox(width: 10),
                  const Text('Daily Schedule', style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.white,
                  )),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: pct >= 1.0 ? AppColors.green.withOpacity(0.15) : AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$doneCount / $totalCount done',
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: pct >= 1.0 ? AppColors.green : AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: AppColors.bg3,
                  valueColor: AlwaysStoppedAnimation(
                    pct >= 1.0 ? AppColors.green : AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Time-of-day groups
        if (morning.isNotEmpty)
          _buildTimeGroup('🌅  Morning', morning, ref),
        if (afternoon.isNotEmpty)
          _buildTimeGroup('☀️  Afternoon', afternoon, ref),
        if (evening.isNotEmpty)
          _buildTimeGroup('🌙  Evening', evening, ref),
      ],
    );
  }

  int _timeToHour(String time) {
    final parts = time.split(':');
    return int.tryParse(parts[0]) ?? 12;
  }

  Widget _buildTimeGroup(String label, List<ScheduleItem> items, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: Text(label, style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary,
          )),
        ),
        ...items.map((item) => _buildScheduleItem(item, ref)),
        const SizedBox(height: 8),
      ],
    );
  }

  // ─── Schedule Item (Timeline style) ───────────────────────
  Widget _buildScheduleItem(ScheduleItem item, WidgetRef ref) {
    final typeColor = _getAccentForType(item.type);
    final hasMacros = item.calories > 0 || item.protein > 0;

    return GestureDetector(
      onTap: () => ref.read(appProvider.notifier).toggleScheduleItem(item.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.done ? AppColors.bg1.withOpacity(0.5) : AppColors.bg1,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: item.done ? AppColors.green.withOpacity(0.2) : AppColors.border1,
          ),
        ),
        child: Row(
          children: [
            // Timeline dot + time
            Column(
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.done ? AppColors.green : typeColor.withOpacity(0.5),
                    border: Border.all(
                      color: item.done ? AppColors.green : typeColor, width: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(item.time, style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: item.done ? AppColors.textMuted : AppColors.textSecondary,
                )),
              ],
            ),
            const SizedBox(width: 12),
            // Icon
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: _getColorForType(item.type).withOpacity(item.done ? 0.15 : 0.4),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(item.icon, style: TextStyle(fontSize: 20,
                color: item.done ? Colors.white54 : null)),
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
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: item.done ? AppColors.textMuted : AppColors.white,
                      decoration: item.done ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(item.sub, style: TextStyle(
                    fontSize: 11,
                    color: item.done ? AppColors.textMuted : AppColors.textSecondary,
                  )),
                  if (hasMacros && !item.done) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        _schedMacroChip('${item.calories.toInt()} kcal', AppColors.accent),
                        if (item.protein > 0)
                          _schedMacroChip('P: ${item.protein.toInt()}g', AppColors.lavender),
                        if (item.carbs > 0)
                          _schedMacroChip('C: ${item.carbs.toInt()}g', AppColors.amber),
                        if (item.fat > 0)
                          _schedMacroChip('F: ${item.fat.toInt()}g', AppColors.teal),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Done indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.done ? AppColors.green.withOpacity(0.15) : Colors.transparent,
                border: Border.all(
                  color: item.done ? AppColors.green : AppColors.textMuted.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: item.done
                ? const Icon(Icons.check_rounded, size: 16, color: AppColors.green)
                : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _schedMacroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(
        fontSize: 10, fontWeight: FontWeight.w600, color: color,
      )),
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

  Color _getAccentForType(ScheduleItemType type) {
    switch (type) {
      case ScheduleItemType.meal: return AppColors.green;
      case ScheduleItemType.snack: return AppColors.amber;
      case ScheduleItemType.workout: return AppColors.red;
      case ScheduleItemType.water: return AppColors.blue;
      case ScheduleItemType.sleep: return AppColors.lavender;
      case ScheduleItemType.walk: return AppColors.teal;
      case ScheduleItemType.protein: return AppColors.blue;
      default: return AppColors.accent;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/colors.dart';
import '../../store/app_provider.dart';
import '../../store/types.dart';
import 'dart:math' as math;

class TodayScreen extends ConsumerWidget {
  const TodayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final profile = state.profile;
    
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(profile),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildMacroCard(profile, state.schedule),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildWaterCard(state.waterConfig, state.schedule)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildStepsCard(profile.stepGoal)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Daily Schedule',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildScheduleList(state.schedule),
                  const SizedBox(height: 100), // Bottom padding for FAB/Navigation
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(UserProfile profile) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.bg0,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        title: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${profile.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  'Let\'s smash your goals today!',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            const Spacer(),
            CircleAvatar(
              backgroundColor: AppColors.bg2,
              child: const Icon(Icons.person_outline, color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroCard(UserProfile profile, List<ScheduleItem> schedule) {
    final targets = profile.macroTargets;
    
    double eaten = 0;
    double pEaten = 0;
    double cEaten = 0;
    double fEaten = 0;

    for (var item in schedule) {
      if (item.done) {
        eaten += item.calories;
        pEaten += item.protein;
        cEaten += item.carbs;
        fEaten += item.fat;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calories',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${eaten.toInt()} / ${targets.calories.toInt()} kcal',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: targets.calories > 0 ? (eaten / targets.calories).clamp(0.0, 1.0) : 0,
                      strokeWidth: 6,
                      backgroundColor: AppColors.bg3,
                      valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    ),
                  ),
                  Text(
                    '${targets.calories > 0 ? (eaten / targets.calories * 100).toInt() : 0}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroProgress('Protein', pEaten, targets.protein, AppColors.blue),
              _buildMacroProgress('Carbs', cEaten, targets.carbs, AppColors.amber),
              _buildMacroProgress('Fat', fEaten, targets.fat, AppColors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroProgress(String label, double current, double target, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: LinearProgressIndicator(
            value: target > 0 ? (current / target).clamp(0.0, 1.0) : 0,
            minHeight: 4,
            backgroundColor: AppColors.bg3,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${current.toInt()}g / ${target.toInt()}g',
          style: const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildWaterCard(WaterConfig? config, List<ScheduleItem> schedule) {
    double current = config?.consumed ?? 0.0;
    final target = config?.target ?? 2500.0;

    // For demo/simplicity, if there are checked water items we can estimate
    int waterItemsDone = schedule.where((i) => i.type == ScheduleItemType.water && i.done).length;
    if (waterItemsDone > 0 && current == 0) {
      // Just a fallback if user taps schedule items instead of the water button directly
      current = waterItemsDone * 250.0;
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
              const Icon(Icons.water_drop_outlined, color: AppColors.blue),
              Consumer(builder: (context, ref, child) {
                return InkWell(
                  onTap: () {
                    ref.read(appProvider.notifier).addWater(250);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('+ 250ml', style: TextStyle(color: AppColors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Water', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            '${current.toInt()} ml',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: target > 0 ? (current / target).clamp(0.0, 1.0) : 0,
            backgroundColor: AppColors.bg3,
            valueColor: const AlwaysStoppedAnimation(AppColors.blue),
            minHeight: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildStepsCard(double stepGoal) {
    const current = 6432;
    
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
          const Icon(Icons.directions_walk, color: AppColors.green),
          const SizedBox(height: 12),
          const Text('Steps', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            '$current',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: current / stepGoal,
            backgroundColor: AppColors.bg3,
            valueColor: const AlwaysStoppedAnimation(AppColors.green),
            minHeight: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList(List<ScheduleItem> items) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No schedule planned.', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }
    return Consumer(builder: (context, ref, child) {
      return Column(
        children: items.map((item) => _buildScheduleItem(
          item.id,
          item.time, 
          item.title, 
          item.sub, 
          item.icon, 
          _getColorForType(item.type),
          item.done,
          ref,
        )).toList(),
      );
    });
  }

  Color _getColorForType(ScheduleItemType type) {
    switch (type) {
      case ScheduleItemType.meal: return AppColors.iconMeal;
      case ScheduleItemType.snack: return AppColors.iconSnack;
      case ScheduleItemType.workout: return AppColors.iconWorkout;
      case ScheduleItemType.water: return AppColors.iconWater;
      case ScheduleItemType.sleep: return AppColors.iconSleep;
      case ScheduleItemType.walk: return AppColors.iconWalk;
      default: return AppColors.iconCustom;
    }
  }

  Widget _buildScheduleItem(String id, String time, String title, String sub, String icon, Color iconBg, bool done, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: done ? AppColors.textSecondary : AppColors.white,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  '$time • $sub',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Checkbox(
            value: done,
            onChanged: (val) {
              ref.read(appProvider.notifier).toggleScheduleItem(id);
            },
            activeColor: AppColors.accent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }
}

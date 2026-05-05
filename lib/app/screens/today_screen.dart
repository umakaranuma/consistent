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
                  _buildMacroCard(profile),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildWaterCard(state.waterConfig)),
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

  Widget _buildMacroCard(UserProfile profile) {
    final targets = profile.macroTargets;
    // For demo purposes, we'll show some progress
    const eaten = 1200.0;
    const pEaten = 85.0;
    const cEaten = 110.0;
    const fEaten = 45.0;

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
                      value: eaten / targets.calories,
                      strokeWidth: 6,
                      backgroundColor: AppColors.bg3,
                      valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    ),
                  ),
                  Text(
                    '${(eaten / targets.calories * 100).toInt()}%',
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
            value: current / target,
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

  Widget _buildWaterCard(WaterConfig? config) {
    final current = config?.consumed ?? 0.0;
    final target = config?.target ?? 2500.0;
    
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
          const Icon(Icons.water_drop_outlined, color: AppColors.blue),
          const SizedBox(height: 12),
          const Text('Water', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            '${current.toInt()} ml',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: current / target,
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
      // Mock some items if empty for design
      return Column(
        children: [
          _buildScheduleItem('08:00', 'Breakfast', 'Oatmeal & Fruits', '🥣', AppColors.iconMeal, true),
          _buildScheduleItem('10:30', 'Morning Snack', 'Almonds & Yogurt', '🥜', AppColors.iconSnack, false),
          _buildScheduleItem('13:00', 'Lunch', 'Chicken Salad', '🥗', AppColors.iconMeal, false),
          _buildScheduleItem('17:00', 'Gym Workout', 'Upper Body Session', '💪', AppColors.iconWorkout, false),
        ],
      );
    }
    return Column(
      children: items.map((item) => _buildScheduleItem(
        item.time, 
        item.title, 
        item.sub, 
        item.icon, 
        _getColorForType(item.type),
        item.done
      )).toList(),
    );
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

  Widget _buildScheduleItem(String time, String title, String sub, String icon, Color iconBg, bool done) {
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
            onChanged: (val) {},
            activeColor: AppColors.accent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }
}

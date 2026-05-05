import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/colors.dart';
import '../../store/app_provider.dart';
import '../../store/types.dart';
import '../../utils/bmi_engine.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

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
          SliverAppBar(
            expandedHeight: 60,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.bg0,
            title: const Text('Profile & Settings', style: TextStyle(fontSize: 18)),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // ─── Profile Header ──────
                  _buildProfileHeader(profile),
                  const SizedBox(height: 24),
                  // ─── BMI Card ────────────
                  _buildBmiSection(profile),
                  const SizedBox(height: 20),
                  // ─── Mode ────────────────
                  _sectionHeader('Mode'),
                  _settingsRow('App mode', profile.mode == AppMode.gym ? 'Gym' : 'Normal', Icons.swap_horiz),
                  if (profile.mode == AppMode.gym)
                    _settingsRow('Gym goal', _gymGoalLabel(profile.gymGoal), Icons.flag_outlined),
                  const SizedBox(height: 20),
                  // ─── Body Stats ──────────
                  _sectionHeader('Body Stats'),
                  _settingsRow('Height', '${profile.heightCm.toInt()} cm', Icons.height),
                  _settingsRow('Current weight', '${profile.currentWeight.toStringAsFixed(1)} kg', Icons.monitor_weight_outlined),
                  _settingsRow('Goal weight', '${profile.goalWeight.toStringAsFixed(1)} kg', Icons.track_changes),
                  _settingsRow('BMI', '${profile.bmi.toStringAsFixed(1)} — ${BmiEngine.getBmiLabel(profile.bmiCategory)}', Icons.analytics_outlined, readonly: true),
                  const SizedBox(height: 20),
                  // ─── Water Settings ──────
                  _sectionHeader('Water Settings'),
                  _settingsRow('Daily target', '${state.waterConfig?.target.toInt() ?? 0} ml', Icons.water_drop_outlined),
                  _settingsRow('Reminder interval', '${state.waterConfig?.reminderIntervalMinutes.toInt() ?? 60} min', Icons.timer_outlined),
                  _settingsRow('Per reminder', '${state.waterConfig?.mlPerReminder.toInt() ?? 250} ml', Icons.local_drink_outlined),
                  const SizedBox(height: 20),
                  // ─── Diet & Calories ─────
                  _sectionHeader('Diet & Calories'),
                  _settingsRow('Calorie target', '${profile.macroTargets.calories.toInt()} kcal', Icons.local_fire_department_outlined),
                  _settingsRow('Protein target', '${profile.macroTargets.protein.toInt()}g', Icons.egg_outlined),
                  _settingsRow('Activity level', _activityLabel(profile.activityLevel), Icons.directions_run),
                  if (profile.planLockedByUser)
                    _actionRow('Reset to recommended plan', Icons.refresh, AppColors.amber, () {
                      ref.read(appProvider.notifier).regeneratePlan();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Plan regenerated from your profile!'),
                        backgroundColor: AppColors.bg3,
                      ));
                    }),
                  const SizedBox(height: 20),
                  // ─── Notifications ───────
                  _sectionHeader('Notifications'),
                  _toggleRow('Push notifications', profile.pushEnabled, Icons.notifications_active_outlined),
                  _toggleRow('Workout reminders', profile.workoutReminders, Icons.fitness_center),
                  _toggleRow('Sleep reminder', profile.sleepReminder, Icons.bedtime_outlined),
                  const SizedBox(height: 20),
                  // ─── App ─────────────────
                  _sectionHeader('App'),
                  _settingsRow('Step goal', '${profile.stepGoal.toInt()}', Icons.directions_walk),
                  _settingsRow('Units', profile.units == 'metric' ? 'Metric (kg, cm)' : 'Imperial (lbs, ft/in)', Icons.straighten),
                  _settingsRow('Age', '${profile.age.toInt()}', Icons.cake_outlined),
                  _settingsRow('Gender', profile.gender == 'male' ? 'Male' : 'Female', Icons.person_outline),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    final initials = profile.name.isNotEmpty
      ? profile.name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
      : 'U';
    final bmiColor = _bmiColor(profile.bmiCategory);

    return Row(
      children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: AppColors.accentBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accent, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(initials, style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accent,
          )),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profile.name, style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white,
              )),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: bmiColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${profile.bmi.toStringAsFixed(1)} · ${BmiEngine.getBmiLabel(profile.bmiCategory)}',
                  style: TextStyle(fontSize: 11, color: bmiColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBmiSection(UserProfile profile) {
    final bmiColor = _bmiColor(profile.bmiCategory);
    final barPos = ((profile.bmi - 15) / 25 * 100).clamp(0.0, 100.0);
    final ideal = BmiEngine.getIdealWeightRange(profile.heightCm);

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
            children: [
              Text(profile.bmi.toStringAsFixed(1), style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: bmiColor,
              )),
              const SizedBox(width: 12),
              Text(BmiEngine.getBmiLabel(profile.bmiCategory), style: TextStyle(
                fontSize: 14, color: bmiColor, fontWeight: FontWeight.w500,
              )),
            ],
          ),
          const SizedBox(height: 12),
          // BMI bar with markers
          Stack(
            children: [
              Container(height: 8, decoration: BoxDecoration(
                color: AppColors.bg3, borderRadius: BorderRadius.circular(4),
              )),
              FractionallySizedBox(
                widthFactor: barPos / 100,
                child: Container(height: 8, decoration: BoxDecoration(
                  color: bmiColor, borderRadius: BorderRadius.circular(4),
                )),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('<18.5', style: TextStyle(fontSize: 9, color: AppColors.bmiUnder)),
              Text('18.5-25', style: TextStyle(fontSize: 9, color: AppColors.bmiNormal)),
              Text('25-30', style: TextStyle(fontSize: 9, color: AppColors.bmiOver)),
              Text('>30', style: TextStyle(fontSize: 9, color: AppColors.bmiObese)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Ideal range for your height: ${ideal['min']}–${ideal['max']} kg',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary,
        )),
      ),
    );
  }

  Widget _settingsRow(String label, String value, IconData icon, {bool readonly = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(
            fontSize: 14, color: AppColors.white,
          ))),
          Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          if (!readonly) ...[
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
          ],
        ],
      ),
    );
  }

  Widget _toggleRow(String label, bool value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.white))),
          Switch(
            value: value,
            onChanged: (_) {},
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _actionRow(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6, top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  String _gymGoalLabel(GymGoal? goal) {
    switch (goal) {
      case GymGoal.fatLoss: return 'Fat Loss';
      case GymGoal.muscleGain: return 'Muscle Gain';
      case GymGoal.maintenance: return 'Maintenance';
      case GymGoal.recomp: return 'Recomp';
      default: return '—';
    }
  }

  String _activityLabel(String level) {
    switch (level) {
      case 'sedentary': return 'Sedentary';
      case 'light': return 'Light';
      case 'moderate': return 'Moderate';
      case 'active': return 'Active';
      case 'very_active': return 'Very Active';
      default: return level;
    }
  }

  Color _bmiColor(BmiCategory cat) {
    switch (cat) {
      case BmiCategory.underweight: return AppColors.bmiUnder;
      case BmiCategory.normal: return AppColors.bmiNormal;
      case BmiCategory.overweight: return AppColors.bmiOver;
      case BmiCategory.obese: return AppColors.bmiObese;
    }
  }
}

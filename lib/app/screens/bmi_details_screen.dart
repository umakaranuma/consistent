import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/colors.dart';
import '../../store/app_provider.dart';
import '../../store/types.dart';
import '../../utils/bmi_engine.dart';

class BmiDetailsScreen extends ConsumerWidget {
  const BmiDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(appProvider).profile;
    if (profile == null) return const Scaffold();

    final bmi = profile.bmi;
    final cat = profile.bmiCategory;
    final ideal = BmiEngine.getIdealWeightRange(profile.heightCm);
    final weight = profile.currentWeight;

    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        backgroundColor: AppColors.bg0,
        elevation: 0,
        title: const Text('BMI & Weight Analysis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Status Card
            _buildStatusCard(profile, ideal, weight, cat),
            const SizedBox(height: 24),

            // Color Coded Range Legend
            const Text('BMI Categories', style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white,
            )),
            const SizedBox(height: 16),
            _buildRangeLegend(bmi),
            const SizedBox(height: 32),

            // Weight Range Details
            const Text('Weight Details', style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white,
            )),
            const SizedBox(height: 16),
            _buildWeightDetails(profile, ideal),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(UserProfile profile, Map<String, double> ideal, double weight, BmiCategory cat) {
    final color = _bmiColor(cat);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          Text('Your current BMI is', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(profile.bmi.toStringAsFixed(1), style: TextStyle(
            fontSize: 48, fontWeight: FontWeight.w900, color: color,
          )),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(BmiEngine.getBmiLabel(cat).toUpperCase(), style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: color,
            )),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statColumn('Height', '${profile.heightCm.toInt()} cm'),
              Container(width: 1, height: 40, color: AppColors.border2),
              _statColumn('Weight', '${weight.toStringAsFixed(1)} kg'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white)),
      ],
    );
  }

  Widget _buildRangeLegend(double currentBmi) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border1),
      ),
      child: Column(
        children: [
          _legendRow('Underweight', '< 18.5', AppColors.bmiUnder, currentBmi < 18.5),
          const Divider(height: 1, color: AppColors.border2),
          _legendRow('Normal', '18.5 - 24.9', AppColors.bmiNormal, currentBmi >= 18.5 && currentBmi < 25),
          const Divider(height: 1, color: AppColors.border2),
          _legendRow('Overweight', '25.0 - 29.9', AppColors.bmiOver, currentBmi >= 25 && currentBmi < 30),
          const Divider(height: 1, color: AppColors.border2),
          _legendRow('Obese', '≥ 30.0', AppColors.bmiObese, currentBmi >= 30),
        ],
      ),
    );
  }

  Widget _legendRow(String label, String range, Color color, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isCurrent ? color.withValues(alpha: 0.1) : Colors.transparent,
      ),
      child: Row(
        children: [
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: TextStyle(
              fontSize: 15,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
              color: isCurrent ? color : AppColors.white,
            )),
          ),
          Text(range, style: TextStyle(
            fontSize: 14,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? color : AppColors.textSecondary,
          )),
        ],
      ),
    );
  }

  Widget _buildWeightDetails(UserProfile profile, Map<String, double> ideal) {
    final weight = profile.currentWeight;
    final goal = profile.goalWeight;
    
    double diffToNormal = 0;
    String advice = '';
    
    if (profile.bmi < 18.5) {
      diffToNormal = ideal['min']! - weight;
      advice = 'You need to gain at least ${diffToNormal.toStringAsFixed(1)} kg to reach a healthy weight.';
    } else if (profile.bmi > 24.9) {
      diffToNormal = weight - ideal['max']!;
      advice = 'You need to lose at least ${diffToNormal.toStringAsFixed(1)} kg to reach a healthy weight.';
    } else {
      advice = 'Great job! You are within the healthy weight range for your height.';
    }

    final diffToGoal = (weight - goal).abs();
    final goalText = weight > goal 
        ? 'Lose ${diffToGoal.toStringAsFixed(1)} kg to reach goal'
        : weight < goal 
            ? 'Gain ${diffToGoal.toStringAsFixed(1)} kg to reach goal'
            : 'You have reached your goal weight!';

    return Container(
      padding: const EdgeInsets.all(20),
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
              const Text('Healthy Range', style: TextStyle(color: AppColors.textSecondary)),
              Text('${ideal['min']} kg - ${ideal['max']} kg', style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.bmiNormal, fontSize: 16,
              )),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border2),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Personal Goal', style: TextStyle(color: AppColors.textSecondary)),
              Text('${goal.toStringAsFixed(1)} kg', style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.accent, fontSize: 16,
              )),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(advice, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.flag_outlined, color: AppColors.accent, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(goalText, style: const TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w500))),
              ],
            ),
          ),
        ],
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
}

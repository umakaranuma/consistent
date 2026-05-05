import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/colors.dart';
import '../../store/assessment_provider.dart';
import '../../store/app_provider.dart';
import '../../store/types.dart';
import '../../utils/bmi_engine.dart';
import '../../utils/water_engine.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishAssessment();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishAssessment() async {
    final data = ref.read(assessmentProvider);
    
    // Calculate BMI and Targets
    final bmi = BmiEngine.calculateBmi(data.currentWeight, data.heightCm);
    final bmiCat = BmiEngine.getBmiCategory(bmi);
    final tdee = BmiEngine.calculateTDEE(
      weightKg: data.currentWeight,
      heightCm: data.heightCm,
      ageYears: data.age,
      gender: data.gender,
      activityLevel: data.activityLevel,
    );
    
    final calTarget = BmiEngine.getCalorieTarget(
      tdee: tdee,
      bmiCategory: bmiCat,
      mode: data.mode,
      gymGoal: data.gymGoal,
    );
    
    final macroTargets = BmiEngine.getMacroTargets(
      calories: calTarget,
      weightKg: data.currentWeight,
      mode: data.mode,
      gymGoal: data.gymGoal,
    );

    final userProfile = UserProfile(
      name: data.name.isEmpty ? 'User' : data.name,
      heightCm: data.heightCm,
      currentWeight: data.currentWeight,
      goalWeight: data.goalWeight,
      bmi: bmi,
      bmiCategory: bmiCat,
      mode: data.mode,
      gymGoal: data.gymGoal,
      stepGoal: 10000,
      macroTargets: macroTargets,
      units: 'metric',
      workStartTime: '09:00',
      workEndTime: '18:00',
      sleepTime: '23:00',
      pushEnabled: true,
      workoutReminders: true,
      sleepReminder: true,
      planLockedByUser: false,
    );

    // Save to state
    ref.read(appProvider.notifier).setProfile(userProfile);
    
    // Water Target
    final waterTarget = BmiEngine.getWaterTarget(data.currentWeight, data.mode);
    final waterConfig = WaterConfig(
      consumed: 0,
      target: waterTarget,
      reminderEnabled: true,
      reminderIntervalMinutes: 60,
      reminderStartTime: '08:00',
      reminderEndTime: '21:00',
      mlPerReminder: 250,
    );
    ref.read(appProvider.notifier).setWaterConfig(waterConfig);

    // Generate and set schedule
    final schedule = BmiEngine.generatePlan(userProfile);
    ref.read(appProvider.notifier).setSchedule(schedule);

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vitatrack_onboarded', 'true');

    if (mounted) {
      context.go('/today');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: Stack(
        children: [
          // Background Gradient / Image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.bg0,
                    AppColors.bg0,
                    AppColors.accentBg.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),
          
          // Page Content
          SafeArea(
            child: Column(
              children: [
                // Progress Indicator
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: List.generate(6, (index) {
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 4,
                          decoration: BoxDecoration(
                            color: index <= _currentPage
                                ? AppColors.accent
                                : AppColors.bg3,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    children: [
                      _WelcomeStep(),
                      _NameModeStep(),
                      _GenderAgeStep(),
                      _BodyMetricsStep(),
                      _GoalActivityStep(),
                      _SummaryStep(),
                    ],
                  ),
                ),
                
                // Bottom Navigation
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: _prevPage,
                          child: const Text(
                            'Back',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      else
                        const SizedBox(width: 60),
                      
                      ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage == 5 ? 'Get Started' : 'Continue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.accent,
              size: 60,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Welcome to VitaTrack',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Your personal companion for health, fitness, and daily consistency. Let\'s set up your profile to personalize your journey.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NameModeStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(assessmentProvider);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'What should we call you?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (val) => ref.read(assessmentProvider).name = val,
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.bg1,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.person_outline, color: AppColors.accent),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Choose your focus',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 20),
          _ModeCard(
            title: 'Health & Wellness',
            desc: 'General health tracking, water, and daily habits.',
            icon: Icons.favorite_outline,
            selected: data.mode == AppMode.normal,
            onTap: () {
              ref.read(assessmentProvider.notifier).update((s) {
                s.mode = AppMode.normal;
                return s;
              });
              // Force rebuild
              ref.invalidate(assessmentProvider);
            },
          ),
          const SizedBox(height: 15),
          _ModeCard(
            title: 'Gym & Fitness',
            desc: 'Advanced calorie tracking and gym goals.',
            icon: Icons.fitness_center,
            selected: data.mode == AppMode.gym,
            onTap: () {
              ref.read(assessmentProvider.notifier).update((s) {
                s.mode = AppMode.gym;
                return s;
              });
              ref.invalidate(assessmentProvider);
            },
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.desc,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withOpacity(0.1) : AppColors.bg1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.accent : AppColors.textSecondary, size: 30),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: selected ? AppColors.accent : AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderAgeStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(assessmentProvider);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 30),
          const Text('Gender', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SelectButton(
                  label: 'Male',
                  selected: data.gender == 'male',
                  onTap: () {
                    data.gender = 'male';
                    ref.invalidate(assessmentProvider);
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _SelectButton(
                  label: 'Female',
                  selected: data.gender == 'female',
                  onTap: () {
                    data.gender = 'female';
                    ref.invalidate(assessmentProvider);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Age', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              Text(
                '${data.age.toInt()} years',
                style: const TextStyle(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: data.age,
            min: 10,
            max: 100,
            divisions: 90,
            activeColor: AppColors.accent,
            inactiveColor: AppColors.bg2,
            onChanged: (val) {
              data.age = val;
              ref.invalidate(assessmentProvider);
            },
          ),
        ],
      ),
    );
  }
}

class _BodyMetricsStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(assessmentProvider);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Body metrics',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 40),
          _MetricSlider(
            label: 'Height',
            value: data.heightCm,
            unit: 'cm',
            min: 100,
            max: 250,
            onChanged: (val) {
              data.heightCm = val;
              ref.invalidate(assessmentProvider);
            },
          ),
          const SizedBox(height: 30),
          _MetricSlider(
            label: 'Current Weight',
            value: data.currentWeight,
            unit: 'kg',
            min: 30,
            max: 200,
            onChanged: (val) {
              data.currentWeight = val;
              ref.invalidate(assessmentProvider);
            },
          ),
          const SizedBox(height: 30),
          _MetricSlider(
            label: 'Goal Weight',
            value: data.goalWeight,
            unit: 'kg',
            min: 30,
            max: 200,
            onChanged: (val) {
              data.goalWeight = val;
              ref.invalidate(assessmentProvider);
            },
          ),
        ],
      ),
    );
  }
}

class _MetricSlider extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _MetricSlider({
    required this.label,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            Text(
              '${value.toInt()} $unit',
              style: const TextStyle(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AppColors.accent,
          inactiveColor: AppColors.bg2,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _GoalActivityStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(assessmentProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          if (data.mode == AppMode.gym) ...[
            const Text(
              'Your Gym Goal',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.white),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _GoalChip(
                  label: 'Fat Loss',
                  selected: data.gymGoal == GymGoal.fatLoss,
                  onTap: () {
                    data.gymGoal = GymGoal.fatLoss;
                    ref.invalidate(assessmentProvider);
                  },
                ),
                _GoalChip(
                  label: 'Muscle Gain',
                  selected: data.gymGoal == GymGoal.muscleGain,
                  onTap: () {
                    data.gymGoal = GymGoal.muscleGain;
                    ref.invalidate(assessmentProvider);
                  },
                ),
                _GoalChip(
                  label: 'Maintenance',
                  selected: data.gymGoal == GymGoal.maintenance,
                  onTap: () {
                    data.gymGoal = GymGoal.maintenance;
                    ref.invalidate(assessmentProvider);
                  },
                ),
                _GoalChip(
                  label: 'Recomp',
                  selected: data.gymGoal == GymGoal.recomp,
                  onTap: () {
                    data.gymGoal = GymGoal.recomp;
                    ref.invalidate(assessmentProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
          const Text(
            'Activity Level',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.white),
          ),
          const SizedBox(height: 15),
          _ActivityOption(
            label: 'Sedentary',
            desc: 'Little or no exercise',
            selected: data.activityLevel == 'sedentary',
            onTap: () {
              data.activityLevel = 'sedentary';
              ref.invalidate(assessmentProvider);
            },
          ),
          _ActivityOption(
            label: 'Lightly Active',
            desc: 'Light exercise 1-3 days/week',
            selected: data.activityLevel == 'light',
            onTap: () {
              data.activityLevel = 'light';
              ref.invalidate(assessmentProvider);
            },
          ),
          _ActivityOption(
            label: 'Moderately Active',
            desc: 'Moderate exercise 3-5 days/week',
            selected: data.activityLevel == 'moderate',
            onTap: () {
              data.activityLevel = 'moderate';
              ref.invalidate(assessmentProvider);
            },
          ),
          _ActivityOption(
            label: 'Very Active',
            desc: 'Hard exercise 6-7 days/week',
            selected: data.activityLevel == 'active',
            onTap: () {
              data.activityLevel = 'active';
              ref.invalidate(assessmentProvider);
            },
          ),
        ],
      ),
    );
  }
}

class _ActivityOption extends StatelessWidget {
  final String label;
  final String desc;
  final bool selected;
  final VoidCallback onTap;

  const _ActivityOption({
    required this.label,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withOpacity(0.1) : AppColors.bg1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.accent : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: selected ? AppColors.accent : AppColors.white, fontWeight: FontWeight.bold)),
            Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GoalChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.bg1,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _SummaryStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(assessmentProvider);
    final bmi = BmiEngine.calculateBmi(data.currentWeight, data.heightCm);
    final cat = BmiEngine.getBmiCategory(bmi);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.green, size: 80),
          const SizedBox(height: 20),
          const Text(
            'All set!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.white),
          ),
          const SizedBox(height: 10),
          Text(
            'We\'ve analyzed your data. Your current BMI is $bmi (${BmiEngine.getBmiLabel(cat)}).',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bg1,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _SummaryRow(label: 'Target Weight', value: '${data.goalWeight.toInt()} kg'),
                const Divider(color: AppColors.bg2),
                _SummaryRow(label: 'Mode', value: data.mode == AppMode.gym ? 'Gym & Fitness' : 'Health & Wellness'),
                const Divider(color: AppColors.bg2),
                _SummaryRow(label: 'Activity', value: data.activityLevel.toUpperCase()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SelectButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.bg1,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

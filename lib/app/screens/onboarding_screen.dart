import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/colors.dart';
import '../../store/app_provider.dart';
import '../../store/types.dart';
import '../../utils/bmi_engine.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _step = 0;

  // Step 2 — Profile
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController(text: '25');
  String _gender = 'male';
  final _heightCtrl = TextEditingController(text: '170');
  String _units = 'metric';
  final _weightCtrl = TextEditingController(text: '70');
  final _goalWeightCtrl = TextEditingController(text: '65');

  // Step 3 — Mode
  AppMode _mode = AppMode.normal;
  GymGoal? _gymGoal;

  // Step 4 — Targets
  String _activityLevel = 'moderate';
  final _workStartCtrl = TextEditingController(text: '09:00');
  final _workEndCtrl = TextEditingController(text: '18:00');
  final _sleepCtrl = TextEditingController(text: '23:00');
  double _waterInterval = 60;
  final double _mlPerReminder = 250;

  // Step 5 — Notifications
  bool _pushEnabled = true;

  double get _bmiPreview {
    final h = double.tryParse(_heightCtrl.text) ?? 170;
    final w = double.tryParse(_weightCtrl.text) ?? 70;
    return BmiEngine.calculateBmi(w, h);
  }

  void _goTo(int page) {
    _pageController.animateToPage(page,
      duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  void _next() {
    if (_step < 4) {
      _goTo(_step + 1);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step > 0) _goTo(_step - 1);
  }

  Future<void> _finish() async {
    final name = _nameCtrl.text.trim().isEmpty ? 'User' : _nameCtrl.text.trim();
    final age = double.tryParse(_ageCtrl.text) ?? 25;
    final heightCm = double.tryParse(_heightCtrl.text) ?? 170;
    final weight = double.tryParse(_weightCtrl.text) ?? 70;
    final goalWeight = double.tryParse(_goalWeightCtrl.text) ?? 65;

    final bmi = BmiEngine.calculateBmi(weight, heightCm);
    final bmiCat = BmiEngine.getBmiCategory(bmi);
    final tdee = BmiEngine.calculateTDEE(
      weightKg: weight, heightCm: heightCm, ageYears: age,
      gender: _gender, activityLevel: _activityLevel,
    );
    final calTarget = BmiEngine.getCalorieTarget(
      tdee: tdee, bmiCategory: bmiCat, mode: _mode, gymGoal: _gymGoal,
    );
    final macros = BmiEngine.getMacroTargets(
      calories: calTarget, weightKg: weight, mode: _mode, gymGoal: _gymGoal,
    );
    final waterTarget = BmiEngine.getWaterTarget(weight, _mode);

    final profile = UserProfile(
      name: name,
      age: age,
      gender: _gender,
      heightCm: heightCm,
      currentWeight: weight,
      goalWeight: goalWeight,
      bmi: bmi,
      bmiCategory: bmiCat,
      mode: _mode,
      gymGoal: _gymGoal,
      stepGoal: 10000,
      macroTargets: macros,
      units: _units,
      activityLevel: _activityLevel,
      workStartTime: _workStartCtrl.text,
      workEndTime: _workEndCtrl.text,
      sleepTime: _sleepCtrl.text,
      pushEnabled: _pushEnabled,
      workoutReminders: true,
      sleepReminder: true,
      planLockedByUser: false,
    );

    final waterConfig = WaterConfig(
      consumed: 0,
      target: waterTarget,
      reminderEnabled: true,
      reminderIntervalMinutes: _waterInterval,
      reminderStartTime: '07:00',
      reminderEndTime: '22:00',
      mlPerReminder: _mlPerReminder,
    );

    final schedule = BmiEngine.generatePlan(profile);

    ref.read(appProvider.notifier).setProfile(profile);
    ref.read(appProvider.notifier).setWaterConfig(waterConfig);
    ref.read(appProvider.notifier).setSchedule(schedule);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vitatrack_onboarded', 'true');

    if (mounted) context.go('/today');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Progress Dots ─────────────
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_step > 0)
                    GestureDetector(
                      onTap: _back,
                      child: Icon(Icons.arrow_back_ios, color: AppColors.textSecondary, size: 18),
                    ),
                  if (_step > 0) const SizedBox(width: 16),
                  ...List.generate(5, (i) => Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i <= _step ? AppColors.accent : AppColors.bg3,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
                ],
              ),
            ),
            // ─── Pages ────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _step = i),
                children: [
                  _buildWelcome(),
                  _buildProfile(),
                  _buildMode(),
                  _buildTargets(),
                  _buildPermissions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Step 1 — Welcome
  // ═══════════════════════════════════════════════════════════
  Widget _buildWelcome() {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.accentBg,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.favorite_rounded, color: AppColors.accent, size: 40),
          ),
          SizedBox(height: 30),
          Text('VitaTrack', style: TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.white,
          )),
          SizedBox(height: 12),
          Text(
            'Your personal health & wellness\ndaily planner',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 50),
          _primaryBtn('Get started →', _next),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Step 2 — Your Profile
  // ═══════════════════════════════════════════════════════════
  Widget _buildProfile() {
    final bmi = _bmiPreview;
    final cat = BmiEngine.getBmiCategory(bmi);
    final label = BmiEngine.getBmiLabel(cat);
    final ideal = BmiEngine.getIdealWeightRange(double.tryParse(_heightCtrl.text) ?? 170);

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us about you', style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.white,
          )),
          const SizedBox(height: 24),
          _inputLabel('Name'),
          _textField(_nameCtrl, 'e.g. Umakaran'),
          _inputLabel('Age'),
          _textField(_ageCtrl, '25', isNumber: true),
          _inputLabel('Gender'),
          const SizedBox(height: 6),
          _chipRow(['male', 'female'], _gender, (v) => setState(() => _gender = v)),
          const SizedBox(height: 16),
          _inputLabel('Height (cm)'),
          _textField(_heightCtrl, '170', isNumber: true),
          _inputLabel('Units'),
          const SizedBox(height: 6),
          _chipRow(['metric', 'imperial'], _units, (v) => setState(() => _units = v)),
          const SizedBox(height: 16),
          _inputLabel('Current weight (${_units == 'metric' ? 'kg' : 'lbs'})'),
          _textField(_weightCtrl, '70', isNumber: true),
          _inputLabel('Goal weight (${_units == 'metric' ? 'kg' : 'lbs'})'),
          _textField(_goalWeightCtrl, '65', isNumber: true),
          SizedBox(height: 16),
          // BMI Preview
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BMI Preview', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                SizedBox(height: 6),
                Row(
                  children: [
                    Text(bmi.toStringAsFixed(1), style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold,
                      color: _bmiColor(cat),
                    )),
                    SizedBox(width: 10),
                    Text('— $label', style: TextStyle(fontSize: 13, color: _bmiColor(cat))),
                  ],
                ),
                SizedBox(height: 4),
                Text('Ideal range: ${ideal['min']}–${ideal['max']} kg',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _primaryBtn('Next →', _next),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Step 3 — Your Mode
  // ═══════════════════════════════════════════════════════════
  Widget _buildMode() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose your mode', style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.white,
          )),
          const SizedBox(height: 24),
          _modeCard(
            'Normal mode',
            'General health & lifestyle tracking.\nBest for: office workers, students, anyone wanting healthy habits.',
            Icons.favorite_outline,
            AppMode.normal,
          ),
          const SizedBox(height: 14),
          _modeCard(
            'Gym mode',
            'Athlete & bodybuilder tracking.\nProtein shakes, macros, workout logs, progressive overload.',
            Icons.fitness_center,
            AppMode.gym,
          ),
          if (_mode == AppMode.gym) ...[
            const SizedBox(height: 24),
            _inputLabel('Your gym goal'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: GymGoal.values.map((g) {
                final labels = {
                  GymGoal.fatLoss: 'Fat Loss',
                  GymGoal.muscleGain: 'Muscle Gain',
                  GymGoal.maintenance: 'Maintain',
                  GymGoal.recomp: 'Recomp',
                };
                return _selectionChip(labels[g]!, _gymGoal == g, () {
                  setState(() => _gymGoal = g);
                });
              }).toList(),
            ),
          ],
          const SizedBox(height: 30),
          _primaryBtn('Next →', _next),
        ],
      ),
    );
  }

  Widget _modeCard(String title, String desc, IconData icon, AppMode mode) {
    final selected = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() {
        _mode = mode;
        if (mode == AppMode.normal) _gymGoal = null;
        if (mode == AppMode.gym && _gymGoal == null) _gymGoal = GymGoal.fatLoss;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentBg : AppColors.bg2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border1,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.accent : AppColors.textSecondary, size: 28),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold,
                    color: selected ? AppColors.pureWhite : AppColors.textPrimary,
                  )),
                  SizedBox(height: 4),
                  Text(desc, style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: AppColors.accent, size: 22),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Step 4 — Targets & Schedule
  // ═══════════════════════════════════════════════════════════
  Widget _buildTargets() {
    final h = double.tryParse(_heightCtrl.text) ?? 170;
    final w = double.tryParse(_weightCtrl.text) ?? 70;
    final age = double.tryParse(_ageCtrl.text) ?? 25;
    final bmi = BmiEngine.calculateBmi(w, h);
    final cat = BmiEngine.getBmiCategory(bmi);
    final tdee = BmiEngine.calculateTDEE(
      weightKg: w, heightCm: h, ageYears: age,
      gender: _gender, activityLevel: _activityLevel,
    );
    final calTarget = BmiEngine.getCalorieTarget(
      tdee: tdee, bmiCategory: cat, mode: _mode, gymGoal: _gymGoal,
    );
    final waterTarget = BmiEngine.getWaterTarget(w, _mode);

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your daily targets', style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.white,
          )),
          SizedBox(height: 4),
          Text('Auto-calculated from your stats',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 24),
          // Calorie target
          _targetDisplay('Daily calorie target', '${calTarget.toInt()} kcal',
            'Based on your BMI & TDEE'),
          const SizedBox(height: 16),
          // Water target
          _targetDisplay('Daily water target', '${waterTarget.toInt()} ml',
            'Based on ${_mode == AppMode.gym ? "40" : "35"}ml × your weight'),
          SizedBox(height: 20),
          _inputLabel('Water reminder interval'),
          const SizedBox(height: 8),
          _chipRow(['60', '90', '120', '180'], _waterInterval.toInt().toString(), (v) {
            setState(() => _waterInterval = double.parse(v));
          }, labels: ['60 min', '90 min', '2 hrs', '3 hrs']),
          SizedBox(height: 20),
          _inputLabel('Activity level'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: [
              _selectionChip('Sedentary', _activityLevel == 'sedentary',
                () => setState(() => _activityLevel = 'sedentary')),
              _selectionChip('Light', _activityLevel == 'light',
                () => setState(() => _activityLevel = 'light')),
              _selectionChip('Moderate', _activityLevel == 'moderate',
                () => setState(() => _activityLevel = 'moderate')),
              _selectionChip('Active', _activityLevel == 'active',
                () => setState(() => _activityLevel = 'active')),
              _selectionChip('Very Active', _activityLevel == 'very_active',
                () => setState(() => _activityLevel = 'very_active')),
            ],
          ),
          SizedBox(height: 20),
          _inputLabel('Work start time'),
          _textField(_workStartCtrl, '09:00'),
          _inputLabel('Work end time'),
          _textField(_workEndCtrl, '18:00'),
          _inputLabel('Target sleep time'),
          _textField(_sleepCtrl, '23:00'),
          const SizedBox(height: 24),
          _primaryBtn('Next →', _next),
        ],
      ),
    );
  }

  Widget _targetDisplay(String label, String value, String hint) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              SizedBox(height: 2),
              Text(hint, style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
          Text(value, style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accent,
          )),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Step 5 — Permissions & Summary
  // ═══════════════════════════════════════════════════════════
  Widget _buildPermissions() {
    final h = double.tryParse(_heightCtrl.text) ?? 170;
    final w = double.tryParse(_weightCtrl.text) ?? 70;
    final age = double.tryParse(_ageCtrl.text) ?? 25;
    final bmi = BmiEngine.calculateBmi(w, h);
    final cat = BmiEngine.getBmiCategory(bmi);
    final tdee = BmiEngine.calculateTDEE(
      weightKg: w, heightCm: h, ageYears: age,
      gender: _gender, activityLevel: _activityLevel,
    );
    final calTarget = BmiEngine.getCalorieTarget(
      tdee: tdee, bmiCategory: cat, mode: _mode, gymGoal: _gymGoal,
    );
    final macros = BmiEngine.getMacroTargets(
      calories: calTarget, weightKg: w, mode: _mode, gymGoal: _gymGoal,
    );
    final waterTarget = BmiEngine.getWaterTarget(w, _mode);

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enable notifications', style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.white,
          )),
          SizedBox(height: 16),
          Text('VitaTrack sends smart reminders:', style: TextStyle(
            fontSize: 13, color: AppColors.textSecondary,
          )),
          SizedBox(height: 10),
          _bulletPoint('Water every ${_waterInterval.toInt()} minutes'),
          _bulletPoint('Meal time alerts'),
          _bulletPoint('Workout reminders'),
          _bulletPoint('Sleep reminder'),
          SizedBox(height: 20),
          SwitchListTile(
            value: _pushEnabled,
            onChanged: (v) => setState(() => _pushEnabled = v),
            title: Text('Allow notifications', style: TextStyle(color: AppColors.white)),
            activeThumbColor: AppColors.accent,
            tileColor: AppColors.bg2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          SizedBox(height: 24),
          // Plan summary
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your plan summary', style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white,
                )),
                const SizedBox(height: 12),
                _summaryRow('Mode', _mode == AppMode.gym
                  ? 'Gym (${_gymGoal?.name ?? ''})'
                  : 'Normal (${BmiEngine.getBmiLabel(cat)})'),
                _summaryRow('Calories', '${calTarget.toInt()} kcal/day'),
                _summaryRow('Water', '${waterTarget.toInt()} ml/day'),
                _summaryRow('Protein', '${macros.protein.toInt()}g/day'),
                _summaryRow('BMI', '${bmi.toStringAsFixed(1)} — ${BmiEngine.getBmiLabel(cat)}'),
              ],
            ),
          ),
          SizedBox(height: 30),
          _primaryBtn("Finish setup — Let's go! 🚀", _finish),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.white)),
        ],
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 6),
      child: Row(
        children: [
          Text('•  ', style: TextStyle(color: AppColors.accent)),
          Text(text, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ─── Shared Widgets ──────────────────────────────────────
  Widget _primaryBtn(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(label, style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white,
        )),
      ),
    );
  }

  Widget _inputLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 14, bottom: 6),
      child: Text(text, style: TextStyle(
        fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary,
      )),
    );
  }

  Widget _textField(TextEditingController ctrl, String hint, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.bg3,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border2, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border2, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accent, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _chipRow(List<String> values, String selected, Function(String) onSelect, {List<String>? labels}) {
    return Row(
      children: values.asMap().entries.map((entry) {
        final i = entry.key;
        final v = entry.value;
        final label = labels != null ? labels[i] : v;
        final isSelected = selected == v;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(v),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : AppColors.bg3,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.border2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(label, style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              )),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _selectionChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.bg3,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border2,
          ),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.textSecondary,
        )),
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

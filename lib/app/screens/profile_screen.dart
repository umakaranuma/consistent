import '../../utils/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../constants/colors.dart';
import '../../main.dart';
import '../../store/app_provider.dart';
import '../../store/types.dart';
import '../../utils/bmi_engine.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final p = state.profile;
    if (p == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const SizedBox(height: 20),
                Text('Profile & Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 20),
                _profileHeader(p),
                const SizedBox(height: 24),
              _bmiCard(p),
              const SizedBox(height: 20),

              _section('Personal'),
              _row('Name', p.name, Icons.person_outline, () => _editText('Name', p.name, (v) =>
                _save(p.copyWith(name: v)))),
              _row('Age', '${p.age.toInt()}', Icons.cake_outlined, () => _editNumber('Age', p.age, (v) =>
                _save(p.copyWith(age: v)))),
              _row('Gender', p.gender == 'male' ? 'Male' : 'Female', Icons.wc, () => _editChoice(
                'Gender', p.gender, {'male': 'Male', 'female': 'Female'}, (v) => _save(p.copyWith(gender: v)))),
              const SizedBox(height: 20),

              _section('Mode'),
              _row('App mode', p.mode == AppMode.gym ? 'Gym' : 'Normal', Icons.swap_horiz, () => _editMode(p)),
              if (p.mode == AppMode.gym)
                _row('Gym goal', _goalLabel(p.gymGoal), Icons.flag_outlined, () => _editGymGoal(p)),
              const SizedBox(height: 20),

              _section('Body Stats'),
              _row('Height', '${p.heightCm.toInt()} cm', Icons.height, () => _editNumber('Height (cm)', p.heightCm, (v) {
                final bmi = BmiEngine.calculateBmi(p.currentWeight, v);
                final cat = BmiEngine.getBmiCategory(bmi);
                _save(p.copyWith(heightCm: v, bmi: bmi, bmiCategory: cat));
              })),
              _row('Current weight', '${p.currentWeight.toStringAsFixed(1)} kg', Icons.monitor_weight_outlined, () =>
                _editNumber('Weight (kg)', p.currentWeight, (v) {
                  final bmi = BmiEngine.calculateBmi(v, p.heightCm);
                  final cat = BmiEngine.getBmiCategory(bmi);
                  final tdee = BmiEngine.calculateTDEE(weightKg: v, heightCm: p.heightCm, ageYears: p.age, gender: p.gender, activityLevel: p.activityLevel);
                  final cal = BmiEngine.getCalorieTarget(tdee: tdee, bmiCategory: cat, mode: p.mode, gymGoal: p.gymGoal);
                  final macros = BmiEngine.getMacroTargets(calories: cal, weightKg: v, mode: p.mode, gymGoal: p.gymGoal);
                  final water = BmiEngine.getWaterTarget(v, p.mode);
                  _save(p.copyWith(currentWeight: v, bmi: bmi, bmiCategory: cat, macroTargets: macros));
                  ref.read(appProvider.notifier).setWaterConfig(state.waterConfig!.copyWith(target: water));
                })),
              _row('Goal weight', '${p.goalWeight.toStringAsFixed(1)} kg', Icons.track_changes, () =>
                _editNumber('Goal weight (kg)', p.goalWeight, (v) => _save(p.copyWith(goalWeight: v)))),
              _row('BMI', '${p.bmi.toStringAsFixed(1)} — ${BmiEngine.getBmiLabel(p.bmiCategory)}',
                Icons.analytics_outlined, null),
              const SizedBox(height: 20),

              _section('Water Settings'),
              _row('Daily target', '${state.waterConfig?.target.toInt() ?? 0} ml', Icons.water_drop_outlined, () =>
                _editNumber('Water target (ml)', state.waterConfig?.target ?? 2500, (v) =>
                  ref.read(appProvider.notifier).setWaterConfig(state.waterConfig!.copyWith(target: v)))),
              _row('Reminder interval', '${state.waterConfig?.reminderIntervalMinutes.toInt() ?? 60} min',
                Icons.timer_outlined, () => _editChoice('Interval', state.waterConfig!.reminderIntervalMinutes.toInt().toString(),
                  {'30': '30 min', '60': '60 min', '90': '90 min', '120': '2 hrs'}, (v) =>
                    ref.read(appProvider.notifier).setWaterConfig(state.waterConfig!.copyWith(reminderIntervalMinutes: double.parse(v))))),
              _row('Per reminder', '${state.waterConfig?.mlPerReminder.toInt() ?? 250} ml', Icons.local_drink_outlined, () =>
                _editChoice('Amount', state.waterConfig!.mlPerReminder.toInt().toString(),
                  {'150': '150 ml', '200': '200 ml', '250': '250 ml', '300': '300 ml', '500': '500 ml'}, (v) =>
                    ref.read(appProvider.notifier).setWaterConfig(state.waterConfig!.copyWith(mlPerReminder: double.parse(v))))),
              const SizedBox(height: 20),

              _section('Diet & Calories'),
              _row('Calorie target', '${p.macroTargets.calories.toInt()} kcal', Icons.local_fire_department_outlined, () =>
                _editNumber('Calorie target', p.macroTargets.calories, (v) =>
                  _save(p.copyWith(macroTargets: p.macroTargets.copyWith(calories: v))))),
              _row('Protein target', '${p.macroTargets.protein.toInt()}g', Icons.egg_outlined, () =>
                _editNumber('Protein (g)', p.macroTargets.protein, (v) =>
                  _save(p.copyWith(macroTargets: p.macroTargets.copyWith(protein: v))))),
              _row('Activity level', _actLabel(p.activityLevel), Icons.directions_run, () => _editChoice(
                'Activity', p.activityLevel, {
                  'sedentary': 'Sedentary', 'light': 'Light', 'moderate': 'Moderate',
                  'active': 'Active', 'very_active': 'Very Active',
                }, (v) {
                  final tdee = BmiEngine.calculateTDEE(weightKg: p.currentWeight, heightCm: p.heightCm, ageYears: p.age, gender: p.gender, activityLevel: v);
                  final cal = BmiEngine.getCalorieTarget(tdee: tdee, bmiCategory: p.bmiCategory, mode: p.mode, gymGoal: p.gymGoal);
                  final macros = BmiEngine.getMacroTargets(calories: cal, weightKg: p.currentWeight, mode: p.mode, gymGoal: p.gymGoal);
                  _save(p.copyWith(activityLevel: v, macroTargets: macros));
                })),
              _actionRow('Reset to recommended plan', Icons.refresh, AppColors.amber, () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.bg2,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: AppColors.amber, size: 48),
                        SizedBox(height: 16),
                        Text('Reset Recommended Plan?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white)),
                        SizedBox(height: 8),
                        Text('This will overwrite your current schedule and macros with the recommended default values based on your profile.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)))),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  ref.read(appProvider.notifier).regeneratePlan();
                                  Navigator.pop(ctx);
                                  _snack('Plan regenerated from your profile!');
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.amber, foregroundColor: AppColors.pureWhite, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              _section('Schedule'),
              _row('Work start', p.workStartTime, Icons.work_outline, () => _editTime('Work start', p.workStartTime, (v) =>
                _save(p.copyWith(workStartTime: v)))),
              _row('Work end', p.workEndTime, Icons.work_off_outlined, () => _editTime('Work end', p.workEndTime, (v) =>
                _save(p.copyWith(workEndTime: v)))),
              _row('Sleep time', p.sleepTime, Icons.bedtime_outlined, () => _editTime('Sleep time', p.sleepTime, (v) =>
                _save(p.copyWith(sleepTime: v)))),
              _row('Step goal', '${p.stepGoal.toInt()}', Icons.directions_walk, () =>
                _editNumber('Step goal', p.stepGoal, (v) => _save(p.copyWith(stepGoal: v)))),
              const SizedBox(height: 20),

              _section('Notifications'),
              _toggle('Push notifications', p.pushEnabled, Icons.notifications_active_outlined, (v) =>
                _save(p.copyWith(pushEnabled: v))),
              _toggle('Workout reminders', p.workoutReminders, Icons.fitness_center, (v) =>
                _save(p.copyWith(workoutReminders: v))),
              _toggle('Sleep reminder', p.sleepReminder, Icons.nightlight_outlined, (v) =>
                _save(p.copyWith(sleepReminder: v))),
              const SizedBox(height: 20),

              _section('App'),
              Consumer(builder: (context, ref, child) {
                final tm = ref.watch(themeProvider);
                final modeStr = tm == ThemeMode.light ? 'Light' : tm == ThemeMode.dark ? 'Dark' : 'System Default';
                return _row('Theme', modeStr, Icons.palette_outlined, () {
                  _showSheet('Theme', (pop) => StatefulBuilder(builder: (ctx, setS) => Column(mainAxisSize: MainAxisSize.min, children: [
                    _choiceTile('System Default', tm == ThemeMode.system, () { ref.read(themeProvider.notifier).setTheme(ThemeMode.system); setS((){}); }),
                    _choiceTile('Dark Mode', tm == ThemeMode.dark, () { ref.read(themeProvider.notifier).setTheme(ThemeMode.dark); setS((){}); }),
                    _choiceTile('Light Mode', tm == ThemeMode.light, () { ref.read(themeProvider.notifier).setTheme(ThemeMode.light); setS((){}); }),
                    const SizedBox(height: 16),
                    _sheetBtn('Done', () => pop()),
                  ])));
                });
              }),
              _row('Units', p.units == 'metric' ? 'Metric (kg, cm)' : 'Imperial (lbs, ft)', Icons.straighten, () =>
                _editChoice('Units', p.units, {'metric': 'Metric (kg, cm)', 'imperial': 'Imperial (lbs, ft)'}, (v) =>
                  _save(p.copyWith(units: v)))),
              const SizedBox(height: 100),
            ]),
          )),
        ],
        ),
      ),
    );
  }

  // ═══════════════════ SAVE HELPER ═══════════════════
  void _save(UserProfile p) => ref.read(appProvider.notifier).updateProfile(p);
  void _snack(String msg) => UiHelpers.showSnack(context, msg, isSuccess: true);

  // ═══════════════════ EDIT MODALS ═══════════════════
  void _editText(String label, String current, Function(String) onSave) {
    final ctrl = TextEditingController(text: current);
    _showSheet(label, (pop) => Column(mainAxisSize: MainAxisSize.min, children: [
      _sheetField(ctrl, label),
      const SizedBox(height: 20),
      _sheetBtn('Save', () { onSave(ctrl.text.trim()); pop(); _snack('$label updated'); }),
    ]));
  }

  void _editNumber(String label, double current, Function(double) onSave) {
    final ctrl = TextEditingController(text: current % 1 == 0 ? current.toInt().toString() : current.toStringAsFixed(1));
    _showSheet(label, (pop) => Column(mainAxisSize: MainAxisSize.min, children: [
      _sheetField(ctrl, label, isNum: true),
      const SizedBox(height: 20),
      _sheetBtn('Save', () { final v = double.tryParse(ctrl.text); if (v != null && v > 0) { onSave(v); pop(); _snack('$label updated'); } }),
    ]));
  }

  void _editChoice(String label, String current, Map<String, String> opts, Function(String) onSave) {
    String selected = current;
    _showSheet(label, (pop) => StatefulBuilder(builder: (ctx, setS) => Column(mainAxisSize: MainAxisSize.min, children: [
      ...opts.entries.map((e) => _choiceTile(e.value, selected == e.key, () => setS(() => selected = e.key))),
      SizedBox(height: 16),
      _sheetBtn('Save', () { onSave(selected); pop(); _snack('$label updated'); }),
    ])));
  }

  void _editTime(String label, String current, Function(String) onSave) async {
    final parts = current.split(':');
    final picked = await showTimePicker(context: context,
      initialTime: TimeOfDay(hour: int.tryParse(parts[0]) ?? 8, minute: int.tryParse(parts[1]) ?? 0),
      builder: (ctx, child) => Theme(data: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(primary: AppColors.accent, surface: AppColors.bg2)), child: child!));
    if (picked != null) {
      final t = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onSave(t); _snack('$label set to $t');
    }
  }

  void _editMode(UserProfile p) {
    AppMode sel = p.mode;
    _showSheet('App Mode', (pop) => StatefulBuilder(builder: (ctx, setS) => Column(mainAxisSize: MainAxisSize.min, children: [
      _modeTile('Normal', 'General health & lifestyle tracking', Icons.favorite_outline, sel == AppMode.normal,
        () => setS(() => sel = AppMode.normal)),
      const SizedBox(height: 10),
      _modeTile('Gym', 'Athlete & bodybuilder tracking, macros, protein', Icons.fitness_center, sel == AppMode.gym,
        () => setS(() => sel = AppMode.gym)),
      const SizedBox(height: 16),
      _sheetBtn('Save', () {
        final updated = p.copyWith(mode: sel, gymGoal: sel == AppMode.gym ? (p.gymGoal ?? GymGoal.fatLoss) : null);
        final tdee = BmiEngine.calculateTDEE(weightKg: p.currentWeight, heightCm: p.heightCm, ageYears: p.age, gender: p.gender, activityLevel: p.activityLevel);
        final cal = BmiEngine.getCalorieTarget(tdee: tdee, bmiCategory: p.bmiCategory, mode: sel, gymGoal: updated.gymGoal);
        final macros = BmiEngine.getMacroTargets(calories: cal, weightKg: p.currentWeight, mode: sel, gymGoal: updated.gymGoal);
        final water = BmiEngine.getWaterTarget(p.currentWeight, sel);
        _save(updated.copyWith(macroTargets: macros));
        ref.read(appProvider.notifier).setWaterConfig(ref.read(appProvider).waterConfig!.copyWith(target: water));
        ref.read(appProvider.notifier).regeneratePlan();
        pop(); _snack('Mode changed to ${sel == AppMode.gym ? "Gym" : "Normal"}');
      }),
    ])));
  }

  void _editGymGoal(UserProfile p) {
    GymGoal sel = p.gymGoal ?? GymGoal.fatLoss;
    _showSheet('Gym Goal', (pop) => StatefulBuilder(builder: (ctx, setS) => Column(mainAxisSize: MainAxisSize.min, children: [
      ...GymGoal.values.map((g) => _choiceTile(_goalLabel(g), sel == g, () => setS(() => sel = g))),
      const SizedBox(height: 16),
      _sheetBtn('Save', () {
        final tdee = BmiEngine.calculateTDEE(weightKg: p.currentWeight, heightCm: p.heightCm, ageYears: p.age, gender: p.gender, activityLevel: p.activityLevel);
        final cal = BmiEngine.getCalorieTarget(tdee: tdee, bmiCategory: p.bmiCategory, mode: AppMode.gym, gymGoal: sel);
        final macros = BmiEngine.getMacroTargets(calories: cal, weightKg: p.currentWeight, mode: AppMode.gym, gymGoal: sel);
        _save(p.copyWith(gymGoal: sel, macroTargets: macros));
        ref.read(appProvider.notifier).regeneratePlan();
        pop(); _snack('Goal changed to ${_goalLabel(sel)}');
      }),
    ])));
  }

  // ═══════════════════ SHEET HELPERS ═══════════════════
  void _showSheet(String title, Widget Function(VoidCallback pop) builder) {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 30),
        decoration: BoxDecoration(color: AppColors.bg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)))),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white)),
          SizedBox(height: 16),
          builder(() => Navigator.pop(context)),
        ]),
      ));
  }

  Widget _sheetField(TextEditingController ctrl, String hint, {bool isNum = false}) => TextField(
    controller: ctrl, autofocus: true,
    keyboardType: isNum ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
    style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
    decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: AppColors.textMuted),
      filled: true, fillColor: AppColors.bg3,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.accent))));

  Widget _sheetBtn(String label, VoidCallback onTap) => SizedBox(width: double.infinity, height: 48,
    child: ElevatedButton(onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), 
        elevation: 0,
      ),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.white))));

  Widget _choiceTile(String label, bool selected, VoidCallback onTap) => GestureDetector(onTap: onTap,
    child: Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: selected ? AppColors.accent.withValues(alpha: 0.15) : AppColors.bg3,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? AppColors.accent : AppColors.border1, width: selected ? 1.5 : 1)),
      child: Row(children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
          color: selected ? AppColors.accent : AppColors.textPrimary))),
        if (selected) Icon(Icons.check_circle, color: AppColors.accent, size: 20),
      ])));

  Widget _modeTile(String title, String desc, IconData icon, bool selected, VoidCallback onTap) => GestureDetector(
    onTap: onTap, child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? AppColors.accent.withValues(alpha: 0.12) : AppColors.bg3,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? AppColors.accent : AppColors.border1, width: selected ? 1.5 : 1)),
      child: Row(children: [
        Icon(icon, color: selected ? AppColors.accent : AppColors.textSecondary, size: 24),
        SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
            color: selected ? AppColors.pureWhite : AppColors.textPrimary)),
          SizedBox(height: 2),
          Text(desc, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ])),
        if (selected) Icon(Icons.check_circle, color: AppColors.accent, size: 20),
      ])));

  // ═══════════════════ UI WIDGETS ═══════════════════
  Widget _profileHeader(UserProfile p) {
    final initials = p.name.isNotEmpty ? p.name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase() : 'U';
    final bmiColor = _bmiClr(p.bmiCategory);
    return GestureDetector(
      onTap: () => _editText('Name', p.name, (v) => _save(p.copyWith(name: v))),
      child: Row(children: [
        Container(width: 52, height: 52,
          decoration: BoxDecoration(color: AppColors.accentBg, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accent, width: 2)),
          alignment: Alignment.center,
          child: Text(initials, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accent))),
        SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(p.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white)),
            SizedBox(width: 6),
            Icon(Icons.edit, color: AppColors.textMuted, size: 14),
          ]),
          const SizedBox(height: 4),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: bmiColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Text('${p.bmi.toStringAsFixed(1)} · ${BmiEngine.getBmiLabel(p.bmiCategory)}',
              style: TextStyle(fontSize: 11, color: bmiColor, fontWeight: FontWeight.w600))),
        ])),
      ]));
  }

  Widget _bmiCard(UserProfile p) {
    final c = _bmiClr(p.bmiCategory);
    final bar = ((p.bmi - 15) / 25 * 100).clamp(0.0, 100.0);
    final ideal = BmiEngine.getIdealWeightRange(p.heightCm);
    return Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.bg1, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border1)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(p.bmi.toStringAsFixed(1), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: c)),
          SizedBox(width: 12),
          Text(BmiEngine.getBmiLabel(p.bmiCategory), style: TextStyle(fontSize: 14, color: c, fontWeight: FontWeight.w500)),
        ]),
        SizedBox(height: 12),
        Stack(children: [
          Container(height: 8, decoration: BoxDecoration(color: AppColors.bg3, borderRadius: BorderRadius.circular(4))),
          FractionallySizedBox(widthFactor: bar / 100,
            child: Container(height: 8, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)))),
        ]),
        SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('<18.5', style: TextStyle(fontSize: 9, color: AppColors.bmiUnder)),
          Text('18.5-25', style: TextStyle(fontSize: 9, color: AppColors.bmiNormal)),
          Text('25-30', style: TextStyle(fontSize: 9, color: AppColors.bmiOver)),
          Text('>30', style: TextStyle(fontSize: 9, color: AppColors.bmiObese)),
        ]),
        SizedBox(height: 6),
        Text('Ideal: ${ideal['min']}–${ideal['max']} kg', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ]));
  }

  Widget _section(String t) => Padding(padding: EdgeInsets.only(bottom: 8),
    child: Align(alignment: Alignment.centerLeft,
      child: Text(t, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary))));

  Widget _row(String label, String value, IconData icon, VoidCallback? onTap) => GestureDetector(
    onTap: onTap,
    child: Container(margin: EdgeInsets.only(bottom: 6),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(color: AppColors.bg1, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: AppColors.white))),
        Text(value, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        if (onTap != null) ...[SizedBox(width: 6),
          Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18)],
      ])));

  Widget _toggle(String label, bool value, IconData icon, Function(bool) onChanged) => Container(
    margin: EdgeInsets.only(bottom: 6),
    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(color: AppColors.bg1, borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      Icon(icon, color: AppColors.textSecondary, size: 20),
      SizedBox(width: 12),
      Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: AppColors.white))),
      Switch(value: value, onChanged: (v) { onChanged(v); _snack('$label ${v ? "enabled" : "disabled"}'); },
        activeColor: AppColors.accent),
    ]));

  Widget _actionRow(String label, IconData icon, Color color, VoidCallback onTap) => GestureDetector(onTap: onTap,
    child: Container(margin: const EdgeInsets.only(bottom: 6, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(children: [
        Icon(icon, color: color, size: 20), const SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600))),
        Icon(Icons.chevron_right, color: color, size: 18),
      ])));

  // ═══════════════════ HELPERS ═══════════════════
  String _goalLabel(GymGoal? g) => switch (g) { GymGoal.fatLoss => 'Fat Loss', GymGoal.muscleGain => 'Muscle Gain',
    GymGoal.maintenance => 'Maintenance', GymGoal.recomp => 'Recomp', _ => '—' };
  String _actLabel(String l) => switch (l) { 'sedentary' => 'Sedentary', 'light' => 'Light', 'moderate' => 'Moderate',
    'active' => 'Active', 'very_active' => 'Very Active', _ => l };
  Color _bmiClr(BmiCategory c) => switch (c) { BmiCategory.underweight => AppColors.bmiUnder,
    BmiCategory.normal => AppColors.bmiNormal, BmiCategory.overweight => AppColors.bmiOver, BmiCategory.obese => AppColors.bmiObese };
}

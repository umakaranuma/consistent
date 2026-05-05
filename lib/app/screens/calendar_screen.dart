import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../store/app_provider.dart';
import '../../store/types.dart';
import '../../utils/bmi_engine.dart';
import 'dart:math' as math;

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
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
            title: const Text('Calendar', style: TextStyle(fontSize: 18)),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // ─── Calendar Card ───────
                  _buildCalendarCard(),
                  const SizedBox(height: 16),
                  // ─── BMI Trend ───────────
                  _buildBmiTrend(state.weightEntries, profile),
                  const SizedBox(height: 16),
                  // ─── Weight Trend ────────
                  _buildWeightTrend(state.weightEntries, profile),
                  const SizedBox(height: 16),
                  // ─── Monthly Stats ───────
                  _buildMonthlyStats(state),
                  const SizedBox(height: 16),
                  // ─── Ring Charts ─────────
                  _buildRingCharts(state),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Calendar Card ──────────────────────────────────────────
  Widget _buildCalendarCard() {
    final now = DateTime.now();
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startWeekday = firstDay.weekday;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border1),
      ),
      child: Column(
        children: [
          // Month Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
                onPressed: () => setState(() =>
                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1)),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_currentMonth),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onPressed: () => setState(() =>
                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Day headers
          Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) => Expanded(
              child: Center(child: Text(d, style: const TextStyle(
                fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600,
              ))),
            )).toList(),
          ),
          const SizedBox(height: 8),
          // Days grid
          ...List.generate(6, (week) {
            return Row(
              children: List.generate(7, (day) {
                final dayNum = week * 7 + day + 1 - (startWeekday - 1);
                if (dayNum < 1 || dayNum > lastDay.day) {
                  return const Expanded(child: SizedBox(height: 38));
                }
                final date = DateTime(_currentMonth.year, _currentMonth.month, dayNum);
                final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
                final isFuture = date.isAfter(now);

                return Expanded(
                  child: GestureDetector(
                    onTap: isFuture ? null : () => setState(() => _selectedDate = date),
                    child: Container(
                      height: 38,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.accent.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isToday ? Border.all(color: AppColors.accent, width: 1) : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 13,
                          color: isFuture ? AppColors.textMuted
                            : isToday ? AppColors.accent : AppColors.white,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  // ─── BMI Trend ──────────────────────────────────────────────
  Widget _buildBmiTrend(List<WeightEntry> entries, UserProfile profile) {
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
          const Text('BMI over time', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            SizedBox(
              height: 80,
              child: Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.trending_up, color: AppColors.textMuted, size: 28),
                  const SizedBox(height: 6),
                  const Text('Log your weight to see trends',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              )),
            )
          else
            SizedBox(
              height: 80,
              child: CustomPaint(
                size: const Size(double.infinity, 80),
                painter: _BmiChartPainter(entries),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppColors.bmiNormal, '18.5–25'),
              const SizedBox(width: 16),
              _legendDot(AppColors.bmiOver, '25–30'),
              const SizedBox(width: 16),
              _legendDot(AppColors.bmiObese, '>30'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(4),
        )),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }

  // ─── Weight Trend & Log Button ──────────────────────────────
  Widget _buildWeightTrend(List<WeightEntry> entries, UserProfile profile) {
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
              const Text('Weight trend', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text('${profile.currentWeight.toStringAsFixed(1)} kg',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: entries.isEmpty
              ? const Center(child: Text('No entries yet', style: TextStyle(fontSize: 12, color: AppColors.textMuted)))
              : CustomPaint(
                  size: const Size(double.infinity, 60),
                  painter: _WeightChartPainter(entries),
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showWeightLogModal(profile),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bg3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: const Text("Log today's weight", style: TextStyle(
                fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500,
              )),
            ),
          ),
        ],
      ),
    );
  }

  void _showWeightLogModal(UserProfile profile) {
    final ctrl = TextEditingController(text: profile.currentWeight.toStringAsFixed(1));
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 30),
        decoration: const BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Log weight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
              decoration: InputDecoration(
                suffixText: 'kg',
                suffixStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.bg3,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            // BMI live preview
            StatefulBuilder(builder: (ctx, setState) {
              final w = double.tryParse(ctrl.text) ?? profile.currentWeight;
              final bmi = BmiEngine.calculateBmi(w, profile.heightCm);
              final cat = BmiEngine.getBmiCategory(bmi);
              ctrl.addListener(() => setState(() {}));
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bg3,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('BMI preview:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    Text('${bmi.toStringAsFixed(1)} — ${BmiEngine.getBmiLabel(cat)}',
                      style: TextStyle(fontSize: 13, color: _bmiColor(cat), fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final w = double.tryParse(ctrl.text);
                  if (w != null && w > 0) {
                    final now = DateTime.now();
                    final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                    final bmi = BmiEngine.calculateBmi(w, profile.heightCm);
                    ref.read(appProvider.notifier).addWeightEntry(
                      WeightEntry(date: dateKey, weight: w, bmi: bmi),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Log weight', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Monthly Stats ──────────────────────────────────────────
  Widget _buildMonthlyStats(AppState state) {
    final notifier = ref.read(appProvider.notifier);
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
          const Text('Today\'s scores', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          _ratioBar('Diet', notifier.dietScore / 100, AppColors.green),
          const SizedBox(height: 8),
          _ratioBar('Water', notifier.waterScore / 100, AppColors.blue),
          const SizedBox(height: 8),
          _ratioBar('Calories', state.profile!.macroTargets.calories > 0
            ? (notifier.caloriesEaten / state.profile!.macroTargets.calories).clamp(0.0, 1.0) : 0.0,
            AppColors.amber),
          if (state.profile!.mode == AppMode.gym) ...[
            const SizedBox(height: 8),
            _ratioBar('Protein', state.profile!.macroTargets.protein > 0
              ? (notifier.proteinEaten / state.profile!.macroTargets.protein).clamp(0.0, 1.0) : 0.0,
              AppColors.lavender),
          ],
        ],
      ),
    );
  }

  Widget _ratioBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.bg3,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${(value * 100).toInt()}%', style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.bold, color: color,
        )),
      ],
    );
  }

  // ─── Ring Charts ────────────────────────────────────────────
  Widget _buildRingCharts(AppState state) {
    final notifier = ref.read(appProvider.notifier);
    final schedule = state.schedule;
    final total = schedule.length;
    final done = schedule.where((i) => i.done).length;
    final workouts = schedule.where((i) => i.type == ScheduleItemType.workout || i.type == ScheduleItemType.walk);
    final workoutsDone = workouts.where((i) => i.done).length;

    return Row(
      children: [
        Expanded(child: _ringChart('On plan', total > 0 ? done / total : 0, AppColors.green)),
        const SizedBox(width: 10),
        Expanded(child: _ringChart('Missed', total > 0 ? (total - done) / total : 0, AppColors.red)),
        const SizedBox(width: 10),
        Expanded(child: _ringChart('Workouts', workouts.isEmpty ? 0 : workoutsDone / workouts.length, AppColors.amber)),
      ],
    );
  }

  Widget _ringChart(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border1),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 50, height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  strokeWidth: 4,
                  backgroundColor: AppColors.bg3,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
                Text('${(value * 100).toInt()}%', style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold, color: color,
                )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
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

// ─── Simple chart painters ────────────────────────────────────
class _BmiChartPainter extends CustomPainter {
  final List<WeightEntry> entries;
  _BmiChartPainter(this.entries);

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;
    final recent = entries.length > 30 ? entries.sublist(entries.length - 30) : entries;
    final paint = Paint()
      ..color = AppColors.accentSoft
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final bmis = recent.map((e) => e.bmi).toList();
    final minB = bmis.reduce(math.min) - 2;
    final maxB = bmis.reduce(math.max) + 2;
    final range = maxB - minB;

    final path = Path();
    for (int i = 0; i < bmis.length; i++) {
      final x = i / (bmis.length - 1).clamp(1, double.infinity) * size.width;
      final y = size.height - ((bmis[i] - minB) / range * size.height);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    canvas.drawPath(path, paint);

    // dots
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < bmis.length; i++) {
      final x = i / (bmis.length - 1).clamp(1, double.infinity) * size.width;
      final y = size.height - ((bmis[i] - minB) / range * size.height);
      dotPaint.color = bmis[i] < 18.5 ? AppColors.bmiUnder
        : bmis[i] < 25 ? AppColors.bmiNormal
        : bmis[i] < 30 ? AppColors.bmiOver : AppColors.bmiObese;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _WeightChartPainter extends CustomPainter {
  final List<WeightEntry> entries;
  _WeightChartPainter(this.entries);

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;
    final recent = entries.length > 30 ? entries.sublist(entries.length - 30) : entries;
    final paint = Paint()
      ..color = AppColors.accentSoft
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final weights = recent.map((e) => e.weight).toList();
    final minW = weights.reduce(math.min) - 1;
    final maxW = weights.reduce(math.max) + 1;
    final range = maxW - minW;

    final path = Path();
    for (int i = 0; i < weights.length; i++) {
      final x = i / (weights.length - 1).clamp(1, double.infinity) * size.width;
      final y = size.height - ((weights[i] - minW) / range * size.height);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

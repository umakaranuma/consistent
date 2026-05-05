import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../constants/colors.dart';
import '../../store/app_provider.dart';
import '../../store/types.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  @override
  void initState() {
    super.initState();
    // Seed default reminders if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reminders = ref.read(appProvider).reminders;
      if (reminders.isEmpty) {
        _seedDefaults();
      }
    });
  }

  void _seedDefaults() {
    final uuid = Uuid();
    final profile = ref.read(appProvider).profile;
    final defaults = [
      Reminder(id: uuid.v4(), title: 'Morning water', time: '07:00', type: 'water', repeat: 'daily', enabled: true),
      Reminder(id: uuid.v4(), title: 'Lunch time', time: '13:00', type: 'meal', repeat: 'daily', enabled: true),
      Reminder(id: uuid.v4(), title: 'Post-lunch walk', time: '13:30', type: 'walk', repeat: 'weekday', enabled: true),
      Reminder(id: uuid.v4(), title: 'Workout', time: '18:30', type: 'workout', repeat: 'weekday', enabled: true),
      Reminder(id: uuid.v4(), title: 'Dinner', time: '20:30', type: 'meal', repeat: 'daily', enabled: true),
      Reminder(id: uuid.v4(), title: 'Sleep reminder', time: '23:00', type: 'sleep', repeat: 'daily', enabled: false),
    ];

    if (profile?.mode == AppMode.gym) {
      defaults.addAll([
        Reminder(id: uuid.v4(), title: 'Pre-workout shake', time: '16:00', type: 'protein', repeat: 'weekday', enabled: true),
        Reminder(id: uuid.v4(), title: 'Post-workout shake', time: '19:00', type: 'protein', repeat: 'weekday', enabled: true),
        Reminder(id: uuid.v4(), title: 'Pre-bed casein', time: '22:00', type: 'protein', repeat: 'daily', enabled: true),
      ]);
    }

    ref.read(appProvider.notifier).setReminders(defaults);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 60,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.bg0,
            title: const Text('Reminders', style: TextStyle(fontSize: 18)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.accent),
                onPressed: () => _showAddReminderModal(),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // ─── Water Reminder Summary ──────
                  _buildWaterReminderCard(state),
                  const SizedBox(height: 20),
                  // ─── Manual Reminders ────────────
                  const Text('Your reminders', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white,
                  )),
                  const SizedBox(height: 12),
                  if (state.reminders.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(30),
                      alignment: Alignment.center,
                      child: const Text('No reminders yet.\nTap + to add one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted)),
                    )
                  else
                    ...state.reminders.map((r) => _buildReminderTile(r)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Water Reminder Card ────────────────────────────────────
  Widget _buildWaterReminderCard(AppState state) {
    final config = state.waterConfig;
    if (config == null) return const SizedBox();

    final interval = config.reminderIntervalMinutes.toInt();
    final ml = config.mlPerReminder.toInt();
    final start = config.reminderStartTime;
    final end = config.reminderEndTime;

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
              Row(
                children: [
                  const Icon(Icons.water_drop, color: AppColors.blue, size: 20),
                  const SizedBox(width: 8),
                  const Text('Water reminders', style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white,
                  )),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: config.reminderEnabled ? AppColors.green.withOpacity(0.15) : AppColors.bg3,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  config.reminderEnabled ? 'Active' : 'Off',
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: config.reminderEnabled ? AppColors.green : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoChip('Every $interval min'),
              const SizedBox(width: 8),
              _infoChip('${ml}ml each'),
              const SizedBox(width: 8),
              _infoChip('$start — $end'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Managed via water settings in Profile',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    );
  }

  // ─── Reminder Tile ──────────────────────────────────────────
  Widget _buildReminderTile(Reminder r) {
    final typeIcon = _typeIcon(r.type);
    final typeColor = _typeColor(r.type);

    return Dismissible(
      key: Key(r.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.red),
      ),
      onDismissed: (_) => ref.read(appProvider.notifier).deleteReminder(r.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bg1,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(typeIcon, color: typeColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.title, style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: r.enabled ? AppColors.white : AppColors.textSecondary,
                  )),
                  Text('${r.time} · ${r.repeat}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            Switch(
              value: r.enabled,
              onChanged: (_) => ref.read(appProvider.notifier).toggleReminder(r.id),
              activeColor: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Add Reminder Modal ─────────────────────────────────────
  void _showAddReminderModal() {
    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController(text: '08:00');
    String type = 'custom';
    String repeat = 'daily';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 30),
          decoration: const BoxDecoration(
            color: AppColors.bg2,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add reminder', style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white,
              )),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Reminder title',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true, fillColor: AppColors.bg3,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Time (HH:MM)',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true, fillColor: AppColors.bg3,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              // Type chips
              Wrap(
                spacing: 6, runSpacing: 6,
                children: ['meal', 'water', 'workout', 'sleep', 'protein', 'custom'].map((t) {
                  return GestureDetector(
                    onTap: () => setModalState(() => type = t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: type == t ? AppColors.accent : AppColors.bg3,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(t, style: TextStyle(
                        fontSize: 12, color: type == t ? Colors.white : AppColors.textSecondary,
                      )),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              // Repeat chips
              Wrap(
                spacing: 6,
                children: ['daily', 'weekday', 'once'].map((r) {
                  return GestureDetector(
                    onTap: () => setModalState(() => repeat = r),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: repeat == r ? AppColors.accent : AppColors.bg3,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(r, style: TextStyle(
                        fontSize: 12, color: repeat == r ? Colors.white : AppColors.textSecondary,
                      )),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    ref.read(appProvider.notifier).addReminder(Reminder(
                      id: const Uuid().v4(),
                      title: titleCtrl.text.trim(),
                      time: timeCtrl.text.trim(),
                      type: type,
                      repeat: repeat,
                      enabled: true,
                    ));
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save reminder', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'meal': return Icons.restaurant;
      case 'water': return Icons.water_drop;
      case 'workout': return Icons.fitness_center;
      case 'sleep': return Icons.bedtime;
      case 'walk': return Icons.directions_walk;
      case 'protein': return Icons.blender;
      default: return Icons.notifications;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'meal': return AppColors.green;
      case 'water': return AppColors.blue;
      case 'workout': return AppColors.amber;
      case 'sleep': return AppColors.lavender;
      case 'walk': return AppColors.teal;
      case 'protein': return AppColors.blue;
      default: return AppColors.accent;
    }
  }
}

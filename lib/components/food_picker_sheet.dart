import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../constants/colors.dart';
import '../../constants/food_database.dart';
import '../../store/app_provider.dart';
import '../../store/types.dart';

/// Bottom sheet that lets the user pick a food from the database
/// and adds it to the schedule as a completed meal.
/// Quantity is per individual unit (1 thosai, 1 idly, etc).
class FoodPickerSheet extends ConsumerStatefulWidget {
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  const FoodPickerSheet({super.key, required this.mealType});

  @override
  ConsumerState<FoodPickerSheet> createState() => _FoodPickerSheetState();
}

class _FoodPickerSheetState extends ConsumerState<FoodPickerSheet> {
  String _search = '';
  // Map of food item ID to selected individual unit count
  final Map<String, int> _quantities = {};
  String? _expandedId;

  List<FoodItem> get _filteredItems {
    final items = FoodDatabase.getByCategory(widget.mealType);
    if (_search.isEmpty) return items;
    final q = _search.toLowerCase();
    return items.where((i) =>
      i.name.toLowerCase().contains(q) ||
      i.description.toLowerCase().contains(q)
    ).toList();
  }

  // Get items already logged for this exact meal category
  List<ScheduleItem> _getAlreadyLogged(List<ScheduleItem> schedule) {
    return schedule.where((s) =>
      s.time == _defaultTime && s.done && s.isCustom
    ).toList();
  }

  String get _title {
    switch (widget.mealType) {
      case 'breakfast': return '🍳 Breakfast';
      case 'lunch': return '🍛 Lunch';
      case 'dinner': return '🍽️ Dinner';
      case 'snack': return '🥜 Snack';
      default: return 'Choose Food';
    }
  }

  String get _defaultTime {
    switch (widget.mealType) {
      case 'breakfast': return '07:30';
      case 'lunch': return '13:00';
      case 'dinner': return '20:00';
      case 'snack': return '16:00';
      default: return '12:00';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final loggedItems = _getAlreadyLogged(state.schedule);
    final loggedCals = loggedItems.fold(0.0, (s, i) => s + i.calories);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border2, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(
              children: [
                Text(_title, style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white,
                )),
                const Spacer(),
                if (loggedItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${loggedCals.toInt()} kcal logged',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.green),
                    ),
                  ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search foods...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.bg3,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border2, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border2, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.accent, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          // Food list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Already logged section
                if (loggedItems.isNotEmpty && _search.isEmpty) ...[
                  _sectionHeader('✅  Already logged', AppColors.green),
                  const SizedBox(height: 8),
                  ...loggedItems.map((s) => _buildLoggedTile(s)),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border1, height: 1),
                  const SizedBox(height: 16),
                  _sectionHeader('➕  Add more', AppColors.textSecondary),
                  const SizedBox(height: 8),
                ],
                ..._filteredItems.map((food) => _buildFoodTile(food)),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text, Color color) {
    return Text(text, style: TextStyle(
      fontSize: 14, fontWeight: FontWeight.bold, color: color,
    ));
  }

  Widget _buildLoggedTile(ScheduleItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(item.icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white,
                )),
                const SizedBox(height: 3),
                Row(
                  children: [
                    _chipSmall('${item.calories.toInt()} kcal', AppColors.accent),
                    const SizedBox(width: 4),
                    if (item.protein > 0)
                      _chipSmall('P:${item.protein.toInt()}g', AppColors.lavender),
                    const SizedBox(width: 4),
                    Text(item.sub, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => ref.read(appProvider.notifier).deleteScheduleItem(item.id),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline, color: AppColors.red, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodTile(FoodItem food) {
    final isExpanded = _expandedId == food.id;
    final qty = _quantities[food.id] ?? food.servingQty; // Default to standard serving qty

    // Per-unit calculations
    final totalCal = (food.caloriesPerUnit * qty).toInt();
    final totalP = (food.proteinPerUnit * qty).toInt();
    final totalC = (food.carbsPerUnit * qty).toInt();
    final totalF = (food.fatPerUnit * qty).toInt();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isExpanded ? AppColors.bg3 : AppColors.bg1,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isExpanded ? AppColors.accent : AppColors.border1),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _expandedId = isExpanded ? null : food.id;
            if (!isExpanded && !_quantities.containsKey(food.id)) {
              _quantities[food.id] = food.servingQty;
            }
          });
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // ─── Top row: icon, name, per-unit info ───
              Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.iconMeal.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(food.icon, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(food.name, style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.white,
                        )),
                        const SizedBox(height: 2),
                        Text(food.description, style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary,
                        )),
                        const SizedBox(height: 4),
                        // Per-unit calorie info
                        Text(
                          '${food.caloriesPerUnit.toInt()} kcal per ${food.unit}  ·  Standard: ${food.servingSize}',
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.add_circle_outline,
                    color: isExpanded ? AppColors.textSecondary : AppColors.accent,
                    size: 24,
                  ),
                ],
              ),
              // ─── Expanded section: qty picker + summary ───
              if (isExpanded) ...[
                const SizedBox(height: 14),
                const Divider(color: AppColors.border1, height: 1),
                const SizedBox(height: 14),
                // Quantity picker
                Row(
                  children: [
                    const Text('How many:', style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
                    )),
                    const Spacer(),
                    // Stepper
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bg1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border2),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: qty > 1 ? () => setState(() => _quantities[food.id] = qty - 1) : null,
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              child: Icon(Icons.remove, size: 18,
                                color: qty > 1 ? AppColors.textPrimary : AppColors.textMuted),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('$qty', style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accent,
                            )),
                          ),
                          InkWell(
                            onTap: () => setState(() => _quantities[food.id] = qty + 1),
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              child: const Icon(Icons.add, size: 18, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(food.unit, style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent,
                    )),
                  ],
                ),
                const SizedBox(height: 14),
                // Nutrition summary card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bg1,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.summarize_outlined, size: 14, color: AppColors.accent),
                          const SizedBox(width: 6),
                          Text(
                            '$qty ${food.unit}${qty > 1 ? 's' : ''} of ${food.name}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _nutrientBox('Calories', '$totalCal', 'kcal', AppColors.accent),
                          _nutrientBox('Protein', '$totalP', 'g', AppColors.lavender),
                          _nutrientBox('Carbs', '$totalC', 'g', AppColors.amber),
                          _nutrientBox('Fat', '$totalF', 'g', AppColors.teal),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Add button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _selectFood(food, qty),
                    icon: const Icon(Icons.add_circle, size: 18),
                    label: Text('Add $qty ${food.unit}${qty > 1 ? 's' : ''} — $totalCal kcal',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _nutrientBox(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800, color: color,
            )),
            Text(unit, style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.6))),
          ],
        ),
      ],
    );
  }

  Widget _chipSmall(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }

  void _selectFood(FoodItem food, int qty) {
    // Calculate per-unit * qty
    final totalCal = food.caloriesPerUnit * qty;
    final totalP = food.proteinPerUnit * qty;
    final totalC = food.carbsPerUnit * qty;
    final totalF = food.fatPerUnit * qty;

    final item = ScheduleItem(
      id: const Uuid().v4(),
      time: _defaultTime,
      title: food.name,
      sub: '$qty ${food.unit}${qty > 1 ? 's' : ''}',
      icon: food.icon,
      type: widget.mealType == 'snack' ? ScheduleItemType.snack : ScheduleItemType.meal,
      calories: totalCal,
      protein: totalP,
      carbs: totalC,
      fat: totalF,
      done: true, // Auto-mark as eaten
      remOn: false,
      isCustom: true,
    );
    ref.read(appProvider.notifier).addScheduleItem(item);
    setState(() {
      _expandedId = null; // collapse
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(food.icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(child: Text(
              '${food.name} × $qty added — ${totalCal.toInt()} kcal',
              style: const TextStyle(fontWeight: FontWeight.w600),
            )),
          ],
        ),
        backgroundColor: AppColors.bg3,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Convenience function to show the food picker
void showFoodPicker(BuildContext context, String mealType) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FoodPickerSheet(mealType: mealType),
  );
}

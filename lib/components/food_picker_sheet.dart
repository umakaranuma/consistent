import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../constants/colors.dart';
import '../../constants/food_database.dart';
import '../../store/app_provider.dart';
import '../../store/types.dart';

/// Bottom sheet that lets the user pick a food from the database
/// and adds it to the schedule as a completed meal.
class FoodPickerSheet extends ConsumerStatefulWidget {
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  const FoodPickerSheet({super.key, required this.mealType});

  @override
  ConsumerState<FoodPickerSheet> createState() => _FoodPickerSheetState();
}

class _FoodPickerSheetState extends ConsumerState<FoodPickerSheet> {
  String _search = '';
  // Map of food item ID to selected servings (default 1)
  final Map<String, double> _servings = {};
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

  // Get items already logged for this exact meal category (based on default time)
  List<ScheduleItem> _getAlreadyLogged(List<ScheduleItem> schedule) {
    return schedule.where((s) => 
      s.time == _defaultTime && s.done && s.isCustom
    ).toList();
  }

  String get _title {
    switch (widget.mealType) {
      case 'breakfast': return 'Choose Breakfast';
      case 'lunch': return 'Choose Lunch';
      case 'dinner': return 'Choose Dinner';
      case 'snack': return 'Choose Snack';
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

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_title, style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white,
                )),
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
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border2, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border2, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
                if (loggedItems.isNotEmpty && _search.isEmpty) ...[
                  const Text('Already logged', style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.accent,
                  )),
                  const SizedBox(height: 10),
                  ...loggedItems.map((s) => _buildLoggedTile(s)),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border1, height: 1),
                  const SizedBox(height: 16),
                  const Text('Add more', style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary,
                  )),
                  const SizedBox(height: 10),
                ],
                ..._filteredItems.map((food) => _buildFoodTile(food)),
                const SizedBox(height: 40), // Padding at bottom
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedTile(ScheduleItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.iconMeal.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
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
                const SizedBox(height: 2),
                Text('${item.calories.toInt()} kcal · ${item.sub}', style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary,
                )),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: AppColors.red, size: 20),
            onPressed: () {
              ref.read(appProvider.notifier).deleteScheduleItem(item.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFoodTile(FoodItem food) {
    final isExpanded = _expandedId == food.id;
    final qty = _servings[food.id] ?? 1.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isExpanded ? AppColors.bg3 : AppColors.bg1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isExpanded ? AppColors.accent : AppColors.border1),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _expandedId = isExpanded ? null : food.id;
            if (!isExpanded && !_servings.containsKey(food.id)) {
              _servings[food.id] = 1.0;
            }
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.iconMeal.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(food.icon, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(food.name, style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white,
                        )),
                        const SizedBox(height: 2),
                        Text(food.description, style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary,
                        )),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _macroChip('${(food.calories * qty).toInt()} kcal', AppColors.accent),
                            const SizedBox(width: 6),
                            _macroChip('P:${(food.protein * qty).toInt()}g', AppColors.blue),
                            const SizedBox(width: 6),
                            _macroChip('C:${(food.carbs * qty).toInt()}g', AppColors.amber),
                            const SizedBox(width: 6),
                            _macroChip('F:${(food.fat * qty).toInt()}g', AppColors.red),
                          ],
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
              if (isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(color: AppColors.border1, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('Quantity:', style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary,
                        )),
                        const SizedBox(width: 12),
                        // Stepper
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.bg1,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border2),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: qty > 0.5 ? () => setState(() => _servings[food.id] = qty - 0.5) : null,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  child: Icon(Icons.remove, size: 16, color: AppColors.textPrimary),
                                ),
                              ),
                              Text(qty % 1 == 0 ? qty.toInt().toString() : qty.toStringAsFixed(1), style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white,
                              )),
                              InkWell(
                                onTap: () => setState(() => _servings[food.id] = qty + 0.5),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  child: Icon(Icons.add, size: 16, color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(food.servingSize, style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary,
                        )),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _selectFood(food, qty),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        minimumSize: const Size(0, 36),
                      ),
                      child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _macroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }

  void _selectFood(FoodItem food, double qty) {
    final item = ScheduleItem(
      id: const Uuid().v4(),
      time: _defaultTime,
      title: food.name,
      sub: 'Qty: ${qty % 1 == 0 ? qty.toInt() : qty.toStringAsFixed(1)} x ${food.servingSize}',
      icon: food.icon,
      type: widget.mealType == 'snack' ? ScheduleItemType.snack : ScheduleItemType.meal,
      calories: food.calories * qty,
      protein: food.protein * qty,
      carbs: food.carbs * qty,
      fat: food.fat * qty,
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
        content: Text('${food.name} added — ${(food.calories * qty).toInt()} kcal'),
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

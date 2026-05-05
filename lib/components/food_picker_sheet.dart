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
  const FoodPickerSheet({Key? key, required this.mealType}) : super(key: key);

  @override
  ConsumerState<FoodPickerSheet> createState() => _FoodPickerSheetState();
}

class _FoodPickerSheetState extends ConsumerState<FoodPickerSheet> {
  String _search = '';

  List<FoodItem> get _filteredItems {
    final items = FoodDatabase.getByCategory(widget.mealType);
    if (_search.isEmpty) return items;
    final q = _search.toLowerCase();
    return items.where((i) =>
      i.name.toLowerCase().contains(q) ||
      i.description.toLowerCase().contains(q)
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
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final food = _filteredItems[index];
                return _buildFoodTile(food);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodTile(FoodItem food) {
    return InkWell(
      onTap: () => _selectFood(food),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bg1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border1),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.iconMeal.withOpacity(0.3),
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
                      _macroChip('${food.calories.toInt()} kcal', AppColors.accent),
                      const SizedBox(width: 6),
                      _macroChip('P:${food.protein.toInt()}g', AppColors.blue),
                      const SizedBox(width: 6),
                      _macroChip('C:${food.carbs.toInt()}g', AppColors.amber),
                      const SizedBox(width: 6),
                      _macroChip('F:${food.fat.toInt()}g', AppColors.red),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.add_circle_outline, color: AppColors.accent, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _macroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }

  void _selectFood(FoodItem food) {
    final item = ScheduleItem(
      id: const Uuid().v4(),
      time: _defaultTime,
      title: food.name,
      sub: food.description,
      icon: food.icon,
      type: widget.mealType == 'snack' ? ScheduleItemType.snack : ScheduleItemType.meal,
      calories: food.calories,
      protein: food.protein,
      carbs: food.carbs,
      fat: food.fat,
      done: true, // Auto-mark as eaten
      remOn: false,
      isCustom: true,
    );
    ref.read(appProvider.notifier).addScheduleItem(item);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${food.name} added — ${food.calories.toInt()} kcal'),
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

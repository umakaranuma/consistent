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
    final dbItems = (widget.mealType == 'snack') ? FoodDatabase.getByCategory(widget.mealType) : FoodDatabase.getWithSides(widget.mealType);
    // Add user-created custom foods
    final customFoods = ref.read(appProvider.notifier).customFoods
      .where((f) => f['category'] == widget.mealType || f['category'] == 'all')
      .map((f) => FoodItem(
        id: f['id'] as String,
        name: f['name'] as String,
        category: widget.mealType,
        description: 'Custom food',
        icon: f['icon'] as String? ?? '\u{1F37D}',
        calories: (f['calories'] as num).toDouble(),
        protein: (f['protein'] as num).toDouble(),
        carbs: (f['carbs'] as num).toDouble(),
        fat: (f['fat'] as num).toDouble(),
        servingSize: f['servingSize'] as String? ?? '1 serving',
        servingQty: f['servingQty'] as int? ?? 1,
        unit: f['unit'] as String? ?? 'serving',
      )).toList();
    final items = [...customFoods, ...dbItems];
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
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border2, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(
              children: [
                Text(_title, style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white,
                )),
                Spacer(),
                if (loggedItems.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${loggedCals.toInt()} kcal logged',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.green),
                    ),
                  ),
                SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search foods...',
                hintStyle: TextStyle(color: AppColors.textMuted),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.bg3,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.border2, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.border2, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.accent, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          // Food list
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Already logged section
                if (loggedItems.isNotEmpty && _search.isEmpty) ...[
                  _sectionHeader('✅  Already logged', AppColors.green),
                  SizedBox(height: 8),
                  ...loggedItems.map((s) => _buildLoggedTile(s)),
                  SizedBox(height: 16),
                  Divider(color: AppColors.border1, height: 1),
                  const SizedBox(height: 16),
                  _sectionHeader('➕  Add more', AppColors.textSecondary),
                  const SizedBox(height: 8),
                ],
                // Create custom food button
                if (_search.isEmpty)
                  _buildCreateFoodButton(),
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
            child: Text(item.icon, style: TextStyle(fontSize: 18)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white,
                )),
                SizedBox(height: 3),
                Row(
                  children: [
                    _chipSmall('${item.calories.toInt()} kcal', AppColors.accent),
                    SizedBox(width: 4),
                    if (item.protein > 0)
                      _chipSmall('P:${item.protein.toInt()}g', AppColors.lavender),
                    SizedBox(width: 4),
                    Text(item.sub, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => ref.read(appProvider.notifier).deleteScheduleItem(item.id),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.delete_outline, color: AppColors.red, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateFoodButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _showCreateFoodDialog,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bg1,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.add_rounded, color: AppColors.accent, size: 24),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create Custom Food', style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.accent,
                    )),
                    SizedBox(height: 2),
                    Text("Can't find your food? Add it here", style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary,
                    )),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateFoodDialog() {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final protCtrl = TextEditingController(text: '0');
    final carbCtrl = TextEditingController(text: '0');
    final fatCtrl = TextEditingController(text: '0');
    final sizeCtrl = TextEditingController(text: '1 serving');
    String selectedCategory = widget.mealType;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          backgroundColor: AppColors.bg2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.restaurant_outlined, color: AppColors.accent, size: 22),
              SizedBox(width: 10),
              Text('Create Custom Food', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white,
              )),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(nameCtrl, 'Food name', 'e.g. Masala Dosa', TextInputType.text),
                const SizedBox(height: 10),
                _dialogField(calCtrl, 'Calories (kcal)', 'e.g. 250', TextInputType.number),
                SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _dialogField(protCtrl, 'Protein (g)', '0', TextInputType.number)),
                  SizedBox(width: 8),
                  Expanded(child: _dialogField(carbCtrl, 'Carbs (g)', '0', TextInputType.number)),
                  SizedBox(width: 8),
                  Expanded(child: _dialogField(fatCtrl, 'Fat (g)', '0', TextInputType.number)),
                ]),
                SizedBox(height: 10),
                _dialogField(sizeCtrl, 'Serving size', '1 plate', TextInputType.text),
                SizedBox(height: 12),
                // Category selector
                Row(
                  children: [
                    Text('Available in: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    SizedBox(width: 6),
                    DropdownButton<String>(
                      value: selectedCategory,
                      dropdownColor: AppColors.bg3,
                      style: TextStyle(fontSize: 13, color: AppColors.white),
                      underline: Container(height: 1, color: AppColors.border2),
                      items: const [
                        DropdownMenuItem(value: 'breakfast', child: Text('Breakfast')),
                        DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
                        DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
                        DropdownMenuItem(value: 'snack', child: Text('Snack')),
                        DropdownMenuItem(value: 'all', child: Text('All meals')),
                      ],
                      onChanged: (v) => setDState(() => selectedCategory = v!),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final cal = double.tryParse(calCtrl.text);
                if (name.isEmpty || cal == null || cal <= 0) return;

                final food = {
                  'id': 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  'name': name,
                  'calories': cal,
                  'protein': double.tryParse(protCtrl.text) ?? 0.0,
                  'carbs': double.tryParse(carbCtrl.text) ?? 0.0,
                  'fat': double.tryParse(fatCtrl.text) ?? 0.0,
                  'servingSize': sizeCtrl.text.trim(),
                  'servingQty': 1,
                  'unit': 'serving',
                  'icon': '\u{1F37D}',
                  'category': selectedCategory,
                };
                ref.read(appProvider.notifier).addCustomFood(food);
                setState(() {}); // refresh list
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('$name added to your food list!'),
                  backgroundColor: AppColors.bg3,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Add Food', style: TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label, String hint, TextInputType type) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: TextStyle(color: AppColors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
        filled: true, fillColor: AppColors.bg3,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.accent)),
      ),
    );
  }

  /// Get effective calories per serving (user override or default)
  double _effectiveCals(FoodItem food) {
    final overrides = ref.read(appProvider.notifier).calorieOverrides;
    return overrides[food.id] ?? food.calories;
  }

  double _effectiveCalsPerUnit(FoodItem food) {
    return _effectiveCals(food) / food.servingQty;
  }

  bool _hasOverride(FoodItem food) {
    return ref.read(appProvider.notifier).calorieOverrides.containsKey(food.id);
  }

  Widget _buildFoodTile(FoodItem food) {
    final isExpanded = _expandedId == food.id;
    final qty = _quantities[food.id] ?? food.servingQty;
    final calPerUnit = _effectiveCalsPerUnit(food);
    final isOverridden = _hasOverride(food);

    // Per-unit calculations (calories use override, macros keep ratio)
    final calRatio = _effectiveCals(food) / food.calories;
    final totalCal = (calPerUnit * qty).toInt();
    final totalP = (food.proteinPerUnit * calRatio * qty).toInt();
    final totalC = (food.carbsPerUnit * calRatio * qty).toInt();
    final totalF = (food.fatPerUnit * calRatio * qty).toInt();

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
                    child: Text(food.icon, style: TextStyle(fontSize: 24)),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(food.name, style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.white,
                        )),
                        SizedBox(height: 2),
                        Text(food.description, style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary,
                        )),
                        const SizedBox(height: 4),
                        // Per-unit calorie info + edit button
                        Row(
                          children: [
                            Text(
                              '${calPerUnit.toInt()} kcal per ${food.unit}',
                              style: TextStyle(fontSize: 10,
                                color: isOverridden ? AppColors.amber : AppColors.textMuted,
                                fontWeight: isOverridden ? FontWeight.w600 : FontWeight.normal),
                            ),
                            if (isOverridden)
                              Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(Icons.edit, size: 10, color: AppColors.amber),
                              ),
                            Text(
                              '  ·  ${food.servingSize}',
                              style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                            ),
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
              // ─── Expanded section: qty picker + summary ───
              if (isExpanded) ...[
                SizedBox(height: 14),
                Divider(color: AppColors.border1, height: 1),
                SizedBox(height: 14),
                // Quantity picker
                Row(
                  children: [
                    Text('How many:', style: TextStyle(
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
                            borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              child: Icon(Icons.remove, size: 18,
                                color: qty > 1 ? AppColors.textPrimary : AppColors.textMuted),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('$qty', style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accent,
                            )),
                          ),
                          InkWell(
                            onTap: () => setState(() => _quantities[food.id] = qty + 1),
                            borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              child: Icon(Icons.add, size: 18, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(food.unit, style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent,
                    )),
                  ],
                ),
                SizedBox(height: 14),
                // Nutrition summary card
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bg1,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.summarize_outlined, size: 14, color: AppColors.accent),
                          SizedBox(width: 6),
                          Text(
                            '$qty ${food.unit}${qty > 1 ? 's' : ''} of ${food.name}${isOverridden ? ' (custom)' : ''}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.white),
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
                // Edit calories button
                OutlinedButton.icon(
                  onPressed: () => _showCalorieEditDialog(food),
                  icon: Icon(Icons.edit_outlined, size: 16,
                    color: isOverridden ? AppColors.amber : AppColors.textSecondary),
                  label: Text(
                    isOverridden
                      ? 'Custom: ${_effectiveCals(food).toInt()} kcal/serving  (tap to edit)'
                      : 'Edit calories for ${food.name}',
                    style: TextStyle(fontSize: 12,
                      color: isOverridden ? AppColors.amber : AppColors.textSecondary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: (isOverridden ? AppColors.amber : AppColors.textMuted).withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                const SizedBox(height: 10),
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
                      foregroundColor: AppColors.pureWhite,
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
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
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

  void _showCalorieEditDialog(FoodItem food) {
    final currentCals = _effectiveCals(food);
    final controller = TextEditingController(text: currentCals.toInt().toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bg2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(food.icon, style: TextStyle(fontSize: 22)),
            SizedBox(width: 10),
            Expanded(child: Text(food.name, style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white,
            ))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calories per serving (${food.servingSize}):',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                suffixText: 'kcal',
                suffixStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                filled: true,
                fillColor: AppColors.bg3,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.accent),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text('Default: ${food.calories.toInt()} kcal',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            Text('This change only affects new entries, not past logs.',
              style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
        actions: [
          if (_hasOverride(food))
            TextButton(
              onPressed: () {
                ref.read(appProvider.notifier).removeCalorieOverride(food.id);
                setState(() {});
                Navigator.pop(ctx);
              },
              child: Text('Reset', style: TextStyle(color: AppColors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                ref.read(appProvider.notifier).setCalorieOverride(food.id, val);
                setState(() {});
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Save', style: TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _selectFood(FoodItem food, int qty) {
    // Calculate per-unit * qty using effective (possibly overridden) calories
    final calPerUnit = _effectiveCalsPerUnit(food);
    final calRatio = _effectiveCals(food) / food.calories;
    final totalCal = calPerUnit * qty;
    final totalP = food.proteinPerUnit * calRatio * qty;
    final totalC = food.carbsPerUnit * calRatio * qty;
    final totalF = food.fatPerUnit * calRatio * qty;

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

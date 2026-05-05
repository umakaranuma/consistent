import '../store/types.dart';

/// Local food database with Sri Lankan and common foods.
/// Each food has calorie, protein, carbs, and fat per standard serving.
/// [servingQty] = how many individual [unit]s make one serving.
/// The picker uses perUnit helpers so the user picks individual pieces.
class FoodDatabase {
  static const List<FoodItem> breakfastItems = [
    FoodItem(id: 'b1', name: 'Puttu', category: 'breakfast',
      description: 'Rice flour & coconut puttu', icon: '🍚',
      calories: 240, protein: 4, carbs: 42, fat: 8,
      servingSize: '1 cylinder', servingQty: 1, unit: 'cylinder'),
    FoodItem(id: 'b2', name: 'Thosai', category: 'breakfast',
      description: 'Rice & urad dal dosa with sambar', icon: '🥞',
      calories: 260, protein: 8, carbs: 40, fat: 6,
      servingSize: '2 pieces', servingQty: 2, unit: 'pc'),
    FoodItem(id: 'b3', name: 'Idly', category: 'breakfast',
      description: 'Steamed rice cakes with chutney', icon: '⚪',
      calories: 195, protein: 6, carbs: 36, fat: 1,
      servingSize: '3 pieces', servingQty: 3, unit: 'pc'),
    FoodItem(id: 'b4', name: 'String Hoppers', category: 'breakfast',
      description: 'Idiyappam with curry', icon: '🍜',
      calories: 280, protein: 5, carbs: 50, fat: 4,
      servingSize: '6 pieces', servingQty: 6, unit: 'pc'),
    FoodItem(id: 'b5', name: 'Egg Roti', category: 'breakfast',
      description: 'Godamba roti with egg filling', icon: '🥚',
      calories: 350, protein: 14, carbs: 38, fat: 16,
      servingSize: '1 piece', servingQty: 1, unit: 'pc'),
    FoodItem(id: 'b6', name: 'Oats Porridge', category: 'breakfast',
      description: 'Oats with milk and banana', icon: '🥣',
      calories: 310, protein: 12, carbs: 48, fat: 8,
      servingSize: '1 bowl', servingQty: 1, unit: 'bowl'),
    FoodItem(id: 'b7', name: 'Bread & Eggs', category: 'breakfast',
      description: '2 toast + 2 scrambled eggs', icon: '🍳',
      calories: 380, protein: 22, carbs: 35, fat: 14,
      servingSize: '2 slices + 2 eggs', servingQty: 1, unit: 'serving'),
    FoodItem(id: 'b8', name: 'Pittu & Coconut Milk', category: 'breakfast',
      description: 'Pittu with lunu miris and coconut milk', icon: '🥥',
      calories: 420, protein: 6, carbs: 52, fat: 22,
      servingSize: '2 cylinders', servingQty: 2, unit: 'cylinder'),
    FoodItem(id: 'b9', name: 'Fruit Smoothie Bowl', category: 'breakfast',
      description: 'Mixed fruits, yogurt, granola', icon: '🍓',
      calories: 280, protein: 10, carbs: 45, fat: 6,
      servingSize: '1 bowl', servingQty: 1, unit: 'bowl'),
    FoodItem(id: 'b10', name: 'Protein Pancakes', category: 'breakfast',
      description: 'Oat pancakes with whey protein', icon: '🥞',
      calories: 340, protein: 28, carbs: 35, fat: 8,
      servingSize: '3 pancakes', servingQty: 3, unit: 'pc'),
  ];

  static const List<FoodItem> lunchItems = [
    FoodItem(id: 'l1', name: 'Rice & Curry', category: 'lunch',
      description: '1 cup rice + dhal + vegetable curry + fish/chicken', icon: '🍛',
      calories: 550, protein: 30, carbs: 65, fat: 14,
      servingSize: '1 plate', servingQty: 1, unit: 'plate'),
    FoodItem(id: 'l2', name: 'Kottu Roti', category: 'lunch',
      description: 'Chopped roti with vegetables & chicken', icon: '🥘',
      calories: 620, protein: 24, carbs: 55, fat: 30,
      servingSize: '1 plate', servingQty: 1, unit: 'plate'),
    FoodItem(id: 'l3', name: 'Biriyani', category: 'lunch',
      description: 'Chicken biryani with raita', icon: '🍚',
      calories: 680, protein: 32, carbs: 72, fat: 26,
      servingSize: '1 plate', servingQty: 1, unit: 'plate'),
    FoodItem(id: 'l4', name: 'Fried Rice', category: 'lunch',
      description: 'Egg fried rice with vegetables', icon: '🍳',
      calories: 520, protein: 16, carbs: 68, fat: 18,
      servingSize: '1 plate', servingQty: 1, unit: 'plate'),
    FoodItem(id: 'l5', name: 'Noodles', category: 'lunch',
      description: 'Stir-fried noodles with chicken', icon: '🍝',
      calories: 480, protein: 20, carbs: 58, fat: 16,
      servingSize: '1 plate', servingQty: 1, unit: 'plate'),
    FoodItem(id: 'l6', name: 'Grilled Chicken Salad', category: 'lunch',
      description: 'Chicken breast, greens, olive oil', icon: '🥗',
      calories: 380, protein: 38, carbs: 12, fat: 18,
      servingSize: '1 bowl', servingQty: 1, unit: 'bowl'),
    FoodItem(id: 'l7', name: 'Fish Curry & Rice', category: 'lunch',
      description: 'Fish curry with red rice', icon: '🐟',
      calories: 510, protein: 34, carbs: 58, fat: 12,
      servingSize: '1 plate', servingQty: 1, unit: 'plate'),
    FoodItem(id: 'l8', name: 'Lamprais', category: 'lunch',
      description: 'Dutch-Burgher rice packet', icon: '🍱',
      calories: 750, protein: 28, carbs: 82, fat: 32,
      servingSize: '1 packet', servingQty: 1, unit: 'packet'),
    FoodItem(id: 'l9', name: 'Roti & Dhal Curry', category: 'lunch',
      description: 'Wheat roti with lentil curry', icon: '🫓',
      calories: 420, protein: 16, carbs: 56, fat: 12,
      servingSize: '2 roti + curry', servingQty: 2, unit: 'roti'),
    FoodItem(id: 'l10', name: 'Chicken Wrap', category: 'lunch',
      description: 'Tortilla wrap with chicken & vegetables', icon: '🌯',
      calories: 440, protein: 30, carbs: 42, fat: 14,
      servingSize: '1 wrap', servingQty: 1, unit: 'wrap'),
  ];

  static const List<FoodItem> dinnerItems = [
    FoodItem(id: 'd1', name: 'Rice & Curry (Light)', category: 'dinner',
      description: '½ cup rice + dhal + vegetables', icon: '🍛',
      calories: 380, protein: 18, carbs: 48, fat: 10,
      servingSize: '1 plate', servingQty: 1, unit: 'plate'),
    FoodItem(id: 'd2', name: 'Grilled Fish & Vegetables', category: 'dinner',
      description: 'Grilled fish fillet with steamed vegetables', icon: '🐟',
      calories: 320, protein: 36, carbs: 14, fat: 12,
      servingSize: '1 plate', servingQty: 1, unit: 'plate'),
    FoodItem(id: 'd3', name: 'Chicken Soup', category: 'dinner',
      description: 'Clear chicken soup with vegetables', icon: '🍲',
      calories: 250, protein: 24, carbs: 18, fat: 8,
      servingSize: '1 bowl', servingQty: 1, unit: 'bowl'),
    FoodItem(id: 'd4', name: 'Egg Kottu', category: 'dinner',
      description: 'Kottu with egg & vegetables, no meat', icon: '🥘',
      calories: 480, protein: 16, carbs: 52, fat: 22,
      servingSize: '1 plate', servingQty: 1, unit: 'plate'),
    FoodItem(id: 'd5', name: 'Vegetable Stir Fry', category: 'dinner',
      description: 'Mixed vegetables with tofu in soy sauce', icon: '🥦',
      calories: 280, protein: 14, carbs: 22, fat: 14,
      servingSize: '1 plate', servingQty: 1, unit: 'plate'),
    FoodItem(id: 'd6', name: 'Chicken Breast & Salad', category: 'dinner',
      description: 'Grilled chicken with garden salad', icon: '🥗',
      calories: 350, protein: 40, carbs: 10, fat: 14,
      servingSize: '1 plate', servingQty: 1, unit: 'plate'),
    FoodItem(id: 'd7', name: 'Omelete & Toast', category: 'dinner',
      description: '3-egg omelette with wheat toast', icon: '🍳',
      calories: 400, protein: 26, carbs: 28, fat: 18,
      servingSize: '1 serving', servingQty: 1, unit: 'serving'),
    FoodItem(id: 'd8', name: 'String Hoppers & Curry', category: 'dinner',
      description: 'Idiyappam with chicken curry', icon: '🍜',
      calories: 420, protein: 22, carbs: 54, fat: 12,
      servingSize: '8 pcs + curry', servingQty: 8, unit: 'pc'),
  ];

  static const List<FoodItem> snackItems = [
    FoodItem(id: 's1', name: 'Mixed Nuts', category: 'snack',
      description: 'Almonds, cashews, walnuts', icon: '🥜',
      calories: 180, protein: 6, carbs: 8, fat: 14,
      servingSize: '30g handful', servingQty: 1, unit: 'handful'),
    FoodItem(id: 's2', name: 'Banana', category: 'snack',
      description: '1 medium banana', icon: '🍌',
      calories: 105, protein: 1, carbs: 27, fat: 0,
      servingSize: '1 medium', servingQty: 1, unit: 'pc'),
    FoodItem(id: 's3', name: 'Greek Yogurt', category: 'snack',
      description: 'Plain Greek yogurt 150g', icon: '🥛',
      calories: 140, protein: 15, carbs: 8, fat: 5,
      servingSize: '150g', servingQty: 1, unit: 'cup'),
    FoodItem(id: 's4', name: 'Protein Bar', category: 'snack',
      description: 'Whey protein bar', icon: '🍫',
      calories: 220, protein: 20, carbs: 24, fat: 8,
      servingSize: '1 bar', servingQty: 1, unit: 'bar'),
    FoodItem(id: 's5', name: 'Fruit Salad', category: 'snack',
      description: 'Mixed fresh fruits', icon: '🍎',
      calories: 120, protein: 2, carbs: 28, fat: 1,
      servingSize: '1 cup', servingQty: 1, unit: 'cup'),
    FoodItem(id: 's6', name: 'Egg (Boiled)', category: 'snack',
      description: 'Hard boiled eggs', icon: '🥚',
      calories: 140, protein: 12, carbs: 1, fat: 10,
      servingSize: '2 eggs', servingQty: 2, unit: 'egg'),
    FoodItem(id: 's7', name: 'Peanut Butter Toast', category: 'snack',
      description: '1 toast with peanut butter', icon: '🍞',
      calories: 230, protein: 8, carbs: 22, fat: 12,
      servingSize: '1 slice', servingQty: 1, unit: 'slice'),
    FoodItem(id: 's8', name: 'Whey Protein Shake', category: 'snack',
      description: '1 scoop whey in water', icon: '🥤',
      calories: 130, protein: 25, carbs: 3, fat: 2,
      servingSize: '1 scoop', servingQty: 1, unit: 'scoop'),
    FoodItem(id: 's9', name: 'Wade', category: 'snack',
      description: 'Ulundu vadai - deep fried lentil', icon: '🧆',
      calories: 260, protein: 10, carbs: 28, fat: 12,
      servingSize: '2 pieces', servingQty: 2, unit: 'pc'),
    FoodItem(id: 's10', name: 'Biscuits & Tea', category: 'snack',
      description: '3 digestive biscuits + tea', icon: '🍪',
      calories: 180, protein: 3, carbs: 30, fat: 6,
      servingSize: '3 biscuits', servingQty: 3, unit: 'biscuit'),
  ];

  static List<FoodItem> getByCategory(String category) {
    switch (category) {
      case 'breakfast': return breakfastItems;
      case 'lunch': return lunchItems;
      case 'dinner': return dinnerItems;
      case 'snack': return snackItems;
      default: return [];
    }
  }

  static List<FoodItem> searchAll(String query) {
    final q = query.toLowerCase();
    return [
      ...breakfastItems,
      ...lunchItems,
      ...dinnerItems,
      ...snackItems,
    ].where((item) =>
      item.name.toLowerCase().contains(q) ||
      item.description.toLowerCase().contains(q)
    ).toList();
  }
}

import '../store/types.dart';

class PlanTemplateItem {
  final String time;
  final String title;
  final String sub;
  final String icon;
  final ScheduleItemType type;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const PlanTemplateItem({
    required this.time,
    required this.title,
    required this.sub,
    required this.icon,
    required this.type,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class DefaultPlans {
  static const List<PlanTemplateItem> planNormalUnderweight = [
    PlanTemplateItem(
      time: '07:00', title: 'Wake up + hydrate',
      sub: '500ml water immediately on waking',
      icon: '💧', type: ScheduleItemType.water, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '07:30', title: 'Breakfast — calorie dense',
      sub: '3 whole eggs + 2 slices whole wheat toast + 1 banana + peanut butter',
      icon: '🍳', type: ScheduleItemType.meal, calories: 580, protein: 28, carbs: 55, fat: 24,
    ),
    PlanTemplateItem(
      time: '10:00', title: 'Mid-morning snack',
      sub: 'Handful of mixed nuts + 1 glass full-fat milk',
      icon: '🥛', type: ScheduleItemType.snack, calories: 300, protein: 12, carbs: 20, fat: 18,
    ),
    PlanTemplateItem(
      time: '13:00', title: 'Lunch — balanced',
      sub: '1.5 cups rice + dhal curry + fish or chicken + vegetables',
      icon: '🍛', type: ScheduleItemType.meal, calories: 650, protein: 35, carbs: 80, fat: 14,
    ),
    PlanTemplateItem(
      time: '15:30', title: 'Afternoon snack',
      sub: 'Banana + peanut butter on 2 crackers',
      icon: '🍌', type: ScheduleItemType.snack, calories: 250, protein: 6, carbs: 40, fat: 8,
    ),
    PlanTemplateItem(
      time: '18:00', title: '30-min light exercise',
      sub: 'Walk or yoga — avoid heavy cardio when underweight',
      icon: '🚶', type: ScheduleItemType.walk, calories: 150, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '19:00', title: 'Post-exercise hydrate',
      sub: '400ml water',
      icon: '💧', type: ScheduleItemType.water, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '20:00', title: 'Dinner — protein rich',
      sub: 'Grilled chicken or fish + sweet potato + steamed vegetables',
      icon: '🍗', type: ScheduleItemType.meal, calories: 550, protein: 40, carbs: 50, fat: 12,
    ),
    PlanTemplateItem(
      time: '22:00', title: 'Night snack',
      sub: '1 cup warm milk + 2 digestive biscuits',
      icon: '🍪', type: ScheduleItemType.snack, calories: 220, protein: 8, carbs: 30, fat: 6,
    ),
    PlanTemplateItem(
      time: '23:30', title: 'Sleep',
      sub: '7–8 hours — critical for healthy weight gain',
      icon: '😴', type: ScheduleItemType.sleep, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
  ];

  static const List<PlanTemplateItem> planNormalHealthy = [
    PlanTemplateItem(
      time: '07:00', title: 'Wake up + hydrate',
      sub: '500ml water on waking',
      icon: '💧', type: ScheduleItemType.water, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '07:30', title: 'Breakfast',
      sub: '2 eggs + 1 slice whole wheat toast + 1 fruit + black coffee or green tea',
      icon: '🍳', type: ScheduleItemType.meal, calories: 380, protein: 22, carbs: 35, fat: 14,
    ),
    PlanTemplateItem(
      time: '09:30', title: 'Mid-morning water',
      sub: '250ml water',
      icon: '💧', type: ScheduleItemType.water, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '11:00', title: 'Morning snack',
      sub: 'Handful of roasted peanuts or a fruit',
      icon: '🌰', type: ScheduleItemType.snack, calories: 150, protein: 5, carbs: 15, fat: 8,
    ),
    PlanTemplateItem(
      time: '13:00', title: 'Lunch',
      sub: '1 cup rice + dhal + vegetables + small serving fish or chicken',
      icon: '🍛', type: ScheduleItemType.meal, calories: 550, protein: 30, carbs: 65, fat: 10,
    ),
    PlanTemplateItem(
      time: '13:30', title: 'Post-lunch walk',
      sub: '10–15 min walking — improves digestion and blood sugar',
      icon: '🚶', type: ScheduleItemType.walk, calories: 60, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '16:30', title: 'Evening snack',
      sub: 'Fruit + 1 cup green tea with no sugar',
      icon: '🍎', type: ScheduleItemType.snack, calories: 100, protein: 2, carbs: 22, fat: 1,
    ),
    PlanTemplateItem(
      time: '18:30', title: 'Workout — 45 min',
      sub: 'HIIT or strength training — alternate days',
      icon: '🏃', type: ScheduleItemType.workout, calories: 280, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '19:15', title: 'Post-workout hydrate',
      sub: '400ml water',
      icon: '💧', type: ScheduleItemType.water, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '20:30', title: 'Dinner — light',
      sub: 'Grilled fish or chicken + steamed vegetables + small salad',
      icon: '🥗', type: ScheduleItemType.meal, calories: 420, protein: 35, carbs: 25, fat: 12,
    ),
    PlanTemplateItem(
      time: '22:30', title: 'Night water',
      sub: '250ml water before late work',
      icon: '💧', type: ScheduleItemType.water, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '00:30', title: 'Sleep',
      sub: 'Target 7–8 hours',
      icon: '😴', type: ScheduleItemType.sleep, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
  ];

  static const List<PlanTemplateItem> planNormalOverweight = [
    PlanTemplateItem(
      time: '07:00', title: 'Wake up + hydrate',
      sub: '500ml water — start metabolism before anything else',
      icon: '💧', type: ScheduleItemType.water, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '07:30', title: 'Breakfast — high protein',
      sub: '3 boiled eggs (whites only if preferred) + vegetables + black coffee',
      icon: '🍳', type: ScheduleItemType.meal, calories: 280, protein: 26, carbs: 8, fat: 14,
    ),
    PlanTemplateItem(
      time: '09:00', title: 'Morning water',
      sub: '300ml water before any tea',
      icon: '💧', type: ScheduleItemType.water, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '13:00', title: 'Lunch — controlled portions',
      sub: '½ cup rice (samba) + dhal + grilled fish or chicken + salad',
      icon: '🍛', type: ScheduleItemType.meal, calories: 480, protein: 32, carbs: 48, fat: 10,
    ),
    PlanTemplateItem(
      time: '13:30', title: 'Post-lunch walk',
      sub: '15–20 min brisk walk — critical for fat loss',
      icon: '🚶', type: ScheduleItemType.walk, calories: 80, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '15:30', title: 'Afternoon snack — small',
      sub: 'Handful peanuts or cucumber slices + 250ml water',
      icon: '🌰', type: ScheduleItemType.snack, calories: 100, protein: 4, carbs: 8, fat: 6,
    ),
    PlanTemplateItem(
      time: '18:30', title: 'Workout — 45–60 min',
      sub: 'HIIT preferred — burns more fat post-workout',
      icon: '🏃', type: ScheduleItemType.workout, calories: 350, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '19:15', title: 'Post-workout hydrate',
      sub: '500ml water — do NOT skip this',
      icon: '💧', type: ScheduleItemType.water, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '20:30', title: 'Dinner — low carb',
      sub: 'Grilled protein + large serving steamed vegetables — NO rice at night',
      icon: '🥗', type: ScheduleItemType.meal, calories: 380, protein: 36, carbs: 20, fat: 12,
    ),
    PlanTemplateItem(
      time: '21:00', title: 'Hard stop — no food after this',
      sub: 'Water or herbal tea only after 9pm',
      icon: '🚫', type: ScheduleItemType.custom, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '22:30', title: 'Night water',
      sub: '250ml water',
      icon: '💧', type: ScheduleItemType.water, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '00:00', title: 'Sleep',
      sub: 'Poor sleep = more fat storage — aim for 7h minimum',
      icon: '😴', type: ScheduleItemType.sleep, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
  ];

  static const List<PlanTemplateItem> planNormalObese = [
    PlanTemplateItem(
      time: '07:00', title: 'Wake up + hydrate',
      sub: '600ml water — largest hydration hit of the day',
      icon: '💧', type: ScheduleItemType.water, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '07:30', title: 'Breakfast — protein only',
      sub: '3 egg whites + 1 whole egg scrambled + 1 cup vegetables, no oil',
      icon: '🍳', type: ScheduleItemType.meal, calories: 200, protein: 24, carbs: 5, fat: 8,
    ),
    PlanTemplateItem(
      time: '09:30', title: 'Morning walk — 20 min',
      sub: 'Low impact — brisk walk. No running until BMI < 30.',
      icon: '🚶', type: ScheduleItemType.walk, calories: 100, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '10:00', title: 'Water + light snack',
      sub: '300ml water + cucumber or celery sticks',
      icon: '💧', type: ScheduleItemType.water, calories: 30, protein: 1, carbs: 6, fat: 0,
    ),
    PlanTemplateItem(
      time: '13:00', title: 'Lunch — strictly portioned',
      sub: '⅓ cup rice + large dhal serving + grilled protein + salad first',
      icon: '🍛', type: ScheduleItemType.meal, calories: 420, protein: 30, carbs: 40, fat: 8,
    ),
    PlanTemplateItem(
      time: '14:00', title: 'Post-lunch walk',
      sub: '20 min walk — non-negotiable',
      icon: '🚶', type: ScheduleItemType.walk, calories: 90, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '15:30', title: 'Afternoon hydration',
      sub: '400ml water — replace afternoon tea habit',
      icon: '💧', type: ScheduleItemType.water, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '18:00', title: 'Evening walk — 30 min',
      sub: 'Brisk walk; can add light resistance bands after 2 weeks',
      icon: '🚶', type: ScheduleItemType.walk, calories: 140, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '19:30', title: 'Post-walk hydrate',
      sub: '400ml water',
      icon: '💧', type: ScheduleItemType.water, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '20:00', title: 'Dinner — very light',
      sub: 'Boiled or grilled protein + vegetables only — zero carbs at dinner',
      icon: '🥗', type: ScheduleItemType.meal, calories: 320, protein: 32, carbs: 12, fat: 10,
    ),
    PlanTemplateItem(
      time: '20:30', title: 'Hard stop — no food',
      sub: 'Water or herbal tea only. This is critical.',
      icon: '🚫', type: ScheduleItemType.custom, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '22:30', title: 'Night water',
      sub: '250ml water',
      icon: '💧', type: ScheduleItemType.water, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '23:00', title: 'Sleep — 8h target',
      sub: 'Consistent sleep schedule helps regulate hunger hormones',
      icon: '😴', type: ScheduleItemType.sleep, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
  ];

  static const List<PlanTemplateItem> planGymFatLoss = [
    PlanTemplateItem(
      time: '06:30', title: 'Pre-workout hydrate',
      sub: '500ml water + black coffee (optional pre-workout)',
      icon: '💧', type: ScheduleItemType.water, calories: 5, protein: 0, carbs: 1, fat: 0,
    ),
    PlanTemplateItem(
      time: '07:00', title: 'Morning workout — 60 min',
      sub: 'Fasted cardio 20min + strength 40min — burns more fat fasted',
      icon: '🏋️', type: ScheduleItemType.workout, calories: 420, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '08:00', title: 'Post-workout — protein shake',
      sub: 'Whey protein 30g in water + 1 banana',
      icon: '🥤', type: ScheduleItemType.protein, calories: 250, protein: 30, carbs: 28, fat: 3,
    ),
    PlanTemplateItem(
      time: '09:00', title: 'Breakfast',
      sub: '3 egg whites + 1 whole egg + spinach + oats 40g',
      icon: '🍳', type: ScheduleItemType.meal, calories: 320, protein: 30, carbs: 32, fat: 10,
    ),
    PlanTemplateItem(
      time: '12:00', title: 'Mid-day water',
      sub: '400ml water before lunch',
      icon: '💧', type: ScheduleItemType.water, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '13:00', title: 'Lunch — high protein',
      sub: '150g chicken breast or fish + ½ cup brown rice + large salad',
      icon: '🍗', type: ScheduleItemType.meal, calories: 480, protein: 45, carbs: 38, fat: 8,
    ),
    PlanTemplateItem(
      time: '16:00', title: 'Afternoon snack',
      sub: 'Greek yogurt 150g or cottage cheese + cucumber',
      icon: '🥛', type: ScheduleItemType.snack, calories: 150, protein: 18, carbs: 8, fat: 4,
    ),
    PlanTemplateItem(
      time: '19:30', title: 'Pre-bed water',
      sub: '300ml water',
      icon: '💧', type: ScheduleItemType.water, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '20:00', title: 'Dinner — low carb',
      sub: '150g grilled protein + roasted vegetables + salad — zero starch',
      icon: '🥗', type: ScheduleItemType.meal, calories: 380, protein: 42, carbs: 18, fat: 12,
    ),
    PlanTemplateItem(
      time: '21:30', title: 'Casein shake (optional)',
      sub: 'Casein protein 25g in water — slow-release overnight',
      icon: '🥤', type: ScheduleItemType.protein, calories: 120, protein: 25, carbs: 4, fat: 1,
    ),
    PlanTemplateItem(
      time: '22:30', title: 'Sleep',
      sub: '8h — GH release during sleep supports fat loss',
      icon: '😴', type: ScheduleItemType.sleep, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
  ];

  static const List<PlanTemplateItem> planGymMuscleGain = [
    PlanTemplateItem(
      time: '07:00', title: 'Wake up + hydrate',
      sub: '600ml water + 5g creatine (optional)',
      icon: '💧', type: ScheduleItemType.water, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '07:30', title: 'Breakfast — calorie dense',
      sub: '4 whole eggs + 80g oats + 1 banana + 250ml whole milk',
      icon: '🍳', type: ScheduleItemType.meal, calories: 700, protein: 42, carbs: 70, fat: 26,
    ),
    PlanTemplateItem(
      time: '10:00', title: 'Mid-morning snack',
      sub: 'Protein shake 30g + peanut butter 2 tbsp + rice cakes',
      icon: '🥤', type: ScheduleItemType.protein, calories: 380, protein: 32, carbs: 28, fat: 14,
    ),
    PlanTemplateItem(
      time: '13:00', title: 'Lunch — heavy',
      sub: '1.5 cup brown rice + 200g chicken breast + vegetables + olive oil dressing',
      icon: '🍗', type: ScheduleItemType.meal, calories: 720, protein: 52, carbs: 72, fat: 14,
    ),
    PlanTemplateItem(
      time: '15:30', title: 'Pre-workout meal',
      sub: 'Banana + 30g oats + 15g whey — 60–90 min before training',
      icon: '⚡', type: ScheduleItemType.snack, calories: 250, protein: 16, carbs: 42, fat: 2,
    ),
    PlanTemplateItem(
      time: '17:00', title: 'Strength training — 75 min',
      sub: 'Heavy compound lifts: squat, bench, deadlift, rows — progressive overload',
      icon: '🏋️', type: ScheduleItemType.workout, calories: 400, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '18:30', title: 'Post-workout — shake immediately',
      sub: 'Whey protein 40g + fast carbs (fruit or dextrose) within 30 min',
      icon: '🥤', type: ScheduleItemType.protein, calories: 300, protein: 40, carbs: 30, fat: 2,
    ),
    PlanTemplateItem(
      time: '20:00', title: 'Dinner',
      sub: '150g rice + 180g lean beef or chicken + vegetables + egg',
      icon: '🍖', type: ScheduleItemType.meal, calories: 680, protein: 50, carbs: 60, fat: 18,
    ),
    PlanTemplateItem(
      time: '22:30', title: 'Pre-bed casein',
      sub: 'Casein protein 30g + 200ml milk — 8h slow release overnight',
      icon: '🥤', type: ScheduleItemType.protein, calories: 230, protein: 32, carbs: 12, fat: 5,
    ),
    PlanTemplateItem(
      time: '23:00', title: 'Sleep — 8h minimum',
      sub: 'Muscle is built during sleep — non-negotiable',
      icon: '😴', type: ScheduleItemType.sleep, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
  ];

  static const List<PlanTemplateItem> planGymMaintenance = [
    PlanTemplateItem(
      time: '07:00', title: 'Wake up + hydrate',
      sub: '500ml water',
      icon: '💧', type: ScheduleItemType.water, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '07:30', title: 'Breakfast',
      sub: '3 eggs + 60g oats + 1 fruit + green tea',
      icon: '🍳', type: ScheduleItemType.meal, calories: 500, protein: 28, carbs: 52, fat: 18,
    ),
    PlanTemplateItem(
      time: '10:30', title: 'Snack',
      sub: 'Greek yogurt 150g + nuts',
      icon: '🥛', type: ScheduleItemType.snack, calories: 220, protein: 18, carbs: 12, fat: 10,
    ),
    PlanTemplateItem(
      time: '13:00', title: 'Lunch',
      sub: '1 cup rice + protein 150g + vegetables',
      icon: '🍛', type: ScheduleItemType.meal, calories: 580, protein: 40, carbs: 58, fat: 12,
    ),
    PlanTemplateItem(
      time: '17:00', title: 'Training — 60 min',
      sub: 'Strength or hybrid training — 4 days/week',
      icon: '🏋️', type: ScheduleItemType.workout, calories: 350, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '18:15', title: 'Post-workout shake',
      sub: 'Whey 30g + banana',
      icon: '🥤', type: ScheduleItemType.protein, calories: 240, protein: 30, carbs: 28, fat: 2,
    ),
    PlanTemplateItem(
      time: '20:00', title: 'Dinner',
      sub: 'Protein 150g + ½ cup rice + vegetables + olive oil',
      icon: '🥗', type: ScheduleItemType.meal, calories: 520, protein: 38, carbs: 42, fat: 16,
    ),
    PlanTemplateItem(
      time: '22:00', title: 'Pre-bed snack',
      sub: 'Cottage cheese or casein 25g',
      icon: '🥛', type: ScheduleItemType.snack, calories: 140, protein: 22, carbs: 5, fat: 4,
    ),
    PlanTemplateItem(
      time: '23:00', title: 'Sleep',
      sub: '7–8 hours',
      icon: '😴', type: ScheduleItemType.sleep, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
  ];

  static const List<PlanTemplateItem> planGymRecomp = [
    PlanTemplateItem(
      time: '07:00', title: 'Wake up + hydrate',
      sub: '500ml water + optional black coffee',
      icon: '💧', type: ScheduleItemType.water, calories: 5, protein: 0, carbs: 1, fat: 0,
    ),
    PlanTemplateItem(
      time: '07:30', title: 'Breakfast — high protein',
      sub: '4 egg whites + 1 whole egg + vegetables + 40g oats on training days',
      icon: '🍳', type: ScheduleItemType.meal, calories: 320, protein: 28, carbs: 30, fat: 10,
    ),
    PlanTemplateItem(
      time: '10:00', title: 'Mid-morning protein',
      sub: 'Whey 25g in water OR Greek yogurt 150g',
      icon: '🥤', type: ScheduleItemType.protein, calories: 150, protein: 25, carbs: 8, fat: 2,
    ),
    PlanTemplateItem(
      time: '13:00', title: 'Lunch — moderate carb',
      sub: '½ cup rice + 160g chicken or fish + large salad + olive oil',
      icon: '🍗', type: ScheduleItemType.meal, calories: 480, protein: 40, carbs: 36, fat: 14,
    ),
    PlanTemplateItem(
      time: '16:30', title: 'Pre-workout',
      sub: 'Banana + 15g whey — 45 min before training',
      icon: '⚡', type: ScheduleItemType.snack, calories: 170, protein: 16, carbs: 24, fat: 1,
    ),
    PlanTemplateItem(
      time: '17:30', title: 'Training — 60–75 min',
      sub: 'Strength training 5 days/week — progressive overload is key',
      icon: '🏋️', type: ScheduleItemType.workout, calories: 380, protein: 0, carbs: 0, fat: 0,
    ),
    PlanTemplateItem(
      time: '19:00', title: 'Post-workout shake',
      sub: 'Whey 35g + fast carbs immediately after training',
      icon: '🥤', type: ScheduleItemType.protein, calories: 240, protein: 35, carbs: 22, fat: 2,
    ),
    PlanTemplateItem(
      time: '20:30', title: 'Dinner — low carb',
      sub: '180g protein source + roasted vegetables + avocado — no starch',
      icon: '🥗', type: ScheduleItemType.meal, calories: 420, protein: 42, carbs: 14, fat: 18,
    ),
    PlanTemplateItem(
      time: '22:30', title: 'Casein before bed',
      sub: 'Casein 25g — anti-catabolic overnight',
      icon: '🥤', type: ScheduleItemType.protein, calories: 120, protein: 25, carbs: 3, fat: 1,
    ),
    PlanTemplateItem(
      time: '23:00', title: 'Sleep',
      sub: '8h — recomp requires optimal recovery',
      icon: '😴', type: ScheduleItemType.sleep, calories: 0, protein: 0, carbs: 0, fat: 0,
    ),
  ];
}

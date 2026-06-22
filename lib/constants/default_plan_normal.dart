// ─────────────────────────────────────────────────────────────
// Consistent — unified daily routine
//
// One desk-worker + evening-gym (6:30–8 PM) routine, used for every
// plan profile. Water intake items are preserved throughout the day.
// Calorie targets still differ per profile (computed from BMI/goal),
// so the same routine adapts automatically via the targets, while the
// schedule structure stays identical for everyone.
// ─────────────────────────────────────────────────────────────

const List<Map<String, dynamic>> consistentDailyPlan = [
  {
    'time': '07:00', 'title': 'Wake up + hydrate',
    'sub': '500ml water immediately on waking — start the day hydrated',
    'icon': '💧', 'type': 'water', 'calories': 0.0, 'protein': 0.0, 'carbs': 0.0, 'fat': 0.0,
  },
  {
    'time': '07:15', 'title': 'Breakfast — Wake Up & Fuel',
    'sub': 'Samaposha 4–5 tbsp + 1 tbsp peanut butter (go easy on the sugar) + 2 boiled eggs. '
        'Alt: 2 slices whole wheat bread + peanut butter + 2 boiled eggs. '
        'Drink: water, or tea/coffee with zero sugar and a splash of milk.',
    'icon': '🥣', 'type': 'meal', 'calories': 420.0, 'protein': 24.0, 'carbs': 38.0, 'fat': 20.0,
  },
  {
    'time': '09:30', 'title': 'Mid-morning water',
    'sub': '250ml water',
    'icon': '💧', 'type': 'water', 'calories': 0.0, 'protein': 0.0, 'carbs': 0.0, 'fat': 0.0,
  },
  {
    'time': '12:30', 'title': 'Pre-lunch water',
    'sub': '300ml water before lunch',
    'icon': '💧', 'type': 'water', 'calories': 0.0, 'protein': 0.0, 'carbs': 0.0, 'fat': 0.0,
  },
  {
    'time': '13:00', 'title': 'Lunch — Desk-Worker Lunch',
    'sub': '1 cup red rice + Jaffna vegetable curries (keerai, poriyal) + a solid portion of '
        'fish curry, chicken, or paruppu (dhal) for protein. Keep the rice controlled.',
    'icon': '🍛', 'type': 'meal', 'calories': 520.0, 'protein': 35.0, 'carbs': 60.0, 'fat': 14.0,
  },
  {
    'time': '15:30', 'title': 'Afternoon water',
    'sub': '250ml water — replace the afternoon tea/soda habit',
    'icon': '💧', 'type': 'water', 'calories': 0.0, 'protein': 0.0, 'carbs': 0.0, 'fat': 0.0,
  },
  {
    'time': '18:00', 'title': 'Pre-Gym Ignition',
    'sub': '30–45 min before workout: 1 banana OR a handful of roasted peanuts / chickpeas (kadalai). '
        'Quick glycogen so you can actually lift after a day at the desk.',
    'icon': '🍌', 'type': 'snack', 'calories': 120.0, 'protein': 3.0, 'carbs': 27.0, 'fat': 2.0,
  },
  {
    'time': '18:30', 'title': 'Gym Session (6:30–8 PM)',
    'sub': 'Strength training. Keep drinking water during the session — aim to finish at least '
        '1 litre across this window.',
    'icon': '🏋️', 'type': 'workout', 'calories': 350.0, 'protein': 0.0, 'carbs': 0.0, 'fat': 0.0,
  },
  {
    'time': '20:00', 'title': 'Post-gym hydrate',
    'sub': '400ml water after your session',
    'icon': '💧', 'type': 'water', 'calories': 0.0, 'protein': 0.0, 'carbs': 0.0, 'fat': 0.0,
  },
  {
    'time': '21:00', 'title': 'Post-Gym Recovery Dinner',
    'sub': 'Muscles need building blocks — not just salad. '
        'Option A: large bowl of Jaffna chickpea/egg salad (boiled chana or 2 chopped boiled eggs '
        'with onion, green chili, tomato, lime, cucumber). '
        'Option B: 2 wheat rottis + Jaffna fish curry or dhal curry.',
    'icon': '🥗', 'type': 'meal', 'calories': 430.0, 'protein': 30.0, 'carbs': 35.0, 'fat': 16.0,
  },
  {
    'time': '21:30', 'title': 'Kitchen closes — no food after this',
    'sub': 'Hard stop at 9:30 PM. Water or unsweetened green tea only from here.',
    'icon': '🚫', 'type': 'custom', 'calories': 0.0, 'protein': 0.0, 'carbs': 0.0, 'fat': 0.0,
  },
  {
    'time': '22:00', 'title': 'Late-night coding — hydration only',
    'sub': 'Keep a 1L bottle of plain water or unsweetened green tea at the desk. '
        'Your brain will crave sugar — zero nighttime snacking.',
    'icon': '💧', 'type': 'water', 'calories': 0.0, 'protein': 0.0, 'carbs': 0.0, 'fat': 0.0,
  },
  {
    'time': '23:30', 'title': 'Sleep',
    'sub': 'Target 7–8 hours — recovery is when the gym work pays off',
    'icon': '😴', 'type': 'sleep', 'calories': 0.0, 'protein': 0.0, 'carbs': 0.0, 'fat': 0.0,
  },
];

// Every normal-mode profile uses the same unified routine.
const List<Map<String, dynamic>> planNormalUnderweight = consistentDailyPlan;
const List<Map<String, dynamic>> planNormalHealthy = consistentDailyPlan;
const List<Map<String, dynamic>> planNormalOverweight = consistentDailyPlan;
const List<Map<String, dynamic>> planNormalObese = consistentDailyPlan;

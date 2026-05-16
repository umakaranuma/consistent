/// Exercise database with muscle groups, descriptions, and reference images.
class ExerciseDatabase {
  static const List<Map<String, dynamic>> exercises = [
    // --- LEGS ---
    {'id': 'ex_squat', 'name': 'Barbell Squat', 'muscle': 'Legs', 'target': 'Quads, Glutes',
     'sets': '4x8-12', 'desc': 'King of leg exercises. Keep back straight, go below parallel.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Squat/0.jpg'},
    {'id': 'ex_legpress', 'name': 'Leg Press', 'muscle': 'Legs', 'target': 'Quads, Hamstrings',
     'sets': '4x10-12', 'desc': 'Place feet shoulder-width apart. Don\'t lock knees at top.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Calf_Press_On_The_Leg_Press_Machine/0.jpg'},
    {'id': 'ex_lunge', 'name': 'Walking Lunges', 'muscle': 'Legs', 'target': 'Quads, Glutes',
     'sets': '3x12 each', 'desc': 'Step forward, lower knee to ground. Keep torso upright.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Walking_Lunge/0.jpg'},
    {'id': 'ex_legcurl', 'name': 'Leg Curls', 'muscle': 'Legs', 'target': 'Hamstrings',
     'sets': '3x12-15', 'desc': 'Lying or seated. Slow controlled movement.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Lying_Leg_Curls/0.jpg'},
    {'id': 'ex_calfr', 'name': 'Calf Raises', 'muscle': 'Legs', 'target': 'Calves',
     'sets': '4x15-20', 'desc': 'Standing or seated. Full stretch at bottom, squeeze at top.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Standing_Calf_Raises/0.jpg'},
    {'id': 'ex_legext', 'name': 'Leg Extensions', 'muscle': 'Legs', 'target': 'Quads',
     'sets': '3x12-15', 'desc': 'Isolation exercise for quad definition. Don\'t use momentum.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Leg_Extensions/0.jpg'},

    // --- ABS ---
    {'id': 'ex_crunch', 'name': 'Crunches', 'muscle': 'Abs', 'target': 'Upper Abs',
     'sets': '3x20', 'desc': 'Curl shoulders off floor. Don\'t pull neck with hands.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Crunches/0.jpg'},
    {'id': 'ex_plank', 'name': 'Plank Hold', 'muscle': 'Abs', 'target': 'Core',
     'sets': '3x45-60s', 'desc': 'Keep body straight. Engage core, don\'t let hips sag.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Plank/0.jpg'},
    {'id': 'ex_legraise', 'name': 'Hanging Leg Raises', 'muscle': 'Abs', 'target': 'Lower Abs',
     'sets': '3x12-15', 'desc': 'Hang from bar, raise legs to 90 degrees. Control the descent.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Hanging_Leg_Raise/0.jpg'},
    {'id': 'ex_russtwist', 'name': 'Russian Twists', 'muscle': 'Abs', 'target': 'Obliques',
     'sets': '3x20', 'desc': 'Sit with feet elevated, twist side to side with weight.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Cable_Russian_Twists/0.jpg'},
    {'id': 'ex_mtnclimb', 'name': 'Mountain Climbers', 'muscle': 'Abs', 'target': 'Core, Cardio',
     'sets': '3x30s', 'desc': 'Plank position, drive knees to chest alternately.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Mountain_Climbers/0.jpg'},

    // --- CHEST ---
    {'id': 'ex_bench', 'name': 'Bench Press', 'muscle': 'Chest', 'target': 'Chest, Triceps',
     'sets': '4x8-10', 'desc': 'Plant feet, arch back slightly. Lower bar to mid-chest.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Bench_Press_-_Medium_Grip/0.jpg'},
    {'id': 'ex_incdb', 'name': 'Incline Dumbbell Press', 'muscle': 'Chest', 'target': 'Upper Chest',
     'sets': '4x10-12', 'desc': '30-45 degree incline. Press dumbbells up and together.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Incline_Dumbbell_Press/0.jpg'},
    {'id': 'ex_cablefly', 'name': 'Cable Flyes', 'muscle': 'Chest', 'target': 'Inner Chest',
     'sets': '3x12-15', 'desc': 'Slight bend in elbows. Squeeze chest at the peak.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Cable_Crossover/0.jpg'},
    {'id': 'ex_pushup', 'name': 'Push-ups', 'muscle': 'Chest', 'target': 'Chest, Triceps',
     'sets': '3x15-20', 'desc': 'Full range of motion. Keep core tight throughout.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Plyo_Kettlebell_Pushups/0.jpg'},
    {'id': 'ex_dips', 'name': 'Chest Dips', 'muscle': 'Chest', 'target': 'Lower Chest',
     'sets': '3x10-12', 'desc': 'Lean forward slightly. Go deep for chest activation.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dips_-_Chest_Version/0.jpg'},

    // --- BICEPS ---
    {'id': 'ex_bbcurl', 'name': 'Barbell Curls', 'muscle': 'Biceps', 'target': 'Biceps',
     'sets': '4x10-12', 'desc': 'Keep elbows pinned to sides. Full stretch at bottom.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Curl/0.jpg'},
    {'id': 'ex_hamcurl', 'name': 'Hammer Curls', 'muscle': 'Biceps', 'target': 'Brachialis',
     'sets': '3x12', 'desc': 'Neutral grip. Builds arm thickness.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Cable_Hammer_Curls_-_Rope_Attachment/0.jpg'},
    {'id': 'ex_conccurl', 'name': 'Concentration Curls', 'muscle': 'Biceps', 'target': 'Bicep Peak',
     'sets': '3x12 each', 'desc': 'Seated, elbow on inner thigh. Squeeze at top.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Concentration_Curls/0.jpg'},
    {'id': 'ex_preacher', 'name': 'Preacher Curls', 'muscle': 'Biceps', 'target': 'Lower Bicep',
     'sets': '3x10-12', 'desc': 'Use preacher bench. Control the negative.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Cable_Preacher_Curl/0.jpg'},

    // --- BACK ---
    {'id': 'ex_deadlift', 'name': 'Deadlifts', 'muscle': 'Back', 'target': 'Lower Back, Hamstrings',
     'sets': '4x6-8', 'desc': 'Hinge at hips. Keep bar close to body. Flat back.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Deadlift/0.jpg'},
    {'id': 'ex_latpull', 'name': 'Lat Pulldown', 'muscle': 'Back', 'target': 'Lats',
     'sets': '4x10-12', 'desc': 'Wide grip. Pull to upper chest. Squeeze shoulder blades.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Wide-Grip_Lat_Pulldown/0.jpg'},
    {'id': 'ex_bentrow', 'name': 'Bent Over Rows', 'muscle': 'Back', 'target': 'Mid Back',
     'sets': '4x8-10', 'desc': 'Hinge forward 45 degrees. Pull bar to lower chest.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Bent_Over_Barbell_Row/0.jpg'},
    {'id': 'ex_pullup', 'name': 'Pull-ups', 'muscle': 'Back', 'target': 'Lats, Biceps',
     'sets': '3xMax', 'desc': 'Full dead hang at bottom. Chin over bar at top.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pullups/0.jpg'},
    {'id': 'ex_cablerow', 'name': 'Seated Cable Rows', 'muscle': 'Back', 'target': 'Mid Back',
     'sets': '3x12', 'desc': 'Pull handle to lower chest. Keep back straight.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Seated_Cable_Rows/0.jpg'},

    // --- TRICEPS ---
    {'id': 'ex_tricpush', 'name': 'Tricep Pushdown', 'muscle': 'Triceps', 'target': 'Triceps',
     'sets': '4x12-15', 'desc': 'Keep elbows pinned. Fully extend at bottom.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Grip_Triceps_Pushdown/0.jpg'},
    {'id': 'ex_skull', 'name': 'Skull Crushers', 'muscle': 'Triceps', 'target': 'Long Head',
     'sets': '3x10-12', 'desc': 'Lower bar to forehead. Keep elbows narrow.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Lying_Triceps_Press/0.jpg'},
    {'id': 'ex_tricdip', 'name': 'Tricep Dips', 'muscle': 'Triceps', 'target': 'Triceps',
     'sets': '3x12-15', 'desc': 'Keep torso upright. Elbows close to body.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dips_-_Triceps_Version/0.jpg'},
    {'id': 'ex_overhead', 'name': 'Overhead Extension', 'muscle': 'Triceps', 'target': 'Long Head',
     'sets': '3x12', 'desc': 'Dumbbell behind head. Extend arms fully overhead.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Seated_Triceps_Press/0.jpg'},

    // --- SHOULDERS ---
    {'id': 'ex_ohp', 'name': 'Overhead Press', 'muscle': 'Shoulders', 'target': 'Front Delts',
     'sets': '4x8-10', 'desc': 'Press bar overhead. Lock out at top. Brace core.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Standing_Military_Press/0.jpg'},
    {'id': 'ex_latraise', 'name': 'Lateral Raises', 'muscle': 'Shoulders', 'target': 'Side Delts',
     'sets': '4x15', 'desc': 'Raise dumbbells to shoulder height. Slight bend in elbows.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Seated_Side_Lateral_Raise/0.jpg'},
    {'id': 'ex_frontraise', 'name': 'Front Raises', 'muscle': 'Shoulders', 'target': 'Front Delts',
     'sets': '3x12', 'desc': 'Raise dumbbells in front to shoulder height.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dumbbell_Raise/0.jpg'},
    {'id': 'ex_facepull', 'name': 'Face Pulls', 'muscle': 'Shoulders', 'target': 'Rear Delts',
     'sets': '4x15', 'desc': 'Pull rope to face height. Squeeze rear delts.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Face_Pull/0.jpg'},
    {'id': 'ex_shrug', 'name': 'Barbell Shrugs', 'muscle': 'Shoulders', 'target': 'Traps',
     'sets': '3x12-15', 'desc': 'Shrug shoulders straight up. Hold at top.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Shrug/0.jpg'},

    // --- CARDIO ---
    {'id': 'ex_run', 'name': 'Running', 'muscle': 'Cardio', 'target': 'Endurance',
     'sets': '20-30 min', 'desc': 'Moderate pace. Keep heart rate at 60-70% max.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Running_Treadmill/0.jpg'},
    {'id': 'ex_jumprope', 'name': 'Jump Rope', 'muscle': 'Cardio', 'target': 'Full Body',
     'sets': '5x2 min', 'desc': 'Light bounces. Wrists do the work, not arms.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Rope_Jumping/0.jpg'},
    {'id': 'ex_burpee', 'name': 'Burpees', 'muscle': 'Cardio', 'target': 'Full Body',
     'sets': '4x10', 'desc': 'Squat, jump back, push-up, jump up. Full explosion.',
     'image': 'https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=400&h=300&fit=crop'},
    {'id': 'ex_rowing', 'name': 'Rowing Machine', 'muscle': 'Cardio', 'target': 'Back, Legs',
     'sets': '15-20 min', 'desc': 'Drive with legs first, then pull with arms.',
     'image': 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Rowing_Stationary/0.jpg'},
  ];

  /// Get exercises for a specific muscle group
  static List<Map<String, dynamic>> getByMuscle(String muscle) {
    return exercises.where((e) => e['muscle'] == muscle).toList();
  }

  /// Get exercises for multiple muscle groups
  static List<Map<String, dynamic>> getByMuscles(List<String> muscles) {
    return exercises.where((e) => muscles.contains(e['muscle'])).toList();
  }

  /// Search exercises by name or muscle
  static List<Map<String, dynamic>> search(String query) {
    final q = query.toLowerCase();
    return exercises.where((e) =>
      (e['name'] as String).toLowerCase().contains(q) ||
      (e['muscle'] as String).toLowerCase().contains(q) ||
      (e['target'] as String).toLowerCase().contains(q)
    ).toList();
  }
}

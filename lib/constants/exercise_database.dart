/// Exercise database with muscle groups, descriptions, and reference images.
class ExerciseDatabase {
  static const List<Map<String, dynamic>> exercises = [
    // --- LEGS ---
    {'id': 'ex_squat', 'name': 'Barbell Squat', 'muscle': 'Legs', 'target': 'Quads, Glutes',
     'sets': '4x8-12', 'desc': 'King of leg exercises. Keep back straight, go below parallel.',
     'image': 'https://images.unsplash.com/photo-1566241142559-40e1dab266c6?w=400&h=300&fit=crop'},
    {'id': 'ex_legpress', 'name': 'Leg Press', 'muscle': 'Legs', 'target': 'Quads, Hamstrings',
     'sets': '4x10-12', 'desc': 'Place feet shoulder-width apart. Don\'t lock knees at top.',
     'image': 'https://images.unsplash.com/photo-1434608519344-49d77a699e1d?w=400&h=300&fit=crop'},
    {'id': 'ex_lunge', 'name': 'Walking Lunges', 'muscle': 'Legs', 'target': 'Quads, Glutes',
     'sets': '3x12 each', 'desc': 'Step forward, lower knee to ground. Keep torso upright.',
     'image': 'https://images.unsplash.com/photo-1597452485669-2c7bb5fef90d?w=400&h=300&fit=crop'},
    {'id': 'ex_legcurl', 'name': 'Leg Curls', 'muscle': 'Legs', 'target': 'Hamstrings',
     'sets': '3x12-15', 'desc': 'Lying or seated. Slow controlled movement.',
     'image': 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400&h=300&fit=crop'},
    {'id': 'ex_calfr', 'name': 'Calf Raises', 'muscle': 'Legs', 'target': 'Calves',
     'sets': '4x15-20', 'desc': 'Standing or seated. Full stretch at bottom, squeeze at top.',
     'image': 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400&h=300&fit=crop'},
    {'id': 'ex_legext', 'name': 'Leg Extensions', 'muscle': 'Legs', 'target': 'Quads',
     'sets': '3x12-15', 'desc': 'Isolation exercise for quad definition. Don\'t use momentum.',
     'image': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&h=300&fit=crop'},

    // --- ABS ---
    {'id': 'ex_crunch', 'name': 'Crunches', 'muscle': 'Abs', 'target': 'Upper Abs',
     'sets': '3x20', 'desc': 'Curl shoulders off floor. Don\'t pull neck with hands.',
     'image': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop'},
    {'id': 'ex_plank', 'name': 'Plank Hold', 'muscle': 'Abs', 'target': 'Core',
     'sets': '3x45-60s', 'desc': 'Keep body straight. Engage core, don\'t let hips sag.',
     'image': 'https://images.unsplash.com/photo-1566241142559-40e1dab266c6?w=400&h=300&fit=crop'},
    {'id': 'ex_legraise', 'name': 'Hanging Leg Raises', 'muscle': 'Abs', 'target': 'Lower Abs',
     'sets': '3x12-15', 'desc': 'Hang from bar, raise legs to 90 degrees. Control the descent.',
     'image': 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=400&h=300&fit=crop'},
    {'id': 'ex_russtwist', 'name': 'Russian Twists', 'muscle': 'Abs', 'target': 'Obliques',
     'sets': '3x20', 'desc': 'Sit with feet elevated, twist side to side with weight.',
     'image': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&h=300&fit=crop'},
    {'id': 'ex_mtnclimb', 'name': 'Mountain Climbers', 'muscle': 'Abs', 'target': 'Core, Cardio',
     'sets': '3x30s', 'desc': 'Plank position, drive knees to chest alternately.',
     'image': 'https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=400&h=300&fit=crop'},

    // --- CHEST ---
    {'id': 'ex_bench', 'name': 'Bench Press', 'muscle': 'Chest', 'target': 'Chest, Triceps',
     'sets': '4x8-10', 'desc': 'Plant feet, arch back slightly. Lower bar to mid-chest.',
     'image': 'https://images.unsplash.com/photo-1534368786749-b63e05c90863?w=400&h=300&fit=crop'},
    {'id': 'ex_incdb', 'name': 'Incline Dumbbell Press', 'muscle': 'Chest', 'target': 'Upper Chest',
     'sets': '4x10-12', 'desc': '30-45 degree incline. Press dumbbells up and together.',
     'image': 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400&h=300&fit=crop'},
    {'id': 'ex_cablefly', 'name': 'Cable Flyes', 'muscle': 'Chest', 'target': 'Inner Chest',
     'sets': '3x12-15', 'desc': 'Slight bend in elbows. Squeeze chest at the peak.',
     'image': 'https://images.unsplash.com/photo-1571388208497-71bedc66e932?w=400&h=300&fit=crop'},
    {'id': 'ex_pushup', 'name': 'Push-ups', 'muscle': 'Chest', 'target': 'Chest, Triceps',
     'sets': '3x15-20', 'desc': 'Full range of motion. Keep core tight throughout.',
     'image': 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=400&h=300&fit=crop'},
    {'id': 'ex_dips', 'name': 'Chest Dips', 'muscle': 'Chest', 'target': 'Lower Chest',
     'sets': '3x10-12', 'desc': 'Lean forward slightly. Go deep for chest activation.',
     'image': 'https://images.unsplash.com/photo-1597452485669-2c7bb5fef90d?w=400&h=300&fit=crop'},

    // --- BICEPS ---
    {'id': 'ex_bbcurl', 'name': 'Barbell Curls', 'muscle': 'Biceps', 'target': 'Biceps',
     'sets': '4x10-12', 'desc': 'Keep elbows pinned to sides. Full stretch at bottom.',
     'image': 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400&h=300&fit=crop'},
    {'id': 'ex_hamcurl', 'name': 'Hammer Curls', 'muscle': 'Biceps', 'target': 'Brachialis',
     'sets': '3x12', 'desc': 'Neutral grip. Builds arm thickness.',
     'image': 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400&h=300&fit=crop'},
    {'id': 'ex_conccurl', 'name': 'Concentration Curls', 'muscle': 'Biceps', 'target': 'Bicep Peak',
     'sets': '3x12 each', 'desc': 'Seated, elbow on inner thigh. Squeeze at top.',
     'image': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&h=300&fit=crop'},
    {'id': 'ex_preacher', 'name': 'Preacher Curls', 'muscle': 'Biceps', 'target': 'Lower Bicep',
     'sets': '3x10-12', 'desc': 'Use preacher bench. Control the negative.',
     'image': 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400&h=300&fit=crop'},

    // --- BACK ---
    {'id': 'ex_deadlift', 'name': 'Deadlifts', 'muscle': 'Back', 'target': 'Lower Back, Hamstrings',
     'sets': '4x6-8', 'desc': 'Hinge at hips. Keep bar close to body. Flat back.',
     'image': 'https://images.unsplash.com/photo-1517963879433-6ad2b056d712?w=400&h=300&fit=crop'},
    {'id': 'ex_latpull', 'name': 'Lat Pulldown', 'muscle': 'Back', 'target': 'Lats',
     'sets': '4x10-12', 'desc': 'Wide grip. Pull to upper chest. Squeeze shoulder blades.',
     'image': 'https://images.unsplash.com/photo-1534368786749-b63e05c90863?w=400&h=300&fit=crop'},
    {'id': 'ex_bentrow', 'name': 'Bent Over Rows', 'muscle': 'Back', 'target': 'Mid Back',
     'sets': '4x8-10', 'desc': 'Hinge forward 45 degrees. Pull bar to lower chest.',
     'image': 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400&h=300&fit=crop'},
    {'id': 'ex_pullup', 'name': 'Pull-ups', 'muscle': 'Back', 'target': 'Lats, Biceps',
     'sets': '3xMax', 'desc': 'Full dead hang at bottom. Chin over bar at top.',
     'image': 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=400&h=300&fit=crop'},
    {'id': 'ex_cablerow', 'name': 'Seated Cable Rows', 'muscle': 'Back', 'target': 'Mid Back',
     'sets': '3x12', 'desc': 'Pull handle to lower chest. Keep back straight.',
     'image': 'https://images.unsplash.com/photo-1571388208497-71bedc66e932?w=400&h=300&fit=crop'},

    // --- TRICEPS ---
    {'id': 'ex_tricpush', 'name': 'Tricep Pushdown', 'muscle': 'Triceps', 'target': 'Triceps',
     'sets': '4x12-15', 'desc': 'Keep elbows pinned. Fully extend at bottom.',
     'image': 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400&h=300&fit=crop'},
    {'id': 'ex_skull', 'name': 'Skull Crushers', 'muscle': 'Triceps', 'target': 'Long Head',
     'sets': '3x10-12', 'desc': 'Lower bar to forehead. Keep elbows narrow.',
     'image': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&h=300&fit=crop'},
    {'id': 'ex_tricdip', 'name': 'Tricep Dips', 'muscle': 'Triceps', 'target': 'Triceps',
     'sets': '3x12-15', 'desc': 'Keep torso upright. Elbows close to body.',
     'image': 'https://images.unsplash.com/photo-1597452485669-2c7bb5fef90d?w=400&h=300&fit=crop'},
    {'id': 'ex_overhead', 'name': 'Overhead Extension', 'muscle': 'Triceps', 'target': 'Long Head',
     'sets': '3x12', 'desc': 'Dumbbell behind head. Extend arms fully overhead.',
     'image': 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400&h=300&fit=crop'},

    // --- SHOULDERS ---
    {'id': 'ex_ohp', 'name': 'Overhead Press', 'muscle': 'Shoulders', 'target': 'Front Delts',
     'sets': '4x8-10', 'desc': 'Press bar overhead. Lock out at top. Brace core.',
     'image': 'https://images.unsplash.com/photo-1534368786749-b63e05c90863?w=400&h=300&fit=crop'},
    {'id': 'ex_latraise', 'name': 'Lateral Raises', 'muscle': 'Shoulders', 'target': 'Side Delts',
     'sets': '4x15', 'desc': 'Raise dumbbells to shoulder height. Slight bend in elbows.',
     'image': 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400&h=300&fit=crop'},
    {'id': 'ex_frontraise', 'name': 'Front Raises', 'muscle': 'Shoulders', 'target': 'Front Delts',
     'sets': '3x12', 'desc': 'Raise dumbbells in front to shoulder height.',
     'image': 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400&h=300&fit=crop'},
    {'id': 'ex_facepull', 'name': 'Face Pulls', 'muscle': 'Shoulders', 'target': 'Rear Delts',
     'sets': '4x15', 'desc': 'Pull rope to face height. Squeeze rear delts.',
     'image': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&h=300&fit=crop'},
    {'id': 'ex_shrug', 'name': 'Barbell Shrugs', 'muscle': 'Shoulders', 'target': 'Traps',
     'sets': '3x12-15', 'desc': 'Shrug shoulders straight up. Hold at top.',
     'image': 'https://images.unsplash.com/photo-1517963879433-6ad2b056d712?w=400&h=300&fit=crop'},

    // --- CARDIO ---
    {'id': 'ex_run', 'name': 'Running', 'muscle': 'Cardio', 'target': 'Endurance',
     'sets': '20-30 min', 'desc': 'Moderate pace. Keep heart rate at 60-70% max.',
     'image': 'https://images.unsplash.com/photo-1571008887538-b36bb32f4571?w=400&h=300&fit=crop'},
    {'id': 'ex_jumprope', 'name': 'Jump Rope', 'muscle': 'Cardio', 'target': 'Full Body',
     'sets': '5x2 min', 'desc': 'Light bounces. Wrists do the work, not arms.',
     'image': 'https://images.unsplash.com/photo-1434608519344-49d77a699e1d?w=400&h=300&fit=crop'},
    {'id': 'ex_burpee', 'name': 'Burpees', 'muscle': 'Cardio', 'target': 'Full Body',
     'sets': '4x10', 'desc': 'Squat, jump back, push-up, jump up. Full explosion.',
     'image': 'https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=400&h=300&fit=crop'},
    {'id': 'ex_rowing', 'name': 'Rowing Machine', 'muscle': 'Cardio', 'target': 'Back, Legs',
     'sets': '15-20 min', 'desc': 'Drive with legs first, then pull with arms.',
     'image': 'https://images.unsplash.com/photo-1519505907962-0a6cb0167c73?w=400&h=300&fit=crop'},
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

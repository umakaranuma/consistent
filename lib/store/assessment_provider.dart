import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'types.dart';

class AssessmentData {
  String name = '';
  AppMode mode = AppMode.normal;
  String gender = 'male';
  double age = 25;
  double heightCm = 170;
  double currentWeight = 70;
  double goalWeight = 65;
  GymGoal? gymGoal;
  String activityLevel = 'moderate';

  AssessmentData();
}

final assessmentProvider = StateProvider<AssessmentData>(
  (ref) => AssessmentData(),
);

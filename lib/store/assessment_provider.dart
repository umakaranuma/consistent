import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'types.dart';

/// Temporary data holder during onboarding assessment flow.
/// Not used after onboarding is complete — data is committed to appProvider.
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

class AssessmentNotifier extends Notifier<AssessmentData> {
  @override
  AssessmentData build() => AssessmentData();

  void update(AssessmentData data) => state = data;
}

final assessmentProvider = NotifierProvider<AssessmentNotifier, AssessmentData>(
  () => AssessmentNotifier(),
);

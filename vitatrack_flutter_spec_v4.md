# VitaTrack — Complete Application Specification v4.0

> **For AI coding agents (Cursor, Windsurf, Copilot, Claude Code):**
> This is the single source of truth. Read every section before generating any code.
> This app is built exclusively in **Flutter (Dart)** with **Firebase** backend.
> Do NOT generate any React Native, Expo, TypeScript, or JavaScript code.
> Do not deviate from these specs. All screens, flows, data models, diet logic,
> BMI engine, water notification system, and gym mode are fully defined here.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack & Project Structure](#2-tech-stack--project-structure)
3. [Design Tokens](#3-design-tokens)
4. [Navigation Architecture](#4-navigation-architecture)
5. [Data Models](#5-data-models)
6. [BMI Engine & Diet Plan Auto-generation](#6-bmi-engine--diet-plan-auto-generation)
7. [Normal Mode — Diet Plans](#7-normal-mode--diet-plans)
8. [Gym Mode — Diet Plans](#8-gym-mode--diet-plans)
9. [Water Intake Engine](#9-water-intake-engine)
10. [Onboarding Flow](#10-onboarding-flow)
11. [Screen Specifications](#11-screen-specifications)
    - 11.1 [Today Screen](#111-today-screen)
    - 11.2 [Calendar Screen](#112-calendar-screen)
    - 11.3 [Reminders Screen](#113-reminders-screen)
    - 11.4 [Profile & Settings Screen](#114-profile--settings-screen)
12. [Modals & Bottom Sheets](#12-modals--bottom-sheets)
13. [Components Library](#13-components-library)
14. [Notification System — Full Spec](#14-notification-system--full-spec)
15. [State Management](#15-state-management)
16. [Storage Schema](#16-storage-schema)
17. [Animations & Micro-interactions](#17-animations--micro-interactions)
18. [Implementation Order](#18-implementation-order)

---

## 1. Project Overview

**App name:** VitaTrack
**Full store name:** VitaTrack: Daily Health Planner
**Bundle ID:** com.vitatrack.app
**Platform:** iOS & Android — Flutter (Dart)
**Theme:** Dark only — deep navy/dark purple, soft violet accent
**Auth:** Firebase Anonymous Auth on first launch; optional Google Sign-In for cross-device sync

### Core Features

| Feature | Description |
|---|---|
| Two modes | Normal (general lifestyle) and Gym (athlete/bodybuilder) — toggled in profile |
| BMI engine | Calculated from height + weight; updates live when weight is logged |
| Auto diet plan | Plan generated from BMI category + mode; fully editable by user |
| Water intake engine | Daily target from bodyweight; customisable interval; smart push notifications |
| Water notification | User sets how many ml per reminder and interval; fired during waking hours only |
| Weight log | Log weight any time; BMI recalculates; diet plan adjusts if BMI category changes |
| Meal planner | Full timestamped plan; per-item calories, protein, carbs, fat; tap-to-complete |
| Reminders | Per-item bell + standalone manager; smart schedule-aware alerts |
| Calendar | Month grid with success/partial/failed coding; weight trend chart |
| Progress | Monthly ratio bars + ring charts |
| Profile & settings | All user data editable post-onboarding |

---

## 2. Tech Stack & Project Structure

```
Framework:        Flutter (Dart) — SDK >=3.0.0
Backend:          Firebase (Firestore, Auth, Cloud Messaging, Analytics)
Local storage:    Hive 2.x (offline-first; Firestore sync in background)
State management: Riverpod 2.x (StateNotifierProvider + Provider)
Navigation:       GoRouter 13.x
Charts:           fl_chart 0.67.x
Notifications:    flutter_local_notifications 17.x + firebase_messaging 14.x
Background tasks: workmanager 0.5.x (midnight reset)
UUID:             uuid 4.x
Date handling:    intl 0.19.x
Permissions:      permission_handler 11.x
```

### Project Structure

```
lib/
├── app/
│   ├── _layout.dart                      ← Root: onboarding gate + tab navigator
│   └── screens/
│       ├── OnboardingScreen.dart
│       ├── TodayScreen.dart
│       ├── CalendarScreen.dart
│       ├── RemindersScreen.dart
│       └── ProfileScreen.dart
│
├── components/
│   ├── ScoreCard.dart
│   ├── ScoreRow.dart
│   ├── CalorieCard.dart
│   ├── WaterCard.dart
│   ├── BmiCard.dart
│   ├── MacroCard.dart
│   ├── WeeklyWorkoutRow.dart
│   ├── ScheduleItem.dart
│   ├── CalendarGrid.dart
│   ├── WeightTrendChart.dart
│   ├── BmiTrendChart.dart
│   ├── RatioBar.dart
│   ├── RingChart.dart
│   ├── ReminderItem.dart
│   ├── ActivityLogList.dart
│   ├── SettingsRow.dart
│   ├── ToggleSwitch.dart
│   ├── FilterChip.dart
│   └── modals/
│       ├── BottomSheet.dart
│       ├── WaterTargetModal.dart
│       ├── WaterReminderModal.dart         ← NEW: full water notification configurator
│       ├── DietEditorModal.dart
│       ├── EditItemModal.dart
│       ├── AddReminderModal.dart
│       ├── EditProfileModal.dart
│       ├── WeightLogModal.dart
│       ├── BmiDetailModal.dart             ← NEW: BMI detail + history
│       ├── StepGoalModal.dart
│       ├── CalorieTargetModal.dart
│       ├── ReminderIntervalModal.dart
│       ├── UnitsModal.dart
│       ├── DayDetailModal.dart
│       └── ModeSwitchModal.dart            ← NEW: Normal ↔ Gym mode switcher
│
├── store/
│   ├── types.dart
│   └── useAppStore.dart
│
├── utils/
│   ├── bmiEngine.ts                       ← NEW: BMI + plan generation logic
│   ├── waterEngine.ts                     ← NEW: water target + notification schedule
│   ├── notifications.dart
│   ├── calendarHelpers.dart
│   ├── calorieHelpers.dart
│   └── dateHelpers.dart
│
└── constants/
    ├── colors.dart
    ├── typography.dart
    ├── spacing.dart
    ├── defaultPlanNormal.ts               ← Normal mode plans (by BMI tier)
    └── defaultPlanGym.ts                  ← Gym mode plans (by goal)
```

---

## 3. Design Tokens

### Colours (`lib/constants/colors.ts`)

```dart
const Colors = {
  bg0:        '#080810',
  bg1:        '#0C0C1A',
  bg2:        '#13132A',
  bg3:        '#1E1E3A',
  bg4:        '#1A1A35',

  border1:    '#1E1E3A',
  border2:    '#2a2a55',

  accent:     '#6C63FF',
  accentSoft: '#9988FF',
  accentBg:   '#1A1A3A',

  green:      '#5DCAA5',
  greenDark:  '#082E18',
  amber:      '#EF9F27',
  amberDark:  '#2E1A08',
  red:        '#E24B4A',
  redDark:    '#2E0808',
  lavender:   '#AFA9EC',
  blue:       '#85B7EB',
  teal:       '#1D9E75',
  tealDark:   '#04342C',

  textPrimary:   '#DDDDDD',
  textSecondary: '#888888',
  textMuted:     '#444444',
  textDisabled:  '#333333',
  white:         '#FFFFFF',

  // BMI category colours
  bmiUnder:   '#85B7EB',   // Underweight — blue
  bmiNormal:  '#5DCAA5',   // Normal — green
  bmiOver:    '#EF9F27',   // Overweight — amber
  bmiObese:   '#E24B4A',   // Obese — red

  // Icon box backgrounds
  iconMeal:    '#0A2E1A',
  iconWater:   '#0D1235',
  iconWorkout: '#2E0D18',
  iconSnack:   '#1E1A08',
  iconSleep:   '#12082E',
  iconWalk:    '#082E2E',
  iconProtein: '#0D1A2E',
  iconCustom:  '#1A1A3A',
};

// // ScheduleItemType stored as String
enum ScheduleItemType { meal, water, workout, snack, sleep, walk, protein, custom }

iconBgByType(type: ScheduleItemType): String {
  final map = <String, Color>{
    meal:    Colors.iconMeal,
    water:   Colors.iconWater,
    workout: Colors.iconWorkout,
    snack:   Colors.iconSnack,
    sleep:   Colors.iconSleep,
    walk:    Colors.iconWalk,
    protein: Colors.iconProtein,
    custom:  Colors.iconCustom,
  };
  return map[type] ?? Colors.iconCustom;
}
```

### Typography & Spacing

```dart
// lib/constants/typography.dart
const Typography = {
  xs: 10, sm: 11, base: 12, md: 13, lg: 14, xl: 16, xxl: 18, h2: 21, h1: 24,
  regular: '400',
  medium:  '500',
  tight: 1.2, normal: 1.5, relaxed: 1.7,
};

// lib/constants/spacing.dart
const Spacing = { xs: 4, sm: 6, md: 10, lg: 14, xl: 16, xxl: 20, section: 24 };
const Radius  = { sm: 8, md: 10, lg: 13, xl: 16, xxl: 20, pill: 99, full: 9999 };
```

---

## 4. Navigation Architecture

### Router (`lib/app/router.dart`)

```dart
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String routeOnboarding = '/onboarding';
const String routeToday      = '/today';
const String routeCalendar   = '/calendar';
const String routeReminders  = '/reminders';
const String routeProfile    = '/profile';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: routeToday,
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final onboarded = prefs.getString('vitatrack_onboarded');
      if (onboarded == null && state.matchedLocation != routeOnboarding) {
        return routeOnboarding;
      }
      return null;
    },
    routes: [
      GoRoute(path: routeOnboarding, builder: (c, s) => const OnboardingScreen()),
      ShellRoute(
        builder: (context, state, child) => MainTabScaffold(child: child),
        routes: [
          GoRoute(path: routeToday,     builder: (c, s) => const TodayScreen()),
          GoRoute(path: routeCalendar,  builder: (c, s) => const CalendarScreen()),
          GoRoute(path: routeReminders, builder: (c, s) => const RemindersScreen()),
          GoRoute(path: routeProfile,   builder: (c, s) => const ProfileScreen()),
        ],
      ),
    ],
  );
}
```

### Bottom Navigation

```dart
// MainTabScaffold uses BottomNavigationBar
// Tab 1 — Today      icon: Icons.grid_view_outlined / Icons.grid_view
// Tab 2 — Calendar   icon: Icons.calendar_today_outlined / Icons.calendar_today
// Tab 3 — Reminders  icon: Icons.notifications_outlined / Icons.notifications
// Tab 4 — Profile    icon: Icons.person_outline / Icons.person

BottomNavigationBar(
  backgroundColor: AppColors.bg1,
  selectedItemColor: AppColors.accent,
  unselectedItemColor: AppColors.textMuted,
  selectedFontSize: 9,
  unselectedFontSize: 9,
  type: BottomNavigationBarType.fixed,
  // Active tab shows a 4dp Container dot (AppColors.accent) centred below label
)
```

---

## 5. Data Models

### `AppMode`

```dart
// AppMode stored as String: 'normal' | 'gym'
enum AppMode { normal, gym }
```

### `BmiCategory`

```dart
// BmiCategory stored as String
enum BmiCategory { underweight, normal, overweight, obese }

// BMI thresholds
// < 18.5  → underweight
// 18.5–24.9 → normal
// 25–29.9   → overweight
// ≥ 30    → obese
```

### `GymGoal`

```dart
// GymGoal stored as String
enum GymGoal { fatLoss, muscleGain, maintenance, recomp }
```

### `ScheduleItemType`

```dart
// ScheduleItemType stored as String
enum ScheduleItemType { meal, water, workout, snack, sleep, walk, protein, custom }
```

### `ScheduleItem`

```dart
interface ScheduleItem {
  String id;
  String time;           // "HH:MM" 24h
  String title;
  String sub;           // description
  String icon;           // emoji
  String type;
  calories: double;           // kcal (0 for water/sleep/walk)
  double protein;           // grams (0 for non-protein items)
  double carbs;           // grams
  double fat;           // grams
  bool done;
  bool remOn;
  isCustom: bool;          // true if user added/significantly modified
}
```

### `MacroTargets`

```dart
interface MacroTargets {
  calories: double;
  double protein;   // grams
  double carbs;   // grams
  double fat;   // grams
}
```

### `WaterConfig`

```dart
interface WaterConfig {
  double consumed;   // ml consumed today
  double target;   // ml daily target
  bool reminderEnabled;
  reminderIntervalMinutes: double;  // e.g. 60, 90, 120
  String reminderStartTime;  // "HH:MM" — start of reminder window
  String reminderEndTime;  // "HH:MM" — end of reminder window
  double mlPerReminder;   // how many ml to drink each reminder (shown in notification body)
  // e.g. "Time to drink 300ml of water!"
}
```

### `WeightEntry`

```dart
interface WeightEntry {
  String date;   // "YYYY-MM-DD"
  weight: double;   // kg or lbs
  double bmi;   // calculated at time of logging
}
```

### `UserProfile`

```dart
interface UserProfile {
  String name;
  double heightCm;   // always stored in cm; displayed in cm or ft/in
  double currentWeight;   // kg or lbs depending on units
  double goalWeight;
  double bmi;   // recalculated every time weight changes
  String bmiCategory;
  String mode;
  String gymGoal;  // only relevant in gym mode
  double stepGoal;
  MacroTargets macroTargets;
  String units; // 'metric' | 'imperial'
  String workStartTime;   // "HH:MM"
  String workEndTime;
  String sleepTime;
  bool pushEnabled;
  workoutReminders: bool;
  bool sleepReminder;
  planLockedByUser: bool;  // true = user has manually edited plan; don't auto-regenerate
}
```

### `Reminder`

```dart
interface Reminder {
  String id;
  String title;
  String time;   // "HH:MM"
  type:     ScheduleItemType | 'custom';
  String repeat; // 'daily' | 'weekday' | 'once'
  bool enabled;
  notifId?: String;
}
```

### `DayRecord`

```dart
interface DayRecord {
  String date;     // "YYYY-MM-DD"
  status:         'success' | 'partial' | 'failed' | 'none';
  double dietScore;     // 0–100
  double waterScore;     // 0–100
  bool workoutDone;
  double calorieScore;     // 0–100
  double proteinScore;     // 0–100 (gym mode; 0 in normal mode)
  double waterConsumed;     // ml
  double caloriesEaten;     // kcal
  double proteinEaten;     // grams
  double bmiAtDay;     // BMI snapshot
  log:            LogEntry[];
}
```

### `LogEntry`

```dart
interface LogEntry {
  String time;   // "HH:MM"
  String message;
}
```

---

## 6. BMI Engine & Diet Plan Auto-generation

### `lib/services/bmiEngine.ts`

```dart
// ─── BMI Calculation ─────────────────────────────────────────────────────────

double calculateBmi(double weightKg, double heightCm) {
  const heightM = heightCm / 100;
  return Math.round((weightKg / (heightM * heightM)) * 10) / 10;
}

String getBmiCategory(double bmi) {
  if (bmi < 18.5) return 'underweight';
  if (bmi < 25)   return 'normal';
  if (bmi < 30)   return 'overweight';
  return 'obese';
}

String getBmiLabel(String cat) {
  return {
    underweight: 'Underweight',
    normal:      'Healthy weight',
    overweight:  'Overweight',
    obese:       'Obese',
  }[cat];
}

String getBmiColor(String cat) {
  return {
    underweight: Colors.bmiUnder,
    normal:      Colors.bmiNormal,
    overweight:  Colors.bmiOver,
    obese:       Colors.bmiObese,
  }[cat];
}

// ─── Ideal weight range (Devine formula + buffer) ────────────────────────────

Map<String, double> getIdealWeightRange(double heightCm) {
  // BMI 18.5–24.9 for this height
  const h = heightCm / 100;
  return {
    min: Math.round(18.5 * h * h * 10) / 10,
    max: Math.round(24.9 * h * h * 10) / 10,
  };
}

// ─── TDEE (Total Daily Energy Expenditure) ───────────────────────────────────
// Uses Mifflin-St Jeor BMR × activity multiplier

calculateTDEE(
  weightKg: double,
  heightCm: double,
  ageYears: double,
  gender: 'male' | 'female',
  activityLevel: 'sedentary' | 'light' | 'moderate' | 'active' | 'very_active'
): double {
  // BMR
  const bmr = gender === 'male'
    ? 10 * weightKg + 6.25 * heightCm - 5 * ageYears + 5
    : 10 * weightKg + 6.25 * heightCm - 5 * ageYears - 161;

  const multipliers = {
    sedentary:   1.2,
    light:       1.375,
    moderate:    1.55,
    active:      1.725,
    very_active: 1.9,
  };
  return Math.round(bmr * multipliers[activityLevel]);
}

// ─── Calorie target from TDEE + goal ─────────────────────────────────────────

getCalorieTarget(
  tdee: double,
  bmiCategory: BmiCategory,
  mode: AppMode,
  gymGoal?: GymGoal
): double {
  if (mode === 'gym') {
    switch (gymGoal) {
      case 'fat_loss':    return tdee - 500;   // 0.5kg/week loss
      case 'muscle_gain': return tdee + 300;   // lean bulk
      case 'maintenance': return tdee;
      case 'recomp':      return tdee - 200;   // slight deficit
      default:            return tdee - 300;
    }
  }
  // Normal mode
  switch (bmiCategory) {
    case 'underweight': return tdee + 200;   // mild surplus
    case 'normal':      return tdee - 100;   // slight deficit to maintain
    case 'overweight':  return tdee - 400;   // ~0.4kg/week loss
    case 'obese':       return tdee - 600;   // ~0.6kg/week loss
  }
}

// ─── Macro targets from calorie target ───────────────────────────────────────

getMacroTargets(
  calories: double,
  weightKg: double,
  mode: AppMode,
  gymGoal?: GymGoal
): MacroTargets {
  let proteinPerKg: double;
  if (mode === 'gym') {
    proteinPerKg = gymGoal === 'muscle_gain' ? 2.2 : 1.8;
  } else {
    proteinPerKg = 1.6;
  }
  const protein = Math.round(weightKg * proteinPerKg);
  const fat     = Math.round(calories * 0.25 / 9);
  const carbs   = Math.round((calories - protein * 4 - fat * 9) / 4);
  return { calories, protein, carbs, fat };
}

// ─── Water target from bodyweight ────────────────────────────────────────────
// Standard: 35ml per kg bodyweight; gym mode: 40ml per kg

int getWaterTarget(double weightKg, String mode) {
  const mlPerKg = mode === 'gym' ? 40 : 35;
  // Round to nearest 250ml for cleaner UX
  return Math.round((weightKg * mlPerKg) / 250) * 250;
}

// ─── Auto-generate plan from profile ─────────────────────────────────────────

List<ScheduleItem> generatePlan(UserProfile profile) {
  const { mode, bmiCategory, gymGoal, macroTargets } = profile;
  const weightKg = toKg(profile.currentWeight, profile.units);

  if (mode === 'gym') {
    return generateGymPlan(gymGoal, macroTargets, weightKg);
  }
  return generateNormalPlan(bmiCategory, macroTargets, weightKg);
}
```

### BMI Card Display Logic

The `BmiCard` component (shown on Today screen and Profile screen) displays:

```
┌──────────────────────────────────────────┐
│  BMI                            [Detail >]│
│                                           │
│  27.6          Overweight                 │
│  [████████████░░░░░░░░]  amber fill       │
│   ↑ your BMI                             │
│                                           │
│  Underweight  Normal  Overweight  Obese  │
│  <18.5       18.5-25   25-30      >30    │
│                                           │
│  Ideal range for your height:            │
│  59.2 – 79.7 kg                         │
│  You are 5.7 kg above healthy range     │
└──────────────────────────────────────────┘
```

- BMI value: 24px medium, coloured by category
- Category label: 13px medium, same colour
- Progress bar: 8px, track `bg3`, fill coloured by category
  - Scale: 15 (left edge) → 40 (right edge)
  - Position: `(bmi - 15) / 25 * 100`%, capped 0–100
- Threshold markers at 18.5, 25, 30 (tiny vertical tick marks on bar)
- "Ideal range" text: 11px `textMuted`
- "Difference" text: 11px, coloured by direction (green if in range, amber/red if over)
- `[Detail >]` opens BmiDetailModal

**BMI recalculation trigger:**
Every time `addWeightEntry()` is called:
1. Recalculate BMI
2. Update `profile.bmi` and `profile.bmiCategory`
3. If `bmiCategory` changed AND `profile.planLockedByUser === false`:
   - Regenerate plan via `generatePlan(profile)`
   - Show toast: "Your BMI category changed. Diet plan updated."
4. If `planLockedByUser === true`:
   - Recalculate macros only; update `profile.macroTargets`
   - Show toast: "BMI updated. Your custom plan is unchanged."

---

## 7. Normal Mode — Diet Plans

Four plans, one per BMI category. Each is the base template.
User can edit any item. Editing sets `item.isCustom = true` and `profile.planLockedByUser = true`.

### 7.1 Underweight Plan (BMI < 18.5)

**Goal:** Healthy weight gain. Calorie surplus ~200 kcal above TDEE.
**Focus:** High protein, complex carbs, healthy fats. 4–5 meals/day.

```dart
const planNormalUnderweight: List<Map<String,dynamic>> = [
  {
    time: '07:00', title: 'Wake up + hydrate',
    sub: '500ml water immediately on waking',
    icon: '💧', type: 'water', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '07:30', title: 'Breakfast — calorie dense',
    sub: '3 whole eggs + 2 slices whole wheat toast + 1 banana + peanut butter',
    icon: '🍳', type: 'meal', calories: 580, protein: 28, carbs: 55, fat: 24,
  },
  {
    time: '10:00', title: 'Mid-morning snack',
    sub: 'Handful of mixed nuts + 1 glass full-fat milk',
    icon: '🥛', type: 'snack', calories: 300, protein: 12, carbs: 20, fat: 18,
  },
  {
    time: '13:00', title: 'Lunch — balanced',
    sub: '1.5 cups rice + dhal curry + fish or chicken + vegetables',
    icon: '🍛', type: 'meal', calories: 650, protein: 35, carbs: 80, fat: 14,
  },
  {
    time: '15:30', title: 'Afternoon snack',
    sub: 'Banana + peanut butter on 2 crackers',
    icon: '🍌', type: 'snack', calories: 250, protein: 6, carbs: 40, fat: 8,
  },
  {
    time: '18:00', title: '30-min light exercise',
    sub: 'Walk or yoga — avoid heavy cardio when underweight',
    icon: '🚶', type: 'walk', calories: 150, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '19:00', title: 'Post-exercise hydrate',
    sub: '400ml water',
    icon: '💧', type: 'water', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '20:00', title: 'Dinner — protein rich',
    sub: 'Grilled chicken or fish + sweet potato + steamed vegetables',
    icon: '🍗', type: 'meal', calories: 550, protein: 40, carbs: 50, fat: 12,
  },
  {
    time: '22:00', title: 'Night snack',
    sub: '1 cup warm milk + 2 digestive biscuits',
    icon: '🍪', type: 'snack', calories: 220, protein: 8, carbs: 30, fat: 6,
  },
  {
    time: '23:30', title: 'Sleep',
    sub: '7–8 hours — critical for healthy weight gain',
    icon: '😴', type: 'sleep', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
];
// Total: ~2750 kcal · 129g protein · 275g carbs · 82g fat
```

### 7.2 Normal Weight Plan (BMI 18.5–24.9)

**Goal:** Maintain healthy weight. Slight deficit (~100 kcal) to stay lean.
**Focus:** Balanced macros. 3 meals + 2 snacks. Moderate exercise.

```dart
const planNormalHealthy: List<Map<String,dynamic>> = [
  {
    time: '07:00', title: 'Wake up + hydrate',
    sub: '500ml water on waking',
    icon: '💧', type: 'water', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '07:30', title: 'Breakfast',
    sub: '2 eggs + 1 slice whole wheat toast + 1 fruit + black coffee or green tea',
    icon: '🍳', type: 'meal', calories: 380, protein: 22, carbs: 35, fat: 14,
  },
  {
    time: '09:30', title: 'Mid-morning water',
    sub: '250ml water',
    icon: '💧', type: 'water', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '11:00', title: 'Morning snack',
    sub: 'Handful of roasted peanuts or a fruit',
    icon: '🌰', type: 'snack', calories: 150, protein: 5, carbs: 15, fat: 8,
  },
  {
    time: '13:00', title: 'Lunch',
    sub: '1 cup rice + dhal + vegetables + small serving fish or chicken',
    icon: '🍛', type: 'meal', calories: 550, protein: 30, carbs: 65, fat: 10,
  },
  {
    time: '13:30', title: 'Post-lunch walk',
    sub: '10–15 min walking — improves digestion and blood sugar',
    icon: '🚶', type: 'walk', calories: 60, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '16:30', title: 'Evening snack',
    sub: 'Fruit + 1 cup green tea with no sugar',
    icon: '🍎', type: 'snack', calories: 100, protein: 2, carbs: 22, fat: 1,
  },
  {
    time: '18:30', title: 'Workout — 45 min',
    sub: 'HIIT or strength training — alternate days',
    icon: '🏃', type: 'workout', calories: 280, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '19:15', title: 'Post-workout hydrate',
    sub: '400ml water',
    icon: '💧', type: 'water', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '20:30', title: 'Dinner — light',
    sub: 'Grilled fish or chicken + steamed vegetables + small salad',
    icon: '🥗', type: 'meal', calories: 420, protein: 35, carbs: 25, fat: 12,
  },
  {
    time: '22:30', title: 'Night water',
    sub: '250ml water before late work',
    icon: '💧', type: 'water', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '00:30', title: 'Sleep',
    sub: 'Target 7–8 hours',
    icon: '😴', type: 'sleep', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
];
// Total: ~1940 kcal · 94g protein · 162g carbs · 45g fat
```

### 7.3 Overweight Plan (BMI 25–29.9)

**Goal:** Steady fat loss. Deficit ~400 kcal below TDEE.
**Focus:** High protein to preserve muscle. Low refined carbs. No food after 9pm.

```dart
const planNormalOverweight: List<Map<String,dynamic>> = [
  {
    time: '07:00', title: 'Wake up + hydrate',
    sub: '500ml water — start metabolism before anything else',
    icon: '💧', type: 'water', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '07:30', title: 'Breakfast — high protein',
    sub: '3 boiled eggs (whites only if preferred) + vegetables + black coffee',
    icon: '🍳', type: 'meal', calories: 280, protein: 26, carbs: 8, fat: 14,
  },
  {
    time: '09:00', title: 'Morning water',
    sub: '300ml water before any tea',
    icon: '💧', type: 'water', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '13:00', title: 'Lunch — controlled portions',
    sub: '½ cup rice (samba) + dhal + grilled fish or chicken + salad',
    icon: '🍛', type: 'meal', calories: 480, protein: 32, carbs: 48, fat: 10,
  },
  {
    time: '13:30', title: 'Post-lunch walk',
    sub: '15–20 min brisk walk — critical for fat loss',
    icon: '🚶', type: 'walk', calories: 80, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '15:30', title: 'Afternoon snack — small',
    sub: 'Handful peanuts or cucumber slices + 250ml water',
    icon: '🌰', type: 'snack', calories: 100, protein: 4, carbs: 8, fat: 6,
  },
  {
    time: '18:30', title: 'Workout — 45–60 min',
    sub: 'HIIT preferred — burns more fat post-workout',
    icon: '🏃', type: 'workout', calories: 350, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '19:15', title: 'Post-workout hydrate',
    sub: '500ml water — do NOT skip this',
    icon: '💧', type: 'water', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '20:30', title: 'Dinner — low carb',
    sub: 'Grilled protein + large serving steamed vegetables — NO rice at night',
    icon: '🥗', type: 'meal', calories: 380, protein: 36, carbs: 20, fat: 12,
  },
  {
    time: '21:00', title: 'Hard stop — no food after this',
    sub: 'Water or herbal tea only after 9pm',
    icon: '🚫', type: 'custom', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '22:30', title: 'Night water',
    sub: '250ml water',
    icon: '💧', type: 'water', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '00:00', title: 'Sleep',
    sub: 'Poor sleep = more fat storage — aim for 7h minimum',
    icon: '😴', type: 'sleep', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
];
// Total: ~1620 kcal · 98g protein · 84g carbs · 42g fat
```

### 7.4 Obese Plan (BMI ≥ 30)

**Goal:** Safe fat loss. Deficit ~600 kcal. Low impact exercise to start.
**Focus:** Very low refined carbs. High protein + fibre. No sugary drinks. Doctor consult note.

```dart
const planNormalObese: List<Map<String,dynamic>> = [
  {
    time: '07:00', title: 'Wake up + hydrate',
    sub: '600ml water — largest hydration hit of the day',
    icon: '💧', type: 'water', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '07:30', title: 'Breakfast — protein only',
    sub: '3 egg whites + 1 whole egg scrambled + 1 cup vegetables, no oil',
    icon: '🍳', type: 'meal', calories: 200, protein: 24, carbs: 5, fat: 8,
  },
  {
    time: '09:30', title: 'Morning walk — 20 min',
    sub: 'Low impact — brisk walk. No running until BMI < 30.',
    icon: '🚶', type: 'walk', calories: 100, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '10:00', title: 'Water + light snack',
    sub: '300ml water + cucumber or celery sticks',
    icon: '💧', type: 'water', calories: 30, protein: 1, carbs: 6, fat: 0,
  },
  {
    time: '13:00', title: 'Lunch — strictly portioned',
    sub: '⅓ cup rice + large dhal serving + grilled protein + salad first',
    icon: '🍛', type: 'meal', calories: 420, protein: 30, carbs: 40, fat: 8,
  },
  {
    time: '14:00', title: 'Post-lunch walk',
    sub: '20 min walk — non-negotiable',
    icon: '🚶', type: 'walk', calories: 90, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '15:30', title: 'Afternoon hydration',
    sub: '400ml water — replace afternoon tea habit',
    icon: '💧', type: 'water', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '18:00', title: 'Evening walk — 30 min',
    sub: 'Brisk walk; can add light resistance bands after 2 weeks',
    icon: '🚶', type: 'walk', calories: 140, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '19:30', title: 'Post-walk hydrate',
    sub: '400ml water',
    icon: '💧', type: 'water', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '20:00', title: 'Dinner — very light',
    sub: 'Boiled or grilled protein + vegetables only — zero carbs at dinner',
    icon: '🥗', type: 'meal', calories: 320, protein: 32, carbs: 12, fat: 10,
  },
  {
    time: '20:30', title: 'Hard stop — no food',
    sub: 'Water or herbal tea only. This is critical.',
    icon: '🚫', type: 'custom', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '22:30', title: 'Night water',
    sub: '250ml water',
    icon: '💧', type: 'water', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '23:00', title: 'Sleep — 8h target',
    sub: 'Consistent sleep schedule helps regulate hunger hormones',
    icon: '😴', type: 'sleep', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
];
// Total: ~1160 kcal · 87g protein · 63g carbs · 26g fat
// Note: Obese plan intentionally low — TDEE-derived target may be higher.
// Calorie target from calculateTDEE() - 600 is the actual target; plan is template only.
```

---

## 8. Gym Mode — Diet Plans

Four plans, one per gym goal. Macro-optimised. Protein shake items included.
All editable. Switching gym goal regenerates plan (unless `planLockedByUser`).

### 8.1 Gym — Fat Loss

**Goal:** Calorie deficit 500 kcal. High protein to preserve muscle. Cardio + strength.

```dart
const planGymFatLoss: List<Map<String,dynamic>> = [
  {
    time: '06:30', title: 'Pre-workout hydrate',
    sub: '500ml water + black coffee (optional pre-workout)',
    icon: '💧', type: 'water', calories: 5, protein: 0, carbs: 1, fat: 0,
  },
  {
    time: '07:00', title: 'Morning workout — 60 min',
    sub: 'Fasted cardio 20min + strength 40min — burns more fat fasted',
    icon: '🏋️', type: 'workout', calories: 420, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '08:00', title: 'Post-workout — protein shake',
    sub: 'Whey protein 30g in water + 1 banana',
    icon: '🥤', type: 'protein', calories: 250, protein: 30, carbs: 28, fat: 3,
  },
  {
    time: '09:00', title: 'Breakfast',
    sub: '3 egg whites + 1 whole egg + spinach + oats 40g',
    icon: '🍳', type: 'meal', calories: 320, protein: 30, carbs: 32, fat: 10,
  },
  {
    time: '12:00', title: 'Mid-day water',
    sub: '400ml water before lunch',
    icon: '💧', type: 'water', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '13:00', title: 'Lunch — high protein',
    sub: '150g chicken breast or fish + ½ cup brown rice + large salad',
    icon: '🍗', type: 'meal', calories: 480, protein: 45, carbs: 38, fat: 8,
  },
  {
    time: '16:00', title: 'Afternoon snack',
    sub: 'Greek yogurt 150g or cottage cheese + cucumber',
    icon: '🥛', type: 'snack', calories: 150, protein: 18, carbs: 8, fat: 4,
  },
  {
    time: '19:30', title: 'Pre-bed water',
    sub: '300ml water',
    icon: '💧', type: 'water', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '20:00', title: 'Dinner — low carb',
    sub: '150g grilled protein + roasted vegetables + salad — zero starch',
    icon: '🥗', type: 'meal', calories: 380, protein: 42, carbs: 18, fat: 12,
  },
  {
    time: '21:30', title: 'Casein shake (optional)',
    sub: 'Casein protein 25g in water — slow-release overnight',
    icon: '🥤', type: 'protein', calories: 120, protein: 25, carbs: 4, fat: 1,
  },
  {
    time: '22:30', title: 'Sleep',
    sub: '8h — GH release during sleep supports fat loss',
    icon: '😴', type: 'sleep', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
];
// Total: ~1700 kcal · 190g protein · 129g carbs · 38g fat
```

### 8.2 Gym — Muscle Gain (Lean Bulk)

**Goal:** Calorie surplus +300 kcal. Very high protein. Progressive overload training.

```dart
const planGymMuscleGain: List<Map<String,dynamic>> = [
  {
    time: '07:00', title: 'Wake up + hydrate',
    sub: '600ml water + 5g creatine (optional)',
    icon: '💧', type: 'water', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '07:30', title: 'Breakfast — calorie dense',
    sub: '4 whole eggs + 80g oats + 1 banana + 250ml whole milk',
    icon: '🍳', type: 'meal', calories: 700, protein: 42, carbs: 70, fat: 26,
  },
  {
    time: '10:00', title: 'Mid-morning snack',
    sub: 'Protein shake 30g + peanut butter 2 tbsp + rice cakes',
    icon: '🥤', type: 'protein', calories: 380, protein: 32, carbs: 28, fat: 14,
  },
  {
    time: '13:00', title: 'Lunch — heavy',
    sub: '1.5 cup brown rice + 200g chicken breast + vegetables + olive oil dressing',
    icon: '🍗', type: 'meal', calories: 720, protein: 52, carbs: 72, fat: 14,
  },
  {
    time: '15:30', title: 'Pre-workout meal',
    sub: 'Banana + 30g oats + 15g whey — 60–90 min before training',
    icon: '⚡', type: 'snack', calories: 250, protein: 16, carbs: 42, fat: 2,
  },
  {
    time: '17:00', title: 'Strength training — 75 min',
    sub: 'Heavy compound lifts: squat, bench, deadlift, rows — progressive overload',
    icon: '🏋️', type: 'workout', calories: 400, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '18:30', title: 'Post-workout — shake immediately',
    sub: 'Whey protein 40g + fast carbs (fruit or dextrose) within 30 min',
    icon: '🥤', type: 'protein', calories: 300, protein: 40, carbs: 30, fat: 2,
  },
  {
    time: '20:00', title: 'Dinner',
    sub: '150g rice + 180g lean beef or chicken + vegetables + egg',
    icon: '🍖', type: 'meal', calories: 680, protein: 50, carbs: 60, fat: 18,
  },
  {
    time: '22:30', title: 'Pre-bed casein',
    sub: 'Casein protein 30g + 200ml milk — 8h slow release overnight',
    icon: '🥤', type: 'protein', calories: 230, protein: 32, carbs: 12, fat: 5,
  },
  {
    time: '23:00', title: 'Sleep — 8h minimum',
    sub: 'Muscle is built during sleep — non-negotiable',
    icon: '😴', type: 'sleep', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
];
// Total: ~3460 kcal · 264g protein · 314g carbs · 81g fat
```

### 8.3 Gym — Maintenance

**Goal:** Match TDEE exactly. Sustain muscle mass. Balanced macros.

```dart
const planGymMaintenance: List<Map<String,dynamic>> = [
  {
    time: '07:00', title: 'Wake up + hydrate',
    sub: '500ml water',
    icon: '💧', type: 'water', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '07:30', title: 'Breakfast',
    sub: '3 eggs + 60g oats + 1 fruit + green tea',
    icon: '🍳', type: 'meal', calories: 500, protein: 28, carbs: 52, fat: 18,
  },
  {
    time: '10:30', title: 'Snack',
    sub: 'Greek yogurt 150g + nuts',
    icon: '🥛', type: 'snack', calories: 220, protein: 18, carbs: 12, fat: 10,
  },
  {
    time: '13:00', title: 'Lunch',
    sub: '1 cup rice + protein 150g + vegetables',
    icon: '🍛', type: 'meal', calories: 580, protein: 40, carbs: 58, fat: 12,
  },
  {
    time: '17:00', title: 'Training — 60 min',
    sub: 'Strength or hybrid training — 4 days/week',
    icon: '🏋️', type: 'workout', calories: 350, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '18:15', title: 'Post-workout shake',
    sub: 'Whey 30g + banana',
    icon: '🥤', type: 'protein', calories: 240, protein: 30, carbs: 28, fat: 2,
  },
  {
    time: '20:00', title: 'Dinner',
    sub: 'Protein 150g + ½ cup rice + vegetables + olive oil',
    icon: '🥗', type: 'meal', calories: 520, protein: 38, carbs: 42, fat: 16,
  },
  {
    time: '22:00', title: 'Pre-bed snack',
    sub: 'Cottage cheese or casein 25g',
    icon: '🥛', type: 'snack', calories: 140, protein: 22, carbs: 5, fat: 4,
  },
  {
    time: '23:00', title: 'Sleep',
    sub: '7–8 hours',
    icon: '😴', type: 'sleep', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
];
// Total: ~2200 kcal · 176g protein · 197g carbs · 62g fat
```

### 8.4 Gym — Body Recomposition

**Goal:** Slight deficit (~200 kcal). Lose fat, preserve/gain muscle simultaneously.
**Focus:** Very high protein (2g/kg). Carb cycling. Strict meal timing.

```dart
const planGymRecomp: List<Map<String,dynamic>> = [
  {
    time: '07:00', title: 'Wake up + hydrate',
    sub: '500ml water + optional black coffee',
    icon: '💧', type: 'water', calories: 5, protein: 0, carbs: 1, fat: 0,
  },
  {
    time: '07:30', title: 'Breakfast — high protein',
    sub: '4 egg whites + 1 whole egg + vegetables + 40g oats on training days',
    icon: '🍳', type: 'meal', calories: 320, protein: 28, carbs: 30, fat: 10,
  },
  {
    time: '10:00', title: 'Mid-morning protein',
    sub: 'Whey 25g in water OR Greek yogurt 150g',
    icon: '🥤', type: 'protein', calories: 150, protein: 25, carbs: 8, fat: 2,
  },
  {
    time: '13:00', title: 'Lunch — moderate carb',
    sub: '½ cup rice + 160g chicken or fish + large salad + olive oil',
    icon: '🍗', type: 'meal', calories: 480, protein: 40, carbs: 36, fat: 14,
  },
  {
    time: '16:30', title: 'Pre-workout',
    sub: 'Banana + 15g whey — 45 min before training',
    icon: '⚡', type: 'snack', calories: 170, protein: 16, carbs: 24, fat: 1,
  },
  {
    time: '17:30', title: 'Training — 60–75 min',
    sub: 'Strength training 5 days/week — progressive overload is key',
    icon: '🏋️', type: 'workout', calories: 380, protein: 0, carbs: 0, fat: 0,
  },
  {
    time: '19:00', title: 'Post-workout shake',
    sub: 'Whey 35g + fast carbs immediately after training',
    icon: '🥤', type: 'protein', calories: 240, protein: 35, carbs: 22, fat: 2,
  },
  {
    time: '20:30', title: 'Dinner — low carb',
    sub: '180g protein source + roasted vegetables + avocado — no starch',
    icon: '🥗', type: 'meal', calories: 420, protein: 42, carbs: 14, fat: 18,
  },
  {
    time: '22:30', title: 'Casein before bed',
    sub: 'Casein 25g — anti-catabolic overnight',
    icon: '🥤', type: 'protein', calories: 120, protein: 25, carbs: 3, fat: 1,
  },
  {
    time: '23:00', title: 'Sleep',
    sub: '8h — recomp requires optimal recovery',
    icon: '😴', type: 'sleep', calories: 0, protein: 0, carbs: 0, fat: 0,
  },
];
// Total: ~1900 kcal · 211g protein · 138g carbs · 48g fat
```

### Plan Selection Logic

```dart
List<Map<String,dynamic>> selectPlan(UserProfile profile) {
  if (profile.mode === 'gym') {
    switch (profile.gymGoal) {
      case 'fat_loss':    return planGymFatLoss;
      case 'muscle_gain': return planGymMuscleGain;
      case 'maintenance': return planGymMaintenance;
      case 'recomp':      return planGymRecomp;
    }
  }
  switch (profile.bmiCategory) {
    case 'underweight': return planNormalUnderweight;
    case 'normal':      return planNormalHealthy;
    case 'overweight':  return planNormalOverweight;
    case 'obese':       return planNormalObese;
  }
}

List<ScheduleItem> planToScheduleItems(List<Map<String,dynamic>> templates) {
  return templates.map(t => ({
    ...t,
    id:       const Uuid().v4(),
    done:     false,
    remOn:    false,
    isCustom: false,
  }));
}
```

---

## 9. Water Intake Engine

### `lib/services/waterEngine.ts`

```dart
// ─── Target calculation ───────────────────────────────────────────────────────

int calculateWaterTarget(double weightKg, String mode) {
  // 35 ml/kg normal, 40 ml/kg gym
  const mlPerKg = mode === 'gym' ? 40 : 35;
  return Math.round((weightKg * mlPerKg) / 250) * 250; // nearest 250ml
}

// Examples:
// 78kg normal → 78 × 35 = 2730 → rounded to 2750ml
// 78kg gym    → 78 × 40 = 3120 → rounded to 3250ml
// 60kg normal → 60 × 35 = 2100 → 2000ml
// 90kg gym    → 90 × 40 = 3600 → 3500ml

// ─── Reminder schedule calculation ───────────────────────────────────────────

class WaterReminderSlot {
  String time;   // "HH:MM"
  double ml;   // how much to drink at this reminder
}

List<WaterReminderSlot> buildWaterSchedule(WaterConfig config) {
  const { target, mlPerReminder, reminderIntervalMinutes, reminderStartTime, reminderEndTime } = config;

  const startMinutes = timeToMinutes(reminderStartTime);
  const endMinutes   = timeToMinutes(reminderEndTime);
  const slots: List<WaterReminderSlot> = [];

  let current = startMinutes;
  let totalScheduled = 0;

  while (current <= endMinutes && totalScheduled < target) {
    const remaining = target - totalScheduled;
    const ml = Math.min(mlPerReminder, remaining);
    slots.push({ time: minutesToTime(current), ml });
    totalScheduled += ml;
    current += reminderIntervalMinutes;
  }

  return slots;
}

function timeToMinutes(time: String): double {
  const [h, m] = time.split(':').map(Number);
  return h * 60 + m;
}

function minutesToTime(double minutes): String {
  const h = Math.floor(minutes / 60) % 24;
  const m = minutes % 60;
  return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`;
}

// ─── Example output ───────────────────────────────────────────────────────────
// target: 2750ml, mlPerReminder: 250ml, interval: 90min, start: 07:00, end: 22:00
// → 07:00 (250ml), 08:30 (250ml), 10:00 (250ml), 11:30 (250ml),
//   13:00 (250ml), 14:30 (250ml), 16:00 (250ml), 17:30 (250ml),
//   19:00 (250ml), 20:30 (250ml), 22:00 (250ml) = 2750ml in 11 reminders

// ─── Schedule notifications for water ────────────────────────────────────────

Future<void> scheduleWaterNotifications(
  config: WaterConfig
): Future<List<String>> {
  // Cancel all existing water notifications first
  const existing = await plugin.pendingNotificationRequests();
  const waterIds  = existing
    .filter(n => n.content.data?.type === 'water')
    .map(n => n.identifier);
  await Promise.all(waterIds.map(id => plugin.cancel(id)));

  if (!config.reminderEnabled) return [];

  const slots = buildWaterSchedule(config);
  const notifIds: String[] = [];

  for (const slot of slots) {
    const [hour, minute] = slot.time.split(':').map(Number);
    const id = await plugin.zonedSchedule({
      content: {
        title: 'FitPlan 💧 Hydration time',
        body:  `Drink ${slot.ml}ml of water now`,
        sound: true,
        data:  { type: 'water' },
      },
      trigger: { hour, minute, repeats: true },
    });
    notifIds.push(id);
  }

  return notifIds;
}
```

### Default Water Config

```dart
const defaultWaterConfig = {
  consumed:                0,
  target:                  2750,    // overridden on onboarding from weight
  reminderEnabled:         true,
  reminderIntervalMinutes: 90,      // every 1.5 hours
  reminderStartTime:       '07:00',
  reminderEndTime:         '22:00',
  mlPerReminder:           250,     // 250ml per reminder
};
```

---

## 10. Onboarding Flow

Shown only on first launch. Writes `'vitatrack_onboarded': 'true'` to SharedPreferences / Hive on completion.

### Step Indicator

5 steps. `● ● ○ ○ ○` — filled = completed/current, empty = future.
Back arrow appears on steps 2–5. Tapping back decrements step.

### Step 1 — Welcome

```
┌──────────────────────────────────┐
│  [FitPlan logo — 64×64 accent]   │
│                                  │
│  FitPlan                         │
│  (h1, textPrimary, centred)      │
│                                  │
│  Your personal fat-loss &        │
│  wellness daily planner          │
│  (14px textSecondary, centred)   │
│                                  │
│  [Get started →]   primary btn   │
└──────────────────────────────────┘
```

### Step 2 — Your Profile

Collects: name, age, gender, height, current weight, goal weight, units.

```
┌──────────────────────────────────┐
│  "Tell us about you"  (h2)       │
│                                  │
│  Name                            │
│  [ e.g. Umakaran              ]  │
│                                  │
│  Age                             │
│  [ 25                         ]  │
│                                  │
│  Gender   [Male] [Female]        │
│           (chip selector)        │
│                                  │
│  Height                          │
│  [ 168                  ] cm     │
│  (shows ft/in if imperial)       │
│                                  │
│  Units   [Metric] [Imperial]     │
│                                  │
│  Current weight                  │
│  [ 78.0                 ] kg     │
│                                  │
│  Goal weight                     │
│  [ 70.0                 ] kg     │
│                                  │
│  ──────────────────────────────  │
│  BMI Preview:                    │
│  27.6 — Overweight  (live calc)  │
│  Ideal range: 52.3–70.4 kg      │
│  ──────────────────────────────  │
│                                  │
│  [Next →]                        │
└──────────────────────────────────┘
```

BMI preview updates in real-time as user types height/weight.
Show BMI value and category (coloured) and ideal weight range.

**Validation:**
- Name: required, min 2 chars
- Age: 10–100
- Height: 100–250 cm
- Weights: must be positive, goal weight logically consistent

### Step 3 — Your Mode

```
┌──────────────────────────────────┐
│  "Choose your mode"  (h2)        │
│                                  │
│  ┌──────────────────────────┐    │
│  │  Normal mode             │    │
│  │  General health &        │    │
│  │  lifestyle tracking      │    │
│  │  Best for: office workers│    │
│  │  [Select]                │    │
│  └──────────────────────────┘    │
│                                  │
│  ┌──────────────────────────┐    │
│  │  Gym mode                │    │
│  │  Athlete & bodybuilder   │    │
│  │  tracking. Protein,      │    │
│  │  macros, workout logs    │    │
│  │  [Select]                │    │
│  └──────────────────────────┘    │
│                                  │
│  [if Gym mode selected:]         │
│  Your goal                       │
│  [Fat loss] [Muscle gain]        │
│  [Maintain] [Recomp]             │
│  (chip selector, single-select)  │
│                                  │
│  [Next →]                        │
└──────────────────────────────────┘
```

Mode cards: `bg2`, `border1` border, radius `xl`.
Selected: 2px `accent` border, `accentBg` tint.

### Step 4 — Targets & Schedule

Shows auto-calculated values from Step 2 data. User can adjust.

```
┌──────────────────────────────────┐
│  "Your daily targets"  (h2)      │
│                                  │
│  Auto-calculated from your stats │
│  (11px textMuted)                │
│                                  │
│  Daily calorie target            │
│  [ 1800                 ] kcal   │
│  Based on your BMI & TDEE       │
│                                  │
│  Daily water target              │
│  [ 2750                 ] ml     │
│  Based on 35ml × your weight    │
│                                  │
│  Water reminder every            │
│  [60min] [90min] [2h] [3h]      │
│  (chip selector)                 │
│                                  │
│  Drink per reminder              │
│  [ 250                  ] ml     │
│                                  │
│  Activity level                  │
│  [Sedentary][Light][Moderate]    │
│  [Active][Very active]           │
│                                  │
│  Work start time                 │
│  [ 09:00              ]          │
│                                  │
│  Work end time                   │
│  [ 18:00              ]          │
│                                  │
│  Target sleep time               │
│  [ 00:30              ]          │
│                                  │
│  [Next →]                        │
└──────────────────────────────────┘
```

### Step 5 — Permissions & Finish

```
┌──────────────────────────────────┐
│  "Enable notifications"  (h2)    │
│                                  │
│  FitPlan sends smart reminders:  │
│  • Water every {interval}        │
│  • Meal time alerts              │
│  • Workout reminders             │
│  • Sleep reminder                │
│  (bulleted, 13px textSecondary)  │
│                                  │
│  [Allow notifications]           │
│  (triggers system permission)    │
│                                  │
│  [Skip for now]                  │
│                                  │
│  ────────────────────────────    │
│  Your plan summary:              │
│  Mode:     Normal (Overweight)   │
│  Calories: 1800 kcal/day        │
│  Water:    2750 ml/day          │
│  Protein:  90g/day              │
│  ────────────────────────────    │
│                                  │
│  [Finish setup — Let's go!]      │
│  (primary button)                │
└──────────────────────────────────┘
```

**On "Finish setup":**
1. Calculate BMI → `profile.bmi`, `profile.bmiCategory`
2. Calculate TDEE → `calculateTDEE(...)`
3. Calculate calorie target → `getCalorieTarget(tdee, bmiCategory, mode, gymGoal)`
4. Calculate macros → `getMacroTargets(calories, weightKg, mode, gymGoal)`
5. Calculate water target → `calculateWaterTarget(weightKg, mode)`
6. Select and seed plan → `planToScheduleItems(selectPlan(profile))`
7. Seed default reminders
8. If notif granted: `scheduleWaterNotifications(waterConfig)` + seed default reminder notifications
9. Write `'vitatrack_onboarded': 'true'`
10. Navigate to `MainTabs` → `Today` screen

---

## 11. Screen Specifications

### 11.1 Today Screen

**SingleChildScrollView**, `bg1` background.

#### Full Layout

```
┌──────────────────────────────────┐
│  Header (greeting + streak)      │
├──────────────────────────────────┤
│  BMI Card                        │
├──────────────────────────────────┤
│  Score Row (Diet · Water ·       │
│             Workout · [Protein]) │
├──────────────────────────────────┤
│  Calorie Card                    │
├──────────────────────────────────┤
│  Macro Card (gym mode only)      │
├──────────────────────────────────┤
│  Water Card                      │
├──────────────────────────────────┤
│  Weekly Workout Row              │
├──────────────────────────────────┤
│  "Schedule" header + Edit plan   │
├──────────────────────────────────┤
│  Filter chips                    │
├──────────────────────────────────┤
│  Schedule item list              │
└──────────────────────────────────┘
```

#### Header

```dart
function greeting(double hour): String {
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}
// "{greeting}, {profile.name}" — 21px medium textPrimary
// Streak pill: "🔥 {streak} day streak" — amberDark bg, amber border/text, 10px medium
```

#### BMI Card (`BmiCard.dart`)

```
BMI                              [Detail >]
27.6                 Overweight
[████████████░░░░░░░░░░░]         amber bar
|      |           |      |
<18.5  18.5      25      30      ← tiny tick marks
Ideal range: 52.3 – 70.4 kg
You are 5.7 kg above healthy range
```

- BMI value: 24px medium, `bmiOver` (amber for overweight)
- Category: 13px medium, same colour
- Bar scale 15→40; `(bmi-15)/25*100`% fill, capped 0–100
- Tick marks at 18.5, 25, 30 (2px wide, 10px tall, `textMuted`)
- Ideal range: 11px `textMuted`
- Difference: 11px, coloured (red if far over, amber if slight, green if in range)
- `[Detail >]` → BmiDetailModal

#### Score Row

4 cards in normal mode, 5 in gym mode (adds Protein):

| Card | Label | Value | Colour |
|---|---|---|---|
| Diet | "Meals" | "n/total" | `green` |
| Water | "Water" | "n%" | `blue` |
| Workout | "Workout" | "Done"/"—" | `amber` |
| Protein | "Protein" (gym) | "ng/Ng" | `lavender` |

#### Calorie Card

- Header: "Calories today" + right: `"{eaten} / {target} kcal"` (12px `accentSoft`)
- Bar: green if ≤ target, amber if 0–10% over, red if >10% over
- Sub: `"{remaining} kcal remaining"` or `"{over} kcal over budget"` in red

#### Macro Card (gym mode only) — `MacroCard.dart`

```
Macros today
Protein  [████████░░]  82g / 190g
Carbs    [██████████]  130g / 129g   ← red if over
Fat      [████░░░░░░]  20g / 38g
```

- Each row: label (50px min-width), bar (flex 1), value (right)
- Protein bar: `lavender`
- Carbs bar: `amber`
- Fat bar: `teal`
- Over-target values turn `red`

#### Water Card

- Header: "Water intake" + right: tappable `"✎ {consumed} / {target}ml"` → Water Target Modal
- 8px progress bar, `accent` fill
- Quick-add row: `+150ml` `+250ml` `+500ml` `✎ Edit` (opens Water Reminder Modal)
- On add: animate bar, `addWater(ml)`, `addLog("Added {ml}ml water")`

#### Weekly Workout Row

```
Mon    Tue    Wed    Thu    Fri    Sat    Sun
HIIT  Strength  HIIT  Strength  HIIT  Walk  Rest
```

- Today's day: outer border `accent` 1px
- Normal mode plan: `['HIIT', 'Strength', 'HIIT', 'Strength', 'HIIT', 'Walk', 'Rest']`
- Gym fat loss: `['Strength', 'Cardio', 'Strength', 'Cardio', 'Strength', 'HIIT', 'Rest']`
- Gym muscle gain: `['Push', 'Pull', 'Legs', 'Push', 'Pull', 'Legs', 'Rest']`
- Gym maintenance: `['Full Body', 'Rest', 'Full Body', 'Rest', 'Full Body', 'Walk', 'Rest']`
- Gym recomp: `['Upper', 'Lower', 'Upper', 'Lower', 'HIIT', 'Walk', 'Rest']`

#### Filter Chips

`All · Meals · Water · Workout · Snacks · Sleep · Protein`
(Protein chip only visible in gym mode)

#### Schedule Item

```
07:30  [🍳]  Breakfast                     [🔔][○]
             3 eggs + toast · 300kcal · P:28g
```

- Sub line: sub text + `· {calories}kcal · P:{protein}g` (if protein > 0)
- Bell: toggles `remOn`, schedules/cancels item-level notification
- Check: toggles `done`, spring animation, `addLog("Completed: {title}")`
- Done state: `opacity: 0.4`, title strikethrough

---

### 11.2 Calendar Screen

**SingleChildScrollView**, `bg1` background.

#### Full Layout

```
┌──────────────────────────────────┐
│  Calendar Card (month grid)      │
├──────────────────────────────────┤
│  BMI Trend Chart                 │
├──────────────────────────────────┤
│  Weight Trend + log button       │
├──────────────────────────────────┤
│  Monthly ratio bars              │
├──────────────────────────────────┤
│  Ring charts (3)                 │
└──────────────────────────────────┘
```

#### Calendar Grid

Day cell states same as v2.0 spec. Day status:

```dart
function computeDayStatus(record: DayRecord): 'success' | 'partial' | 'failed' {
  const gymBonus = record.proteinScore > 0 ? record.proteinScore : 100;
  const score = (record.dietScore + record.waterScore + record.calorieScore +
                 (record.workoutDone ? 100 : 0) + gymBonus) / 5;
  if (score >= 75) return 'success';
  if (score >= 40) return 'partial';
  return 'failed';
}
```

#### BMI Trend Chart (`BmiTrendChart.dart`)

SVG line chart. Height 80px. Last 30 `WeightEntry` records (bmi field).

- Line: `accentSoft`, strokeWidth 1.5
- Background zone bands:
  - Green band (18.5–25): very subtle `greenDark` fill
  - Amber band (25–30): subtle `amberDark` fill
  - Red zone (>30 or <18.5): subtle `redDark` fill
- Your BMI dots: 4px, coloured by their category
- "Your BMI over time" label: 11px `textMuted`

#### Weight Trend + Log Button

- Mini SVG line chart (height 80px), `accentSoft` line
- "Log today's weight" → full-width `bg3` button → WeightLogModal

#### Monthly Ratio Bars

Meals / Water / Workout / Calories / Protein (gym mode only)

#### Ring Charts

On plan · Missed · Workouts — same spec as v2.0

---

### 11.3 Reminders Screen

Same spec as v2.0. Default reminders seeded from `defaultReminders`.
Water interval reminders NOT shown here (managed via Water Reminder Modal).
Only manual/meal/workout/sleep reminders shown.

---

### 11.4 Profile & Settings Screen

#### Layout

```
┌──────────────────────────────────┐
│  Profile header (avatar + edit)  │
│  BMI badge inline                │
├──────────────────────────────────┤
│  Section: Mode                   │
│    App mode (Normal/Gym)   ›     │
│    Gym goal (if gym mode)  ›     │
├──────────────────────────────────┤
│  Section: Body stats             │
│    Height                  ›     │
│    Current weight          ›     │
│    Goal weight             ›     │
│    BMI (read-only display)       │
├──────────────────────────────────┤
│  Section: Water settings         │
│    Daily water target      ›     │
│    Water reminder setup    ›     │
├──────────────────────────────────┤
│  Section: Diet & calories        │
│    Edit meal schedule      ›     │
│    Calorie target          ›     │
│    Reset to recommended plan ›   │
├──────────────────────────────────┤
│  Section: Notifications          │
│    Push notifications   [toggle] │
│    Workout reminders    [toggle] │
│    Sleep reminder       [toggle] │
├──────────────────────────────────┤
│  Section: App                    │
│    Step goal               ›     │
│    Units (metric/imperial) ›     │
└──────────────────────────────────┘
```

#### Profile Header

- Avatar: 52×52, `accentBg`, 2px `accent` border — `deriveInitials(name)`
- BMI badge inline: small pill `"{bmi} · {category}"` — coloured by category

#### "Reset to recommended plan" Row

- Appears only when `planLockedByUser === true`
- Tapping shows confirmation Alert:
  - "Regenerate plan? This will replace your current custom plan with the recommended plan for your BMI/goal."
  - Confirm → `generatePlan(profile)` → `initScheduleFrom(plan)` → `planLockedByUser = false`

---

## 12. Modals & Bottom Sheets

### Common Sheet Style

```dart
{
  backgroundColor:     Colors.bg2,
  borderTopLeftRadius:  20,
  borderTopRightRadius: 20,
  borderTopWidth:       0.5,
  borderTopColor:       Colors.border2,
  padding:              16,
  paddingBottom:        32,
}
```

### Common Input Style

```dart
{
  backgroundColor: Colors.bg3,
  borderWidth:     0.5,
  borderColor:     Colors.border2,
  borderRadius:    Radius.md,
  paddingVertical:   9,
  paddingHorizontal: 12,
  color:           Colors.textPrimary,
  fontSize:        14,
  marginBottom:    10,
  // Focus: borderColor → Colors.accent
}
```

### 12.1 Water Target Modal

**Title:** "Water settings"
**Trigger:** Water card right label OR Profile water target row.

```
Daily water target (ml)
[ 2750                              ]
Presets: [2000] [2500] [2750] [3000] [3500]

Recommended for your weight:
35 ml × 78 kg = 2750 ml           ← 11px textMuted, live calc

[Recalculate from weight]          ← secondary button
[Save]
[Cancel]
```

On "Recalculate": calls `calculateWaterTarget(weightKg, mode)`, fills input.
On Save: `setWaterTarget(ml)`, re-schedule water notifications.

---

### 12.2 Water Reminder Modal (NEW — full spec)

**Title:** "Water reminders"
**Trigger:** "✎ Edit" in water card OR "Water reminder setup" in Profile.

This is the most important water UX screen. User fully configures when and how much.

```
┌──────────────────────────────────────┐
│  Water reminders              [✕]    │
├──────────────────────────────────────┤
│  Enable water reminders  [toggle]    │
│                                      │
│  ── (below sections dim if disabled) │
│                                      │
│  Reminder window                     │
│  Start time     End time             │
│  [ 07:00 ]      [ 22:00 ]            │
│                                      │
│  Remind me every                     │
│  [30min][60min][90min][2h][3h]       │
│  (chip selector)                     │
│                                      │
│  Drink per reminder                  │
│  [ 250                      ] ml     │
│  Presets: [150] [200] [250] [300]    │
│                                      │
│  ────────────────────────────────    │
│  Preview schedule:                   │
│  07:00 → 250ml   ← generated live   │
│  08:30 → 250ml                       │
│  10:00 → 250ml                       │
│  11:30 → 250ml                       │
│  …                                   │
│  Total: 2750ml in 11 reminders      │
│  (11px textMuted, scrollable list)   │
│  ────────────────────────────────    │
│                                      │
│  [Save & schedule]    primary        │
│  [Cancel]             secondary      │
└──────────────────────────────────────┘
```

**Live preview logic:**
Call `buildWaterSchedule(config)` on every field change.
Display as list: `"{time} → {ml}ml"` rows, 11px `textMuted`.
Show total: `"Total: {sum}ml in {count} reminders"`.

**On save:**
- `setWaterConfig(config)` in store
- `scheduleWaterNotifications(config)` — cancels old, schedules new
- Show toast: "Water reminders updated — {count} notifications scheduled"

---

### 12.3 Diet Plan Editor Modal

**Title:** "Edit meal plan"
**Trigger:** "✎ Edit plan" on Today OR Profile.

Scrollable list of all schedule items.

```
[icon]  07:30 — Breakfast                [Edit]
        3 eggs + toast · 300kcal · P:28g

[icon]  09:00 — Water                    [Edit]
        250ml water · 0kcal

[icon]  13:00 — Lunch                    [Edit]
        ½ cup rice + protein · 480kcal · P:32g
```

Footer note (if `planLockedByUser`):
`"Your plan has custom edits. Tap ↺ in Profile to reset to recommended plan."` — 11px amber

**Add custom item:** `"+ Add item"` button at bottom → opens Edit Item Modal with blank fields.

---

### 12.4 Edit Plan Item Modal

**Title:** "Edit item" / "Add item"
**Trigger:** Edit button in Diet Editor, or "+ Add item".

```
Title
[ Breakfast                          ]

Description
[ 3 eggs + 1 slice wheat toast       ]

Time
[ 07:30                              ]

Type
[Meal][Water][Snack][Workout][Sleep][Protein][Walk][Custom]

Calories (kcal)
[ 300                                ]

Protein (g)
[ 28                                 ]

Carbs (g)
[ 35                                 ]

Fat (g)
[ 14                                 ]

[Save changes]
[Delete item]      ← red secondary btn, only if editing existing
[Cancel]
```

**On save (edit):** `updateItem(id, patch)`, re-sort by time, `planLockedByUser = true`.
**On save (new):** create new `ScheduleItem`, append, re-sort, `planLockedByUser = true`.
**On delete:** confirm Alert → `deleteItem(id)`, `planLockedByUser = true`.

---

### 12.5 Add Reminder Modal

Same as v2.0. Types now include `protein`.

---

### 12.6 Edit Profile Modal

**Title:** "Edit profile"

```
Name
[ Umakaran                           ]

Age
[ 25                                 ]

Gender   [Male] [Female]

Work start time
[ 09:00                              ]

Work end time
[ 18:00                              ]

Target sleep time
[ 00:30                              ]

[Save profile]
[Cancel]
```

Height, weight, goal weight are edited via Body Stats rows (separate modals).

---

### 12.7 Weight Log Modal

**Title:** "Log weight"
**Trigger:** "Log today's weight" on Calendar, or Current weight row in Profile.

```
Today's weight
[ 78.0                       ] kg

─────────────────────────────────
BMI preview:  27.6 — Overweight   ← live calculation as user types
Ideal range:  52.3 – 70.4 kg
─────────────────────────────────

Recent entries:
  May 04 — 78.2 kg  (BMI 27.7)
  May 03 — 78.5 kg  (BMI 27.8)
  May 02 — 78.8 kg  (BMI 27.9)

[Log weight]
[Cancel]
```

**On save:**
1. `addWeightEntry({ date, weight, bmi })`
2. Recalculate BMI
3. `updateProfile({ currentWeight: weight, bmi, bmiCategory })`
4. Recalculate water target: `calculateWaterTarget(weightKg, mode)`
5. If `bmiCategory` changed and `!planLockedByUser`: `regeneratePlan()`; show toast
6. If water target changed: `setWaterTarget(newTarget)`; re-schedule water notifications

---

### 12.8 BMI Detail Modal

**Title:** "BMI details"
**Trigger:** `[Detail >]` on BMI Card.

```
Your BMI
27.6 — Overweight
(large display, amber coloured)

──────────────────────────────────
Category ranges:
< 18.5      Underweight  (blue)
18.5 – 24.9 Healthy      (green)
25 – 29.9   Overweight   (amber)
≥ 30        Obese        (red)
──────────────────────────────────
[████████████░░░░░░░░░] ← bar with your dot

Your details:
Height:          168 cm
Current weight:  78.0 kg
Ideal range:     52.3 – 70.4 kg
To reach healthy BMI: lose 5.7 kg

──────────────────────────────────
BMI history (last 10 entries):
  May 04 — 27.6
  May 01 — 27.8
  Apr 28 — 28.1
  (list, 11px textMuted)
──────────────────────────────────

Note: BMI is a general indicator.
It does not account for muscle mass.
Gym users with high muscle may show
elevated BMI incorrectly.
(11px textMuted, italic)

[Close]
```

---

### 12.9 Mode Switch Modal

**Title:** "Switch mode"
**Trigger:** App mode row in Profile.

```
Current: Normal mode

Switch to:
┌──────────────────────────────┐
│  Normal mode                 │
│  General lifestyle tracking  │
│  [Select]                    │
└──────────────────────────────┘

┌──────────────────────────────┐
│  Gym mode                    │
│  Protein, macros, shakes     │
│  [Select]                    │
└──────────────────────────────┘

If Gym mode selected, also shows:
Your gym goal:
[Fat loss] [Muscle gain] [Maintain] [Recomp]

⚠ Switching mode will regenerate
your diet plan unless you have
custom edits saved.

[Switch & update plan]  primary
[Cancel]                secondary
```

**On confirm:**
- `updateProfile({ mode, gymGoal })`
- Recalculate macros + calorie target
- Recalculate water target → re-schedule water notifications
- If `!planLockedByUser`: `regeneratePlan()` with new mode plan

---

### 12.10 Step Goal Modal

```
Daily step target
[ 10000                             ]
Presets: [5000] [8000] [10000] [12000]
[Save] [Cancel]
```

---

### 12.11 Calorie Target Modal

```
Daily calorie goal (kcal)
[ 1800                              ]
Presets: [1500] [1800] [2000] [2200]

Recommended based on your stats:
TDEE – 400 = 1800 kcal   (11px textMuted)

[Recalculate from profile]   secondary
[Save] [Cancel]
```

---

### 12.12 Units Modal

```
[Metric (kg, cm)]
[Imperial (lbs, ft/in)]

Note: Changing units does not
convert existing log entries.

[Save] [Cancel]
```

---

### 12.13 Day Detail Modal

**Trigger:** Tap any date cell in Calendar.

```
Wed, 30 Apr                        [✕]

Status: [On plan ✓]   (green pill)

Scores:
Diet score     72%   [████████░░]
Water score    85%   [█████████░]
Calorie score  90%   [█████████░]
Protein score  78%   [████████░░]  ← gym mode only
Workout:       Done ✓

BMI at day:    27.8
Weight logged: 78.5 kg

Steps: — (not tracked)

─────────────────────────────────
Activity log:
07:30  Logged breakfast ✓
08:30  Added 250ml water
13:05  Completed lunch
18:35  Workout done
20:30  Logged dinner
─────────────────────────────────

[Close]
```

---

### 12.14 Reminder Interval Modal

```
Water reminder window
Start: [ 07:00 ]   End: [ 22:00 ]

Remind every
[30min] [60min] [90min] [2h] [3h]

[Save] [Cancel]
```

---

## 13. Components Library

### `<BmiCard>`

```dart
class BmiCard (props) {
  double bmi;
  String category;
  double heightCm;
  double weightKg;
  onDetail:     () => void;
}
```

### `<BmiTrendChart>`

```dart
interface BmiTrendChartProps {
  entries:  WeightEntry[];   // has .bmi field
  double? height;          // default 80
}
```

### `<MacroCard>`

```dart
class MacroCard (props) {
  MacroTargets eaten;
  MacroTargets targets;
}
```

### `<ScoreCard>`

```dart
class ScoreCard (props) {
  String label;
  String value;
  double fillPct;
  String fillColor;
}
```

### `<WaterCard>`

```dart
interface WaterCardProps {
  config:         WaterConfig;
  onAdd:          (double ml) => void;
  onEditTarget:   () => void;
  onEditReminder: () => void;
}
```

### `<WeeklyWorkoutRow>`

```dart
interface WeeklyWorkoutRowProps {
  plan:  List<String>;  // 7-item array
  today: double;    // 0=Mon, 6=Sun
}
```

### `<ScheduleItem>`

```dart
interface ScheduleItemProps {
  item:       ScheduleItem;
  onToggle:   () => void;
  onReminder: () => void;
}
```

### `<CalendarGrid>`

```dart
interface CalendarGridProps {
  double year;
  double month;
  records:    Record<string, DayRecord>;
  onDayPress: (date: String) => void;
}
```

### `<WeightTrendChart>`

```dart
interface WeightTrendChartProps {
  entries: WeightEntry[];
  height?: double;
}
```

### `<RatioBar>`

```dart
interface RatioBarProps {
  String label;
  value: double;
  String color;
}
```

### `<RingChart>`

```dart
interface RingChartProps {
  double value;
  String color;
  String label;
  double? size;
}
```

### All other components match v2.0 spec.

---

## 14. Notification System — Full Spec

### `lib/services/notifications.ts`

```dart
import * as Notifications from 'flutter_local_notifications + firebase_messaging';
import 'package:timezone/timezone.dart' as tz;

// Flutter: configure foreground notification presentation in AndroidManifest.xml
// and Info.plist. Use flutter_local_notifications for foreground display.

Future<void> Future<bool> requestPermissions() {
  const { status } = await FirebaseMessaging.instance.requestPermission();
  return status === 'granted';
}

function nextOccurrence(hours: double, minutes: double): Date {
  const now  = new Date();
  const next = setMinutes(setHours(new Date(), hours), minutes);
  next.setSeconds(0); next.setMilliseconds(0);
  if (next <= now) return addDays(next, 1);
  return next;
}

// Schedule a manual reminder (meal/workout/sleep etc.)
Future<void> Future<String> scheduleReminder(Reminder reminder) {
  const [hours, minutes] = reminder.time.split(':').map(Number);

  if (reminder.repeat === 'weekday') {
    const ids: String[] = [];
    for (const weekday of [2, 3, 4, 5, 6]) {
      const id = await plugin.zonedSchedule({
        content: { title: 'VitaTrack', body: reminder.title, sound: true, data: { type: reminder.type } },
        trigger: { weekday, hour: hours, minute: minutes, repeats: true },
      });
      ids.push(id);
    }
    return ids.join(',');
  }

  const trigger = reminder.repeat === 'daily'
    ? { hour: hours, minute: minutes, repeats: true }
    : { date: nextOccurrence(hours, minutes) };

  return plugin.zonedSchedule({
    content: { title: 'VitaTrack', body: reminder.title, sound: true, data: { type: reminder.type } },
    trigger,
  });
}

Future<void> Future<void> cancelReminder(String notifId) {
  const ids = notifId.split(',');
  await Promise.all(ids.map(id => plugin.cancel(id)));
}

Future<void> Future<Reminder> toggleReminderNotif(Reminder reminder) {
  if (reminder.enabled && reminder.notifId) {
    await cancelReminder(reminder.notifId);
    return { ...reminder, enabled: false, notifId: undefined };
  }
  const notifId = await scheduleReminder(reminder);
  return { ...reminder, enabled: true, notifId };
}

// Schedule item-level reminder (bell icon on schedule item)
Future<void> Future<String> scheduleItemReminder(ScheduleItem item) {
  const [hours, minutes] = item.time.split(':').map(Number);
  return plugin.zonedSchedule({
    content: {
      title: 'VitaTrack',
      body:  `Time for: ${item.title}`,
      sound: true,
      data:  { type: item.type, itemId: item.id },
    },
    trigger: { hour: hours, minute: minutes, repeats: true },
  });
}

// ─── Water notification management ───────────────────────────────────────────
// Delegated to waterEngine.ts — see Section 9
// Call: scheduleWaterNotifications(config) from waterEngine.dart

// ─── Default reminders seed ──────────────────────────────────────────────────
Future<void> seedDefaultReminders(
  reminders: List<Reminder>,
  pushEnabled: bool
): Future<List<Reminder>> {
  if (!pushEnabled) return reminders;
  const updated: List<Reminder> = [];
  for (const r of reminders) {
    if (r.enabled) {
      const notifId = await scheduleReminder(r);
      updated.push({ ...r, notifId });
    } else {
      updated.push(r);
    }
  }
  return updated;
}
```

### Default Reminders

```dart
const defaultReminders: // Omit<Reminder, 'id' | 'notifId'>[] = [
  { title: 'Morning water',          time: '07:00', type: 'water',   repeat: 'daily',   enabled: true  },
  { title: 'Mid-morning hydration',  time: '09:30', type: 'water',   repeat: 'daily',   enabled: true  },
  { title: 'Lunch time',             time: '13:00', type: 'meal',    repeat: 'daily',   enabled: true  },
  { title: 'Post-lunch walk',        time: '13:30', type: 'walk',    repeat: 'weekday', enabled: true  },
  { title: 'Evening snack',          time: '16:30', type: 'meal',    repeat: 'daily',   enabled: false },
  { title: 'Workout',                time: '18:30', type: 'workout', repeat: 'weekday', enabled: true  },
  { title: 'Dinner',                 time: '20:30', type: 'meal',    repeat: 'daily',   enabled: true  },
  { title: 'Sleep reminder',         time: '00:15', type: 'sleep',   repeat: 'daily',   enabled: false },
];
// Note: gym mode also adds:
const gymExtraReminders: // Omit<Reminder, 'id' | 'notifId'>[] = [
  { title: 'Pre-workout shake',      time: '16:00', type: 'protein', repeat: 'weekday', enabled: true  },
  { title: 'Post-workout shake',     time: '18:30', type: 'protein', repeat: 'weekday', enabled: true  },
  { title: 'Pre-bed casein',         time: '22:00', type: 'protein', repeat: 'daily',   enabled: true  },
];
```

---

## 15. State Management — Riverpod

All state is managed with `flutter_riverpod`. Screens are `ConsumerWidget`. 
Providers are defined in `lib/providers/`. State is persisted to Hive locally 
and synced to Firestore in background.

### Hive Initialisation (`lib/main.dart`)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  Hive.registerAdapter(ScheduleItemAdapter());  // typeId: 0
  Hive.registerAdapter(MacroTargetsAdapter());  // typeId: 1
  Hive.registerAdapter(WaterConfigAdapter());   // typeId: 2
  Hive.registerAdapter(WeightEntryAdapter());   // typeId: 3
  Hive.registerAdapter(UserProfileAdapter());   // typeId: 4
  Hive.registerAdapter(ReminderAdapter());      // typeId: 5
  Hive.registerAdapter(DayRecordAdapter());     // typeId: 6
  await Hive.openBox<ScheduleItem>('scheduleItems');
  await Hive.openBox<WaterConfig>('waterConfig');
  await Hive.openBox<Reminder>('reminders');
  await Hive.openBox<DayRecord>('dayRecords');
  await Hive.openBox<WeightEntry>('weightLog');
  await Hive.openBox<UserProfile>('profile');
  await Hive.openBox('activityLog');
  await NotificationService.init();
  await BackgroundService.init();
  runApp(const ProviderScope(child: VitaTrackApp()));
}
```

### Provider Definitions

```dart
// lib/providers/profile_provider.dart
final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  final box = Hive.box<UserProfile>('profile');
  return ProfileNotifier(box.get('current') ?? UserProfile.defaults(), ref);
});

class ProfileNotifier extends StateNotifier<UserProfile> {
  ProfileNotifier(super.state, this._ref);
  final Ref _ref;
  void updateProfile(UserProfile p) {
    state = p;
    Hive.box<UserProfile>('profile').put('current', p);
    FirestoreService.saveProfile(p); // background, fire-and-forget
  }
  void regeneratePlan() {
    final items = generatePlan(state);
    _ref.read(scheduleProvider.notifier).initScheduleFrom(items);
    updateProfile(state.copyWith(planLockedByUser: false));
  }
}

// lib/providers/schedule_provider.dart
final scheduleProvider = StateNotifierProvider<ScheduleNotifier, List<ScheduleItem>>((ref) {
  final box = Hive.box<ScheduleItem>('scheduleItems');
  return ScheduleNotifier(box.values.toList(), ref);
});

class ScheduleNotifier extends StateNotifier<List<ScheduleItem>> {
  ScheduleNotifier(super.state, this._ref);
  final Ref _ref;
  void setItemDone(String id, bool done) {
    state = [for (final i in state) i.id == id ? i.copyWith(done: done) : i];
    _persist(); _log(done ? 'Completed: ${_find(id)?.title}' : 'Unchecked: ${_find(id)?.title}');
  }
  void updateItem(String id, ScheduleItem patch) {
    state = ([for (final i in state) i.id == id ? patch : i]
      ..sort((a, b) => a.time.compareTo(b.time)));
    _persist();
    _ref.read(profileProvider.notifier)
      .updateProfile(_ref.read(profileProvider).copyWith(planLockedByUser: true));
  }
  void deleteItem(String id) {
    state = state.where((i) => i.id != id).toList(); _persist();
    _ref.read(profileProvider.notifier)
      .updateProfile(_ref.read(profileProvider).copyWith(planLockedByUser: true));
  }
  void addItem(ScheduleItem item) {
    state = ([...state, item]..sort((a, b) => a.time.compareTo(b.time))); _persist();
    _ref.read(profileProvider.notifier)
      .updateProfile(_ref.read(profileProvider).copyWith(planLockedByUser: true));
  }
  void initScheduleFrom(List<ScheduleItem> items) { state = items; _persist(); }
  void resetDone() { state = [for (final i in state) i.copyWith(done: false)]; _persist(); }
  void _persist() {
    final box = Hive.box<ScheduleItem>('scheduleItems');
    box.clear();
    for (final item in state) box.put(item.id, item);
    FirestoreService.saveSchedule(state);
  }
  ScheduleItem? _find(String id) =>
    state.cast<ScheduleItem?>().firstWhere((i) => i?.id == id, orElse: () => null);
  void _log(String? msg) {
    if (msg != null) _ref.read(activityLogProvider.notifier).addLog(msg);
  }
}

// lib/providers/water_provider.dart
final waterProvider = StateNotifierProvider<WaterNotifier, WaterConfig>((ref) {
  final box = Hive.box<WaterConfig>('waterConfig');
  return WaterNotifier(box.get('current') ?? WaterConfig(), ref);
});

class WaterNotifier extends StateNotifier<WaterConfig> {
  WaterNotifier(super.state, this._ref);
  final Ref _ref;
  void addWater(int ml) {
    state = state.copyWith(consumed: state.consumed + ml); _persist();
    _ref.read(activityLogProvider.notifier).addLog('Added ${ml}ml water');
  }
  void resetWater() { state = state.copyWith(consumed: 0); _persist(); }
  void setWaterTarget(int ml) {
    state = state.copyWith(target: ml); _persist();
    NotificationService.scheduleWaterNotifications(state);
  }
  void setWaterConfig(WaterConfig config) { state = config; _persist(); }
  void _persist() {
    Hive.box<WaterConfig>('waterConfig').put('current', state);
    FirestoreService.saveWaterConfig(state);
  }
}

// lib/providers/weight_log_provider.dart
final weightLogProvider = StateNotifierProvider<WeightLogNotifier, List<WeightEntry>>((ref) {
  final box = Hive.box<WeightEntry>('weightLog');
  return WeightLogNotifier(
    box.values.toList()..sort((a,b) => a.date.compareTo(b.date)), ref);
});

class WeightLogNotifier extends StateNotifier<List<WeightEntry>> {
  WeightLogNotifier(super.state, this._ref);
  final Ref _ref;
  void addWeightEntry(WeightEntry entry) {
    state = [...state.where((e) => e.date != entry.date), entry]
      ..sort((a, b) => a.date.compareTo(b.date));
    Hive.box<WeightEntry>('weightLog').put(entry.date, entry);
    // BMI cascade
    final profile  = _ref.read(profileProvider);
    final weightKg = profile.units == 'imperial' ? entry.weight * 0.453592 : entry.weight;
    final newBmi   = calculateBmi(weightKg, profile.heightCm);
    final newCat   = getBmiCategory(newBmi);
    final waterTgt = calculateWaterTarget(weightKg, profile.mode);
    final tdee     = calculateTDEE(weightKg: weightKg, heightCm: profile.heightCm,
      age: profile.age, gender: profile.gender, activityLevel: profile.activityLevel);
    final calTgt   = getCalorieTarget(tdee, newCat, profile.mode, profile.gymGoal);
    final macros   = getMacroTargets(calTgt, weightKg, profile.mode, profile.gymGoal);
    final updated  = profile.copyWith(currentWeight: entry.weight, bmi: newBmi,
      bmiCategory: newCat, macroTargets: macros);
    _ref.read(profileProvider.notifier).updateProfile(updated);
    _ref.read(waterProvider.notifier).setWaterTarget(waterTgt);
    if (newCat != profile.bmiCategory && !profile.planLockedByUser) {
      _ref.read(profileProvider.notifier).regeneratePlan();
    }
    _ref.read(activityLogProvider.notifier)
      .addLog('Weight: ${entry.weight}${profile.units == "metric" ? "kg" : "lbs"} · BMI $newBmi');
    FirestoreService.saveWeightLog(state);
  }
}

// lib/providers/activity_log_provider.dart
final activityLogProvider = StateNotifierProvider<ActivityLogNotifier, List<LogEntry>>((ref) {
  return ActivityLogNotifier([]);
});
class ActivityLogNotifier extends StateNotifier<List<LogEntry>> {
  ActivityLogNotifier(super.state);
  void addLog(String message) {
    final now = DateTime.now();
    final time = '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}';
    state = [LogEntry(time: time, message: message), ...state];
  }
  void clear() => state = [];
}

// lib/providers/computed_providers.dart
final caloriesEatenProvider = Provider<int>((ref) =>
  ref.watch(scheduleProvider).where((i) => i.done).fold(0, (s, i) => s + i.calories));

final proteinEatenProvider = Provider<int>((ref) =>
  ref.watch(scheduleProvider).where((i) => i.done).fold(0, (s, i) => s + i.protein));

final dietScoreProvider = Provider<int>((ref) {
  final meals = ref.watch(scheduleProvider).where((i) => i.type == 'meal').toList();
  if (meals.isEmpty) return 0;
  return (meals.where((i) => i.done).length / meals.length * 100).round();
});

final waterScoreProvider = Provider<int>((ref) {
  final c = ref.watch(waterProvider);
  return (c.consumed / c.target * 100).clamp(0, 100).round();
});

final streakProvider = Provider<int>((ref) {
  final records = ref.watch(dayRecordProvider);
  var streak = 0;
  var date   = DateTime.now();
  while (true) {
    final k = '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';
    if (records[k]?.status != 'success') break;
    streak++; date = date.subtract(const Duration(days: 1));
  }
  return streak;
});
```

### Midnight Reset (`lib/services/background_service.dart`)

```dart
import 'package:workmanager/workmanager.dart';

class BackgroundService {
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await Workmanager().registerPeriodicTask(
      'midnightReset', 'midnightReset',
      frequency: const Duration(hours: 1),
      constraints: Constraints(networkType: NetworkType.not_required),
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'midnightReset') {
      final prefs  = await SharedPreferences.getInstance();
      final today  = DateTime.now();
      final todayK = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
      final lastK  = prefs.getString('vitatrack_last_reset_date');
      if (lastK == todayK) return true; // already reset today

      await Hive.initFlutter();
      // Register adapters (required in background isolate)
      // ... (same as main.dart)
      final scheduleBox = await Hive.openBox<ScheduleItem>('scheduleItems');
      final waterBox    = await Hive.openBox<WaterConfig>('waterConfig');

      // Reset schedule done flags
      for (final item in scheduleBox.values) {
        scheduleBox.put(item.id, item.copyWith(done: false));
      }
      // Reset water consumed
      final water = waterBox.get('current');
      if (water != null) waterBox.put('current', water.copyWith(consumed: 0));
      await prefs.setString('vitatrack_last_reset_date', todayK);
    }
    return true;
  });
}
```
---

## 16. Storage Schema

| Key | Type | Description |
|---|---|---|
| `vitatrack_store-v3` | JSON | Full persisted Riverpod state |
| `vitatrack_onboarded` | `"true"` | Skip onboarding flag |
| `vitatrack_notif-granted` | `"true"` | Notification permission flag |

### Data Size Estimates

| Data | Est. size |
|---|---|
| Schedule (13 items, with macros) | ~6 KB |
| DayRecords (1 year) | ~250 KB |
| WeightLog (1 year daily) | ~20 KB |
| Reminders (20 items) | ~4 KB |
| ActivityLog (daily) | ~5 KB |
| **Total (1 year)** | **~285 KB** |

---

## 17. Animations & Micro-interactions

| Element | Animation |
|---|---|
| Schedule item check | `AnimationController` + spring `Curve` scale 0→1 on checkmark, damping 15 |
| Schedule item uncheck | `AnimatedContainer` / `TweenAnimationBuilder` opacity 1→0.4, 200ms |
| Water progress bar | `AnimatedContainer` / `TweenAnimationBuilder` width, 400ms, `Curves.easeOut` |
| Calorie/Macro bars | Same as water bar |
| BMI bar | `AnimatedContainer` / `TweenAnimationBuilder` width on mount, 800ms, `Curves.elasticOut` |
| BMI dot position | `AnimationController` + spring `Curve` when BMI changes (weight log) |
| Score bar fill | `AnimatedContainer` / `TweenAnimationBuilder`, 600ms on mount, `Curves.easeOutQuad` |
| Ring chart arc | `AnimatedContainer` / `TweenAnimationBuilder` strokeDashoffset, 800ms, delay = index × 150ms |
| RatioBar fill | `AnimatedContainer` / `TweenAnimationBuilder` width, 600ms, delay = index × 80ms |
| Modal open | `AnimationController` + spring `Curve` translateY from screen height, damping 20, stiffness 200 |
| Modal close | `AnimatedContainer` / `TweenAnimationBuilder` translateY to screen height, 220ms, `Curves.easeIn` |
| Toggle switch | `AnimationController` + spring `Curve` knob translateX, 200ms, damping 18 |
| Calendar day press | Scale 1→0.92→1, `AnimationController` sequence |
| Streak pill | Pulse: scale 1→1.05→1, 2 loops on increment |
| Water quick-add | Scale 1→0.94→1, 120ms |
| BMI category change | Flash pulse on BMI value: opacity 1→0.3→1, 300ms |
| Water reminder preview | Rows fade in staggered, 50ms delay each |

All use `Flutter animations use GPU by default` for `transform`/`opacity`.
Progress bar widths use `use `AnimatedContainer` for layout animations` with layout animation.

---

## 18. Implementation Order

Build in this exact order to avoid missing dependency errors:

1. **`pubspec.yaml`** — add all dependencies listed in Section 2. Run `flutter pub get`.
2. **`lib/constants/`** — colors, typography, spacing. No dependencies.
2. **`src/store/types.dart`** — all interfaces. Depends on constants only.
3. **`lib/services/bmiEngine.ts`** — BMI + TDEE + plan selection logic.
4. **`lib/services/waterEngine.ts`** — water target + schedule builder.
5. **`lib/constants/defaultPlanNormal.ts`** — 4 normal mode plan arrays.
6. **`lib/constants/defaultPlanGym.ts`** — 4 gym mode plan arrays.
7. **`lib/services/notifications.ts`** — all notification logic.
8. **`lib/services/dateHelpers.ts`** — todayISO, currentTime, registerMidnightReset.
9. **`src/store/app_store.dart`** — Riverpod providers + Hive. Imports all utils.
10. **Leaf components:** `ScoreCard`, `RatioBar`, `RingChart`, `ToggleSwitch`, `FilterChip`
11. **Mid-level components:** `BmiCard`, `BmiTrendChart`, `MacroCard`, `WaterCard`,
    `CalorieCard`, `WeeklyWorkoutRow`, `WeightTrendChart`, `ScheduleItem`,
    `ReminderItem`, `SettingsRow`, `ScoreRow`, `ActivityLogList`
12. **`BottomSheet.dart`** — shared modal wrapper.
13. **All modals** — import BottomSheet + components.
14. **`CalendarGrid.dart`** — imports RatioBar + RingChart.
15. **Screen components** — `TodayScreen`, `CalendarScreen`, `RemindersScreen`, `ProfileScreen`.
16. **`_layout.dart`** — root navigator, onboarding gate, `registerMidnightReset()` call.
17. **`OnboardingScreen.dart`** — last; depends on bmiEngine, waterEngine, store init.

### Critical Rules for AI Agents

- All colours → `Colors.*` — zero hardcoded hex in component files.
- `deriveInitials(name)` → computed at render time. Never stored.
- BMI recalculates **every** `addWeightEntry()` call — not just on Profile save.
- Water target recalculates from weight — always call `calculateWaterTarget()` after weight log.
- If BMI category changes AND `planLockedByUser === false` → regenerate plan automatically.
- Show toast on plan regeneration: never silently replace the plan.
- Water notifications are distinct from manual reminders — managed separately, not shown in Reminders screen.
- `planLockedByUser = true` on any `updateItem`, `deleteItem`, or `addItem` call.
- Store key is `'vitatrack_store'` — bump version if schema changes to avoid migration errors.
- `weekday` repeat → 5 separate notifications → `notifId` is comma-joined string.
- On `deleteReminder`: call `cancelReminder(notifId)` BEFORE `deleteReminder(id)`.
- Gym mode score formula includes protein score; normal mode uses 100 as bonus (always met).
- Age and gender **must be stored** in `UserProfile` — required for TDEE calculation.
- `activityLog` resets on midnight — do not persist more than one day's log at a time.

---

*Document version: 4.0 · May 2026*
*Framework: Flutter (Dart) + Firebase*
*Status: Complete — BMI engine, normal/gym diet plans, water notification engine,
all modals, all screens, state management, and implementation order fully specified.*

import 'package:flutter/material.dart';

class AppThemeState {
  static bool isDark = true;
}

class AppColors {
  static Color get bg0 => AppThemeState.isDark ? const Color(0xFF080810) : const Color(0xFFF5F5F7);
  static Color get bg1 => AppThemeState.isDark ? const Color(0xFF0C0C1A) : const Color(0xFFFFFFFF);
  static Color get bg2 => AppThemeState.isDark ? const Color(0xFF13132A) : const Color(0xFFF0F0F5);
  static Color get bg3 => AppThemeState.isDark ? const Color(0xFF1E1E3A) : const Color(0xFFE5E5EA);
  static Color get bg4 => AppThemeState.isDark ? const Color(0xFF1A1A35) : const Color(0xFFD1D1D6);

  static Color get border1 => AppThemeState.isDark ? const Color(0xFF1E1E3A) : const Color(0xFFE5E5EA);
  static Color get border2 => AppThemeState.isDark ? const Color(0xFF2A2A55) : const Color(0xFFC7C7CC);

  static Color get accent => const Color(0xFF6C63FF);
  static Color get accentSoft => const Color(0xFF9988FF);
  static Color get accentBg => AppThemeState.isDark ? const Color(0xFF1A1A3A) : const Color(0xFFE0E0FF);

  static Color get green => const Color(0xFF5DCAA5);
  static Color get greenDark => AppThemeState.isDark ? const Color(0xFF082E18) : const Color(0xFFD0F0E0);
  static Color get amber => const Color(0xFFEF9F27);
  static Color get amberDark => AppThemeState.isDark ? const Color(0xFF2E1A08) : const Color(0xFFFFECCC);
  static Color get red => const Color(0xFFE24B4A);
  static Color get redDark => AppThemeState.isDark ? const Color(0xFF2E0808) : const Color(0xFFFFDEDE);
  static Color get lavender => const Color(0xFFAFA9EC);
  static Color get blue => const Color(0xFF85B7EB);
  static Color get teal => const Color(0xFF1D9E75);
  static Color get tealDark => AppThemeState.isDark ? const Color(0xFF04342C) : const Color(0xFFCCEEE4);

  static Color get textPrimary => AppThemeState.isDark ? const Color(0xFFDDDDDD) : const Color(0xFF1C1C1E);
  static Color get textSecondary => AppThemeState.isDark ? const Color(0xFF888888) : const Color(0xFF8E8E93);
  static Color get textMuted => AppThemeState.isDark ? const Color(0xFF444444) : const Color(0xFFAEAEB2);
  static Color get textDisabled => AppThemeState.isDark ? const Color(0xFF333333) : const Color(0xFFC7C7CC);
  static Color get white => AppThemeState.isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1E);
  static Color get pureWhite => const Color(0xFFFFFFFF);

  // BMI category colours
  static Color get bmiUnder => const Color(0xFF85B7EB);
  static Color get bmiNormal => const Color(0xFF5DCAA5);
  static Color get bmiOver => const Color(0xFFEF9F27);
  static Color get bmiObese => const Color(0xFFE24B4A);

  // Icon box backgrounds
  static Color get iconMeal => AppThemeState.isDark ? const Color(0xFF0A2E1A) : const Color(0xFFD0F0E0);
  static Color get iconWater => AppThemeState.isDark ? const Color(0xFF0D1235) : const Color(0xFFD0E0FF);
  static Color get iconWorkout => AppThemeState.isDark ? const Color(0xFF2E0D18) : const Color(0xFFFFD0E0);
  static Color get iconSnack => AppThemeState.isDark ? const Color(0xFF1E1A08) : const Color(0xFFFFECCC);
  static Color get iconSleep => AppThemeState.isDark ? const Color(0xFF12082E) : const Color(0xFFE0D0FF);
  static Color get iconWalk => AppThemeState.isDark ? const Color(0xFF082E2E) : const Color(0xFFD0F0F0);
  static Color get iconProtein => AppThemeState.isDark ? const Color(0xFF0D1A2E) : const Color(0xFFD0E0FF);
  static Color get iconCustom => AppThemeState.isDark ? const Color(0xFF1A1A3A) : const Color(0xFFE0E0FF);
}

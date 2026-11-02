import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Design tokens: light, flat and minimal. A single blue accent plus basic
/// status colors; no gradients, blur or glow. Every screen and widget reads
/// from here; no ad-hoc colors, sizes or radii elsewhere.
///
/// Naming: `x` is the main color, `xLight` a darker variant that stays readable
/// as text/icons on white, `xTint` a pale fill for tinted cards.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF2563EB);
  static const primaryDeep = Color(0xFF1D4ED8);
  static const primaryLight = Color(0xFF1D4ED8);
  static const primaryTint = Color(0xFFEFF6FF);

  static const accent = Color(0xFF2563EB);
  static const accentLight = Color(0xFF1D4ED8);
  static const accentTint = Color(0xFFEFF6FF);

  static const orange = Color(0xFFF59E0B);
  static const orangeLight = Color(0xFFB45309);
  static const orangeTint = Color(0xFFFFFBEB);

  static const red = Color(0xFFDC2626);
  static const redLight = Color(0xFFB91C1C);
  static const redTint = Color(0xFFFEF2F2);

  static const yellow = Color(0xFFF59E0B);
  static const yellowLight = Color(0xFFB45309);

  static const success = Color(0xFF16A34A);
  static const successLight = Color(0xFF15803D);
  static const successTint = Color(0xFFF0FDF4);

  static const background = Colors.white;
  static const surface = Colors.white;
  /// Shade for the app header and nav bar, so they read apart from the white page.
  static const chrome = Color(0xFFEAF2FF);
  static const surfaceMuted = Color(0xFFF3F4F6);
  static const border = Color(0xFFE5E7EB);
  static const disabled = Color(0xFFD1D5DB);

  static const text = Color(0xFF374151);
  static const textStrong = Color(0xFF111827);
  static const textMuted = Color(0xFF6B7280);
}

/// The app's icon set (Phosphor: bold for UI chrome, fill for emphasis and
/// selected states). Never use `Icons.*` directly.
///
/// Only the font assets of `phosphor_flutter` are used: its Dart API extends
/// `IconData`, which current Flutter no longer allows.
class AppIcons {
  AppIcons._();
  static const _pkg = 'phosphor_flutter';

  static const home = IconData(0xe2c2, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);
  static const homeFill = IconData(0xe2c2, fontFamily: 'PhosphorFill', fontPackage: _pkg, matchTextDirection: true);
  static const mic = IconData(0xe326, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);
  static const micFill = IconData(0xe326, fontFamily: 'PhosphorFill', fontPackage: _pkg, matchTextDirection: true);
  static const history = IconData(0xe1a0, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);
  static const historyFill = IconData(0xe1a0, fontFamily: 'PhosphorFill', fontPackage: _pkg, matchTextDirection: true);
  static const profile = IconData(0xe4c4, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);
  static const profileFill = IconData(0xe4c4, fontFamily: 'PhosphorFill', fontPackage: _pkg, matchTextDirection: true);

  static const back = IconData(0xe138, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);
  static const next = IconData(0xe13a, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);
  static const close = IconData(0xe4f6, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);
  static const check = IconData(0xe182, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);
  static const checkCircle = IconData(0xe184, fontFamily: 'PhosphorFill', fontPackage: _pkg, matchTextDirection: true);
  static const xCircle = IconData(0xe4f8, fontFamily: 'PhosphorFill', fontPackage: _pkg, matchTextDirection: true);
  static const warning = IconData(0xe4e0, fontFamily: 'PhosphorFill', fontPackage: _pkg, matchTextDirection: true);
  static const speaker = IconData(0xe44a, fontFamily: 'PhosphorFill', fontPackage: _pkg, matchTextDirection: true);
  static const stop = IconData(0xe46c, fontFamily: 'PhosphorFill', fontPackage: _pkg, matchTextDirection: true);
  static const play = IconData(0xe3d0, fontFamily: 'PhosphorFill', fontPackage: _pkg, matchTextDirection: true);
  static const shuffle = IconData(0xe422, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);
  static const refresh = IconData(0xe094, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);
  static const search = IconData(0xe30c, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);
  static const edit = IconData(0xe3b4, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);

  static const streak = IconData(0xe242, fontFamily: 'PhosphorFill', fontPackage: _pkg, matchTextDirection: true);
  static const trophy = IconData(0xe67e, fontFamily: 'PhosphorFill', fontPackage: _pkg, matchTextDirection: true);
  static const star = IconData(0xe46a, fontFamily: 'PhosphorFill', fontPackage: _pkg, matchTextDirection: true);
  static const bolt = IconData(0xe2de, fontFamily: 'PhosphorFill', fontPackage: _pkg, matchTextDirection: true);
  static const chart = IconData(0xe156, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);
  static const calendar = IconData(0xe712, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);
  static const objection = IconData(0xe17e, fontFamily: 'PhosphorFill', fontPackage: _pkg, matchTextDirection: true);
  static const chat = IconData(0xe16c, fontFamily: 'PhosphorFill', fontPackage: _pkg, matchTextDirection: true);
  static const hint = IconData(0xe2dc, fontFamily: 'PhosphorFill', fontPackage: _pkg, matchTextDirection: true);
  static const hideEye = IconData(0xe224, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);
  static const box = IconData(0xe390, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);

  static const user = IconData(0xe4c2, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);
  static const badge = IconData(0xe6f6, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);
  static const pin = IconData(0xe316, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);
  static const phone = IconData(0xe3b8, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);
  static const admin = IconData(0xe40c, fontFamily: 'PhosphorBold', fontPackage: _pkg, matchTextDirection: true);
}

/// Text-safe color for a 0-10 score: green 7+, orange 4+, red below.
Color scoreColor(double s) => s >= 7 ? AppColors.successLight : (s >= 4 ? AppColors.orangeLight : AppColors.redLight);

/// Tint matching [scoreColor], for badge backgrounds.
Color scoreTint(double s) => s >= 7 ? AppColors.successTint : (s >= 4 ? AppColors.orangeTint : AppColors.redTint);

class AppSpace {
  AppSpace._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadius {
  AppRadius._();
  static const double card = 16;
  static const double button = 14;
  static const double pill = 999;
}

/// Type scale. Baloo Da 2 is rounded and covers both Latin and Bengali.
class AppText {
  AppText._();
  static const family = 'BalooDa2';

  static const display = TextStyle(fontSize: 30, fontWeight: FontWeight.w800, height: 1.25, color: AppColors.textStrong);
  static const title = TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1.3, color: AppColors.textStrong);
  static const headline = TextStyle(fontSize: 17, fontWeight: FontWeight.w800, height: 1.35, color: AppColors.textStrong);
  static const body = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.45, color: AppColors.text);
  static const bodyStrong = TextStyle(fontSize: 15, fontWeight: FontWeight.w800, height: 1.45, color: AppColors.text);
  static const caption = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.4, color: AppColors.textMuted);
  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.3, height: 1.2);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.light).copyWith(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.primary,
    tertiary: AppColors.orange,
    error: AppColors.red,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
  );

  final base = ThemeData(brightness: Brightness.light, useMaterial3: true, fontFamily: AppText.family);
  final textTheme = base.textTheme
      .apply(bodyColor: AppColors.text, displayColor: AppColors.textStrong, fontFamily: AppText.family)
      .copyWith(
        headlineMedium: AppText.display,
        headlineSmall: AppText.title,
        titleLarge: AppText.title,
        titleMedium: AppText.headline,
        titleSmall: AppText.bodyStrong,
        bodyLarge: AppText.body,
        bodyMedium: AppText.body,
        bodySmall: AppText.caption,
        labelLarge: AppText.button,
        labelMedium: AppText.caption,
      );

  final roundedBorder = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button));
  const hairline = BorderSide(color: AppColors.border, width: 2);

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme,
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 2, space: 2),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary),
    iconTheme: const IconThemeData(color: AppColors.text),
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (_) => const Icon(AppIcons.back),
      closeButtonIconBuilder: (_) => const Icon(AppIcons.close),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.chrome,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppText.title,
      iconTheme: IconThemeData(color: AppColors.textStrong),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card), side: hairline),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.chrome,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 64,
      indicatorColor: Colors.white,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.primary, width: 2),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith((states) => AppText.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.textMuted,
          )),
      iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.textMuted)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(64, 50),
        textStyle: AppText.button,
        shape: roundedBorder,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(64, 50),
        textStyle: AppText.button,
        side: hairline,
        shape: roundedBorder,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primary, textStyle: AppText.button, shape: roundedBorder),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.md),
      hintStyle: AppText.body.copyWith(color: AppColors.textMuted),
      labelStyle: AppText.body.copyWith(color: AppColors.textMuted),
      prefixIconColor: AppColors.textMuted,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.card), borderSide: hairline),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.card), borderSide: hairline),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: AppText.title,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textStrong,
      contentTextStyle: AppText.bodyStrong.copyWith(color: Colors.white),
      shape: roundedBorder,
    ),
  );
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Spacing scale used across the app (multiples of 4).
abstract final class Gap {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Corner radii used across the app.
abstract final class Corners {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double pill = 999;
}

/// Warm "kitchen" palette: terracotta primary, olive secondary, amber tertiary, cream surfaces.
abstract final class AppColors {
  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF993C1D),
    onPrimary: Color(0xFFFFFBF5),
    primaryContainer: Color(0xFFFAECE7),
    onPrimaryContainer: Color(0xFF4A1B0C),
    secondary: Color(0xFF3B6D11),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFEAF3DE),
    onSecondaryContainer: Color(0xFF173404),
    tertiary: Color(0xFF854F0B),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFAEEDA),
    onTertiaryContainer: Color(0xFF412402),
    error: Color(0xFFA32D2D),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFCEBEB),
    onErrorContainer: Color(0xFF501313),
    surface: Color(0xFFFFFBF5),
    onSurface: Color(0xFF2C2C2A),
    onSurfaceVariant: Color(0xFF5F5E5A),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFBF6EE),
    surfaceContainer: Color(0xFFF6F1E8),
    surfaceContainerHigh: Color(0xFFF1EFE8),
    surfaceContainerHighest: Color(0xFFEAE6DC),
    outline: Color(0xFF888780),
    outlineVariant: Color(0xFFD3D1C7),
    inverseSurface: Color(0xFF2C2C2A),
    onInverseSurface: Color(0xFFF1EFE8),
    inversePrimary: Color(0xFFF0997B),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Colors.transparent,
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFF0997B),
    onPrimary: Color(0xFF4A1B0C),
    primaryContainer: Color(0xFF712B13),
    onPrimaryContainer: Color(0xFFFAECE7),
    secondary: Color(0xFF97C459),
    onSecondary: Color(0xFF173404),
    secondaryContainer: Color(0xFF27500A),
    onSecondaryContainer: Color(0xFFEAF3DE),
    tertiary: Color(0xFFEF9F27),
    onTertiary: Color(0xFF412402),
    tertiaryContainer: Color(0xFF633806),
    onTertiaryContainer: Color(0xFFFAEEDA),
    error: Color(0xFFF09595),
    onError: Color(0xFF501313),
    errorContainer: Color(0xFF791F1F),
    onErrorContainer: Color(0xFFFCEBEB),
    surface: Color(0xFF1A1917),
    onSurface: Color(0xFFEDEAE3),
    onSurfaceVariant: Color(0xFFB4B2A9),
    surfaceContainerLowest: Color(0xFF141312),
    surfaceContainerLow: Color(0xFF201F1C),
    surfaceContainer: Color(0xFF252420),
    surfaceContainerHigh: Color(0xFF2D2C28),
    surfaceContainerHighest: Color(0xFF383732),
    outline: Color(0xFF888780),
    outlineVariant: Color(0xFF444441),
    inverseSurface: Color(0xFFEDEAE3),
    onInverseSurface: Color(0xFF2C2C2A),
    inversePrimary: Color(0xFF993C1D),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Colors.transparent,
  );
}

/// Soft tile colours for recipe and collection artwork: (background, icon) for light and dark.
abstract final class TileColors {
  static const _light = [
    (Color(0xFFFAC775), Color(0xFF633806)), // amber
    (Color(0xFFF5C4B3), Color(0xFF712B13)), // coral
    (Color(0xFFC0DD97), Color(0xFF27500A)), // green
    (Color(0xFF9FE1CB), Color(0xFF085041)), // teal
    (Color(0xFFF4C0D1), Color(0xFF72243E)), // pink
    (Color(0xFFCECBF6), Color(0xFF3C3489)), // purple
  ];
  static const _dark = [
    (Color(0xFF633806), Color(0xFFFAC775)),
    (Color(0xFF712B13), Color(0xFFF5C4B3)),
    (Color(0xFF27500A), Color(0xFFC0DD97)),
    (Color(0xFF085041), Color(0xFF9FE1CB)),
    (Color(0xFF72243E), Color(0xFFF4C0D1)),
    (Color(0xFF3C3489), Color(0xFFCECBF6)),
  ];

  static int get count => _light.length;

  static (Color background, Color foreground) of(
    BuildContext context,
    int index,
  ) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final list = dark ? _dark : _light;
    return list[index % list.length];
  }
}

abstract final class AppTheme {
  static ThemeData light() => _build(AppColors.light);
  static ThemeData dark() => _build(AppColors.dark);

  static ThemeData _build(ColorScheme c) {
    final base = ThemeData(colorScheme: c, useMaterial3: true);
    final body = GoogleFonts.interTextTheme(base.textTheme);
    // Headings in a warm serif; everything else in Inter.
    TextStyle? serif(TextStyle? s, {FontWeight weight = FontWeight.w600}) =>
        GoogleFonts.fraunces(textStyle: s, fontWeight: weight);
    final text = body
        .copyWith(
          displayLarge: serif(body.displayLarge),
          displayMedium: serif(body.displayMedium),
          displaySmall: serif(body.displaySmall),
          headlineLarge: serif(body.headlineLarge),
          headlineMedium: serif(body.headlineMedium),
          headlineSmall: serif(body.headlineSmall),
          titleLarge: serif(body.titleLarge),
          titleMedium: body.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          titleSmall: body.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          labelLarge: body.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        )
        .apply(bodyColor: c.onSurface, displayColor: c.onSurface);

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(Corners.sm),
      borderSide: BorderSide.none,
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Corners.sm + 2),
    );
    const buttonSize = Size(64, 48);

    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: c.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(fontSize: 22),
      ),
      cardTheme: CardThemeData(
        color: c.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.md),
          side: BorderSide(color: c.outlineVariant, width: 0.8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceContainerHigh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Gap.lg,
          vertical: 14,
        ),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        disabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: c.primary, width: 1.6),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: c.error, width: 1.2),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: c.error, width: 1.6),
        ),
        labelStyle: TextStyle(color: c.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: c.primary),
        hintStyle: TextStyle(color: c.onSurfaceVariant),
        prefixIconColor: c.onSurfaceVariant,
        suffixIconColor: c.onSurfaceVariant,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: text.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          elevation: 0,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          side: BorderSide(color: c.outlineVariant),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 44),
          shape: buttonShape,
          textStyle: text.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        elevation: 2,
        focusElevation: 2,
        hoverElevation: 3,
        highlightElevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        extendedTextStyle: text.labelLarge,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceContainerHigh,
        selectedColor: c.primary,
        secondarySelectedColor: c.primary,
        labelStyle: text.labelMedium?.copyWith(color: c.onSurface),
        secondaryLabelStyle: text.labelMedium?.copyWith(color: c.onPrimary),
        side: BorderSide.none,
        shape: const StadiumBorder(),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(
          horizontal: Gap.sm,
          vertical: Gap.xs,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.primaryContainer,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? c.onPrimaryContainer
                : c.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? c.onPrimaryContainer
                : c.onSurfaceVariant,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.surfaceContainerLowest,
        indicatorColor: c.primaryContainer,
        selectedIconTheme: IconThemeData(color: c.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: c.onSurfaceVariant),
        selectedLabelTextStyle: text.labelMedium?.copyWith(
          color: c.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: text.labelMedium?.copyWith(
          color: c.onSurfaceVariant,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surfaceContainerLowest,
        selectedItemColor: c.primary,
        unselectedItemColor: c.onSurfaceVariant,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Gap.lg,
          vertical: Gap.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.sm),
        ),
        iconColor: c.onSurfaceVariant,
        titleTextStyle: text.titleMedium,
        subtitleTextStyle: text.bodyMedium?.copyWith(color: c.onSurfaceVariant),
      ),
      dividerTheme: DividerThemeData(
        color: c.outlineVariant,
        thickness: 0.8,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: c.onInverseSurface),
        actionTextColor: c.inversePrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.sm),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.lg),
        ),
        titleTextStyle: text.headlineSmall?.copyWith(fontSize: 22),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Corners.lg)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.sm),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
      ),
    );
  }
}

/// Use only the bundled font files (assets/fonts), never download them, and list their
/// licences on Flutter's licence page. Call once at start-up and await it: the fonts
/// are loaded before the first frame, so text never flashes in a fallback font.
Future<void> useBundledFonts() async {
  GoogleFonts.config.allowRuntimeFetching = false;
  GoogleFonts.inter();
  GoogleFonts.inter(fontWeight: FontWeight.w500);
  GoogleFonts.inter(fontWeight: FontWeight.w600);
  GoogleFonts.fraunces(fontWeight: FontWeight.w600);
  await GoogleFonts.pendingFonts();
  LicenseRegistry.addLicense(() async* {
    for (final (family, file) in [
      ('Inter', 'Inter-OFL.txt'),
      ('Fraunces', 'Fraunces-OFL.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([
        family,
      ], await rootBundle.loadString('assets/fonts/$file'));
    }
  });
}

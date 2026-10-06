import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Which of the three appearances the app is currently wearing.
enum AppThemeMode { light, dark, gradient }

extension AppThemeModeInfo on AppThemeMode {
  String get label => switch (this) {
        AppThemeMode.light => 'Light',
        AppThemeMode.dark => 'Dark',
        AppThemeMode.gradient => 'Gradient',
      };

  String get blurb => switch (this) {
        AppThemeMode.light => 'Black on cream, the default',
        AppThemeMode.dark => 'Warm charcoal, easy at night',
        AppThemeMode.gradient => 'Indigo shading into violet',
      };

  bool get isDark => this != AppThemeMode.light;
}

/// One complete set of colour tokens.
///
/// Tokens are split by role rather than by appearance, which is the part
/// that matters when the palette flips. [ink] is text and inverts on dark;
/// [ctaFill] is the solid slab behind a primary button or a selected chip
/// and inverts with it; [onLightSurface] never moves, because the things it
/// paints sit on a chip that is white in every theme.
@immutable
class Palette {
  const Palette({
    required this.ink,
    required this.inkSoft,
    required this.grey,
    required this.greyLight,
    required this.hairline,
    required this.surface,
    required this.surfaceAlt,
    required this.ctaFill,
    required this.onCta,
    required this.purple,
    required this.purpleDeep,
    required this.purpleSoft,
    required this.purpleTile,
    required this.green,
    required this.greenSoft,
    required this.greenInk,
    required this.danger,
    required this.pinkSoft,
    required this.blueSoft,
    required this.tanSoft,
    required this.gold,
    this.pageGradient,
  });

  // Text, brightest to faintest.
  final Color ink;
  final Color inkSoft;
  final Color grey;
  final Color greyLight;

  final Color hairline;

  /// Page and card fill. Cards are told apart by their border, not their
  /// fill, which is why one token serves both.
  final Color surface;

  /// Subtly tinted panel: term tables, avatar chips, quiet blocks.
  final Color surfaceAlt;

  /// Solid slab for primary buttons, selected chips and the active dot.
  final Color ctaFill;
  final Color onCta;

  final Color purple;
  final Color purpleDeep;
  final Color purpleSoft;
  final Color purpleTile;
  final Color green;
  final Color greenSoft;

  /// Text and icons that sit *on* [greenSoft]. A fixed Material green works
  /// on the light tint and turns to mud on the dark one, so it moves too.
  final Color greenInk;

  /// Error text. Material's red is only just legible on a dark surface.
  final Color danger;
  final Color pinkSoft;
  final Color blueSoft;
  final Color tanSoft;
  final Color gold;

  /// Painted behind the whole app when set, with [surface] left translucent
  /// so it shows through.
  final Gradient? pageGradient;
}

const _light = Palette(
  ink: Color(0xFF1A1A1A),
  inkSoft: Color(0xFF3A3A3A),
  grey: Color(0xFF6B7280),
  greyLight: Color(0xFF9CA3AF),
  hairline: Color(0xFFE5E1DA),
  surface: Color(0xFFFFFFFF),
  surfaceAlt: Color(0xFFFBF8F2),
  ctaFill: Color(0xFF1A1A1A),
  onCta: Color(0xFFFFFFFF),
  purple: Color(0xFF6C4FD9),
  purpleDeep: Color(0xFF4B2FB0),
  purpleSoft: Color(0xFFF1EDFB),
  purpleTile: Color(0xFF8B6FF0),
  green: Color(0xFF1D9A5C),
  greenSoft: Color(0xFFEAF6EE),
  greenInk: Color(0xFF1B6B39),
  danger: Color(0xFFD0453F),
  pinkSoft: Color(0xFFFBE7E9),
  blueSoft: Color(0xFFE7F0FB),
  tanSoft: Color(0xFFFBF1E1),
  gold: Color(0xFFC9A227),
);

/// Warm charcoal rather than pure black: the light theme is cream-based, so
/// a neutral-warm dark keeps the same character and is easier to sit with.
const _dark = Palette(
  ink: Color(0xFFEDEBE7),
  inkSoft: Color(0xFFC6C3BD),
  grey: Color(0xFFA3A1A9),
  greyLight: Color(0xFF83818C),
  hairline: Color(0xFF33363F),
  surface: Color(0xFF1B1D23),
  surfaceAlt: Color(0xFF23262E),
  ctaFill: Color(0xFFEDEBE7),
  onCta: Color(0xFF15161A),
  purple: Color(0xFFAE95FF),
  purpleDeep: Color(0xFFCFBEFF),
  purpleSoft: Color(0xFF2C2545),
  purpleTile: Color(0xFF7C5CE6),
  green: Color(0xFF4FCF92),
  greenSoft: Color(0xFF16342A),
  greenInk: Color(0xFF7FE3B4),
  danger: Color(0xFFFF8A80),
  pinkSoft: Color(0xFF3B2228),
  blueSoft: Color(0xFF18293D),
  tanSoft: Color(0xFF342A1C),
  gold: Color(0xFFE2BC55),
);

/// Indigo shading into violet, with every panel a translucent white wash so
/// the gradient carries through the whole page instead of stopping at the
/// first card.
const _gradient = Palette(
  ink: Color(0xFFF1EEF8),
  inkSoft: Color(0xFFCFC9DF),
  grey: Color(0xFFA9A2C0),
  greyLight: Color(0xFF877FA0),
  hairline: Color(0x2EFFFFFF),
  surface: Color(0x14FFFFFF),
  surfaceAlt: Color(0x1FFFFFFF),
  ctaFill: Color(0xFFF1EEF8),
  onCta: Color(0xFF1B1240),
  purple: Color(0xFFBBA4FF),
  purpleDeep: Color(0xFFDCD0FF),
  purpleSoft: Color(0x33A98CFF),
  purpleTile: Color(0xFF8468F0),
  green: Color(0xFF5BDBA1),
  greenSoft: Color(0x2E4FCF92),
  greenInk: Color(0xFF8CEBBE),
  danger: Color(0xFFFF9E99),
  pinkSoft: Color(0x2EFF8FA3),
  blueSoft: Color(0x2E7FB2FF),
  tanSoft: Color(0x2EE0B457),
  gold: Color(0xFFE9C463),
  pageGradient: LinearGradient(
    colors: [Color(0xFF150F30), Color(0xFF241751), Color(0xFF16123A)],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
);

/// Design tokens lifted from the Stable Money screenshots, resolved against
/// whichever appearance is active.
///
/// These are getters rather than constants so a single palette swap repaints
/// the whole app. Anything reading them must therefore not be `const`.
class AppColors {
  AppColors._();

  static Palette _p = _light;
  static AppThemeMode _mode = AppThemeMode.light;

  static Palette get palette => _p;
  static AppThemeMode get mode => _mode;
  static bool get isDark => _mode.isDark;

  static void apply(AppThemeMode mode) {
    _mode = mode;
    _p = switch (mode) {
      AppThemeMode.light => _light,
      AppThemeMode.dark => _dark,
      AppThemeMode.gradient => _gradient,
    };
  }

  static Color get ink => _p.ink;
  static Color get inkSoft => _p.inkSoft;
  static Color get grey => _p.grey;
  static Color get greyLight => _p.greyLight;
  static Color get hairline => _p.hairline;

  /// Page and card fill. Named `white` for the light theme it came from;
  /// on dark appearances it is the dark surface.
  static Color get white => _p.surface;
  static Color get cream => _p.surfaceAlt;

  static Color get ctaFill => _p.ctaFill;
  static Color get onCta => _p.onCta;

  /// Fixed dark ink for text and icons that sit on a chip which stays white
  /// in every theme — the round header buttons, the gold promo button.
  static const onLightSurface = Color(0xFF1A1A1A);

  static Color get purple => _p.purple;
  static Color get purpleDeep => _p.purpleDeep;
  static Color get purpleSoft => _p.purpleSoft;
  static Color get purpleTile => _p.purpleTile;
  static Color get green => _p.green;
  static Color get greenSoft => _p.greenSoft;
  static Color get greenInk => _p.greenInk;
  static Color get danger => _p.danger;
  static Color get pinkSoft => _p.pinkSoft;
  static Color get blueSoft => _p.blueSoft;
  static Color get tanSoft => _p.tanSoft;
  static Color get gold => _p.gold;

  static Gradient? get pageGradient => _p.pageGradient;
}

/// Swaps the palette and tells the app to repaint.
class ThemeController extends ChangeNotifier {
  AppThemeMode _mode = AppThemeMode.light;
  AppThemeMode get mode => _mode;

  void select(AppThemeMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    AppColors.apply(mode);
    notifyListeners();
  }
}

/// One instance for the prototype. A production app would put this behind an
/// inherited widget and persist the choice.
final themeController = ThemeController();

class AppTheme {
  AppTheme._();

  static TextTheme get _textTheme => TextTheme(
        displaySmall: GoogleFonts.dmSans(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          height: 1.2,
        ),
        headlineSmall: GoogleFonts.dmSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        titleLarge: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.ink,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.grey,
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.grey,
          letterSpacing: 0.4,
        ),
      );

  static TextStyle get serifHeading => GoogleFonts.lora(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.green,
        fontStyle: FontStyle.normal,
      );

  static TextStyle get serifItalic => GoogleFonts.lora(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        color: AppColors.isDark
            ? const Color(0xFFE0A96B)
            : const Color(0xFF8A5A2B),
      );

  /// Kept as `light` so existing references still resolve; it now returns
  /// whichever appearance is active.
  static ThemeData get light => data;

  static ThemeData get data => ThemeData(
        useMaterial3: true,
        brightness: AppColors.isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: AppColors.white,
        canvasColor: AppColors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.purple,
          brightness: AppColors.isDark ? Brightness.dark : Brightness.light,
          primary: AppColors.purple,
          surface: AppColors.white,
          onSurface: AppColors.ink,
        ),
        textTheme: _textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: AppColors.ink),
          titleTextStyle: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.hairline,
          thickness: 1,
          space: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.ctaFill,
            foregroundColor: AppColors.onCta,
            disabledBackgroundColor: AppColors.hairline,
            disabledForegroundColor: AppColors.greyLight,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            elevation: 0,
          ),
        ),
        // Sheets and dialogs sit on the page, so they take the same surface
        // rather than Material's own default, which would be near-white.
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: AppColors.isDark
              ? AppColors.palette.surfaceAlt
              : AppColors.white,
          surfaceTintColor: Colors.transparent,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.isDark
              ? AppColors.palette.surfaceAlt
              : AppColors.white,
          surfaceTintColor: Colors.transparent,
        ),
        listTileTheme: ListTileThemeData(
          textColor: AppColors.ink,
          iconColor: AppColors.ink,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.ctaFill,
          contentTextStyle: GoogleFonts.dmSans(
            color: AppColors.onCta,
            fontSize: 14,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          hintStyle: TextStyle(color: AppColors.greyLight),
          labelStyle: TextStyle(color: AppColors.grey),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.hairline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.hairline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.purple, width: 1.4),
          ),
        ),
        splashFactory: InkRipple.splashFactory,
      );
}

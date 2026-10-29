// lib/theme_manager.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { dark, light, purple, blue, gold, custom }

class ThemeManager with ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;

  AppThemeMode _currentMode = AppThemeMode.dark;
  Color _customPrimaryColor = Colors.teal;
  Color _customAccentColor = Colors.tealAccent;
  Color _customTextColor = Colors.white;
  Color _customBackgroundColor = const Color(0xFF121212); // Fundo Principal (Scaffold)
  Color _customSecondaryBackgroundColor = const Color(0xFF1E1E1E); // Fundo Secundário (Cards/Bars)
  Locale _currentLocale = const Locale('pt', 'BR');

  AppThemeMode get currentMode => _currentMode;
  Color get customPrimary => _customPrimaryColor;
  Color get customAccent => _customAccentColor;
  Color get customText => _customTextColor;
  Color get customBackground => _customBackgroundColor;
  Color get customSecondaryBackground => _customSecondaryBackgroundColor; // Novo Getter
  Locale get currentLocale => _currentLocale;

  ThemeManager._internal() {
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt('theme_mode') ?? 0;
    _currentMode = AppThemeMode.values[modeIndex];
    
    final colorPrimary = prefs.getInt('custom_primary');
    if (colorPrimary != null) _customPrimaryColor = Color(colorPrimary);
    
    final colorAccent = prefs.getInt('custom_accent');
    if (colorAccent != null) _customAccentColor = Color(colorAccent);

    final colorText = prefs.getInt('custom_text');
    if (colorText != null) _customTextColor = Color(colorText);

    final colorBg = prefs.getInt('custom_background');
    if (colorBg != null) _customBackgroundColor = Color(colorBg);

    // Carregar secundário
    final colorSecBg = prefs.getInt('custom_secondary_background');
    if (colorSecBg != null) _customSecondaryBackgroundColor = Color(colorSecBg);

    final langCode = prefs.getString('language_code');
    if (langCode != null) _currentLocale = Locale(langCode);

    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _currentMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  // Atualizado para aceitar 5 cores
  Future<void> setCustomColors(Color primary, Color accent, Color text, Color background, Color secondaryBackground) async {
    _customPrimaryColor = primary;
    _customAccentColor = accent;
    _customTextColor = text;
    _customBackgroundColor = background;
    _customSecondaryBackgroundColor = secondaryBackground;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('custom_primary', primary.value);
    await prefs.setInt('custom_accent', accent.value);
    await prefs.setInt('custom_text', text.value);
    await prefs.setInt('custom_background', background.value);
    await prefs.setInt('custom_secondary_background', secondaryBackground.value);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    notifyListeners();
  }

  ThemeData getThemeData() {
    Brightness brightness;
    Color primary;
    Color surface;
    Color background;
    Color onBackground;
    Color accent;

    switch (_currentMode) {
      case AppThemeMode.light:
        brightness = Brightness.light;
        primary = const Color(0xFF6200EE); 
        surface = const Color(0xFFFFFFFF);
        background = const Color(0xFFF5F5F5);
        onBackground = Colors.black87;
        accent = const Color(0xFF03DAC6);
        break;
      case AppThemeMode.purple:
        brightness = Brightness.dark;
        primary = const Color(0xFF9C27B0);
        surface = const Color(0xFF2D1B38);
        background = const Color(0xFF1A0F23);
        onBackground = Colors.white;
        accent = const Color(0xFFE040FB);
        break;
      case AppThemeMode.blue:
        brightness = Brightness.dark;
        primary = const Color(0xFF2196F3);
        surface = const Color(0xFF102027);
        background = const Color(0xFF0A1216);
        onBackground = Colors.white;
        accent = const Color(0xFF448AFF);
        break;
      case AppThemeMode.gold:
        brightness = Brightness.dark;
        primary = const Color(0xFFFFD700);
        surface = const Color(0xFF212121);
        background = const Color(0xFF000000);
        onBackground = const Color(0xFFFFF8E1);
        accent = const Color(0xFFFFAB00);
        break;
      case AppThemeMode.custom:
        // A magia acontece aqui:
        background = _customBackgroundColor; // Fundo geral
        surface = _customSecondaryBackgroundColor; // Cartões, Barras
        
        // Estima o brilho com base no fundo principal
        brightness = ThemeData.estimateBrightnessForColor(_customBackgroundColor);
        
        primary = _customPrimaryColor;
        onBackground = _customTextColor;
        accent = _customAccentColor;
        break;
      case AppThemeMode.dark:
      default:
        brightness = Brightness.dark;
        primary = Colors.indigo;
        surface = Colors.grey[900]!;
        background = Colors.grey[850]!;
        onBackground = Colors.white;
        accent = Colors.blueAccent;
        break;
    }

    final baseTextTheme = GoogleFonts.latoTextTheme(ThemeData(brightness: brightness).textTheme);
    
    final textTheme = baseTextTheme.copyWith(
      displayLarge: GoogleFonts.cinzel(fontSize: 57, fontWeight: FontWeight.bold, color: onBackground),
      displayMedium: GoogleFonts.cinzel(fontSize: 45, fontWeight: FontWeight.bold, color: onBackground),
      displaySmall: GoogleFonts.cinzel(fontSize: 36, fontWeight: FontWeight.bold, color: onBackground),
      headlineLarge: GoogleFonts.cinzel(fontSize: 32, fontWeight: FontWeight.bold, color: onBackground),
      headlineMedium: GoogleFonts.cinzel(fontSize: 28, fontWeight: FontWeight.bold, color: onBackground),
      headlineSmall: GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.bold, color: onBackground),
      titleLarge: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.bold, color: onBackground),
      titleMedium: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w500, color: onBackground),
      titleSmall: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w500, color: onBackground),
      bodyLarge: GoogleFonts.lato(fontSize: 16, color: onBackground),
      bodyMedium: GoogleFonts.lato(fontSize: 14, color: onBackground),
      bodySmall: GoogleFonts.lato(fontSize: 12, color: onBackground.withOpacity(0.7)),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        secondary: accent,
        surface: surface,
        background: background,
        onSurface: onBackground,
      ),
      scaffoldBackgroundColor: background,
      cardColor: surface,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: surface, // Agora usa a cor secundária
        titleTextStyle: GoogleFonts.cinzel(
          color: onBackground,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: onBackground),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        labelStyle: TextStyle(color: onBackground.withOpacity(0.7), fontFamily: GoogleFonts.lato().fontFamily),
        hintStyle: TextStyle(color: onBackground.withOpacity(0.5), fontFamily: GoogleFonts.lato().fontFamily),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: GoogleFonts.lato(color: onBackground),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        titleTextStyle: GoogleFonts.cinzel(color: onBackground, fontSize: 20, fontWeight: FontWeight.bold),
        contentTextStyle: GoogleFonts.lato(color: onBackground),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface, // Agora usa a cor secundária
        selectedItemColor: primary,
        unselectedItemColor: onBackground.withOpacity(0.5),
        selectedLabelStyle: GoogleFonts.lato(fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.lato(),
      ),
      iconTheme: IconThemeData(color: onBackground),
      cardTheme: CardThemeData(
        color: surface, // Agora usa a cor secundária
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      ),
      listTileTheme: ListTileThemeData(
        textColor: onBackground,
        iconColor: onBackground,
      )
    );
  }
}
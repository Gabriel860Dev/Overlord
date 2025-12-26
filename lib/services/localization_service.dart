import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Certifique-se que o caminho gerado está correto
import 'package:dark_age/generated/l10n.dart'; // Gerado pelo Flutter Intl

class LocalizationService with ChangeNotifier {
  Locale _locale = const Locale('pt'); // Padrão Português
  static const String _localeKey = 'app_locale';

  Locale get locale => _locale;

  LocalizationService() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeString = prefs.getString(_localeKey);
    if (localeString != null && localeString.isNotEmpty) {
      _locale = Locale(localeString);
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  // Locales suportados
  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('pt', ''),
  ];

  // Delegates de localização
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate, // Delegate gerado
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

// Helper para acessar as traduções mais facilmente
AppLocalizations AppLocalizationsOf(BuildContext context) {
  return AppLocalizations.of(context)!;
}

// Extensão para facilitar o acesso (opcional, mas útil)
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}

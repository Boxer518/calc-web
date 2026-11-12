import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Светлая или тёмная тема и последняя пара валют.
///
/// Оба выбора пишутся в localStorage через shared_preferences и читаются
/// заново после перезагрузки страницы.
class AppSettings extends ChangeNotifier {
  AppSettings(this._prefs)
    : _themeMode = _prefs.getString(_themeKey) == 'dark'
          ? ThemeMode.dark
          : ThemeMode.light;

  static const _themeKey = 'theme_mode';
  static const _fromKey = 'currency_from';
  static const _toKey = 'currency_to';

  final SharedPreferences _prefs;
  ThemeMode _themeMode;

  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(prefs);
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    _prefs.setString(_themeKey, isDark ? 'dark' : 'light');
    notifyListeners();
  }

  String get fromCurrency => _prefs.getString(_fromKey) ?? 'USD';

  String get toCurrency => _prefs.getString(_toKey) ?? 'RUB';

  Future<void> saveCurrencyPair(String from, String to) {
    return Future.wait([
      _prefs.setString(_fromKey, from),
      _prefs.setString(_toKey, to),
    ]);
  }
}

class SettingsScope extends InheritedNotifier<AppSettings> {
  const SettingsScope({
    required AppSettings settings,
    required super.child,
    super.key,
  }) : super(notifier: settings);

  static AppSettings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SettingsScope>();
    assert(scope != null, 'SettingsScope не найден выше по дереву');
    return scope!.notifier!;
  }
}

class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    final isDark = settings.isDark;
    return IconButton(
      tooltip: isDark ? 'Светлая тема' : 'Тёмная тема',
      onPressed: settings.toggleTheme,
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
    );
  }
}

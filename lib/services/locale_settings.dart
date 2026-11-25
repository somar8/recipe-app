import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

/// Which language the app uses: Automatic (follows the phone), or one chosen in Account.
/// Saved on the device, and in the account when signed in, so it follows you around.
class LocaleSettings extends ChangeNotifier {
  static final LocaleSettings _instance = LocaleSettings._internal();
  factory LocaleSettings() => _instance;
  LocaleSettings._internal();

  /// The languages the app speaks, in the order they're offered.
  static const supported = [
    Locale('en'),
    Locale('ar'),
    Locale('nl'),
    Locale('de'),
  ];

  /// Each language's own name, so people find theirs whatever language is showing.
  static const nativeNames = {
    'en': 'English',
    'ar': 'العربية',
    'nl': 'Nederlands',
    'de': 'Deutsch',
  };

  static const _key = 'language';

  Locale? _chosen;

  /// The chosen language, or null for Automatic.
  Locale? get chosen => _chosen;

  /// The language actually in use.
  Locale get effective => _chosen ?? deviceLocale;

  /// The phone's preferred language if the app speaks it, else English.
  static Locale get deviceLocale {
    for (final l in WidgetsBinding.instance.platformDispatcher.locales) {
      for (final s in supported) {
        if (s.languageCode == l.languageCode) return s;
      }
    }
    return supported.first;
  }

  static Locale? _parse(String? code) {
    for (final s in supported) {
      if (s.languageCode == code) return s;
    }
    return null; // 'auto', unknown or missing
  }

  /// Reads the saved choice: the account's when signed in, else this device's.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _chosen = _parse(prefs.getString(_key));
    } catch (_) {}
    await loadFontsFor(effective);
    _readFromAccount();
    Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) => _readFromAccount(),
      onError: (_) {},
    );
  }

  void _readFromAccount() {
    final user = Supabase.instance.client.auth.currentUser;
    final saved = user?.userMetadata?['language'] as String?;
    if (saved == null) {
      return; // nothing in the account yet: keep this device's choice
    }
    final locale = _parse(saved);
    if (locale != _chosen) {
      _chosen = locale;
      _saveLocally();
      loadFontsFor(effective).then((_) => notifyListeners());
    }
  }

  /// null = Automatic.
  Future<void> setLanguage(Locale? locale) async {
    if (locale == _chosen) return;
    _chosen = locale;
    await loadFontsFor(effective);
    notifyListeners();
    _saveLocally();
    try {
      if (Supabase.instance.client.auth.currentUser != null) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'language': locale?.languageCode ?? 'auto'}),
        );
      }
    } catch (_) {
      // Offline: it's still saved on this device.
    }
  }

  Future<void> _saveLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, _chosen?.languageCode ?? 'auto');
    } catch (_) {}
  }
}

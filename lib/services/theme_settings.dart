import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Light, dark or follow the device. Saved in the signed-in user's account, so the
/// choice follows them to every device.
class ThemeSettings extends ChangeNotifier {
  static final ThemeSettings _instance = ThemeSettings._internal();
  factory ThemeSettings() => _instance;
  ThemeSettings._internal();

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  /// Reads the saved choice whenever someone signs in or out.
  void init() {
    _readFromAccount();
    Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) => _readFromAccount(),
    );
  }

  void _readFromAccount() {
    final saved =
        Supabase.instance.client.auth.currentUser?.userMetadata?['theme']
            as String?;
    final mode = ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
    if (mode != _mode) {
      _mode = mode;
      notifyListeners();
    }
  }

  /// Applies the choice at once, then saves it to the account in the background.
  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'theme': mode.name}),
      );
    } catch (_) {
      // Not saved (offline): it still applies for now and is saved next time.
    }
  }
}

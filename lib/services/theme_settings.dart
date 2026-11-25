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

  /// A choice that couldn't be saved yet (for example offline); retried on the next
  /// account event, and never overwritten by the older value stored in the account.
  ThemeMode? _unsaved;
  bool _saving = false;

  /// Reads the saved choice whenever someone signs in or out.
  void init() {
    _readFromAccount();
    Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) => _readFromAccount(),
      onError: (_) {}, // shown by AuthService; nothing to do here
    );
  }

  void _readFromAccount() {
    if (_saving) return; // our own save is on its way; its echo would flicker
    if (_unsaved != null) {
      if (Supabase.instance.client.auth.currentUser != null) _save(_unsaved!);
      return;
    }
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
    await _save(mode);
  }

  Future<void> _save(ThemeMode mode) async {
    _saving = true;
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'theme': mode.name}),
      );
      if (_unsaved == mode) _unsaved = null;
    } catch (_) {
      _unsaved = mode; // offline: keep it, try again later
    } finally {
      _saving = false;
    }
  }
}

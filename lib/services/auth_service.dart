import '../l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'errors.dart';

/// Sign-up, sign-in and sign-out through Supabase Auth.
/// Supabase keeps the session on the device and refreshes it by itself.
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  GoTrueClient get _auth => Supabase.instance.client.auth;

  /// Call once after Supabase.initialize. Tells listeners (the router) when you sign in or out.
  void init() {
    _auth.onAuthStateChange.listen(
      (_) => notifyListeners(),
      // Supabase reports some problems here instead of throwing, for example a
      // confirmation link opened in another browser or after it expired.
      onError: (Object e) {
        problem.value = _isLinkProblem(e)
            ? tr.confirmLinkFailed
            : friendlyError(e, fallback: tr.signInProblem);
        notifyListeners();
      },
    );
  }

  /// A sign-in problem to show on the sign-in screen; cleared once shown.
  final problem = ValueNotifier<String?>(null);

  static bool _isLinkProblem(Object e) {
    final t = e.toString().toLowerCase();
    return t.contains('code verifier') ||
        t.contains('pkce') ||
        t.contains('otp') ||
        t.contains('expired');
  }

  bool get isLoggedIn => _auth.currentSession != null;

  String? get email => _auth.currentUser?.email;

  Map<String, dynamic> get _meta => _auth.currentUser?.userMetadata ?? const {};

  /// First name; older accounts only had one "username", whose first word is used.
  String get firstName {
    final first = (_meta['first_name'] as String?)?.trim();
    if (first != null && first.isNotEmpty) return first;
    final old = (_meta['username'] as String?)?.trim() ?? '';
    return old.contains(' ') ? old.substring(0, old.indexOf(' ')) : old;
  }

  /// Last name (may be empty).
  String get lastName {
    if (_meta['first_name'] != null) {
      return (_meta['last_name'] as String?)?.trim() ?? '';
    }
    final old = (_meta['username'] as String?)?.trim() ?? '';
    return old.contains(' ') ? old.substring(old.indexOf(' ') + 1).trim() : '';
  }

  /// "First Last" as friends see it, or the email when no name is set.
  String? get username {
    final full = [firstName, lastName].where((p) => p.isNotEmpty).join(' ');
    return full.isNotEmpty ? full : email;
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      throw Exception(friendlyError(e, fallback: tr.couldNotSignIn));
    }
  }

  /// Returns true when the account is ready to use, or false when the user
  /// must first confirm their email address.
  Future<bool> register(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    try {
      final res = await _auth.signUp(
        email: email,
        password: password,
        data: _nameData(firstName, lastName),
        // On the web, the confirmation link brings the user back to this site.
        emailRedirectTo: kIsWeb ? Uri.base.origin : null,
      );
      // Supabase hides whether an email is taken; an empty identities list means it is.
      if (res.user != null && (res.user!.identities?.isEmpty ?? false)) {
        throw const AuthException('User already registered');
      }
      return res.session != null;
    } catch (e) {
      throw Exception(friendlyError(e, fallback: tr.couldNotCreateAccount));
    }
  }

  /// Stored as first and last name; "username" too, for screens that read the full name.
  static Map<String, dynamic> _nameData(String first, String last) => {
    'first_name': first.trim(),
    'last_name': last.trim(),
    'username': [
      first.trim(),
      last.trim(),
    ].where((p) => p.isNotEmpty).join(' '),
  };

  /// Changes your name as shown in the app and to friends.
  Future<void> updateName(String firstName, String lastName) async {
    try {
      await _auth.updateUser(
        UserAttributes(data: _nameData(firstName, lastName)),
      );
      notifyListeners();
    } catch (e) {
      throw Exception(friendlyError(e, fallback: tr.couldNotSaveName));
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (_) {
      // Signing out locally still works when offline.
    }
  }
}

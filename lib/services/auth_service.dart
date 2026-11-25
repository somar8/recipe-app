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
            ? 'That confirmation link didn\'t work here (it may have expired or been opened '
                  'in another browser). Your email may still be confirmed: try signing in.'
            : friendlyError(
                e,
                fallback:
                    'Something went wrong with signing in. Please try again.',
              );
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

  String? get username =>
      (_auth.currentUser?.userMetadata?['username'] as String?) ?? email;

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      throw Exception(
        friendlyError(e, fallback: 'Could not sign in. Please try again.'),
      );
    }
  }

  /// Returns true when the account is ready to use, or false when the user
  /// must first confirm their email address.
  Future<bool> register(String username, String email, String password) async {
    try {
      final res = await _auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
        // On the web, the confirmation link brings the user back to this site.
        emailRedirectTo: kIsWeb ? Uri.base.origin : null,
      );
      // Supabase hides whether an email is taken; an empty identities list means it is.
      if (res.user != null && (res.user!.identities?.isEmpty ?? false)) {
        throw const AuthException('User already registered');
      }
      return res.session != null;
    } catch (e) {
      throw Exception(
        friendlyError(
          e,
          fallback: 'Could not create the account. Please try again.',
        ),
      );
    }
  }

  /// Changes the display name shown in the app.
  Future<void> updateName(String name) async {
    try {
      await _auth.updateUser(UserAttributes(data: {'username': name}));
      notifyListeners();
    } catch (e) {
      throw Exception(
        friendlyError(
          e,
          fallback: 'Could not save your name. Please try again.',
        ),
      );
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

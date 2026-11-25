import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/l10n.dart';

/// Turns a Supabase or network error into a sentence the user can act on, in the
/// app's current language. The database's own messages are recognised and translated.
String friendlyError(Object error, {String? fallback, String? forbidden}) {
  final l = tr;
  if (error is AuthException) {
    final msg = error.message.toLowerCase();
    // Checked first: a network error's text holds the request URL (...grant_type=password).
    if (error is AuthRetryableFetchException || _looksOffline(msg)) {
      return l.errorOffline;
    }
    if (msg.contains('invalid login')) return l.errorWrongPassword;
    if (msg.contains('email not confirmed')) return l.errorConfirmEmailFirst;
    if (msg.contains('already registered')) return l.errorAccountExists;
    if (msg.startsWith('password')) {
      return l
          .errorPasswordTooShort; // "Password should be at least 6 characters."
    }
    if (msg.contains('rate limit') || error.statusCode == '429') {
      return l.errorTooManyAttempts;
    }
    return fallback ?? l.errorGeneric;
  }
  if (error is PostgrestException) {
    final msg = error.message.toLowerCase();
    switch (error.code) {
      case '22023': // send_friend_request
        return msg.contains('own email') ? l.errorOwnEmail : l.errorNotAnEmail;
      case '54000': // limits set by the database
        if (msg.contains('open requests')) return l.errorTooManyOpenRequests;
        if (msg.contains('recipes')) return l.errorRecipeLimit;
        if (msg.contains('collections')) return l.errorCollectionLimit;
        if (msg.contains('ingredients')) return l.errorIngredientLimit;
        return l.errorSlowDown;
      case 'P0002':
      case 'PGRST116':
        return l.errorNotFound;
      case '23514':
        return l.errorCheckValues;
      case '42501':
        if (msg.contains('confirm your email')) return l.errorConfirmEmailFirst;
        return forbidden ?? l.errorForbidden;
    }
    if (error.code == 'PGRST301' || msg.contains('jwt')) {
      return l.errorSessionExpired;
    }
    return fallback ?? l.errorGeneric;
  }
  if (_looksOffline(error.toString())) return l.errorOffline;
  return fallback ?? l.errorGeneric;
}

bool _looksOffline(String text) {
  final t = text.toLowerCase();
  return t.contains('failed host lookup') ||
      t.contains('socketexception') ||
      t.contains('clientexception') ||
      t.contains('xmlhttprequest') ||
      t.contains('failed to fetch') ||
      t.contains('network');
}

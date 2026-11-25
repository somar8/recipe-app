import 'package:supabase_flutter/supabase_flutter.dart';

/// Turns a Supabase or network error into a sentence the user can act on.
String friendlyError(Object error, {String fallback = 'Something went wrong. Please try again.'}) {
  if (error is AuthException) {
    final msg = error.message.toLowerCase();
    // Checked first: a network error's text holds the request URL (...grant_type=password).
    if (error is AuthRetryableFetchException || _looksOffline(msg)) return _offline;
    if (msg.contains('invalid login')) return 'Wrong email or password.';
    if (msg.contains('email not confirmed')) {
      return 'Please confirm your email first: open the link we sent you.';
    }
    if (msg.contains('already registered')) return 'An account with this email already exists. Sign in instead.';
    if (msg.startsWith('password')) return error.message; // e.g. "Password should be at least 6 characters."
    if (msg.contains('rate limit') || error.statusCode == '429') {
      return 'Too many attempts. Please wait a few minutes and try again.';
    }
    return error.message;
  }
  if (error is PostgrestException) {
    switch (error.code) {
      case 'P0002':
      case 'PGRST116':
        return 'Not found. It may have been deleted.';
      case '23514':
        return 'Please check the values: times and servings must be above 0, and a title is required.';
      case '42501':
        return 'You are not allowed to do that. Try signing in again.';
    }
    if (error.code == 'PGRST301' || error.message.toLowerCase().contains('jwt')) {
      return 'Your session has expired. Please sign in again.';
    }
    return fallback;
  }
  if (_looksOffline(error.toString())) return _offline;
  return fallback;
}

const _offline = 'No connection. Check your internet and try again.';

bool _looksOffline(String text) {
  final t = text.toLowerCase();
  return t.contains('failed host lookup') ||
      t.contains('socketexception') ||
      t.contains('clientexception') ||
      t.contains('xmlhttprequest') ||
      t.contains('failed to fetch') ||
      t.contains('network');
}

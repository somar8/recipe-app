import 'package:flutter/widgets.dart';
import '../services/locale_settings.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  /// The text for the current language, e.g. `context.l10n.save`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// For code without a BuildContext (services, filters, formatting): the app's current
/// language. Widgets use `context.l10n`, so they rebuild when the language changes.
AppLocalizations get tr => lookupAppLocalizations(LocaleSettings().effective);

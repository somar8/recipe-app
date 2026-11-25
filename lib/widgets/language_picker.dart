import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../services/locale_settings.dart';
import '../theme/app_theme.dart';

/// Bottom sheet with Automatic and each language in its own script.
Future<void> showLanguagePicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    builder: (context) {
      final l = context.l10n;
      final current = LocaleSettings().chosen?.languageCode;
      final device =
          LocaleSettings.nativeNames[LocaleSettings.deviceLocale.languageCode]!;
      Widget option(String? code, String title, [String? subtitle]) => ListTile(
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle),
        trailing: current == code
            ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
            : null,
        selected: current == code,
        onTap: () {
          Navigator.pop(context);
          LocaleSettings().setLanguage(code == null ? null : Locale(code));
        },
      );
      return Padding(
        padding: const EdgeInsets.only(bottom: Gap.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.sm),
              child: Text(
                l.chooseLanguage,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            option(null, l.languageAutomatic, l.languageAutomaticHint(device)),
            for (final s in LocaleSettings.supported)
              option(
                s.languageCode,
                LocaleSettings.nativeNames[s.languageCode]!,
              ),
          ],
        ),
      );
    },
  );
}

/// Small globe button with the current language, for screens before signing in.
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleSettings(),
      builder: (context, _) => TextButton.icon(
        onPressed: () => showLanguagePicker(context),
        icon: const Icon(Icons.language),
        label: Text(
          LocaleSettings.nativeNames[LocaleSettings().effective.languageCode]!,
        ),
      ),
    );
  }
}

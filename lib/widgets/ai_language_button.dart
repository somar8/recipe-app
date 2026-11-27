import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../services/ai_service.dart';
import '../services/locale_settings.dart';

/// "Answer in English ▾": which language the AI writes in. Starts as the app's
/// language; another choice stays until the app is closed.
class AiLanguageButton extends StatelessWidget {
  const AiLanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final ai = AiService();
    return ListenableBuilder(
      listenable: Listenable.merge([ai.answerLanguage, LocaleSettings()]),
      builder: (context, _) {
        final l = context.l10n;
        final current = ai.effectiveAnswerLanguage.languageCode;
        final name = LocaleSettings.nativeNames[current]!;
        return MenuAnchor(
          menuChildren: [
            for (final s in LocaleSettings.supported)
              MenuItemButton(
                leadingIcon: Icon(
                  Icons.check,
                  color: s.languageCode == current
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                ),
                // Following the app again when the app's own language is picked.
                onPressed: () => ai.answerLanguage.value =
                    s == LocaleSettings().effective ? null : s,
                child: Text(LocaleSettings.nativeNames[s.languageCode]!),
              ),
          ],
          builder: (context, menu, _) => TextButton.icon(
            onPressed: () => menu.isOpen ? menu.close() : menu.open(),
            icon: const Icon(Icons.translate, size: 18),
            label: Text(l.aiAnswerIn(name)),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/friend_service.dart';
import '../services/theme_settings.dart';
import '../services/locale_settings.dart';
import '../widgets/language_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Future<void> _editName() async {
    await context.push('/account/details');
    if (mounted) setState(() {}); // show the new name
  }

  Future<void> _signOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.signOutQuestion),
        content: Text(context.l10n.signOutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.signOut),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await AuthService().logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final name = AuthService().username ?? '';
    final email = AuthService().email ?? '';
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.account)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.xxl),
        child: PageWidth(
          maxWidth: 560,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Gap.lg),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: c.primaryContainer,
                        foregroundColor: c.onPrimaryContainer,
                        child: Text(
                          initial,
                          style: t.titleLarge?.copyWith(
                            color: c.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: Gap.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: t.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: t.bodyMedium?.copyWith(
                                color: c.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: context.l10n.editYourDetails,
                        onPressed: _editName,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Gap.md),
              Card(
                child: ListTile(
                  leading: Icon(Icons.group_outlined, color: c.primary),
                  title: Text(context.l10n.friends),
                  subtitle: Text(context.l10n.friendsSubtitle),
                  trailing: ValueListenableBuilder<int>(
                    valueListenable: FriendService().waitingCount,
                    builder: (_, count, _) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (count > 0) Badge(label: Text('$count')),
                        const SizedBox(width: Gap.sm),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                  onTap: () => context.push('/account/friends'),
                ),
              ),
              SizedBox(height: Gap.xl),
              Text(
                context.l10n.appearance,
                style: t.titleSmall?.copyWith(color: c.onSurfaceVariant),
              ),
              SizedBox(height: Gap.sm),
              ListenableBuilder(
                listenable: ThemeSettings(),
                builder: (context, _) => SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_outlined),
                      label: Text(context.l10n.themeAuto),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text(context.l10n.themeLight),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text(context.l10n.themeDark),
                    ),
                  ],
                  selected: {ThemeSettings().mode},
                  onSelectionChanged: (s) => ThemeSettings().setMode(s.first),
                ),
              ),
              const SizedBox(height: Gap.xs),
              Text(
                context.l10n.themeAutoHint,
                style: t.bodySmall?.copyWith(color: c.onSurfaceVariant),
              ),
              const SizedBox(height: Gap.xl),
              Text(
                context.l10n.language,
                style: t.titleSmall?.copyWith(color: c.onSurfaceVariant),
              ),
              const SizedBox(height: Gap.sm),
              Card(
                child: ListenableBuilder(
                  listenable: LocaleSettings(),
                  builder: (context, _) {
                    final chosen = LocaleSettings().chosen;
                    final device = LocaleSettings
                        .nativeNames[LocaleSettings.deviceLocale.languageCode]!;
                    return ListTile(
                      leading: Icon(Icons.language, color: c.primary),
                      title: Text(
                        chosen == null
                            ? context.l10n.languageAutomatic
                            : LocaleSettings.nativeNames[chosen.languageCode]!,
                      ),
                      subtitle: chosen == null
                          ? Text(context.l10n.languageAutomaticHint(device))
                          : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => showLanguagePicker(context),
                    );
                  },
                ),
              ),
              const SizedBox(height: Gap.xxl),
              OutlinedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
                label: Text(context.l10n.signOut),
                style: OutlinedButton.styleFrom(foregroundColor: c.error),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/friend_service.dart';
import '../services/theme_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Future<void> _editName() async {
    final controller = TextEditingController(
      text: AuthService().username ?? '',
    );
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Name'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty || !mounted) return;
    try {
      await AuthService().updateName(name.trim());
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _signOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Your recipes stay saved in your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
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
      appBar: AppBar(title: const Text('Account')),
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
                        tooltip: 'Change your name',
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
                  title: const Text('Friends'),
                  subtitle: const Text('Add friends and answer requests'),
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
              const SizedBox(height: Gap.xl),
              Text(
                'Appearance',
                style: t.titleSmall?.copyWith(color: c.onSurfaceVariant),
              ),
              const SizedBox(height: Gap.sm),
              ListenableBuilder(
                listenable: ThemeSettings(),
                builder: (context, _) => SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_outlined),
                      label: Text('Auto'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {ThemeSettings().mode},
                  onSelectionChanged: (s) => ThemeSettings().setMode(s.first),
                ),
              ),
              const SizedBox(height: Gap.xs),
              Text(
                'Auto follows your device\'s setting.',
                style: t.bodySmall?.copyWith(color: c.onSurfaceVariant),
              ),
              const SizedBox(height: Gap.xxl),
              OutlinedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
                style: OutlinedButton.styleFrom(foregroundColor: c.error),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

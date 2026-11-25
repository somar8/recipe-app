import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import 'package:go_router/go_router.dart';
import '../models/friends.dart';
import '../services/friend_service.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// Bottom sheet to choose which friends can see a recipe or collection.
/// [load] returns the friends it's shared with now; [save] stores the new choice.
Future<void> showShareSheet(
  BuildContext context, {
  required String title,
  required String explanation,
  required Future<Set<String>> Function() load,
  required Future<void> Function(Set<String> friendIds) save,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true, // covers the bottom bar too
    builder: (_) => _ShareSheet(
      title: title,
      explanation: explanation,
      load: load,
      save: save,
    ),
  );
}

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({
    required this.title,
    required this.explanation,
    required this.load,
    required this.save,
  });

  final String title;
  final String explanation;
  final Future<Set<String>> Function() load;
  final Future<void> Function(Set<String>) save;

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  List<Friend>? _friends;
  Set<String> _initial = {};
  Set<String> _picked = {};
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        FriendService().friends(),
        widget.load(),
      ]);
      if (!mounted) return;
      setState(() {
        _friends = results[0] as List<Friend>;
        _initial = results[1] as Set<String>;
        _picked = {..._initial};
      });
    } catch (e) {
      if (mounted) setState(() => _error = errorText(e));
    }
  }

  Future<void> _done() async {
    final messenger = ScaffoldMessenger.of(context);
    final l = context.l10n;
    final navigator = Navigator.of(context);
    if (_picked.length == _initial.length && _picked.containsAll(_initial)) {
      navigator.pop();
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.save(_picked);
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _picked.isEmpty ? l.noLongerShared : l.sharedWithN(_picked.length),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = errorText(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final friends = _friends;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: t.titleLarge),
            const SizedBox(height: Gap.xs),
            Text(
              widget.explanation,
              style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
            ),
            const SizedBox(height: Gap.md),
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: c.error)),
              const SizedBox(height: Gap.sm),
            ],
            if (friends == null && _error == null)
              const Padding(
                padding: EdgeInsets.all(Gap.xl),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (friends != null && friends.isEmpty) ...[
              Text(context.l10n.noFriendsAddedYet, style: t.bodyLarge),
              const SizedBox(height: Gap.md),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/account/friends');
                },
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: Text(context.l10n.addFriends),
              ),
            ] else if (friends != null) ...[
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.5,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final f in friends)
                      CheckboxListTile(
                        value: _picked.contains(f.id),
                        onChanged: (_) => setState(
                          () => _picked.contains(f.id)
                              ? _picked.remove(f.id)
                              : _picked.add(f.id),
                        ),
                        secondary: PersonAvatar(name: f.name),
                        title: Text(f.name, overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          f.email,
                          overflow: TextOverflow.ellipsis,
                        ),
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: Gap.md),
              FilledButton(
                onPressed: _saving ? null : _done,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.l10n.done),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import '../models/friends.dart';
import '../services/friend_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/common.dart';
import '../widgets/skeleton.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _service = FriendService();

  List<Friend> _friends = [];
  List<IncomingRequest> _incoming = [];
  List<SentRequest> _sent = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // After an error, show the loading placeholder again instead of empty lists.
    setState(() {
      if (_error != null) _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _service.friends(),
        _service.incoming(),
        _service.sent(),
      ]);
      if (!mounted) return;
      setState(() {
        _friends = results[0] as List<Friend>;
        _incoming = results[1] as List<IncomingRequest>;
        _sent = results[2] as List<SentRequest>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = errorText(e);
        _loading = false;
      });
    }
  }

  Future<void> _run(Future<void> Function() action, String done) async {
    try {
      await action();
      if (!mounted) return;
      showMessage(context, done);
      await _load();
    } catch (e) {
      if (mounted) showMessage(context, errorText(e));
    }
  }

  Future<void> _unfriend(Friend f) async {
    final ok = await confirmDialog(
      context,
      title: 'Remove ${f.name}?',
      message:
          'You\'ll stop seeing each other\'s shared recipes and collections. You can send a new request later.',
      confirmLabel: 'Remove',
    );
    if (ok) await _run(() => _service.unfriend(f.id), 'Removed ${f.name}');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: _loading
          ? const ListPageSkeleton(cards: 3, showSearch: false)
          : _error != null
          ? ErrorState(message: _error!, onRetry: _load)
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Gap.lg,
                  Gap.sm,
                  Gap.lg,
                  Gap.xxl,
                ),
                children: [
                  PageWidth(
                    maxWidth: 640,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ---- Add a friend ----
                        _AddFriendCard(onChanged: _load),

                        // ---- Waiting for you ----
                        if (_incoming.isNotEmpty) ...[
                          SectionHeader(
                            title: 'Waiting for you',
                            trailing: _CountBadge(_incoming.length),
                          ),
                          for (final r in _incoming)
                            Padding(
                              padding: const EdgeInsets.only(bottom: Gap.sm),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(Gap.md),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _PersonRow(
                                        person: r.from,
                                        subtitle: 'wants to be friends',
                                      ),
                                      const SizedBox(height: Gap.md),
                                      Row(
                                        spacing: Gap.sm,
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => _run(
                                                () => _service.remove(
                                                  r.id,
                                                  incoming: true,
                                                ),
                                                'Declined',
                                              ),
                                              child: const Text('Decline'),
                                            ),
                                          ),
                                          Expanded(
                                            child: FilledButton(
                                              onPressed: () => _run(
                                                () => _service.accept(r.id),
                                                'You and ${r.from.name} are now friends',
                                              ),
                                              child: const Text('Accept'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],

                        // ---- Friends ----
                        SectionHeader(
                          title: 'Your friends',
                          trailing: Text(
                            '${_friends.length}',
                            style: t.titleMedium?.copyWith(
                              color: c.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (_friends.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: Gap.md,
                            ),
                            child: Text(
                              'No friends yet. Send a request above, then share recipes from any recipe\'s Share button.',
                              style: t.bodyMedium?.copyWith(
                                color: c.onSurfaceVariant,
                              ),
                            ),
                          )
                        else
                          Card(
                            child: Column(
                              children: [
                                for (var i = 0; i < _friends.length; i++) ...[
                                  if (i > 0)
                                    const Divider(
                                      indent: Gap.lg,
                                      endIndent: Gap.lg,
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      Gap.md,
                                      Gap.sm,
                                      Gap.xs,
                                      Gap.sm,
                                    ),
                                    child: _PersonRow(
                                      person: _friends[i],
                                      trailing: PopupMenuButton<String>(
                                        tooltip: 'More for ${_friends[i].name}',
                                        onSelected: (_) =>
                                            _unfriend(_friends[i]),
                                        itemBuilder: (_) => [
                                          PopupMenuItem(
                                            value: 'remove',
                                            child: Text(
                                              'Remove friend',
                                              style: TextStyle(color: c.error),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                        // ---- Sent ----
                        if (_sent.isNotEmpty) ...[
                          const SectionHeader(title: 'Requests you sent'),
                          Card(
                            child: Column(
                              children: [
                                for (var i = 0; i < _sent.length; i++) ...[
                                  if (i > 0)
                                    const Divider(
                                      indent: Gap.lg,
                                      endIndent: Gap.lg,
                                    ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.schedule_send_outlined,
                                      color: c.onSurfaceVariant,
                                    ),
                                    title: Text(
                                      _sent[i].name ?? _sent[i].label,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      _sent[i].name != null
                                          ? '${_sent[i].label} · waiting for an answer'
                                          : 'Waiting for an answer',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: TextButton(
                                      onPressed: () => _run(
                                        () => _service.remove(_sent[i].id),
                                        'Request cancelled',
                                      ),
                                      child: const Text('Cancel'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.person, this.subtitle, this.trailing});

  final Friend person;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        PersonAvatar(name: person.name),
        const SizedBox(width: Gap.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                person.name,
                style: t.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle ?? person.email,
                style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge(this.count);
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: 2),
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(Corners.pill),
      ),
      child: Text(
        '$count',
        style: TextStyle(color: c.onPrimary, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// "Add a friend": type a name or email; matching people appear as you type.
/// A full email address can always be sent to, even if nobody shows up for it.
class _AddFriendCard extends StatefulWidget {
  const _AddFriendCard({required this.onChanged});

  /// Called after a request was sent or a friendship made, to refresh the lists.
  final Future<void> Function() onChanged;

  @override
  State<_AddFriendCard> createState() => _AddFriendCardState();
}

class _AddFriendCardState extends State<_AddFriendCard> {
  final _service = FriendService();
  final _input = TextEditingController();
  Timer? _debounce;
  List<PersonMatch> _matches = [];
  bool _searching = false;
  String? _error;
  final Set<String> _busy = {};
  int _searchId = 0;

  static final _emailPattern = RegExp(r'^\S+@\S+\.\S+$');

  String get _text => _input.text.trim();
  bool get _isEmail => _emailPattern.hasMatch(_text);

  @override
  void dispose() {
    _debounce?.cancel();
    _input.dispose();
    super.dispose();
  }

  void _onTyped(String _) {
    _debounce?.cancel();
    _searchId++; // any answer still on its way is for an older text
    setState(() {
      _error = null;
      _matches = []; // never show results for a different text
      _searching = _text.length >= 3;
    });
    if (_text.length < 3) return;
    // Wait for a pause in typing before asking the database.
    _debounce = Timer(const Duration(milliseconds: 300), _search);
  }

  Future<void> _search() async {
    final id = ++_searchId;
    setState(() => _searching = true);
    try {
      final found = await _service.search(_text);
      if (!mounted || id != _searchId) return; // a newer search is on its way
      setState(() {
        _matches = found;
        _searching = false;
      });
    } catch (e) {
      if (!mounted || id != _searchId) return;
      setState(() {
        _error = errorText(e);
        _searching = false;
      });
    }
  }

  Future<void> _add(PersonMatch p) async {
    setState(() => _busy.add(p.id));
    try {
      await _service.sendTo(p.id);
      if (!mounted) return;
      showMessage(
        context,
        p.status == 'received'
            ? 'You and ${p.name} are now friends'
            : 'Request sent to ${p.name}',
      );
      await _search();
      await widget.onChanged();
    } catch (e) {
      if (mounted) showMessage(context, errorText(e));
    } finally {
      if (mounted) setState(() => _busy.remove(p.id));
    }
  }

  Future<void> _sendToEmail() async {
    final email = _text;
    setState(() => _busy.add(email));
    try {
      await _service.send(email);
      if (!mounted) return;
      // Same message whether or not the address has an account: that stays private.
      showMessage(
        context,
        'Request sent to $email. If they use Recipe App, they\'ll see it.',
      );
      _input.clear();
      setState(() => _matches = []);
      await widget.onChanged();
    } catch (e) {
      if (mounted) showMessage(context, errorText(e));
    } finally {
      if (mounted) setState(() => _busy.remove(email));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final showResults = _text.length >= 3;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Gap.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add a friend', style: t.titleMedium),
            const SizedBox(height: Gap.xs),
            Text(
              'Search by name or email. Pick someone to send a request.',
              style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
            ),
            const SizedBox(height: Gap.md),
            TextField(
              controller: _input,
              onChanged: _onTyped,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.search,
              autocorrect: false,
              onSubmitted: (_) =>
                  _isEmail && _matches.isEmpty ? _sendToEmail() : null,
              decoration: InputDecoration(
                hintText: 'Name or email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : (_text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear',
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _input.clear();
                                _onTyped('');
                              },
                            )),
              ),
            ),
            if (_text.isNotEmpty && _text.length < 3)
              Padding(
                padding: const EdgeInsets.only(top: Gap.sm, left: Gap.xs),
                child: Text(
                  'Type at least 3 letters',
                  style: t.bodySmall?.copyWith(color: c.onSurfaceVariant),
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: Gap.sm),
                child: Text(_error!, style: TextStyle(color: c.error)),
              ),
            if (showResults && !_searching && _error == null) ...[
              const SizedBox(height: Gap.sm),
              for (final p in _matches)
                _MatchRow(
                  person: p,
                  busy: _busy.contains(p.id),
                  onAdd: () => _add(p),
                ),
              if (_matches.isEmpty && !_isEmail)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: Gap.sm,
                    horizontal: Gap.xs,
                  ),
                  child: Text(
                    'No one found. Try their full email address.',
                    style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
                  ),
                ),
              if (_isEmail && _matches.isEmpty)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Gap.xs,
                  ),
                  leading: Icon(Icons.mail_outline, color: c.primary),
                  title: Text(
                    'Send a request to $_text',
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: const Text(
                    'They\'ll see it when they use Recipe App',
                  ),
                  trailing: _busy.contains(_text)
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : FilledButton.tonal(
                          onPressed: _sendToEmail,
                          child: const Text('Send'),
                        ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One search result: name, hidden email, and what you can do.
class _MatchRow extends StatelessWidget {
  const _MatchRow({
    required this.person,
    required this.busy,
    required this.onAdd,
  });

  final PersonMatch person;
  final bool busy;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final Widget action = busy
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : switch (person.status) {
            'friend' => Text(
              'Friends',
              style: t.labelLarge?.copyWith(color: c.secondary),
            ),
            'sent' => Text(
              'Requested',
              style: t.labelLarge?.copyWith(color: c.onSurfaceVariant),
            ),
            'received' => FilledButton(
              onPressed: onAdd,
              child: const Text('Accept'),
            ),
            _ => FilledButton.tonal(onPressed: onAdd, child: const Text('Add')),
          };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Gap.xs),
      child: Row(
        children: [
          PersonAvatar(name: person.name),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: t.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  person.status == 'received'
                      ? 'Wants to be friends'
                      : person.emailHint,
                  style: t.bodySmall?.copyWith(color: c.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: Gap.sm),
          action,
        ],
      ),
    );
  }
}

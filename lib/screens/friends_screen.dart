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
  final _email = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Friend> _friends = [];
  List<IncomingRequest> _incoming = [];
  List<SentRequest> _sent = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _error = null);
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

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _email.text.trim();
    setState(() => _sending = true);
    try {
      await _service.send(email);
      _email.clear();
      if (!mounted) return;
      // Same message whether or not the address has an account: that stays private.
      showMessage(
        context,
        'Request sent to $email. If they use Recipe App, they\'ll see it.',
      );
      await _load();
    } catch (e) {
      if (mounted) showMessage(context, errorText(e));
    } finally {
      if (mounted) setState(() => _sending = false);
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
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(Gap.lg),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text('Add a friend', style: t.titleMedium),
                                  const SizedBox(height: Gap.xs),
                                  Text(
                                    'Enter their email. They can accept the request in their Friends list.',
                                    style: t.bodyMedium?.copyWith(
                                      color: c.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: Gap.md),
                                  TextFormField(
                                    controller: _email,
                                    keyboardType: TextInputType.emailAddress,
                                    autofillHints: const [AutofillHints.email],
                                    textInputAction: TextInputAction.send,
                                    onFieldSubmitted: (_) => _send(),
                                    validator: (v) =>
                                        (v == null ||
                                            !RegExp(
                                              r'^\S+@\S+\.\S+$',
                                            ).hasMatch(v.trim()))
                                        ? 'Enter an email address'
                                        : null,
                                    decoration: const InputDecoration(
                                      hintText: 'friend@example.com',
                                      prefixIcon: Icon(Icons.alternate_email),
                                    ),
                                  ),
                                  const SizedBox(height: Gap.md),
                                  FilledButton.icon(
                                    onPressed: _sending ? null : _send,
                                    icon: const Icon(
                                      Icons.person_add_alt_1_outlined,
                                    ),
                                    label: const Text('Send request'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

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
                                      _sent[i].email,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: const Text(
                                      'Waiting for an answer',
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

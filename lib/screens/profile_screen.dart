import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/common.dart';

/// Account -> Your details: first and last name (what friends see) and your email.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _first = TextEditingController(text: AuthService().firstName);
  late final _last = TextEditingController(text: AuthService().lastName);
  bool _saving = false;

  bool get _changed =>
      _first.text.trim() != AuthService().firstName ||
      _last.text.trim() != AuthService().lastName;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await AuthService().updateName(_first.text, _last.text);
      if (!mounted) return;
      showMessage(context, context.l10n.detailsSaved);
      context.canPop() ? context.pop() : context.go('/account');
    } catch (e) {
      if (mounted) showMessage(context, errorText(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final preview = [
      _first.text.trim(),
      _last.text.trim(),
    ].where((p) => p.isNotEmpty).join(' ');

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.yourDetails)),
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, Gap.xxl),
          children: [
            PageWidth(
              maxWidth: 560,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: PersonAvatar(
                      name: preview.isEmpty ? '?' : preview,
                      radius: 40,
                    ),
                  ),
                  const SizedBox(height: Gap.sm),
                  Text(
                    preview.isEmpty ? ' ' : preview,
                    style: t.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Gap.xl),
                  TextFormField(
                    controller: _first,
                    autofocus: AuthService().firstName.isEmpty,
                    autofillHints: const [AutofillHints.givenName],
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    maxLength: 40,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? context.l10n.enterFirstName
                        : null,
                    decoration: InputDecoration(
                      labelText: context.l10n.firstName,
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: Gap.md),
                  TextFormField(
                    controller: _last,
                    autofillHints: const [AutofillHints.familyName],
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    maxLength: 40,
                    onFieldSubmitted: (_) => _changed ? _save() : null,
                    decoration: InputDecoration(
                      labelText: context.l10n.lastNameOptional,
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: Gap.sm),
                  Text(
                    context.l10n.friendsSeeName,
                    style: t.bodySmall?.copyWith(color: c.onSurfaceVariant),
                  ),
                  const SizedBox(height: Gap.xl),
                  TextFormField(
                    initialValue: AuthService().email ?? '',
                    readOnly: true,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: context.l10n.email,
                      prefixIcon: Icon(Icons.mail_outline),
                      helperText: context.l10n.emailCantChange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.md),
          child: PageWidth(
            maxWidth: 560,
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving || !_changed ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.l10n.save),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

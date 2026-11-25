import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../widgets/language_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/food_art.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _checkEmail = false;
  String? _error;

  Future<void> _submit() async {
    if (_firstNameController.text.trim().isEmpty) {
      setState(() => _error = context.l10n.enterFirstName);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ready = await AuthService().register(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      if (ready) {
        context.go('/recipes');
      } else {
        setState(() {
          _checkEmail = true;
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Choose a language before signing in.
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: const [LanguageButton(), SizedBox(width: 8)],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AutofillGroup(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AppLogo()),
                  const SizedBox(height: Gap.lg),
                  Text(
                    context.l10n.appName,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.createYourAccount,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (_checkEmail) ...[
                    Icon(
                      Icons.mark_email_read_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.checkEmailMessage(
                        _emailController.text.trim(),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => context.go('/login'),
                      child: Text(context.l10n.goToSignIn),
                    ),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _firstNameController,
                            autofillHints: const [AutofillHints.givenName],
                            textCapitalization: TextCapitalization.words,
                            maxLength: 40,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: context.l10n.firstName,
                              counterText: '',
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _lastNameController,
                            autofillHints: const [AutofillHints.familyName],
                            textCapitalization: TextCapitalization.words,
                            maxLength: 40,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: context.l10n.lastName,
                              counterText: '',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 16,
                        top: 4,
                      ),
                      child: Text(
                        context.l10n.nameShownHint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      autofillHints: const [AutofillHints.email],
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: context.l10n.email,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: context.l10n.password,
                        helperText: context.l10n.atLeast6,
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(context.l10n.createAccount),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(context.l10n.alreadyHaveAccount),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/l10n.dart';
import '../services/ai_service.dart';
import '../services/data_changes.dart';
import '../services/recipe_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_language_button.dart';
import '../widgets/app_shell.dart';
import '../widgets/common.dart';
import '../widgets/food_art.dart';
import '../widgets/skeleton.dart';

/// "What can I cook?": list what you have, get a few meals to choose from, save one.
class CookScreen extends StatefulWidget {
  const CookScreen({super.key});

  @override
  State<CookScreen> createState() => _CookScreenState();
}

class _CookScreenState extends State<CookScreen> {
  static const _key = 'cook.have';

  final _input = TextEditingController();
  final _inputFocus = FocusNode();
  final List<String> _have = [];
  List<AiIdea> _ideas = [];
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  @override
  void dispose() {
    _input.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  /// What you had last time stays, so you only change what's new.
  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_key) ?? const [];
      if (mounted && saved.isNotEmpty) setState(() => _have.addAll(saved));
    } catch (_) {}
  }

  Future<void> _remember() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, _have);
    } catch (_) {}
  }

  /// Adds what was typed or pasted: one item, or several separated by commas or lines.
  void _add([String? text]) {
    final items = (text ?? _input.text)
        .split(RegExp(r'[,،\n;]'))
        .map(
          (s) => s.replaceFirst(RegExp(r'^\s*(?:[-*•]|\d+[.)])\s*'), '').trim(),
        )
        .where((s) => s.isNotEmpty && s.length <= 80);
    setState(() {
      for (final item in items) {
        if (_have.length >= 40) break;
        if (!_have.any((h) => h.toLowerCase() == item.toLowerCase())) {
          _have.add(item);
        }
      }
      _input.clear();
    });
    _remember();
    _inputFocus.requestFocus();
  }

  void _remove(String item) {
    setState(() => _have.remove(item));
    _remember();
  }

  void _clearAll() {
    setState(() {
      _have.clear();
      _ideas = [];
    });
    _remember();
  }

  Future<void> _suggest() async {
    if (_input.text.trim().isNotEmpty) _add();
    if (_have.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ideas = await AiService().suggestMeals(List.of(_have));
      if (!mounted) return;
      setState(() => _ideas = ideas);
    } catch (e) {
      if (mounted) setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _open(AiIdea idea) async {
    final id = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (_) => _IdeaSheet(idea: idea),
    );
    if (id != null && mounted) context.go('/recipes/$id');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: PageWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, 96),
            children: [
              Text(l.whatCanICook, style: t.headlineMedium),
              const SizedBox(height: Gap.xs),
              Text(
                l.whatCanICookHint,
                style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
              ),
              const SizedBox(height: Gap.lg),
              TextField(
                controller: _input,
                focusNode: _inputFocus,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _add(),
                onChanged: (v) {
                  // A pasted list with line breaks becomes chips at once.
                  if (v.contains('\n')) _add(v);
                },
                decoration: InputDecoration(
                  labelText: l.addWhatYouHave,
                  hintText: l.addWhatYouHaveExample,
                  suffixIcon: IconButton(
                    tooltip: l.add,
                    icon: const Icon(Icons.add),
                    onPressed: () => _add(),
                  ),
                ),
              ),
              const SizedBox(height: Gap.md),
              if (_have.isEmpty)
                Text(
                  l.nothingAddedYet,
                  style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
                )
              else ...[
                Wrap(
                  spacing: Gap.sm,
                  runSpacing: Gap.sm,
                  children: [
                    for (final item in _have)
                      InputChip(
                        label: Text(item),
                        onDeleted: () => _remove(item),
                        deleteButtonTooltipMessage: l.removeItem(item),
                      ),
                  ],
                ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: _clearAll,
                    child: Text(l.clearAll),
                  ),
                ),
              ],
              const SizedBox(height: Gap.md),
              FilledButton.icon(
                onPressed: _busy || (_have.isEmpty && _input.text.isEmpty)
                    ? null
                    : _suggest,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _busy
                      ? l.thinkingUpMeals
                      : _ideas.isEmpty
                      ? l.suggestMeals
                      : l.suggestOtherMeals,
                ),
              ),
              const SizedBox(height: Gap.xs),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: Gap.md,
                children: [
                  const AiLanguageButton(),
                  ValueListenableBuilder<int?>(
                    valueListenable: AiService().remaining,
                    builder: (context, left, _) => left == null
                        ? const SizedBox.shrink()
                        : Text(
                            l.aiLeftToday(left),
                            style: t.bodySmall?.copyWith(
                              color: c.onSurfaceVariant,
                            ),
                          ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: Gap.md),
                Text(_error!, style: TextStyle(color: c.error)),
              ],
              if (_busy) ...[
                const SizedBox(height: Gap.lg),
                for (var i = 0; i < 3; i++) const CardSkeleton(),
              ] else if (_ideas.isNotEmpty) ...[
                SectionHeader(title: l.pickAMeal),
                for (final idea in _ideas)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Gap.sm),
                    child: _IdeaCard(idea: idea, onTap: () => _open(idea)),
                  ),
                Text(
                  l.aiCheckNote,
                  style: t.bodySmall?.copyWith(color: c.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IdeaCard extends StatelessWidget {
  const _IdeaCard({required this.idea, required this.onTap});

  final AiIdea idea;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final missing = idea.missing;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Gap.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FoodArt(title: idea.title, size: 72),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(idea.title, style: t.titleMedium),
                    if (idea.description.isNotEmpty) ...[
                      const SizedBox(height: Gap.xs),
                      Text(
                        idea.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodyMedium?.copyWith(
                          color: c.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: Gap.sm),
                    Wrap(
                      spacing: Gap.md,
                      runSpacing: Gap.xs,
                      children: [
                        MetaLabel(
                          icon: Icons.schedule,
                          text: formatMinutes(
                            idea.prepMinutes + idea.cookMinutes,
                          ),
                        ),
                        MetaLabel(
                          icon: Icons.people_outline,
                          text: l.servesN(idea.servings),
                        ),
                      ],
                    ),
                    const SizedBox(height: Gap.sm),
                    Text(
                      missing.isEmpty
                          ? l.youHaveEverything
                          : l.youdNeed(
                              missing.map((m) => m.ingredient.name).join(', '),
                            ),
                      style: t.bodySmall?.copyWith(
                        color: missing.isEmpty ? c.primary : c.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The whole suggested meal, with Save to my recipes. Closes with the new recipe's id.
class _IdeaSheet extends StatefulWidget {
  const _IdeaSheet({required this.idea});
  final AiIdea idea;

  @override
  State<_IdeaSheet> createState() => _IdeaSheetState();
}

class _IdeaSheetState extends State<_IdeaSheet> {
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final saved = await RecipeService().create(widget.idea.toRecipe());
      markDataChanged();
      if (!mounted) return;
      showMessage(context, context.l10n.savedToYourRecipes);
      Navigator.pop(context, saved.id);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showMessage(context, errorText(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final idea = widget.idea;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 1,
      builder: (context, scroll) => Column(
        children: [
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.lg),
              children: [
                Row(
                  children: [
                    FoodArt(title: idea.title, size: 56),
                    const SizedBox(width: Gap.md),
                    Expanded(child: Text(idea.title, style: t.headlineSmall)),
                  ],
                ),
                if (idea.description.isNotEmpty) ...[
                  const SizedBox(height: Gap.sm),
                  Text(
                    idea.description,
                    style: t.bodyLarge?.copyWith(color: c.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: Gap.md),
                Wrap(
                  spacing: Gap.md,
                  runSpacing: Gap.xs,
                  children: [
                    MetaLabel(
                      icon: Icons.timer_outlined,
                      text: '${l.prep} ${formatMinutes(idea.prepMinutes)}',
                    ),
                    MetaLabel(
                      icon: Icons.local_fire_department_outlined,
                      text: '${l.cook} ${formatMinutes(idea.cookMinutes)}',
                    ),
                    MetaLabel(
                      icon: Icons.people_outline,
                      text: l.servesN(idea.servings),
                    ),
                  ],
                ),
                SectionHeader(title: l.ingredients),
                for (final i in idea.ingredients)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Gap.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          i.have
                              ? Icons.check_circle_outline
                              : Icons.shopping_basket_outlined,
                          size: 20,
                          color: i.have ? c.primary : c.tertiary,
                          semanticLabel: i.have ? l.youHaveThis : l.toBuy,
                        ),
                        const SizedBox(width: Gap.sm),
                        Expanded(
                          child: Text(i.ingredient.name, style: t.bodyLarge),
                        ),
                        if (i.ingredient.amountText.isNotEmpty)
                          Text(
                            i.ingredient.amountText,
                            style: t.bodyMedium?.copyWith(
                              color: c.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                SectionHeader(title: l.steps),
                for (final (n, step) in idea.steps.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Gap.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 13,
                          backgroundColor: c.primaryContainer,
                          foregroundColor: c.onPrimaryContainer,
                          child: Text('${n + 1}', style: t.labelMedium),
                        ),
                        const SizedBox(width: Gap.md),
                        Expanded(child: Text(step, style: t.bodyLarge)),
                      ],
                    ),
                  ),
                Text(
                  l.aiCheckNote,
                  style: t.bodySmall?.copyWith(color: c.onSurfaceVariant),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Gap.lg,
                Gap.sm,
                Gap.lg,
                Gap.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l.close),
                    ),
                  ),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: const Icon(Icons.bookmark_add_outlined),
                      label: Text(l.saveToMyRecipes),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

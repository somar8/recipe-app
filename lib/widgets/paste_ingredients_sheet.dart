import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import 'package:flutter/services.dart';
import '../models/ingredient_parser.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';

/// Bottom sheet: paste text, see the ingredients it becomes, add them all at once.
/// Closes with the ingredients, or null when cancelled.
class PasteIngredientsSheet extends StatefulWidget {
  const PasteIngredientsSheet({super.key});

  @override
  State<PasteIngredientsSheet> createState() => _PasteIngredientsSheetState();
}

class _PasteIngredientsSheetState extends State<PasteIngredientsSheet> {
  final _text = TextEditingController();
  List<RecipeIngredient> _found = [];

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _update() => setState(() => _found = parseIngredients(_text.text));

  /// Fills the box from the clipboard, for one-tap pasting.
  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.trim().isEmpty || !mounted) return;
    _text.text = _text.text.trim().isEmpty ? text : '${_text.text}\n$text';
    _update();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final count = _found.length;

    return Padding(
      // Stay above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.l10n.pasteIngredients, style: t.titleLarge),
              const SizedBox(height: Gap.xs),
              Text(
                context.l10n.pasteIngredientsHint,
                style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
              ),
              const SizedBox(height: Gap.md),
              TextField(
                controller: _text,
                autofocus: true,
                minLines: 5,
                maxLines: 8,
                keyboardType: TextInputType.multiline,
                onChanged: (_) => _update(),
                decoration: InputDecoration(
                  hintText: context.l10n.pasteIngredientsExample,
                  alignLabelWithHint: true,
                  suffixIcon: IconButton(
                    tooltip: context.l10n.pasteFromClipboard,
                    icon: const Icon(Icons.content_paste),
                    onPressed: _pasteFromClipboard,
                  ),
                ),
              ),
              if (count > 0) ...[
                const SizedBox(height: Gap.md),
                Text(
                  context.l10n.weFoundIngredients(count),
                  style: t.titleSmall,
                ),
                const SizedBox(height: Gap.xs),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: count,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (_, i) {
                      final ing = _found[i];
                      final amount = ing.amountText;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: Gap.sm),
                        child: Row(
                          children: [
                            Expanded(child: Text(ing.name, style: t.bodyLarge)),
                            if (amount.isNotEmpty)
                              Text(
                                amount,
                                style: t.bodyMedium?.copyWith(
                                  color: c.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: Gap.md),
              Row(
                spacing: Gap.sm,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.l10n.cancel),
                    ),
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: count == 0
                          ? null
                          : () => Navigator.pop(context, _found),
                      child: Text(
                        count == 0
                            ? context.l10n.add
                            : context.l10n.addN(count),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

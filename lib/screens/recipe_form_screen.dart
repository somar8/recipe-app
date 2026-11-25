import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/common.dart';

/// One ingredient line in the form. The key keeps the row's identity while reordering.
class _IngredientFields {
  _IngredientFields([RecipeIngredient? i])
    : name = TextEditingController(text: i?.name ?? ''),
      quantity = TextEditingController(text: i?.quantity ?? ''),
      unit = TextEditingController(text: i?.unit ?? '');

  final key = UniqueKey();
  final TextEditingController name;
  final TextEditingController quantity;
  final TextEditingController unit;
  final nameFocus = FocusNode();

  bool get isEmpty => name.text.trim().isEmpty;

  void dispose() {
    name.dispose();
    quantity.dispose();
    unit.dispose();
    nameFocus.dispose();
  }
}

/// Opens full-screen. Closes with the saved recipe's id, or null when cancelled.
class RecipeFormScreen extends StatefulWidget {
  final int? editId;
  const RecipeFormScreen({super.key, this.editId});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _recipeService = RecipeService();
  final _formKey = GlobalKey<FormState>();
  bool get _isEdit => widget.editId != null;

  final _title = TextEditingController();
  final _description = TextEditingController();
  final _instructions = TextEditingController();
  final _prep = TextEditingController();
  final _cook = TextEditingController();
  final _servings = TextEditingController();
  final List<_IngredientFields> _ingredients = [];

  bool _loading = false;

  /// Editing, but the item could not be loaded: show an error, never an empty form
  /// (saving that would overwrite the real item with blanks).
  bool _loadFailed = false;
  bool _saving = false;
  String? _error;
  String _savedSnapshot = ''; // set in initState (new) or after loading (edit)

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _load();
    } else {
      _ingredients.add(_IngredientFields());
      _savedSnapshot = _snapshot();
    }
  }

  @override
  void dispose() {
    for (final c in [
      _title,
      _description,
      _instructions,
      _prep,
      _cook,
      _servings,
    ]) {
      c.dispose();
    }
    for (final row in _ingredients) {
      row.dispose();
    }
    super.dispose();
  }

  /// Everything typed, as one string, to tell whether there are unsaved changes.
  String _snapshot() => [
    _title.text,
    _description.text,
    _instructions.text,
    _prep.text,
    _cook.text,
    _servings.text,
    for (final i in _ingredients.where((i) => !i.isEmpty))
      '${i.name.text}|${i.quantity.text}|${i.unit.text}',
  ].join('\n');

  bool get _hasChanges => _snapshot() != _savedSnapshot;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await _recipeService.getById(widget.editId!);
      if (!mounted) return; // closed while loading
      for (final row in _ingredients) {
        row.dispose();
      }
      _ingredients.clear();
      _title.text = r.title;
      _description.text = r.description ?? '';
      _instructions.text = r.instructions ?? '';
      _prep.text = r.prepTimeMinutes?.toString() ?? '';
      _cook.text = r.cookTimeMinutes?.toString() ?? '';
      _servings.text = r.servings?.toString() ?? '';
      for (final i in r.ingredients ?? const <RecipeIngredient>[]) {
        _ingredients.add(_IngredientFields(i));
      }
      if (_ingredients.isEmpty) _ingredients.add(_IngredientFields());
      _savedSnapshot = _snapshot();
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = errorText(e);
          _loading = false;
          _loadFailed = true;
        });
      }
    }
  }

  void _addIngredient() {
    final row = _IngredientFields();
    setState(() => _ingredients.add(row));
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => row.nameFocus.requestFocus(),
    );
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index).dispose();
      if (_ingredients.isEmpty) _ingredients.add(_IngredientFields());
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    String? text(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    final recipe = Recipe(
      title: _title.text.trim(),
      description: text(_description),
      instructions: text(_instructions),
      prepTimeMinutes: int.tryParse(_prep.text),
      cookTimeMinutes: int.tryParse(_cook.text),
      servings: int.tryParse(_servings.text),
      ingredients: [
        for (final i in _ingredients.where((i) => !i.isEmpty))
          RecipeIngredient(
            name: i.name.text.trim(),
            quantity: text(i.quantity),
            unit: text(i.unit),
          ),
      ],
    );
    try {
      final saved = _isEdit
          ? await _recipeService.update(widget.editId!, recipe)
          : await _recipeService.create(recipe);
      if (!mounted) return;
      _savedSnapshot = _snapshot();
      _close(saved.id);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = errorText(e);
          _saving = false;
        });
      }
    }
  }

  /// Back to where the form was opened from, with the saved id. When the form was the
  /// first page (opened from a link or after a reload), goes to the item or the list.
  void _close(int? id) {
    if (context.canPop()) {
      context.pop(id);
    } else {
      context.go(
        id == null
            ? (widget.editId == null ? '/recipes' : '/recipes/${widget.editId}')
            : '/recipes/$id',
      );
    }
  }

  void _confirmOrClose() => _hasChanges ? _confirmLeave() : _close(null);

  Future<void> _confirmLeave() async {
    final leave = await confirmDialog(
      context,
      title: 'Discard changes?',
      message: 'What you typed in this recipe won\'t be saved.',
      confirmLabel: 'Discard',
    );
    if (leave && mounted) {
      _savedSnapshot = _snapshot();
      _close(null);
    }
  }

  String? _positiveNumber(String? v) {
    if (v == null || v.isEmpty) return null;
    final n = int.tryParse(v);
    return (n == null || n <= 0) ? 'Above 0' : null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _saving || _loading || _loadFailed || !_hasChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: () => context.canPop()
                ? Navigator.maybePop(context)
                : _confirmOrClose(),
          ),
          title: Text(_isEdit ? 'Edit recipe' : 'New recipe'),
        ),
        body: _loadFailed
            ? ErrorState(
                message: _error ?? 'Could not load this.',
                onRetry: () {
                  setState(() => _loadFailed = false);
                  _load();
                },
              )
            : _loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                onChanged: () => setState(() {}),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    Gap.lg,
                    Gap.sm,
                    Gap.lg,
                    Gap.xxl,
                  ),
                  children: [PageWidth(maxWidth: 680, child: _fields(context))],
                ),
              ),
        bottomNavigationBar: _loading || _loadFailed
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Gap.lg,
                    Gap.sm,
                    Gap.lg,
                    Gap.md,
                  ),
                  child: PageWidth(
                    maxWidth: 680,
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_isEdit ? 'Save changes' : 'Save recipe'),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _fields(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final numberFormat = [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(4),
    ];

    Widget numberField(
      TextEditingController ctrl,
      String label,
      String suffix,
      IconData icon,
    ) => TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: numberFormat,
      validator: _positiveNumber,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null)
          Container(
            margin: const EdgeInsets.only(bottom: Gap.md),
            padding: const EdgeInsets.all(Gap.md),
            decoration: BoxDecoration(
              color: c.errorContainer,
              borderRadius: BorderRadius.circular(Corners.sm),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: c.onErrorContainer),
                const SizedBox(width: Gap.sm),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(color: c.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
        TextFormField(
          controller: _title,
          autofocus: !_isEdit,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          style: t.titleMedium,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Give your recipe a name'
              : null,
          decoration: const InputDecoration(
            labelText: 'Recipe name',
            hintText: 'Fluffy pancakes',
          ),
        ),
        const SizedBox(height: Gap.md),
        TextFormField(
          controller: _description,
          minLines: 1,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Short description',
            hintText: 'Sunday breakfast classic',
          ),
        ),

        const SectionHeader(title: 'Time and servings'),
        LayoutBuilder(
          builder: (context, box) {
            final prep = numberField(
              _prep,
              'Prep',
              'min',
              Icons.timer_outlined,
            );
            final cook = numberField(
              _cook,
              'Cook',
              'min',
              Icons.local_fire_department_outlined,
            );
            final serves = numberField(
              _servings,
              'Serves',
              '',
              Icons.people_outline,
            );
            if (box.maxWidth >= 520) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: prep),
                  const SizedBox(width: Gap.md),
                  Expanded(child: cook),
                  const SizedBox(width: Gap.md),
                  Expanded(child: serves),
                ],
              );
            }
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: prep),
                    const SizedBox(width: Gap.md),
                    Expanded(child: cook),
                  ],
                ),
                const SizedBox(height: Gap.md),
                serves,
              ],
            );
          },
        ),

        SectionHeader(
          title: 'Ingredients',
          trailing: Text(
            '${_ingredients.where((i) => !i.isEmpty).length}',
            style: t.titleMedium?.copyWith(color: c.onSurfaceVariant),
          ),
        ),
        Text(
          'Drag the handle to change the order.',
          style: t.bodySmall?.copyWith(color: c.onSurfaceVariant),
        ),
        const SizedBox(height: Gap.sm),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: _ingredients.length,
          onReorderItem: (from, to) => setState(() {
            _ingredients.insert(to, _ingredients.removeAt(from));
          }),
          itemBuilder: (context, i) => _IngredientEditor(
            key: _ingredients[i].key,
            index: i,
            fields: _ingredients[i],
            onRemove: () => _removeIngredient(i),
            onChanged: () => setState(() {}),
            onSubmitted: i == _ingredients.length - 1 ? _addIngredient : null,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addIngredient,
            icon: const Icon(Icons.add),
            label: const Text('Add ingredient'),
          ),
        ),

        const SectionHeader(title: 'Steps'),
        TextFormField(
          controller: _instructions,
          minLines: 6,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText:
                'Whisk the flour, milk and eggs until smooth.\nRest the batter for 10 minutes.',
            helperText: 'One step per line. They\'re numbered for you.',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}

class _IngredientEditor extends StatelessWidget {
  const _IngredientEditor({
    super.key,
    required this.index,
    required this.fields,
    required this.onRemove,
    required this.onChanged,
    this.onSubmitted,
  });

  final int index;
  final _IngredientFields fields;
  final VoidCallback onRemove;
  final VoidCallback
  onChanged; // ingredient fields are not form fields, so report edits
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final name = TextField(
      controller: fields.name,
      focusNode: fields.nameFocus,
      onChanged: (_) => onChanged(),
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(hintText: 'Ingredient', isDense: true),
    );
    final qty = TextField(
      controller: fields.quantity,
      onChanged: (_) => onChanged(),
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(hintText: 'Amount', isDense: true),
    );
    final unit = TextField(
      controller: fields.unit,
      onChanged: (_) => onChanged(),
      textInputAction: onSubmitted != null
          ? TextInputAction.done
          : TextInputAction.next,
      onSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
      decoration: const InputDecoration(hintText: 'Unit', isDense: true),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Gap.xs,
                vertical: Gap.md,
              ),
              child: Icon(
                Icons.drag_indicator,
                color: c.outline,
                semanticLabel: 'Drag to reorder',
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                if (box.maxWidth >= 440) {
                  return Row(
                    children: [
                      Expanded(flex: 5, child: name),
                      const SizedBox(width: Gap.sm),
                      Expanded(flex: 2, child: qty),
                      const SizedBox(width: Gap.sm),
                      Expanded(flex: 2, child: unit),
                    ],
                  );
                }
                // Phones: the name gets the full width, amount and unit below it.
                return Column(
                  children: [
                    name,
                    const SizedBox(height: Gap.xs),
                    Row(
                      children: [
                        Expanded(child: qty),
                        const SizedBox(width: Gap.sm),
                        Expanded(child: unit),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: 'Remove ingredient',
            color: c.onSurfaceVariant,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

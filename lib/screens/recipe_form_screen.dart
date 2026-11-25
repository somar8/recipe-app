import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

class RecipeFormScreen extends StatefulWidget {
  final int? editId;
  const RecipeFormScreen({super.key, this.editId});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _recipeService = RecipeService();
  bool get _isEditMode => widget.editId != null;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = TextEditingController();

  List<({TextEditingController name, TextEditingController quantity, TextEditingController unit})>
      _ingredientControllers = [];

  bool _loading = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _addIngredientRow();
    if (_isEditMode) _loadRecipe();
  }

  void _addIngredientRow({RecipeIngredient? ingredient}) {
    setState(() {
      _ingredientControllers.add((
        name: TextEditingController(text: ingredient?.name ?? ''),
        quantity: TextEditingController(text: ingredient?.quantity ?? ''),
        unit: TextEditingController(text: ingredient?.unit ?? ''),
      ));
    });
  }

  void _removeIngredientRow(int index) {
    final row = _ingredientControllers[index];
    row.name.dispose();
    row.quantity.dispose();
    row.unit.dispose();
    setState(() { _ingredientControllers.removeAt(index); });
  }

  Future<void> _loadRecipe() async {
    setState(() { _loading = true; _error = null; });
    try {
      final recipe = await _recipeService.getById(widget.editId!);
      _titleController.text = recipe.title;
      _descriptionController.text = recipe.description ?? '';
      _instructionsController.text = recipe.instructions ?? '';
      _prepTimeController.text = recipe.prepTimeMinutes?.toString() ?? '';
      _cookTimeController.text = recipe.cookTimeMinutes?.toString() ?? '';
      _servingsController.text = recipe.servings?.toString() ?? '';

      // Clear default empty row and populate from recipe
      for (final row in _ingredientControllers) {
        row.name.dispose(); row.quantity.dispose(); row.unit.dispose();
      }
      _ingredientControllers = [];

      final ingredients = recipe.ingredients ?? [];
      for (final ing in ingredients) {
        _addIngredientRow(ingredient: ing);
      }
      if (_ingredientControllers.isEmpty) _addIngredientRow();

      setState(() { _loading = false; });
    } catch (_) {
      setState(() { _error = 'Failed to load recipe.'; _loading = false; });
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      setState(() { _error = 'Title is required.'; });
      return;
    }
    setState(() { _saving = true; _error = null; });

    final recipe = Recipe(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
      instructions: _instructionsController.text.trim().isNotEmpty ? _instructionsController.text.trim() : null,
      prepTimeMinutes: int.tryParse(_prepTimeController.text),
      cookTimeMinutes: int.tryParse(_cookTimeController.text),
      servings: int.tryParse(_servingsController.text),
      ingredients: _ingredientControllers
          .where((r) => r.name.text.trim().isNotEmpty)
          .map((r) => RecipeIngredient(
                name: r.name.text.trim(),
                quantity: r.quantity.text.trim().isNotEmpty ? r.quantity.text.trim() : null,
                unit: r.unit.text.trim().isNotEmpty ? r.unit.text.trim() : null,
              ))
          .toList(),
    );

    try {
      final saved = _isEditMode
          ? await _recipeService.update(widget.editId!, recipe)
          : await _recipeService.create(recipe);
      if (mounted) context.go('/recipes/${saved.id}');
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _saving = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    for (final row in _ingredientControllers) {
      row.name.dispose(); row.quantity.dispose(); row.unit.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Recipe' : 'New Recipe'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title *', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _prepTimeController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(labelText: 'Prep Time (min)', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _cookTimeController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(labelText: 'Cook Time (min)', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _servingsController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(labelText: 'Servings', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ingredients', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () => _addIngredientRow(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_ingredientControllers.length, (i) {
                    final row = _ingredientControllers[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: row.name,
                              decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder(), isDense: true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: row.quantity,
                              decoration: const InputDecoration(labelText: 'Qty', border: OutlineInputBorder(), isDense: true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: row.unit,
                              decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder(), isDense: true),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _ingredientControllers.length > 1 ? () => _removeIngredientRow(i) : null,
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Text('Instructions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _instructionsController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: 'Step by step instructions...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(_isEditMode ? 'Update Recipe' : 'Create Recipe'),
                  ),
                ],
              ),
            ),
    );
  }
}
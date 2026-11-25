import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/group_recipes.dart';
import '../services/group_service.dart';

class GroupFormScreen extends StatefulWidget {
  final int? editId;
  const GroupFormScreen({super.key, this.editId});

  @override
  State<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends State<GroupFormScreen> {
  final _groupService = GroupService();
  bool get _isEditMode => widget.editId != null;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _loading = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) _loadGroup();
  }

  Future<void> _loadGroup() async {
    setState(() { _loading = true; _error = null; });
    try {
      final group = await _groupService.getById(widget.editId!);
      _nameController.text = group.name;
      _descriptionController.text = group.description ?? '';
      setState(() { _loading = false; });
    } catch (_) {
      setState(() { _error = 'Failed to load collection.'; _loading = false; });
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() { _error = 'Name is required.'; });
      return;
    }
    setState(() { _saving = true; _error = null; });

    final group = GroupRecipes(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
    );

    try {
      final saved = _isEditMode
          ? await _groupService.update(widget.editId!, group)
          : await _groupService.create(group);
      if (mounted) context.go('/groups/${saved.id}');
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _saving = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Collection' : 'New Collection'),
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
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Collection Name *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(_isEditMode ? 'Update Collection' : 'Create Collection'),
                  ),
                ],
              ),
            ),
    );
  }
}
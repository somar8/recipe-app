import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import 'package:go_router/go_router.dart';
import '../models/group_recipes.dart';
import '../services/group_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/common.dart';
import '../widgets/food_art.dart';

/// Opens full-screen. Closes with the saved collection's id, or null when cancelled.
class GroupFormScreen extends StatefulWidget {
  final int? editId;
  const GroupFormScreen({super.key, this.editId});

  @override
  State<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends State<GroupFormScreen> {
  final _groupService = GroupService();
  final _formKey = GlobalKey<FormState>();
  bool get _isEdit => widget.editId != null;

  final _name = TextEditingController();
  final _description = TextEditingController();

  bool _loading = false;

  /// Editing, but the item could not be loaded: show an error, never an empty form
  /// (saving that would overwrite the real item with blanks).
  bool _loadFailed = false;
  bool _saving = false;
  String? _error;
  String _savedSnapshot = '\n';

  @override
  void initState() {
    super.initState();
    if (_isEdit) _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  String _snapshot() => '${_name.text}\n${_description.text}';
  bool get _hasChanges => _snapshot() != _savedSnapshot;

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final g = await _groupService.getById(widget.editId!);
      if (!mounted) return; // closed while loading
      _name.text = g.name;
      _description.text = g.description ?? '';
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

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final group = GroupRecipes(
      name: _name.text.trim(),
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
    );
    try {
      final saved = _isEdit
          ? await _groupService.update(widget.editId!, group)
          : await _groupService.create(group);
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
            ? (widget.editId == null ? '/groups' : '/groups/${widget.editId}')
            : '/groups/$id',
      );
    }
  }

  void _confirmOrClose() => _hasChanges ? _confirmLeave() : _close(null);

  Future<void> _confirmLeave() async {
    final leave = await confirmDialog(
      context,
      title: context.l10n.discardChangesQuestion,
      message: context.l10n.discardMessage,
      confirmLabel: context.l10n.discard,
    );
    if (leave && mounted) {
      _savedSnapshot = _snapshot();
      _close(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return PopScope(
      canPop: _saving || _loading || _loadFailed || !_hasChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: context.l10n.close,
            onPressed: () => context.canPop()
                ? Navigator.maybePop(context)
                : _confirmOrClose(),
          ),
          title: Text(
            _isEdit ? context.l10n.editCollection : context.l10n.newCollection,
          ),
        ),
        body: _loadFailed
            ? ErrorState(
                message: _error ?? context.l10n.couldNotLoad,
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
                    Gap.lg,
                    Gap.lg,
                    Gap.xxl,
                  ),
                  children: [
                    PageWidth(
                      maxWidth: 560,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: ValueListenableBuilder(
                              valueListenable: _name,
                              builder: (_, value, _) => CollectionArt(
                                name: value.text.trim().isEmpty
                                    ? 'New'
                                    : value.text.trim(),
                                size: 88,
                              ),
                            ),
                          ),
                          const SizedBox(height: Gap.xl),
                          if (_error != null) ...[
                            Text(_error!, style: TextStyle(color: c.error)),
                            const SizedBox(height: Gap.md),
                          ],
                          TextFormField(
                            controller: _name,
                            autofocus: !_isEdit,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? context.l10n.giveCollectionName
                                : null,
                            decoration: InputDecoration(
                              labelText: context.l10n.name,
                              hintText: context.l10n.collectionNameExample,
                            ),
                          ),
                          const SizedBox(height: Gap.md),
                          TextFormField(
                            controller: _description,
                            minLines: 2,
                            maxLines: 4,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              labelText: context.l10n.description,
                              hintText:
                                  context.l10n.collectionDescriptionExample,
                              alignLabelWithHint: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                    maxWidth: 560,
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
                            : Text(
                                _isEdit
                                    ? context.l10n.saveChanges
                                    : context.l10n.createCollection,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/group_recipes.dart';
import '../services/auth_service.dart';
import '../services/group_service.dart';

const _groupEmojis = ['📗','📘','📙','📕','📔','📒','📓','🗂️'];

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  final _groupService = GroupService();
  List<GroupRecipes> _groups = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _groupService.getAll();
      setState(() { _groups = data; _loading = false; });
    } catch (_) {
      setState(() { _error = 'Failed to load collections.'; _loading = false; });
    }
  }

  Future<void> _deleteGroup(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Collection'),
        content: const Text('Are you sure you want to delete this collection?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _groupService.delete(id);
      setState(() { _groups = _groups.where((g) => g.id != id).toList(); });
    } catch (_) {
      if (mounted) setState(() { _error = 'Failed to delete collection.'; });
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Logout', onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _groups.isEmpty
                    ? const Center(child: Text('No collections yet.'))
                    : ListView.builder(
                        itemCount: _groups.length,
                        itemBuilder: (_, i) {
                          final group = _groups[i];
                          return ListTile(
                            leading: Text(
                              _groupEmojis[i % _groupEmojis.length],
                              style: const TextStyle(fontSize: 28),
                            ),
                            title: Text(group.name),
                            subtitle: group.description != null
                                ? Text(group.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
                                : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteGroup(group.id!),
                            ),
                            onTap: () => context.push('/groups/${group.id}'),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/groups/new');
          _loadGroups();
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) context.go('/recipes');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Recipes'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_open), label: 'Collections'),
        ],
      ),
    );
  }
}
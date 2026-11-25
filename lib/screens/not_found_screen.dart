import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/common.dart';

/// For links that point nowhere, such as /recipes/abc or a recipe that was deleted.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: EmptyState(
        icon: Icons.search_off,
        title: 'Page not found',
        message:
            'This link doesn\'t lead anywhere. The recipe may have been deleted.',
        actionLabel: 'Go to your recipes',
        actionIcon: Icons.restaurant_menu,
        onAction: () => context.go('/recipes'),
      ),
    );
  }
}

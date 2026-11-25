import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
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
        title: context.l10n.pageNotFound,
        message: context.l10n.pageNotFoundMessage,
        actionLabel: context.l10n.goToYourRecipes,
        actionIcon: Icons.restaurant_menu,
        onAction: () => context.go('/recipes'),
      ),
    );
  }
}

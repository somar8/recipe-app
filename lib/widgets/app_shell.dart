import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'food_art.dart';
import '../services/friend_service.dart';

/// Screen widths where the layout changes (Material 3 window size classes).
abstract final class Breakpoints {
  /// Below this: phone layout with a bottom bar.
  static const double medium = 600;

  /// From this width the side rail shows its labels next to the icons.
  static const double expanded = 1100;
}

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _destinations = [
  _Destination(
    'Recipes',
    Icons.restaurant_menu_outlined,
    Icons.restaurant_menu,
  ),
  _Destination(
    'Collections',
    Icons.folder_special_outlined,
    Icons.folder_special,
  ),
  _Destination('Account', Icons.person_outline, Icons.person),
];

/// The frame around the three main tabs: a bottom bar on phones, a side rail on
/// tablets and laptops. Each tab keeps its own history and scroll position.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  StatefulNavigationShell get shell => widget.shell;

  @override
  void initState() {
    super.initState();
    // Friend requests waiting: shown as a badge on the Account tab.
    FriendService().refreshWaitingCount();
  }

  /// Account icon with the number of waiting friend requests.
  Widget _icon(_Destination d, {required bool selected}) {
    final icon = Icon(selected ? d.selectedIcon : d.icon);
    if (d.label != 'Account') return icon;
    return ValueListenableBuilder<int>(
      valueListenable: FriendService().waitingCount,
      builder: (_, count, _) => Semantics(
        label: count == 0
            ? null
            : '$count friend ${count == 1 ? 'request' : 'requests'} waiting',
        child: Badge(
          isLabelVisible: count > 0,
          label: Text('$count'),
          child: icon,
        ),
      ),
    );
  }

  void _select(int index) {
    // Tapping the current tab again returns to its first screen.
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < Breakpoints.medium) {
      return Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: _select,
          destinations: [
            for (final d in _destinations)
              NavigationDestination(
                icon: _icon(d, selected: false),
                selectedIcon: _icon(d, selected: true),
                label: d.label,
              ),
          ],
        ),
      );
    }

    final extended = width >= Breakpoints.expanded;
    final c = Theme.of(context).colorScheme;
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: _select,
            extended: extended,
            minExtendedWidth: 220,
            labelType: extended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            groupAlignment: -0.85,
            leading: Padding(
              padding: const EdgeInsets.only(top: Gap.lg, bottom: Gap.sm),
              child: extended
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppLogo(size: 40),
                        const SizedBox(width: Gap.md),
                        Text(
                          'Recipe App',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    )
                  : const AppLogo(size: 40),
            ),
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: _icon(d, selected: false),
                  selectedIcon: _icon(d, selected: true),
                  label: Text(d.label),
                ),
            ],
          ),
          VerticalDivider(width: 1, thickness: 1, color: c.outlineVariant),
          Expanded(child: shell),
        ],
      ),
    );
  }
}

/// Centres page content and caps its width, so text and forms stay readable on wide screens.
class PageWidth extends StatelessWidget {
  const PageWidth({super.key, required this.child, this.maxWidth = 760});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    // heightFactor 1: as tall as the content (a full page fills the screen anyway; a
    // bottom bar stays a bar).
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

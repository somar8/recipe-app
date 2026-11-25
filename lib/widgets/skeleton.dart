import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Gently pulses its child, for loading placeholders. Holds still when the device asks
/// for reduced motion.
class Pulse extends StatefulWidget {
  const Pulse({super.key, required this.child});

  final Widget child;

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduced motion: hold still at full strength.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(
        begin: 0.45,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}

/// A grey rounded block standing in for content that is still loading.
class Bone extends StatelessWidget {
  const Bone({super.key, this.width, this.height = 14, this.radius = 6});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Placeholder in the shape of a recipe or collection card.
class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Gap.md),
        child: Row(
          children: [
            const Bone(width: 72, height: 72, radius: Corners.sm),
            const SizedBox(width: Gap.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FractionallySizedBox(
                    widthFactor: 0.6,
                    child: Bone(height: 16),
                  ),
                  const SizedBox(height: Gap.sm),
                  const FractionallySizedBox(
                    widthFactor: 0.85,
                    child: Bone(height: 12),
                  ),
                  const SizedBox(height: Gap.md),
                  Row(
                    children: const [
                      Bone(width: 56, height: 10),
                      SizedBox(width: Gap.md),
                      Bone(width: 40, height: 10),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading placeholder for a list page: a heading and a few cards.
class ListPageSkeleton extends StatelessWidget {
  const ListPageSkeleton({super.key, this.cards = 5, this.showSearch = true});

  final int cards;
  final bool showSearch;

  @override
  Widget build(BuildContext context) {
    return Pulse(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(Gap.lg),
        children: [
          const Bone(width: 120, height: 12),
          const SizedBox(height: Gap.sm),
          const Bone(width: 200, height: 28),
          if (showSearch) ...[
            const SizedBox(height: Gap.lg),
            const Bone(height: 48, radius: Corners.sm),
          ],
          const SizedBox(height: Gap.lg),
          for (var i = 0; i < cards; i++) ...[
            const CardSkeleton(),
            const SizedBox(height: Gap.md),
          ],
        ],
      ),
    );
  }
}

/// Loading placeholder for the recipe page.
class RecipePageSkeleton extends StatelessWidget {
  const RecipePageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Pulse(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          const Bone(height: 200, radius: 0),
          Padding(
            padding: const EdgeInsets.all(Gap.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Gap.sm),
                const Bone(width: 240, height: 28),
                const SizedBox(height: Gap.md),
                const Bone(width: 180, height: 14),
                const SizedBox(height: Gap.lg),
                Row(
                  children: [
                    for (var i = 0; i < 4; i++) ...[
                      if (i > 0) const SizedBox(width: Gap.sm),
                      const Expanded(
                        child: Bone(height: 72, radius: Corners.sm),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: Gap.xl),
                const Bone(width: 140, height: 22),
                const SizedBox(height: Gap.md),
                for (var i = 0; i < 4; i++) ...[
                  const Bone(height: 16),
                  const SizedBox(height: Gap.md),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

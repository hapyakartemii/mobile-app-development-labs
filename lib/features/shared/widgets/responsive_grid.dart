import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';

/// Lays children out in as many columns as fit the available width.
///
/// Uses [LayoutBuilder], so it adapts to its parent, not the whole screen
/// (e.g. a half-width column on tablets).
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    required this.children,
    super.key,
    this.minItemWidth = 150,
    this.maxColumns = 4,
  });

  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.m;
        final width = constraints.maxWidth;
        final columns = ((width + gap) / (minItemWidth + gap)).floor().clamp(
          1,
          maxColumns,
        );
        final itemWidth = (width - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

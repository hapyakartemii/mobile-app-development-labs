import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/theme/responsive.dart';

/// Scrollable page content with adaptive padding and a max width,
/// so screens don't stretch edge to edge on tablets.
class PageBody extends StatelessWidget {
  const PageBody({required this.child, super.key, this.maxWidth = 1100});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(context.pagePadding),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        ),
      ),
    );
  }
}

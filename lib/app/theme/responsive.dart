import 'package:flutter/widgets.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';

/// Width thresholds for switching layouts.
abstract final class Breakpoints {
  static const double tablet = 600;
  static const double wide = 900;
}

/// Screen-size helpers based on [MediaQuery].
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isTablet => screenWidth >= Breakpoints.tablet;

  bool get isWide => screenWidth >= Breakpoints.wide;

  double get pagePadding => isTablet ? AppSpacing.xl : AppSpacing.m;
}

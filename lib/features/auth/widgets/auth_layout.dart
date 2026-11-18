import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/app/theme/responsive.dart';
import 'package:flutter_lab1/features/shared/widgets/app_logo.dart';

/// Shared frame for login and registration: logo, title and a form
/// limited in width so it stays readable on tablets.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    required this.title,
    required this.subtitle,
    required this.children,
    super.key,
  });

  static const double maxFormWidth = 440;

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.pagePadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxFormWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.m,
                children: [
                  const Center(child: AppLogo()),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app_routes.dart';

/// Top bar of the dashboard: refresh from the server and the profile.
class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({required this.onRefresh, super.key});

  final VoidCallback onRefresh;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Метеостанція'),
      actions: [
        IconButton(
          tooltip: 'Оновити',
          icon: const Icon(Icons.refresh),
          onPressed: onRefresh,
        ),
        IconButton(
          tooltip: 'Профіль',
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
        ),
      ],
    );
  }
}

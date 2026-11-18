import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app_routes.dart';

/// Top bar of the dashboard with a button to the profile.
class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Метеостанція'),
      actions: [
        IconButton(
          tooltip: 'Профіль',
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
        ),
      ],
    );
  }
}

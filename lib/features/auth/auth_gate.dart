import 'package:flutter/material.dart';
import 'package:flutter_lab1/features/shared/widgets/app_logo.dart';

/// Splash while [AuthCubit.checkSession] restores the saved session;
/// [AppShell] then opens the dashboard or the login screen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 24,
          children: [AppLogo(), CircularProgressIndicator()],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app_routes.dart';
import 'package:flutter_lab1/app/app_scope.dart';
import 'package:flutter_lab1/features/shared/widgets/app_logo.dart';

/// First screen: restores the saved session and opens the dashboard,
/// or the login screen if nobody is signed in.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final user = await AppScope.of(context).authRepository.currentUser();
    if (!mounted) return;
    await Navigator.pushReplacementNamed(
      context,
      user == null ? AppRoutes.login : AppRoutes.main,
    );
  }

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

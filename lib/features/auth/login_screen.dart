import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app_routes.dart';
import 'package:flutter_lab1/app/app_scope.dart';
import 'package:flutter_lab1/domain/repositories/auth_repository.dart';
import 'package:flutter_lab1/domain/validation/validators.dart';
import 'package:flutter_lab1/features/auth/widgets/auth_layout.dart';
import 'package:flutter_lab1/features/auth/widgets/auth_switch_link.dart';
import 'package:flutter_lab1/features/shared/widgets/app_button.dart';
import 'package:flutter_lab1/features/shared/widgets/app_message.dart';
import 'package:flutter_lab1/features/shared/widgets/app_text_field.dart';
import 'package:flutter_lab1/features/shared/widgets/notice_banner.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      await AppScope.of(
        context,
      ).authRepository.login(email: _email.text, password: _password.text);
      if (!mounted) return;
      await AppRoutes.resetTo(context, AppRoutes.main);
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AuthLayout(
        title: 'Вхід',
        subtitle: 'Увійдіть, щоб бачити дані своїх метеостанцій',
        children: [
          AppTextField(
            label: 'Email',
            hint: 'name@example.com',
            icon: Icons.email_outlined,
            controller: _email,
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
          ),
          AppTextField(
            label: 'Пароль',
            icon: Icons.lock_outline,
            controller: _password,
            validator: Validators.requiredPassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            enabled: !_isLoading,
            isPassword: true,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => showComingSoon(context),
              child: const Text('Забули пароль?'),
            ),
          ),
          if (_error case final error?) NoticeBanner(message: error),
          AppButton(
            label: 'Увійти',
            icon: Icons.login,
            isLoading: _isLoading,
            onPressed: _submit,
          ),
          AuthSwitchLink(
            question: 'Немає акаунта?',
            action: 'Зареєструватися',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.registration),
          ),
        ],
      ),
    );
  }
}

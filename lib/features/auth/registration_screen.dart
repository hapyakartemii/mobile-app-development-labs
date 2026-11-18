import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app_routes.dart';
import 'package:flutter_lab1/app/app_scope.dart';
import 'package:flutter_lab1/domain/repositories/auth_repository.dart';
import 'package:flutter_lab1/domain/validation/validators.dart';
import 'package:flutter_lab1/features/auth/widgets/auth_layout.dart';
import 'package:flutter_lab1/features/auth/widgets/auth_switch_link.dart';
import 'package:flutter_lab1/features/shared/widgets/app_button.dart';
import 'package:flutter_lab1/features/shared/widgets/app_text_field.dart';
import 'package:flutter_lab1/features/shared/widgets/notice_banner.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in [_name, _email, _password, _confirm]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      await AppScope.of(context).authRepository.register(
        name: _name.text,
        email: _email.text,
        password: _password.text,
      );
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
        title: 'Реєстрація',
        subtitle: 'Створіть акаунт і підключіть першу метеостанцію',
        children: [
          AppTextField(
            label: "Ім'я",
            icon: Icons.person_outline,
            controller: _name,
            validator: Validators.name,
            enabled: !_isLoading,
          ),
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
            hint: 'Мінімум 8 символів, літери та цифри',
            icon: Icons.lock_outline,
            controller: _password,
            validator: Validators.password,
            enabled: !_isLoading,
            isPassword: true,
          ),
          AppTextField(
            label: 'Повторіть пароль',
            icon: Icons.lock_reset,
            controller: _confirm,
            validator: Validators.confirmPassword(() => _password.text),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            enabled: !_isLoading,
            isPassword: true,
          ),
          if (_error case final error?) NoticeBanner(message: error),
          AppButton(
            label: 'Створити акаунт',
            icon: Icons.person_add_alt_1,
            isLoading: _isLoading,
            onPressed: _submit,
          ),
          AuthSwitchLink(
            question: 'Вже маєте акаунт?',
            action: 'Увійти',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

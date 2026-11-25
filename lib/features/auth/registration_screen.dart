import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab1/domain/validation/validators.dart';
import 'package:flutter_lab1/features/auth/widgets/auth_layout.dart';
import 'package:flutter_lab1/features/auth/widgets/auth_switch_link.dart';
import 'package:flutter_lab1/features/shared/widgets/app_button.dart';
import 'package:flutter_lab1/features/shared/widgets/app_text_field.dart';
import 'package:flutter_lab1/features/shared/widgets/notice_banner.dart';
import 'package:flutter_lab1/logic/auth/auth_cubit.dart';
import 'package:flutter_lab1/logic/auth/auth_state.dart';

/// Registration form. Stateful only for the text controllers and the form
/// key; the request, its loading state and errors live in [AuthCubit].
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

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().clearError();
  }

  @override
  void dispose() {
    for (final controller in [_name, _email, _password, _confirm]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().register(
      name: _name.text,
      email: _email.text,
      password: _password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) => Form(
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
              enabled: !state.isSubmitting,
            ),
            AppTextField(
              label: 'Email',
              hint: 'name@example.com',
              icon: Icons.email_outlined,
              controller: _email,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              enabled: !state.isSubmitting,
            ),
            AppTextField(
              label: 'Пароль',
              hint: 'Мінімум 8 символів, літери та цифри',
              icon: Icons.lock_outline,
              controller: _password,
              validator: Validators.password,
              enabled: !state.isSubmitting,
              isPassword: true,
            ),
            AppTextField(
              label: 'Повторіть пароль',
              icon: Icons.lock_reset,
              controller: _confirm,
              validator: Validators.confirmPassword(() => _password.text),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              enabled: !state.isSubmitting,
              isPassword: true,
            ),
            if (state.error case final error?) NoticeBanner(message: error),
            AppButton(
              label: 'Створити акаунт',
              icon: Icons.person_add_alt_1,
              isLoading: state.isSubmitting,
              onPressed: _submit,
            ),
            AuthSwitchLink(
              question: 'Вже маєте акаунт?',
              action: 'Увійти',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

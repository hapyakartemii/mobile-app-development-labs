import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab1/app/app_routes.dart';
import 'package:flutter_lab1/domain/validation/validators.dart';
import 'package:flutter_lab1/features/auth/widgets/auth_layout.dart';
import 'package:flutter_lab1/features/auth/widgets/auth_switch_link.dart';
import 'package:flutter_lab1/features/shared/widgets/app_button.dart';
import 'package:flutter_lab1/features/shared/widgets/app_message.dart';
import 'package:flutter_lab1/features/shared/widgets/app_text_field.dart';
import 'package:flutter_lab1/features/shared/widgets/notice_banner.dart';
import 'package:flutter_lab1/logic/auth/auth_cubit.dart';
import 'package:flutter_lab1/logic/auth/auth_state.dart';

/// Login form. Stateful only to own the text controllers and the form key
/// (local UI state); loading and errors come from [AuthCubit], and
/// [AppShell] opens the dashboard once the user is signed in.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().clearError();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().login(
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
              enabled: !state.isSubmitting,
            ),
            AppTextField(
              label: 'Пароль',
              icon: Icons.lock_outline,
              controller: _password,
              validator: Validators.requiredPassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              enabled: !state.isSubmitting,
              isPassword: true,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => showComingSoon(context),
                child: const Text('Забули пароль?'),
              ),
            ),
            if (state.error case final error?) NoticeBanner(message: error),
            AppButton(
              label: 'Увійти',
              icon: Icons.login,
              isLoading: state.isSubmitting,
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
      ),
    );
  }
}

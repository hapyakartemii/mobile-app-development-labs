import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab1/logic/ui/visibility_cubit.dart';

/// Form field with an icon; password fields get a visibility toggle kept
/// in a small [VisibilityCubit] instead of `setState`.
/// Errors from [validator] appear under the field.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    required this.icon,
    super.key,
    this.controller,
    this.validator,
    this.hint,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.enabled = true,
    this.isPassword = false,
  });

  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool isPassword;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VisibilityCubit(hidden: isPassword),
      child: BlocBuilder<VisibilityCubit, bool>(
        builder: (context, hidden) => TextFormField(
          controller: controller,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          enabled: enabled,
          obscureText: hidden,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            errorMaxLines: 2,
            prefixIcon: Icon(icon),
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: context.read<VisibilityCubit>().toggle,
                    tooltip: hidden ? 'Показати пароль' : 'Сховати пароль',
                    icon: Icon(
                      hidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

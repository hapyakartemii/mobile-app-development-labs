import 'package:flutter/material.dart';

/// Form field with an icon; password fields get a visibility toggle.
/// Errors from [validator] appear under the field.
class AppTextField extends StatefulWidget {
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
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.isPassword;

  void _toggleVisibility() => setState(() => _obscured = !_obscured);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      obscureText: _obscured,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorMaxLines: 2,
        prefixIcon: Icon(widget.icon),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: _toggleVisibility,
                tooltip: _obscured ? 'Показати пароль' : 'Сховати пароль',
                icon: Icon(
                  _obscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              )
            : null,
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Campo de texto do design system.
///
/// A aparência vem do `InputDecorationTheme` de `AppTheme`. Com
/// [obscureText], exibe a ação acessível de mostrar/ocultar o conteúdo.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLines;
  final int? minLines;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _obscured,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.obscureText ? 1 : widget.minLines,
      enableSuggestions: !widget.obscureText,
      autocorrect: !widget.obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                key: const Key('password-visibility'),
                tooltip: _obscured ? 'Mostrar senha' : 'Ocultar senha',
                onPressed: widget.enabled
                    ? () => setState(() => _obscured = !_obscured)
                    : null,
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

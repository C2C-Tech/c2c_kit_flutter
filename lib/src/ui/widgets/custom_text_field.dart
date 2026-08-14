import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';
import '../l10n/kit_l10n.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.l10n,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final KitL10n l10n;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: KitColors.textPrimary,
      ),
      validator: widget.validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return widget.l10n.fieldRequired(widget.label);
            }
            return null;
          },
      decoration: kitInputDecoration(
        label: widget.label,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: KitColors.textHint,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
    );
  }
}

InputDecoration kitInputDecoration({
  required String label,
  IconData? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      color: KitColors.textSecondary,
      fontWeight: FontWeight.w500,
    ),
    floatingLabelStyle: const TextStyle(
      color: KitColors.primary,
      fontWeight: FontWeight.w600,
    ),
    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, color: KitColors.primary, size: 20)
        : null,
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    filled: true,
    fillColor: KitColors.primaryMuted.withValues(alpha: 0.45),
    border: _border(KitColors.border, width: 1),
    enabledBorder: _border(KitColors.border, width: 1),
    focusedBorder: _border(KitColors.primary, width: 1.5),
    errorBorder: _border(KitColors.error, width: 1),
    focusedErrorBorder: _border(KitColors.error, width: 1.5),
  );
}

OutlineInputBorder _border(Color color, {double width = 1}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppDimensions.radius16),
    borderSide: BorderSide(color: color, width: width),
  );
}

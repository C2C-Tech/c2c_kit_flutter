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
        fontSize: 13,
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
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: KitColors.primary),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: KitColors.primary, size: 22)
            : null,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        filled: true,
        fillColor: Colors.grey.withValues(alpha: 0.05),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        border: _border(KitColors.primary),
        enabledBorder: _border(KitColors.primary),
        focusedBorder: _border(KitColors.primary),
        errorBorder: _border(KitColors.error, width: 1),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 2}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radius12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

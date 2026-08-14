import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';

class KitPinField extends StatelessWidget {
  const KitPinField({
    super.key,
    required this.length,
    required this.onChanged,
  });

  final int length;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width.clamp(0, AppDimensions.maxFormWidth);
    final spacing = 8.0;
    final available = maxWidth - AppDimensions.spacing32 * 2;
    final cell = ((available - spacing * (length - 1)) / length).clamp(36.0, 48.0);

    return MaterialPinField(
      length: length,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      theme: MaterialPinTheme(
        cellSize: Size(cell, cell + 10),
        fillColor: KitColors.primaryMuted,
        filledFillColor: KitColors.white,
        focusedFillColor: KitColors.primary.withValues(alpha: 0.08),
        spacing: spacing,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        borderColor: KitColors.border,
        focusedBorderColor: KitColors.primary,
        filledBorderColor: KitColors.primary,
        borderWidth: 1,
        focusedBorderWidth: 1.5,
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: KitColors.textPrimary,
        ),
      ),
    );
  }
}

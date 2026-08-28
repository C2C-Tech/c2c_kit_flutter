import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';
import '../../../constants/extras.dart';
import '../../../constants/validations.dart';
import '../l10n/kit_l10n.dart';

/// Live password requirement checklist shown while the user types.
class KitPasswordStrengthIndicator extends StatelessWidget {
  const KitPasswordStrengthIndicator({
    super.key,
    required this.password,
    required this.l10n,
    required this.visible,
  });

  final String password;
  final KitL10n l10n;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: AppDurations.fast,
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: visible
          ? Padding(
              padding: const EdgeInsets.only(top: AppDimensions.spacing12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.spacing12),
                decoration: BoxDecoration(
                  color: KitColors.primaryMuted.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(AppDimensions.radius12),
                  border: Border.all(
                    color: KitColors.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ConditionRow(
                      label: l10n.passwordMinEightCharacters,
                      met: PasswordValidation.hasMinLength(password),
                    ),
                    const SizedBox(height: AppDimensions.spacing4),
                    _ConditionRow(
                      label: l10n.passwordOneUppercase,
                      met: PasswordValidation.hasUppercase(password),
                    ),
                    const SizedBox(height: AppDimensions.spacing4),
                    _ConditionRow(
                      label: l10n.passwordOneSpecialCharacter,
                      met: PasswordValidation.hasSpecialChar(password),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _ConditionRow extends StatelessWidget {
  const _ConditionRow({
    required this.label,
    required this.met,
  });

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final Color color = met ? KitColors.success : KitColors.textHint;
    final IconData icon = met
        ? Icons.check_circle_rounded
        : Icons.radio_button_unchecked_rounded;

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppDimensions.spacing8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: met ? FontWeight.w600 : FontWeight.w500,
              color: met ? KitColors.textPrimary : KitColors.textSecondary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

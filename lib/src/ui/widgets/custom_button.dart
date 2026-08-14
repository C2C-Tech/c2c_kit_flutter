import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isOutlined = false,
    this.isLoading = false,
    this.backgroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final bool isLoading;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? KitColors.primary;
    final enabled = !isLoading && onPressed != null;

    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        height: AppDimensions.buttonHeight,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: bg,
            backgroundColor: bg.withValues(alpha: 0.04),
            side: BorderSide(color: bg.withValues(alpha: 0.55), width: 1.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radius16),
            ),
          ),
          child: _child(bg),
        ),
      );
    }

    final radius = BorderRadius.circular(AppDimensions.radius16);
    final useBrandGradient = backgroundColor == null;

    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          color: useBrandGradient ? null : bg,
          gradient: useBrandGradient
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: enabled
                      ? [KitColors.primaryLight, bg]
                      : [
                          KitColors.primaryLight.withValues(alpha: 0.45),
                          bg.withValues(alpha: 0.45),
                        ],
                )
              : null,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: bg.withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: KitColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: _child(KitColors.white),
        ),
      ),
    );
  }

  Widget _child(Color color) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2.2, color: color),
      );
    }
    return Text(
      label,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: color,
      ),
    );
  }
}

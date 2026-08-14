import 'package:flutter/material.dart';

import '../../../constants/apps.dart';
import '../../../constants/colors.dart';

/// Per-app mark so host products stay visually distinct.
class C2cAppLogo extends StatelessWidget {
  const C2cAppLogo({super.key, required this.app, this.size = 40});

  final C2cApp app;
  final double size;

  static const packageName = 'c2c_kit_flutter';

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.24;
    final path = app.logoPath;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        color: KitColors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: KitColors.primary.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: KitColors.primary.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: path == null
          ? Icon(
              app.fallbackIcon,
              size: size * 0.52,
              color: KitColors.primary,
            )
          : Image.asset(
              path,
              package: packageName,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
    );
  }
}

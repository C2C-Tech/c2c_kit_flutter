import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../constants/apps.dart';
import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';
import '../../../constants/extras.dart';
import 'c2c_app_logo.dart';
import 'c2c_logo.dart';

/// C2C platform mark plus the host app identity.
class C2cBrandHeader extends StatelessWidget {
  const C2cBrandHeader({
    super.key,
    required this.app,
    this.title,
    this.subtitle,
    this.compact = false,
  });

  final C2cApp app;
  final String? title;
  final String? subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = compact ? _compact() : _hero();

    return content
        .animate()
        .fadeIn(duration: AppDurations.normal)
        .slideY(begin: 0.06, end: 0, duration: AppDurations.normal, curve: Curves.easeOut);
  }

  Widget _hero() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 168,
              height: 168,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    KitColors.primaryLight.withValues(alpha: 0.22),
                    KitColors.primaryLight.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            const C2cLogo(size: 104),
          ],
        ),
        const SizedBox(height: AppDimensions.spacing8),
        _appIdentityCard(),
        if (title != null) ...[
          const SizedBox(height: AppDimensions.spacing24),
          Text(
            title!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: KitColors.textPrimary,
            ),
          ),
        ],
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: KitColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _appIdentityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing12,
      ),
      decoration: BoxDecoration(
        color: KitColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        border: Border.all(color: KitColors.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: KitColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          C2cAppLogo(app: app, size: 48),
          const SizedBox(width: AppDimensions.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: KitColors.textPrimary,
                  ),
                ),
                if (app.punchLine != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    app.punchLine!,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.3,
                      color: KitColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compact() {
    return Row(
      children: [
        const C2cLogo(size: 44),
        const SizedBox(width: AppDimensions.spacing12),
        C2cAppLogo(app: app, size: 40),
        const SizedBox(width: AppDimensions.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                  app.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: KitColors.textPrimary,
                  ),
                ),
                if (title != null || app.punchLine != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    title ?? app.punchLine!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: KitColors.textSecondary,
                    ),
                  ),
                ],
            ],
          ),
        ),
      ],
    );
  }
}

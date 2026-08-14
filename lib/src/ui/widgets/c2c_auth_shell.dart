import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../constants/apps.dart';
import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';
import '../../../constants/extras.dart';
import '../l10n/kit_l10n.dart';
import 'c2c_brand_header.dart';

/// Shared auth page chrome: glow, padding, and a centered max-width column.
class C2cAuthShell extends StatelessWidget {
  const C2cAuthShell({
    super.key,
    required this.app,
    required this.child,
    this.locale = KitL10n.defaultLocale,
    this.title,
    this.subtitle,
    this.compactHeader = false,
    this.showHeader = true,
  });

  final C2cApp app;
  final Widget child;
  final Locale locale;
  final String? title;
  final String? subtitle;
  final bool compactHeader;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final padding = AppDimensions.contentPadding(context);
    final compactSubtitle = subtitle;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            KitColors.primaryLight.withValues(alpha: 0.16),
            KitColors.background,
            KitColors.background,
          ],
          stops: const [0, 0.38, 1],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            padding,
            AppDimensions.spacing16,
            padding,
            padding + 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimensions.maxFormWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showHeader) ...[
                    C2cBrandHeader(
                      app: app,
                      locale: locale,
                      title: title,
                      subtitle: subtitle,
                      compact: compactHeader,
                    ),
                    if (compactHeader &&
                        compactSubtitle != null &&
                        compactSubtitle.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.spacing12),
                      Text(
                        compactSubtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: KitColors.textSecondary,
                        ),
                      ),
                    ],
                    SizedBox(
                      height: compactHeader
                          ? AppDimensions.spacing24
                          : AppDimensions.spacing32,
                    ),
                  ],
                  child
                      .animate()
                      .fadeIn(
                        delay: AppDurations.fast,
                        duration: AppDurations.normal,
                      )
                      .slideY(
                        begin: 0.04,
                        end: 0,
                        delay: AppDurations.fast,
                        duration: AppDurations.normal,
                        curve: Curves.easeOut,
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

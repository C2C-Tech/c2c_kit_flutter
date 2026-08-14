import 'package:flutter/material.dart';

import '../../../constants/apps.dart';
import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';
import 'c2c_app_logo.dart';
import 'c2c_logo.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.app,
    this.onBack,
    this.actions,
    this.showBack = true,
  });

  final String title;
  final C2cApp? app;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: KitColors.surface,
      foregroundColor: KitColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      titleSpacing: showBack ? 0 : AppDimensions.spacing16,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: KitColors.textPrimary,
        ),
      ),
      actions: [
        if (app != null)
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.spacing12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const C2cLogo(size: 28),
                const SizedBox(width: 8),
                C2cAppLogo(app: app!, size: 28),
              ],
            ),
          ),
        ...?actions,
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: KitColors.primary.withValues(alpha: 0.08),
          height: 1,
        ),
      ),
    );
  }
}

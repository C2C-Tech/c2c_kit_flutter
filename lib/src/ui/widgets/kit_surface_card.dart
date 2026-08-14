import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';

class KitSurfaceCard extends StatelessWidget {
  const KitSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.spacing20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: KitColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius20),
        border: Border.all(color: KitColors.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: KitColors.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class KitFormSection extends StatelessWidget {
  const KitFormSection({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return KitSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: KitColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: AppDimensions.spacing8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: KitColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing16),
          child,
        ],
      ),
    );
  }
}

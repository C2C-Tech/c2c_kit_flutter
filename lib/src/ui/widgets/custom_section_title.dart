import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';

class CustomSectionTitle extends StatelessWidget {
  const CustomSectionTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: KitColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 14,
              color: KitColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

void showCustomMessage(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? KitColors.error : KitColors.primaryDark,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

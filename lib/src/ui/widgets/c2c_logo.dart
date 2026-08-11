import 'package:flutter/material.dart';

/// Built-in C2C logo from kit assets.
class C2cLogo extends StatelessWidget {
  const C2cLogo({super.key, this.size = 72});

  final double size;

  static const assetPath = 'assets/c2c_logo.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      package: 'c2c_kit_flutter',
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

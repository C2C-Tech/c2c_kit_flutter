import 'package:flutter/material.dart';

const String otpCodeHASH =
    'HASHSERHANHASHUMAR\$Turkiye&PakistanZanzibat129.A\$B';

enum C2cApp {
  maintenance(
    name: 'Maintenance',
    logoPath: 'assets/maintenance_icon.png',
    punchLine: 'Keep every asset running.',
  ),
  ppm(
    name: 'PPM',
    logoPath: 'assets/ppm_icon.png',
    punchLine: 'Plan, prevent, maintain.',
  ),
  authenticator(
    name: 'Authenticator',
    logoPath: 'assets/authenticator_icon.png',
    punchLine: 'Secure access to your C2C apps.',
  );

  const C2cApp({required this.name, this.logoPath, this.punchLine});

  final String name;
  final String? logoPath;
  final String? punchLine;

  IconData get fallbackIcon => switch (this) {
    C2cApp.maintenance => Icons.handyman_outlined,
    C2cApp.ppm => Icons.home_work_outlined,
    C2cApp.authenticator => Icons.verified_user_outlined,
  };

  /// Value sent as the `Application-ID` request header.
  String get applicationId => switch (this) {
    C2cApp.maintenance => 'maintenance',
    C2cApp.ppm => 'ppm',
    C2cApp.authenticator => 'authenticator',
  };
}

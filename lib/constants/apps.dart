import 'package:flutter/material.dart';

const String otpCodeHASH =
    'HASHSERHANHASHUMAR\$Turkiye&PakistanZanzibat129.A\$B';

enum C2cApp {
  maintenance(
    name: 'Handwerker',
    logoPath: 'assets/maintenance_icon.png',
    punchLineEn: 'Keep every asset running.',
    punchLineDe: 'Jedes Asset stets in Betrieb.',
  ),
  ppm(
    name: 'Immobilienverwaltung',
    logoPath: 'assets/ppm_icon.png',
    punchLineEn: 'Plan, prevent, maintain.',
    punchLineDe: 'Planen, vorbeugen, instandhalten.',
  ),
  authenticator(
    name: 'Authenticator',
    logoPath: 'assets/authenticator_icon.png',
    punchLineEn: 'Secure access to your C2C apps.',
    punchLineDe: 'Sicherer Zugriff auf Ihre C2C-Apps.',
  );

  const C2cApp({
    required this.name,
    this.logoPath,
    required this.punchLineEn,
    required this.punchLineDe,
  });

  final String name;
  final String? logoPath;
  final String punchLineEn;
  final String punchLineDe;

  /// German unless [locale] language is explicitly English.
  String punchLine(Locale locale) =>
      locale.languageCode.toLowerCase() == 'en' ? punchLineEn : punchLineDe;

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

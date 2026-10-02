import 'package:c2c_kit_flutter/c2c_kit_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  static const Locale locale = Locale('en');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'C2C Kit',
      debugShowCheckedModeBanner: false,
      locale: locale,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: KitColors.primary),
      ),
      home: const ExampleHome(),
    );
  }
}

class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key});

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> {
  static const C2cApp _app = C2cApp.ppm;
  static const Locale _locale = ExampleApp.locale;
  static const String _demoEmail = 'serhanozgul10@icloud.com';
  static const String _demoPassword = 'Sezenserhan2003.';

  AuthTokens? _tokens;
  String? _email;

  Future<void> _onAuth(AuthTokens tokens, String email) async {
    setState(() {
      _tokens = tokens;
      _email = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthTokens? tokens = _tokens;
    if (tokens == null) {
      return C2cLoginScreen(
        app: _app,
        locale: _locale,
        isDebugMode: kDebugMode,
        initialEmail: _email ?? _demoEmail,
        initialPassword: _demoPassword,
        onSuccess: _onAuth,
        onPasskeySuccess: _onAuth,
      );
    }

    return _SignedInPage(
      email: _email ?? '',
      onPasskeys: () {
        showC2cPasskeySettings(
          context,
          app: _app,
          accessToken: tokens.cloudAccessToken,
          locale: _locale,
          debugMode: kDebugMode,
        );
      },
      onLogout: () => setState(() => _tokens = null),
    );
  }
}

class _SignedInPage extends StatelessWidget {
  const _SignedInPage({
    required this.email,
    required this.onPasskeys,
    required this.onLogout,
  });

  final String email;
  final VoidCallback onPasskeys;
  final VoidCallback onLogout;

  static const Locale _locale = ExampleApp.locale;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KitColors.background,
      appBar: AppBar(
        backgroundColor: KitColors.surface,
        foregroundColor: KitColors.textPrimary,
        title: const Text('Immobilienverwaltung'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                email,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: KitColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Signed in with the ppm cloud session. Passkeys are managed with the cloud access token.',
                style: TextStyle(fontSize: 14, color: KitColors.textSecondary),
              ),
              const SizedBox(height: 24),
              CustomButton(label: 'Passkeys', onPressed: onPasskeys),
              const SizedBox(height: 12),
              CustomButton(
                label: 'Privacy Policy',
                isOutlined: true,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const PrivacyPolicyScreen(locale: _locale),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: 'Terms & Conditions',
                isOutlined: true,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const TermsAndConditionsScreen(locale: _locale),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: 'Log out',
                isOutlined: true,
                onPressed: onLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

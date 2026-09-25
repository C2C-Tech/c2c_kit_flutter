import 'package:c2c_kit_flutter/c2c_kit_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const LegalPreviewApp());
}

class LegalPreviewApp extends StatelessWidget {
  const LegalPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'C2C Legal Preview',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: KitColors.primary),
      ),
      home: const LegalPreviewHome(),
    );
  }
}

class LegalPreviewHome extends StatelessWidget {
  const LegalPreviewHome({super.key});

  static const Locale locale = Locale('en');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KitColors.background,
      appBar: AppBar(
        title: const Text(
          'C2C Legal Preview',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const PrivacyPolicyScreen(locale: locale),
                      ),
                    );
                  },
                  child: const Text('Open Privacy Policy'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const TermsAndConditionsScreen(locale: locale),
                      ),
                    );
                  },
                  child: const Text('Open Terms & Conditions'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

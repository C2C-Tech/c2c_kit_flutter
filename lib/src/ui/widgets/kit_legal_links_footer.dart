import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';
import '../../legal/privacy_screen.dart';
import '../../legal/terms_and_condition.dart';
import '../l10n/kit_l10n.dart';

/// Tappable Terms & Privacy footer for login / sign-up screens.
class KitLegalLinksFooter extends StatelessWidget {
  const KitLegalLinksFooter({super.key, this.locale});

  /// When null, [KitL10n.defaultLocale] (German) is used.
  final Locale? locale;

  void _openTerms(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TermsAndConditionsScreen(locale: locale),
      ),
    );
  }

  void _openPrivacy(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PrivacyPolicyScreen(locale: locale),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final KitL10n l10n = KitL10n(locale);
    const TextStyle baseStyle = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12,
      height: 1.45,
      fontWeight: FontWeight.w400,
      color: KitColors.textSecondary,
    );
    final TextStyle linkStyle = baseStyle.copyWith(
      color: KitColors.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: KitColors.primary.withValues(alpha: 0.35),
    );

    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.spacing16),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(l10n.legalFooterPrefix, style: baseStyle),
          GestureDetector(
            onTap: () => _openTerms(context),
            child: Text(l10n.termsShort, style: linkStyle),
          ),
          Text(l10n.legalFooterAnd, style: baseStyle),
          GestureDetector(
            onTap: () => _openPrivacy(context),
            child: Text(l10n.privacyShort, style: linkStyle),
          ),
          Text(l10n.legalFooterSuffix, style: baseStyle),
        ],
      ),
    );
  }
}

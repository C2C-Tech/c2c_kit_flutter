import 'package:flutter/material.dart';

import '../ui/l10n/kit_l10n.dart';
import 'legal_document_widgets.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key, this.locale});

  /// When null, [KitL10n.defaultLocale] (German) is used.
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    final KitL10n l10n = KitL10n(locale);

    return LegalDocumentScaffold(
      title: l10n.termsAndConditions,
      heroIcon: Icons.description_outlined,
      heroTitle: l10n.termsAndConditions,
      heroBody: l10n.termsScopeP1,
      sections: [
        LegalSectionCard(
          title: l10n.termsScopeHeading,
          icon: Icons.rule_folder_outlined,
          children: [LegalBodyText(l10n.termsScopeP1)],
        ),
        LegalSectionCard(
          title: l10n.termsPartnerHeading,
          icon: Icons.apartment_outlined,
          children: [
            LegalBodyText(l10n.termsPartnerIntro),
            LegalBodyText(l10n.termsPartnerAddress),
          ],
        ),
        LegalSectionCard(
          title: l10n.termsSubjectHeading,
          icon: Icons.handshake_outlined,
          children: [
            LegalBodyText(l10n.termsSubjectP1),
            LegalSubHeading(l10n.termsConclusionSubheading),
            LegalBodyText(l10n.termsConclusionP1),
            LegalSubHeading(l10n.termsAutomationSubheading),
            LegalBodyText(l10n.termsAutomationP1),
            LegalSubHeading(l10n.termsConfirmationSubheading),
            LegalBodyText(l10n.termsConfirmationP1),
          ],
        ),
        LegalSectionCard(
          title: l10n.termsPricesHeading,
          icon: Icons.payments_outlined,
          accentTeal: true,
          children: [
            LegalSubHeading(l10n.termsPriceStructureSubheading),
            LegalBodyText(l10n.termsPriceStructureP1),
            LegalSubHeading(l10n.termsPriceViewSubheading),
            LegalBodyText(l10n.termsPriceViewP1),
            LegalSubHeading(l10n.termsBillingSubheading),
            LegalBodyText(l10n.termsBillingP1),
          ],
        ),
        LegalSectionCard(
          title: l10n.termsPaymentHeading,
          icon: Icons.account_balance_outlined,
          children: [LegalBodyText(l10n.termsPaymentP1)],
        ),
        LegalSectionCard(
          title: l10n.termsWithdrawalHeading,
          icon: Icons.undo_rounded,
          children: [
            LegalSubHeading(l10n.termsWithdrawalPropertySubheading),
            LegalBodyText(l10n.termsWithdrawalPropertyP1),
            LegalBodyText(l10n.termsWithdrawalPropertyP2),
            LegalBulletItem(l10n.termsWithdrawalB1),
            LegalBulletItem(l10n.termsWithdrawalB2),
            LegalBulletItem(l10n.termsWithdrawalB3),
            LegalSubHeading(l10n.termsWithdrawalExclusionSubheading),
            LegalBodyText(l10n.termsWithdrawalExclusionP1),
          ],
        ),
        LegalSectionCard(
          title: l10n.termsTermHeading,
          icon: Icons.event_repeat_outlined,
          accentTeal: true,
          children: [
            LegalSubHeading(l10n.termsTermSubheading),
            LegalBodyText(l10n.termsTermP1),
            LegalSubHeading(l10n.termsRenewalSubheading),
            LegalBodyText(l10n.termsRenewalP1),
            LegalSubHeading(l10n.termsTerminationSubheading),
            LegalBodyText(l10n.termsTerminationP1),
          ],
        ),
        LegalSectionCard(
          title: l10n.termsLiabilityHeading,
          icon: Icons.balance_outlined,
          children: [LegalBodyText(l10n.termsLiabilityP1)],
        ),
        LegalContactCard(
          title: l10n.privacyContactSubheading,
          address: l10n.termsPartnerAddress,
          email: l10n.privacyControllerEmail,
        ),
      ],
    );
  }
}

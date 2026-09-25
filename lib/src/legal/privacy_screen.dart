import 'package:flutter/material.dart';

import '../ui/l10n/kit_l10n.dart';
import 'legal_document_widgets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key, this.locale});

  /// When null, [KitL10n.defaultLocale] (German) is used.
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    final KitL10n l10n = KitL10n(locale);

    return LegalDocumentScaffold(
      title: l10n.privacyPolicy,
      heroIcon: Icons.shield_outlined,
      heroTitle: l10n.privacyPolicy,
      heroBody: l10n.privacyIntro,
      heroBadge: l10n.privacyLastUpdated,
      sections: [
        LegalSectionCard(
          title: l10n.privacyControllerHeading,
          icon: Icons.business_outlined,
          children: [
            LegalBodyText(l10n.privacyControllerAddress),
            LegalBodyText(l10n.privacyControllerEmail),
          ],
        ),
        LegalSectionCard(
          title: l10n.privacyDataTypesHeading,
          icon: Icons.dataset_outlined,
          children: [
            LegalBodyText(l10n.privacyDataTypesP1),
            LegalBodyText(l10n.privacyDataTypesP2),
            LegalBodyText(l10n.privacyDataTypesP3),
            LegalBodyText(l10n.privacyDataTypesP4),
            LegalBodyText(l10n.privacyDataTypesP5),
            LegalBodyText(l10n.privacyDataTypesP6),
            LegalBodyText(l10n.privacyDataTypesP7),
          ],
        ),
        LegalSectionCard(
          title: l10n.privacyProcessingHeading,
          icon: Icons.hub_outlined,
          children: [
            LegalSubHeading(l10n.privacyMethodsSubheading),
            LegalBodyText(l10n.privacyMethodsP1),
            LegalBodyText(l10n.privacyMethodsP2),
            LegalSubHeading(l10n.privacyPlaceSubheading),
            LegalBodyText(l10n.privacyPlaceP1),
            LegalBodyText(l10n.privacyPlaceP2),
            LegalSubHeading(l10n.privacyRetentionSubheading),
            LegalBodyText(l10n.privacyRetentionP1),
          ],
        ),
        LegalSectionCard(
          title: l10n.privacyCookieHeading,
          icon: Icons.cookie_outlined,
          accentTeal: true,
          children: [LegalBodyText(l10n.privacyCookieP1)],
        ),
        LegalSectionCard(
          title: l10n.privacyEuHeading,
          icon: Icons.gavel_outlined,
          children: [
            LegalSubHeading(l10n.privacyLegalBasesSubheading),
            LegalBodyText(l10n.privacyLegalBasesIntro),
            LegalBulletItem(l10n.privacyLegalBasesB1),
            LegalBulletItem(l10n.privacyLegalBasesB2),
            LegalBulletItem(l10n.privacyLegalBasesB3),
            LegalBulletItem(l10n.privacyLegalBasesB4),
            LegalBulletItem(l10n.privacyLegalBasesB5),
            LegalBodyText(l10n.privacyLegalBasesOutro),
            LegalSubHeading(l10n.privacyRetentionMoreSubheading),
            LegalBodyText(l10n.privacyRetentionMoreP1),
            LegalBulletItem(l10n.privacyRetentionMoreB1),
            LegalBulletItem(l10n.privacyRetentionMoreB2),
            LegalBodyText(l10n.privacyRetentionMoreP2),
            LegalSubHeading(l10n.privacyGdprRightsSubheading),
            LegalBodyText(l10n.privacyGdprRightsIntro),
            LegalBulletItem(l10n.privacyGdprRightB1),
            LegalBulletItem(l10n.privacyGdprRightB2),
            LegalBulletItem(l10n.privacyGdprRightB3),
            LegalBulletItem(l10n.privacyGdprRightB4),
            LegalBulletItem(l10n.privacyGdprRightB5),
            LegalBulletItem(l10n.privacyGdprRightB6),
            LegalBulletItem(l10n.privacyGdprRightB7),
            LegalBulletItem(l10n.privacyGdprRightB8),
            LegalSubHeading(l10n.privacyObjectionSubheading),
            LegalBodyText(l10n.privacyObjectionP1),
            LegalBodyText(l10n.privacyObjectionP2),
            LegalSubHeading(l10n.privacyHowToExerciseSubheading),
            LegalBodyText(l10n.privacyHowToExerciseP1),
          ],
        ),
        LegalSectionCard(
          title: l10n.privacyFurtherInfoHeading,
          icon: Icons.info_outline_rounded,
          children: [
            LegalSubHeading(l10n.privacyLegalActionSubheading),
            LegalBodyText(l10n.privacyLegalActionP1),
            LegalBodyText(l10n.privacyLegalActionP2),
            LegalSubHeading(l10n.privacySystemLogsSubheading),
            LegalBodyText(l10n.privacySystemLogsP1),
            LegalSubHeading(l10n.privacyNotContainedSubheading),
            LegalBodyText(l10n.privacyNotContainedP1),
            LegalSubHeading(l10n.privacyChangesSubheading),
            LegalBodyText(l10n.privacyChangesP1),
            LegalBodyText(l10n.privacyChangesP2),
          ],
        ),
        LegalSectionCard(
          title: l10n.privacyDefinitionsHeading,
          icon: Icons.menu_book_outlined,
          children: [
            LegalSubHeading(l10n.privacyDefPersonalDataSubheading),
            LegalBodyText(l10n.privacyDefPersonalDataP1),
            LegalSubHeading(l10n.privacyDefUsageDataSubheading),
            LegalBodyText(l10n.privacyDefUsageDataP1),
            LegalSubHeading(l10n.privacyDefUserSubheading),
            LegalBodyText(l10n.privacyDefUserP1),
            LegalSubHeading(l10n.privacyDefDataSubjectSubheading),
            LegalBodyText(l10n.privacyDefDataSubjectP1),
            LegalSubHeading(l10n.privacyDefProcessorSubheading),
            LegalBodyText(l10n.privacyDefProcessorP1),
            LegalSubHeading(l10n.privacyDefControllerSubheading),
            LegalBodyText(l10n.privacyDefControllerP1),
            LegalSubHeading(l10n.privacyDefApplicationSubheading),
            LegalBodyText(l10n.privacyDefApplicationP1),
            LegalSubHeading(l10n.privacyDefServiceSubheading),
            LegalBodyText(l10n.privacyDefServiceP1),
            LegalSubHeading(l10n.privacyDefEuSubheading),
            LegalBodyText(l10n.privacyDefEuP1),
            LegalSubHeading(l10n.privacyLegalNoticeSubheading),
            LegalBodyText(l10n.privacyLegalNoticeP1),
          ],
        ),
        LegalSectionCard(
          title: l10n.privacyHowWeHelpHeading,
          icon: Icons.support_agent_outlined,
          accentTeal: true,
          children: [
            LegalSubHeading(l10n.privacyYourDataSubheading),
            LegalBulletItem(l10n.privacyYourDataB1),
            LegalBulletItem(l10n.privacyYourDataB2),
            LegalBulletItem(l10n.privacyYourDataB3),
            LegalBulletItem(l10n.privacyYourDataB4),
            LegalSubHeading(l10n.privacyProblemsSubheading),
            LegalBodyText(l10n.privacyProblemsP1),
          ],
        ),
        LegalContactCard(
          title: l10n.privacyContactSubheading,
          address: l10n.privacyControllerAddress,
          email: l10n.privacyControllerEmail,
          footerLines: [
            l10n.privacyFooterPolicy,
            l10n.privacyFooterCookie,
          ],
        ),
      ],
    );
  }
}

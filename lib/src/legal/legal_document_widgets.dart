import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../constants/colors.dart';
import '../../constants/dimensions.dart';
import '../../constants/extras.dart';
import '../ui/widgets/custom_app_bar.dart';

/// Shared C2C legal document chrome — Poppins, blue hero, section cards.
class LegalDocumentScaffold extends StatefulWidget {
  const LegalDocumentScaffold({
    super.key,
    required this.title,
    required this.heroIcon,
    required this.heroTitle,
    required this.heroBody,
    this.heroBadge,
    required this.sections,
  });

  final String title;
  final IconData heroIcon;
  final String heroTitle;
  final String heroBody;
  final String? heroBadge;
  final List<Widget> sections;

  @override
  State<LegalDocumentScaffold> createState() => _LegalDocumentScaffoldState();
}

class _LegalDocumentScaffoldState extends State<LegalDocumentScaffold> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KitColors.background,
      appBar: CustomAppBar(title: widget.title),
      body: Container(
        width: double.infinity,
        alignment: Alignment.topLeft,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              KitColors.primaryLight.withValues(alpha: 0.14),
              KitColors.background,
              KitColors.background,
            ],
            stops: const [0, 0.28, 1],
          ),
        ),
        // RTL around Scrollbar only → thumb sits on the physical left edge.
        // Inner LTR keeps legal copy reading left-to-right.
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: RawScrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 4,
            radius: const Radius.circular(8),
            padding: const EdgeInsets.only(left: 2, top: 8, bottom: 8),
            thumbColor: KitColors.primary.withValues(alpha: 0.45),
            trackColor: KitColors.primary.withValues(alpha: 0.08),
            trackBorderColor: Colors.transparent,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: DefaultTextStyle.merge(
                style: const TextStyle(fontFamily: 'Poppins'),
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.spacing16,
                    AppDimensions.spacing16,
                    AppDimensions.spacing12,
                    40,
                  ),
                  children: [
                    LegalHeroBanner(
                      icon: widget.heroIcon,
                      title: widget.heroTitle,
                      body: widget.heroBody,
                      badge: widget.heroBadge,
                    )
                        .animate()
                        .fadeIn(duration: AppDurations.normal)
                        .slideY(
                          begin: 0.06,
                          end: 0,
                          duration: AppDurations.normal,
                          curve: Curves.easeOutCubic,
                        ),
                    const SizedBox(height: AppDimensions.spacing20),
                    ...widget.sections.asMap().entries.map(
                      (MapEntry<int, Widget> entry) {
                        final int index = entry.key;
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppDimensions.spacing16,
                          ),
                          child: entry.value
                              .animate()
                              .fadeIn(
                                delay: AppDurations.fast * (index + 1),
                                duration: AppDurations.normal,
                              )
                              .slideY(
                                begin: 0.04,
                                end: 0,
                                delay: AppDurations.fast * (index + 1),
                                duration: AppDurations.normal,
                                curve: Curves.easeOutCubic,
                              ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LegalHeroBanner extends StatelessWidget {
  const LegalHeroBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radius24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            KitColors.primary,
            KitColors.blueGlow,
            KitColors.primaryDark,
          ],
          stops: [0, 0.55, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: KitColors.primaryDark.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -30,
            child: IgnorePointer(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: KitColors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -50,
            child: IgnorePointer(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: KitColors.teal.withValues(alpha: 0.18),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: KitColors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: KitColors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Icon(icon, color: KitColors.white, size: 24),
                  ),
                  if (badge != null) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: KitColors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: KitColors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        badge!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: KitColors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppDimensions.spacing20),
              Text(
                title,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: KitColors.white,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing12),
              Text(
                body,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  height: 1.55,
                  fontWeight: FontWeight.w400,
                  color: KitColors.white.withValues(alpha: 0.88),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LegalSectionCard extends StatelessWidget {
  const LegalSectionCard({
    super.key,
    required this.title,
    required this.children,
    this.icon,
    this.accentTeal = false,
  });

  final String title;
  final List<Widget> children;
  final IconData? icon;
  final bool accentTeal;

  @override
  Widget build(BuildContext context) {
    final Color accent = accentTeal ? KitColors.teal : KitColors.primary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: KitColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius20),
        border: Border.all(color: KitColors.border.withValues(alpha: 0.7)),
        boxShadow: const [
          BoxShadow(
            color: KitColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 3, color: accent),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, size: 20, color: accent),
                      ),
                      const SizedBox(width: AppDimensions.spacing12),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: KitColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacing16),
                ...children,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LegalSubHeading extends StatelessWidget {
  const LegalSubHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: KitColors.textPrimary,
        ),
      ),
    );
  }
}

class LegalBodyText extends StatelessWidget {
  const LegalBodyText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          height: 1.65,
          fontWeight: FontWeight.w400,
          color: KitColors.textSecondary,
        ),
      ),
    );
  }
}

class LegalBulletItem extends StatelessWidget {
  const LegalBulletItem(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 9),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: KitColors.primary.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                height: 1.6,
                fontWeight: FontWeight.w400,
                color: KitColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LegalContactCard extends StatelessWidget {
  const LegalContactCard({
    super.key,
    required this.title,
    required this.address,
    required this.email,
    this.footerLines = const [],
  });

  final String title;
  final String address;
  final String email;
  final List<String> footerLines;

  @override
  Widget build(BuildContext context) {
    return LegalSectionCard(
      title: title,
      icon: Icons.mail_outline_rounded,
      accentTeal: true,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: KitColors.primaryMuted,
            borderRadius: BorderRadius.circular(AppDimensions.radius12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  color: KitColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 18,
                    color: KitColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      email.replaceFirst(RegExp(r'^(Email|E-Mail):\s*'), ''),
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: KitColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (footerLines.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...footerLines.map(
            (String line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 1.5,
                  color: KitColors.textHint,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

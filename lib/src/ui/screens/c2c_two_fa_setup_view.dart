import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../constants/apps.dart';
import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';
import '../../api/auth_api.dart';
import '../../api/models.dart';
import '../l10n/kit_l10n.dart';
import '../widgets/c2c_brand_header.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_message.dart';
import '../widgets/custom_section_title.dart';
import '../widgets/kit_pin_field.dart';
import '../widgets/kit_surface_card.dart';

enum _TwoFaStage { methodSelection, totpSetup, enterCode }

/// Opens the 2FA enable/disable flow.
///
/// Uses a dialog on web, and a full screen route on mobile.
Future<bool?> showC2cTwoFaSetup(
  BuildContext context, {
  required C2cApp app,
  required String accessToken,
  required String refreshToken,
  Locale locale = KitL10n.defaultLocale,
  TwoFaMethod? currentMethod,
  String userEmail = '',
  Future<void> Function({required bool disabled})? onCompleted,
}) {
  final view = C2cTwoFaSetupView(
    app: app,
    accessToken: accessToken,
    refreshToken: refreshToken,
    locale: locale,
    currentMethod: currentMethod,
    userEmail: userEmail,
    isDialog: kIsWeb,
    onCompleted: onCompleted,
  );

  final l10n = KitL10n(locale);

  if (kIsWeb) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: KitColors.surface,
        surfaceTintColor: KitColors.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460, maxHeight: 640),
          child: Material(
            color: KitColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
            clipBehavior: Clip.antiAlias,
            child: view,
          ),
        ),
      ),
    );
  }

  return Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: KitColors.background,
        appBar: CustomAppBar(title: l10n.twoFactorAuth, app: app),
        body: SafeArea(child: view),
      ),
    ),
  );
}

/// Enable / disable 2FA flow (dialog on web, screen on mobile).
class C2cTwoFaSetupView extends StatefulWidget {
  const C2cTwoFaSetupView({
    super.key,
    required this.app,
    required this.accessToken,
    required this.refreshToken,
    this.locale = KitL10n.defaultLocale,
    this.currentMethod,
    this.userEmail = '',
    this.isDialog = false,
    this.onCompleted,
  });

  final C2cApp app;
  final String accessToken;
  final String refreshToken;
  final Locale locale;

  /// Non-null means the user already has 2FA → disable flow.
  final TwoFaMethod? currentMethod;
  final String userEmail;
  final bool isDialog;

  /// Called after successful enable/disable (before pop).
  final Future<void> Function({required bool disabled})? onCompleted;

  @override
  State<C2cTwoFaSetupView> createState() => _C2cTwoFaSetupViewState();
}

class _C2cTwoFaSetupViewState extends State<C2cTwoFaSetupView> {
  static const _otpLength = 6;

  KitL10n get _l10n => KitL10n(widget.locale);

  late final bool _isDisabling;
  late TwoFaMethod? _selectedMethod;
  _TwoFaStage _stage = _TwoFaStage.methodSelection;

  String _otp = '';
  String? _totpSecret;
  String? _provisioningUri;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _isDisabling = widget.currentMethod != null;
    _selectedMethod = widget.currentMethod;
    if (_isDisabling) {
      _stage = _TwoFaStage.enterCode;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _prepareDisableCode();
      });
    }
  }

  Future<void> _prepareDisableCode() async {
    if (_selectedMethod == TwoFaMethod.email) {
      final response = await AuthApi.sendEmail2FaCode(
        app: widget.app,
        accessToken: widget.accessToken,
      );
      if (!mounted) return;
      if (!response.isOk) {
        showCustomMessage(context, response.errorMessage, isError: true);
      } else {
        showCustomMessage(context, _l10n.twoFaEmailCodeSent);
      }
    }
  }

  Future<void> _onSelectMethod(TwoFaMethod method) async {
    setState(() {
      _selectedMethod = method;
      _loading = true;
    });

    try {
      if (method == TwoFaMethod.totp) {
        final response = await AuthApi.setupTotp2Fa(
          app: widget.app,
          accessToken: widget.accessToken,
        );
        if (!mounted) return;
        if (!response.isOk) {
          showCustomMessage(context, response.errorMessage, isError: true);
          return;
        }
        final data = response.data is Map
            ? Map<String, dynamic>.from(response.data as Map)
            : <String, dynamic>{};
        setState(() {
          _totpSecret = data['secret']?.toString();
          _provisioningUri = data['provisioning_uri']?.toString();
          _stage = _TwoFaStage.totpSetup;
        });
        return;
      }

      final response = await AuthApi.sendEmail2FaCode(
        app: widget.app,
        accessToken: widget.accessToken,
      );
      if (!mounted) return;
      if (!response.isOk) {
        showCustomMessage(context, response.errorMessage, isError: true);
        return;
      }
      showCustomMessage(context, _l10n.twoFaEmailCodeSent);
      setState(() {
        _otp = '';
        _stage = _TwoFaStage.enterCode;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendEmailCode() async {
    final response = await AuthApi.sendEmail2FaCode(
      app: widget.app,
      accessToken: widget.accessToken,
    );
    if (!mounted) return;
    showCustomMessage(
      context,
      response.isOk ? _l10n.twoFaEmailCodeSent : response.errorMessage,
      isError: !response.isOk,
    );
  }

  Future<void> _submitCode() async {
    if (_otp.length < _otpLength || _otp.contains(RegExp(r'[^0-9]'))) {
      showCustomMessage(context, _l10n.completeSixDigitCode, isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final response = _isDisabling
          ? await AuthApi.disable2Fa(
              app: widget.app,
              accessToken: widget.accessToken,
              code: _otp.trim(),
            )
          : await AuthApi.enable2Fa(
              app: widget.app,
              accessToken: widget.accessToken,
              method: _selectedMethod!,
              code: _otp.trim(),
            );

      if (!mounted) return;

      if (response.isError) {
        showCustomMessage(context, response.errorMessage, isError: true);
        return;
      }

      await widget.onCompleted?.call(disabled: _isDisabling);
      if (!mounted) return;

      showCustomMessage(
        context,
        _isDisabling ? _l10n.twoFaDisabledSuccess : _l10n.twoFaEnabledSuccess,
      );
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _copySecret() async {
    if (_totpSecret == null) return;
    await Clipboard.setData(ClipboardData(text: _totpSecret!));
    if (!mounted) return;
    showCustomMessage(context, _l10n.twoFaSecretCopied);
  }

  @override
  Widget build(BuildContext context) {
    final double padding = AppDimensions.contentPadding(context);
    final Widget content = switch (_stage) {
      _TwoFaStage.methodSelection => _buildMethodSelection(),
      _TwoFaStage.totpSetup => _buildTotpSetup(),
      _TwoFaStage.enterCode => _buildEnterCode(),
    };

    if (widget.isDialog) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: KitColors.primary.withValues(alpha: 0.08),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _l10n.twoFactorAuth,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: KitColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: KitColors.textSecondary,
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: content,
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: content,
    );
  }

  Widget _buildMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.isDialog) ...[
          C2cBrandHeader(
            app: widget.app,
            locale: widget.locale,
            title: _l10n.twoFactorAuth,
            compact: true,
          ),
          const SizedBox(height: AppDimensions.spacing24),
        ],
        KitSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomSectionTitle(
                title: _l10n.twoFaChooseMethod,
                subtitle: _l10n.twoFaChooseMethodSubtitle,
              ),
              const SizedBox(height: AppDimensions.spacing24),
              _MethodCard(
                icon: Icons.phonelink_lock_outlined,
                title: _l10n.twoFaAuthenticatorApp,
                subtitle: _l10n.twoFaAuthenticatorAppSubtitle,
                onTap: _loading
                    ? null
                    : () => _onSelectMethod(TwoFaMethod.totp),
              ),
              const SizedBox(height: AppDimensions.spacing12),
              _MethodCard(
                icon: Icons.email_outlined,
                title: _l10n.twoFaEmailMethod,
                subtitle: _l10n.twoFaEmailMethodSubtitle,
                onTap: _loading
                    ? null
                    : () => _onSelectMethod(TwoFaMethod.email),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotpSetup() {
    return KitSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomSectionTitle(
            title: _l10n.twoFaScanQrTitle,
            subtitle: _l10n.twoFaScanQrSubtitle,
          ),
          const SizedBox(height: AppDimensions.spacing24),
          if (_provisioningUri != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radius16),
                  border: Border.all(
                    color: KitColors.primary.withValues(alpha: 0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: KitColors.primary.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: _provisioningUri!,
                  size: 200,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          if (_totpSecret != null) ...[
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              _l10n.twoFaManualSecret,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: KitColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            InkWell(
              onTap: _copySecret,
              borderRadius: BorderRadius.circular(AppDimensions.radius12),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.spacing16),
                decoration: BoxDecoration(
                  color: KitColors.primaryMuted,
                  borderRadius: BorderRadius.circular(AppDimensions.radius12),
                  border: Border.all(
                    color: KitColors.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        _totpSecret!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: KitColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: KitColors.primary.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.spacing24),
          CustomButton(
            label: _l10n.continueLabel,
            onPressed: () {
              setState(() {
                _otp = '';
                _stage = _TwoFaStage.enterCode;
              });
            },
          ),
          const SizedBox(height: AppDimensions.spacing12),
          CustomButton(
            label: _l10n.cancel,
            isOutlined: true,
            onPressed: () {
              setState(() {
                _selectedMethod = null;
                _totpSecret = null;
                _provisioningUri = null;
                _stage = _TwoFaStage.methodSelection;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnterCode() {
    final isEmail = _selectedMethod == TwoFaMethod.email;

    final l10n = _l10n;

    return KitSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomSectionTitle(
            title: _isDisabling ? l10n.twoFaDisableTitle : l10n.codeVerification,
            subtitle: _isDisabling
                ? (isEmail
                    ? l10n.twoFaDisableEmailSubtitle
                    : l10n.twoFaDisableTotpSubtitle)
                : (isEmail
                    ? l10n.enterEmailCodeSubtitle(widget.userEmail)
                    : l10n.twoFaEnterTotpCodeSubtitle),
          ),
          const SizedBox(height: AppDimensions.spacing24),
          KitPinField(
            length: _otpLength,
            onChanged: (value) => _otp = value,
          ),
          if (isEmail) ...[
            const SizedBox(height: AppDimensions.spacing16),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: _resendEmailCode,
                child: Text(l10n.twoFaResendCode),
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.spacing24),
          CustomButton(
            label: _isDisabling ? l10n.twoFaDisable : l10n.verify,
            backgroundColor: _isDisabling ? KitColors.error : null,
            isLoading: _loading,
            onPressed: _loading ? null : _submitCode,
          ),
          if (!_isDisabling) ...[
            const SizedBox(height: AppDimensions.spacing12),
            CustomButton(
              label: l10n.cancel,
              isOutlined: true,
              onPressed: () {
                setState(() {
                  _otp = '';
                  if (_selectedMethod == TwoFaMethod.totp) {
                    _stage = _TwoFaStage.totpSetup;
                  } else {
                    _selectedMethod = null;
                    _stage = _TwoFaStage.methodSelection;
                  }
                });
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radius16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        decoration: BoxDecoration(
          color: KitColors.primaryMuted.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
          border: Border.all(color: KitColors.primary.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: KitColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radius12),
              ),
              child: Icon(icon, color: KitColors.primary, size: 22),
            ),
            const SizedBox(width: AppDimensions.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: KitColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: KitColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: KitColors.textHint),
          ],
        ),
      ),
    );
  }
}

class C2cTwoFaSetupScreen extends StatelessWidget {
  const C2cTwoFaSetupScreen({
    super.key,
    required this.app,
    required this.accessToken,
    required this.refreshToken,
    this.locale = KitL10n.defaultLocale,
    this.currentMethod,
    this.userEmail = '',
    this.onCompleted,
  });

  final C2cApp app;
  final String accessToken;
  final String refreshToken;
  final Locale locale;
  final TwoFaMethod? currentMethod;
  final String userEmail;
  final Future<void> Function({required bool disabled})? onCompleted;

  @override
  Widget build(BuildContext context) {
    final l10n = KitL10n(locale);
    return Scaffold(
      backgroundColor: KitColors.background,
      appBar: CustomAppBar(title: l10n.twoFactorAuth, app: app),
      body: SafeArea(
        child: C2cTwoFaSetupView(
          app: app,
          accessToken: accessToken,
          refreshToken: refreshToken,
          locale: locale,
          currentMethod: currentMethod,
          userEmail: userEmail,
          onCompleted: onCompleted,
        ),
      ),
    );
  }
}

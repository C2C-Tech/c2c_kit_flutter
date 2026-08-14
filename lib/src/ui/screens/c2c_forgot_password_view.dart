import 'package:flutter/material.dart';

import '../../../constants/apps.dart';
import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';
import '../../api/auth_api.dart';
import '../l10n/kit_l10n.dart';
import '../widgets/c2c_auth_shell.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_message.dart';
import '../widgets/custom_section_title.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/kit_pin_field.dart';
import '../widgets/kit_step_progress.dart';
import '../widgets/kit_surface_card.dart';

/// Three-step forgot-password flow:
///
/// 1. Enter email → `/forgotpwd`
/// 2. Enter OTP  → `/verify_code`
/// 3. New password → `/resetpwd`
///
/// On success, [onSuccess] is called so the host app can navigate (e.g. back
/// to the login screen).
class C2cForgotPasswordView extends StatefulWidget {
  const C2cForgotPasswordView({
    super.key,
    required this.app,
    required this.onSuccess,
    this.locale = KitL10n.defaultLocale,
    this.initialEmail,
  });

  final C2cApp app;
  final Locale locale;
  final VoidCallback onSuccess;
  final String? initialEmail;

  @override
  State<C2cForgotPasswordView> createState() => _C2cForgotPasswordViewState();
}

enum _Step { email, otp, newPassword }

class _C2cForgotPasswordViewState extends State<C2cForgotPasswordView> {
  static const _otpLength = 6;

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  _Step _step = _Step.email;
  String _otp = '';
  bool _loading = false;

  KitL10n get _l10n => KitL10n(widget.locale);

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Step 1 – send recovery code
  // ---------------------------------------------------------------------------

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final response = await AuthApi.forgotPassword(
        app: widget.app,
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      if (response.isOk) {
        showCustomMessage(context, _l10n.codeSent);
        setState(() => _step = _Step.otp);
      } else {
        showCustomMessage(context, response.errorMessage, isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Step 2 – verify code
  // ---------------------------------------------------------------------------

  Future<void> _verifyCode() async {
    final l10n = _l10n;
    if (_otp.length < _otpLength || _otp.contains(RegExp(r'[^0-9]'))) {
      showCustomMessage(context, l10n.completeSixDigitCode, isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final response = await AuthApi.verifyRecoveryCode(
        app: widget.app,
        email: _emailController.text.trim(),
        code: _otp.trim(),
      );

      if (!mounted) return;

      if (response.isOk) {
        showCustomMessage(context, l10n.codeVerified);
        setState(() => _step = _Step.newPassword);
      } else {
        showCustomMessage(context, response.errorMessage, isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Step 3 – reset password
  // ---------------------------------------------------------------------------

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final response = await AuthApi.resetPassword(
        app: widget.app,
        email: _emailController.text.trim(),
        otp: _otp.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (response.isOk) {
        showCustomMessage(context, _l10n.passwordResetSuccess);
        widget.onSuccess();
      } else {
        showCustomMessage(context, response.errorMessage, isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;
    final stepIndex = switch (_step) {
      _Step.email => 0,
      _Step.otp => 1,
      _Step.newPassword => 2,
    };

    return C2cAuthShell(
      app: widget.app,
      locale: widget.locale,
      compactHeader: true,
      title: l10n.forgotPasswordTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KitStepProgress(
            labels: [l10n.email, l10n.stepCode, l10n.password],
            currentIndex: stepIndex,
          ),
          const SizedBox(height: AppDimensions.spacing24),
          switch (_step) {
            _Step.email => _buildEmailStep(),
            _Step.otp => _buildOtpStep(),
            _Step.newPassword => _buildNewPasswordStep(),
          },
        ],
      ),
    );
  }

  // ---- Step 1 ---------------------------------------------------------------

  Widget _buildEmailStep() {
    final l10n = _l10n;

    return Form(
      key: _formKey,
      child: KitSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomSectionTitle(
              title: l10n.forgotPasswordTitle,
              subtitle: l10n.forgotPasswordSubtitle,
            ),
            const SizedBox(height: AppDimensions.spacing24),
            CustomTextField(
              label: l10n.emailAddress,
              l10n: l10n,
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.fieldRequired(l10n.emailAddress);
                }
                if (!value.contains('@')) return l10n.invalidEmail;
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacing24),
            CustomButton(
              label: l10n.sendCode,
              isLoading: _loading,
              onPressed: _loading ? null : _sendCode,
            ),
          ],
        ),
      ),
    );
  }

  // ---- Step 2 ---------------------------------------------------------------

  Widget _buildOtpStep() {
    final l10n = _l10n;

    return KitSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomSectionTitle(
            title: l10n.codeVerification,
            subtitle: l10n.emailVerificationMessage(_emailController.text.trim()),
          ),
          const SizedBox(height: AppDimensions.spacing24),
          KitPinField(
            length: _otpLength,
            onChanged: (value) => _otp = value,
          ),
          const SizedBox(height: AppDimensions.spacing24),
          CustomButton(
            label: l10n.verifyCode,
            isLoading: _loading,
            onPressed: _loading ? null : _verifyCode,
          ),
        ],
      ),
    );
  }

  // ---- Step 3 ---------------------------------------------------------------

  Widget _buildNewPasswordStep() {
    final l10n = _l10n;

    return Form(
      key: _formKey,
      child: KitSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomSectionTitle(title: l10n.resetPassword, subtitle: ''),
            const SizedBox(height: AppDimensions.spacing24),
            CustomTextField(
              label: l10n.newPassword,
              l10n: l10n,
              controller: _passwordController,
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.fieldRequired(l10n.newPassword);
                }
                if (value.length < 8) return l10n.passwordTooShort;
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacing16),
            CustomTextField(
              label: l10n.confirmNewPassword,
              l10n: l10n,
              controller: _confirmController,
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value != _passwordController.text) {
                  return l10n.passwordsDoNotMatch;
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacing24),
            CustomButton(
              label: l10n.resetPassword,
              isLoading: _loading,
              onPressed: _loading ? null : _resetPassword,
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen wrapper for [C2cForgotPasswordView].
class C2cForgotPasswordScreen extends StatelessWidget {
  const C2cForgotPasswordScreen({
    super.key,
    required this.app,
    required this.onSuccess,
    this.locale = KitL10n.defaultLocale,
    this.initialEmail,
  });

  final C2cApp app;
  final Locale locale;
  final VoidCallback onSuccess;
  final String? initialEmail;

  @override
  Widget build(BuildContext context) {
    final l10n = KitL10n(locale);
    return Scaffold(
      backgroundColor: KitColors.background,
      appBar: CustomAppBar(title: l10n.forgotPasswordTitle, app: app),
      body: C2cForgotPasswordView(
        app: app,
        locale: locale,
        onSuccess: onSuccess,
        initialEmail: initialEmail,
      ),
    );
  }
}

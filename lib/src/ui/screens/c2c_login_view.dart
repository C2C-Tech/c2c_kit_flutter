import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../constants/app_ids.dart';
import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';
import '../../api/auth_api.dart';
import '../../api/models.dart';
import '../l10n/kit_l10n.dart';
import '../widgets/c2c_logo.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_message.dart';
import '../widgets/custom_section_title.dart';
import '../widgets/custom_text_field.dart';

/// Reusable login form. Host apps wrap this in their own route.
class C2cLoginView extends StatefulWidget {
  const C2cLoginView({
    super.key,
    required this.app,
    required this.onSuccess,
    this.locale = KitL10n.defaultLocale,
    this.onForgotPassword,
    this.onSignUp,
    this.initialEmail,
    this.isDebugMode = false,
  });

  final C2cApp app;
  final Locale locale;
  final Future<void> Function(
    AuthTokens tokens,
    Map<String, dynamic>? userDataForRegistration,
    String email,
  )
  onSuccess;

  final VoidCallback? onForgotPassword;
  final VoidCallback? onSignUp;
  final String? initialEmail;

  /// When true, pre-fills email/password for faster local testing.
  final bool isDebugMode;

  @override
  State<C2cLoginView> createState() => _C2cLoginViewState();
}

class _C2cLoginViewState extends State<C2cLoginView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _loading = false;

  KitL10n get _l10n => KitL10n(widget.locale);

  @override
  void initState() {
    super.initState();
    final debug = widget.isDebugMode;
    _emailController = TextEditingController(
      text: widget.initialEmail ?? (debug ? 'test@example.com' : ''),
    );
    _passwordController = TextEditingController(
      text: debug ? 'c2C@123456' : '',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _loading = true);
    try {
      final LoginResult result = await AuthApi.login(
        app: widget.app,
        email: email,
        password: password,
      );

      if (!mounted) return;

      switch (result) {
        case LoginSuccess(:final tokens, :final userDataForRegistration):
          await widget.onSuccess(tokens, userDataForRegistration, email);
        case LoginRequires2Fa challenge:
          final loginSucess = await C2cLoginTwoFaView.show(
            context,
            app: widget.app,
            locale: widget.locale,
            tempToken: challenge.tempToken,
            method: challenge.method,
            email: email,
          );
          if (loginSucess != null && mounted) {
            await widget.onSuccess(
              loginSucess.tokens,
              loginSucess.userDataForRegistration,
              email,
            );
          }

        case LoginFailure(:final message):
          showCustomMessage(context, message, isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    final l10n = _l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Center(child: C2cLogo()),
        const SizedBox(height: 24),
        Text(
          l10n.continueSignIn,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: KitColors.primary,
          ),
        ),
        const SizedBox(height: 32),
        Form(
          key: _formKey,
          child: Column(
            children: [
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
              const SizedBox(height: 20),
              CustomTextField(
                label: l10n.password,
                l10n: l10n,
                controller: _passwordController,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
            ],
          ),
        ),
        if (widget.onForgotPassword != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onForgotPassword,
              child: Text(
                l10n.forgotPassword,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: KitColors.primary,
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        CustomButton(
          label: l10n.login,
          isLoading: _loading,
          onPressed: _loading ? null : _submit,
        ),
        if (widget.onSignUp != null) ...[
          const SizedBox(height: 16),
          CustomButton(
            label: l10n.signUp,
            isOutlined: true,
            onPressed: widget.onSignUp,
          ),
        ],
      ],
    );
  }
}

/// Full-screen wrapper for [C2cLoginView].
class C2cLoginScreen extends StatelessWidget {
  const C2cLoginScreen({
    super.key,
    required this.app,
    required this.onSuccess,
    this.locale = KitL10n.defaultLocale,
    this.onForgotPassword,
    this.onSignUp,
    this.initialEmail,
    this.isDebugMode = false,
    this.handleTwoFaInternally = true,
  });

  final C2cApp app;
  final Locale locale;
  final Future<void> Function(
    AuthTokens authTokens,
    Map<String, dynamic>? userDataForRegistration,
    String email,
  )
  onSuccess;

  final VoidCallback? onForgotPassword;
  final VoidCallback? onSignUp;
  final String? initialEmail;
  final bool isDebugMode;
  final bool handleTwoFaInternally;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KitColors.surface,
      body: C2cLoginView(
        app: app,
        locale: locale,
        onSuccess: onSuccess,
        onForgotPassword: onForgotPassword,
        onSignUp: onSignUp,
        initialEmail: initialEmail,
        isDebugMode: isDebugMode,
      ),
    );
  }
}

/// Login 2FA challenge UI (dialog on web, screen elsewhere).
class C2cLoginTwoFaView extends StatefulWidget {
  const C2cLoginTwoFaView({
    super.key,
    required this.app,
    required this.tempToken,
    required this.method,
    required this.email,
    this.locale = KitL10n.defaultLocale,
    this.isDialog = false,
  });

  final C2cApp app;
  final Locale locale;
  final String tempToken;
  final TwoFaMethod method;
  final String email;
  final bool isDialog;

  /// Shows dialog on web / pushed route on mobile. Returns tokens on success.
  static Future<LoginSuccess?> show(
    BuildContext context, {
    required C2cApp app,
    required String tempToken,
    required TwoFaMethod method,
    required String email,
    Locale locale = KitL10n.defaultLocale,
  }) {
    final view = C2cLoginTwoFaView(
      app: app,
      locale: locale,
      tempToken: tempToken,
      method: method,
      email: email,
      isDialog: kIsWeb,
    );

    final l10n = KitL10n(locale);

    if (kIsWeb) {
      return showDialog<LoginSuccess>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          backgroundColor: KitColors.surface,
          surfaceTintColor: KitColors.surface,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
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

    return Navigator.of(context).push<LoginSuccess>(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: KitColors.background,
          appBar: CustomAppBar(title: l10n.twoFactorAuth),
          body: SafeArea(child: view),
        ),
      ),
    );
  }

  @override
  State<C2cLoginTwoFaView> createState() => _C2cLoginTwoFaViewState();
}

class _C2cLoginTwoFaViewState extends State<C2cLoginTwoFaView> {
  static const _otpLength = 6;
  String _otp = '';
  bool _loading = false;

  KitL10n get _l10n => KitL10n(widget.locale);

  Future<void> _submit() async {
    final l10n = _l10n;
    if (_otp.length < _otpLength || _otp.contains(RegExp(r'[^0-9]'))) {
      showCustomMessage(context, l10n.completeSixDigitCode, isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await AuthApi.verifyLogin2Fa(
        app: widget.app,
        tempToken: widget.tempToken,
        code: _otp.trim(),
      );

      if (!mounted) return;

      switch (result) {
        case LoginSuccess success:
          Navigator.of(context).pop(success);
        case LoginFailure(:final message, :final statusCode):
          if (statusCode == 401) {
            Navigator.of(context).pop();
          }
          showCustomMessage(context, message, isError: true);
        case LoginRequires2Fa():
          // Unreachable from /2fa/verify — kept for sealed LoginResult exhaustiveness.
          break;
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppDimensions.contentPadding(context);
    final isEmail = widget.method == TwoFaMethod.email;
    final l10n = _l10n;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomSectionTitle(
          title: l10n.loginTwoFaTitle,
          subtitle: isEmail
              ? l10n.loginTwoFaEmailSubtitle(widget.email)
              : l10n.loginTwoFaTotpSubtitle,
        ),
        const SizedBox(height: AppDimensions.spacing24),
        MaterialPinField(
          length: _otpLength,
          keyboardType: TextInputType.number,
          onChanged: (value) => _otp = value,
          theme: MaterialPinTheme(
            cellSize: const Size(45, 55),
            fillColor: KitColors.surface,
            filledFillColor: KitColors.surface,
            focusedFillColor: KitColors.primary.withValues(alpha: 0.2),
            spacing: 10,
            borderRadius: BorderRadius.circular(AppDimensions.radius12),
            borderColor: KitColors.primary,
            focusedBorderColor: KitColors.primary,
            filledBorderColor: KitColors.primary,
            borderWidth: 2,
            focusedBorderWidth: 2.5,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: KitColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacing24),
        CustomButton(
          label: l10n.verify,
          isLoading: _loading,
          onPressed: _loading ? null : _submit,
        ),
        const SizedBox(height: AppDimensions.spacing12),
        CustomButton(
          label: l10n.cancel,
          isOutlined: true,
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
        ),
      ],
    );

    if (widget.isDialog) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: KitColors.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.twoFactorAuth,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: KitColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.of(context).pop(),
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
}

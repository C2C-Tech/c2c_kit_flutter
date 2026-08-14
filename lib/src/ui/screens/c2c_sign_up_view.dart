import 'package:c2c_kit_flutter/c2c_kit_flutter.dart';
import 'package:flutter/material.dart';

import '../widgets/c2c_auth_shell.dart';
import '../widgets/kit_pin_field.dart';
import '../widgets/kit_surface_card.dart';

/// Generic sign-up form usable across apps.
///
/// Flow: `/initializeregistration` → OTP sheet → `/register` (with `code`).
/// On success, [onSuccess] receives tokens and the form body (without OTP).
class C2cSignUpView extends StatefulWidget {
  const C2cSignUpView({
    super.key,
    required this.app,
    required this.onSuccess,
    this.locale = KitL10n.defaultLocale,
    this.onLoginTap,
    this.isDebugMode = false,
  });

  final C2cApp app;
  final Locale locale;
  final Future<void> Function(AuthTokens authTokens, Map<String, dynamic> body)
  onSuccess;
  final VoidCallback? onLoginTap;

  /// When true, pre-fills all form fields for faster local testing.
  final bool isDebugMode;

  @override
  State<C2cSignUpView> createState() => _C2cSignUpViewState();
}

class _C2cSignUpViewState extends State<C2cSignUpView> {
  static const _otpLength = 6;

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _streetController;
  late final TextEditingController _houseNumberController;
  late final TextEditingController _cityController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _birthPlaceController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;

  /// UI value: `Herr` / `Frau` (same as registration screen).
  String _gender = 'Herr';
  bool _loading = false;

  KitL10n get _l10n => KitL10n(widget.locale);

  String get _email => _emailController.text.trim();

  @override
  void initState() {
    super.initState();
    final debug = widget.isDebugMode;
    _nameController = TextEditingController(text: debug ? 'Max' : '');
    _surnameController = TextEditingController(text: debug ? 'Mustermann' : '');
    _phoneController = TextEditingController(
      text: debug ? '+491234567890' : '',
    );
    _streetController = TextEditingController(
      text: debug ? 'Musterstraße' : '',
    );
    _houseNumberController = TextEditingController(text: debug ? '12' : '');
    _cityController = TextEditingController(text: debug ? 'Berlin' : '');
    _postalCodeController = TextEditingController(text: debug ? '10115' : '');
    _birthDateController = TextEditingController(
      text: debug ? '01.01.1990' : '',
    );
    _birthPlaceController = TextEditingController(text: debug ? 'Berlin' : '');
    _emailController = TextEditingController(
      text: debug ? 'test@example.com' : '',
    );
    _passwordController = TextEditingController(
      text: debug ? 'c2C@123456' : '',
    );
    _confirmController = TextEditingController(text: debug ? 'c2C@123456' : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _houseNumberController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _birthDateController.dispose();
    _birthPlaceController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// Converts displayed `dd.MM.yyyy` to API `yyyy-MM-dd`.
  String _formattedBirthDate() {
    final raw = _birthDateController.text.trim();
    if (raw.isEmpty) return '';
    final parts = raw.split('.');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return raw;
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    _birthDateController.text =
        '${picked.day.toString().padLeft(2, '0')}.'
        '${picked.month.toString().padLeft(2, '0')}.'
        '${picked.year}';
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = _l10n;

    setState(() => _loading = true);
    try {
      final init = await AuthApi.initializeRegistration(
        app: widget.app,
        email: _email,
      );
      if (!mounted) return;

      if (!init.isOk) {
        showCustomMessage(
          context,
          init.errorMessage.isNotEmpty
              ? init.errorMessage
              : l10n.initializationFailed,
          isError: true,
        );
        return;
      }

      await _showOtpSheet();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, dynamic> getRegisterBody({String? enteredCode}) {
    Map<String, dynamic> body = {
      'name': _nameController.text.trim(),
      'surname': _surnameController.text.trim(),
      'email': _email,
      'password': _passwordController.text,
      'phone_number': _phoneController.text.trim(),
      'street': _streetController.text.trim(),
      'house_number': _houseNumberController.text.trim(),
      'city': _cityController.text.trim(),
      'postal_code': _postalCodeController.text.trim(),
      "gender": _gender == 'Herr' ? 'Male' : 'Female',
      'birthdate': _formattedBirthDate(),
      'birthplace': _birthPlaceController.text.trim(),
      'role': "user",
    };

    return enteredCode == null ? body : {...body, 'code': enteredCode};
  }

  Future<void> _showOtpSheet() {
    final l10n = _l10n;
    final email = _email;
    String enteredCode = '';
    var verifying = false;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> verifyOtp() async {
              if (enteredCode.length < _otpLength ||
                  enteredCode.contains(RegExp(r'[^0-9]'))) {
                showCustomMessage(
                  context,
                  l10n.completeSixDigitCode,
                  isError: true,
                );
                return;
              }

              setSheetState(() => verifying = true);
              try {
                final result = await AuthApi.register(
                  app: widget.app,
                  body: getRegisterBody(enteredCode: enteredCode),
                );
                if (!sheetContext.mounted) return;

                switch (result) {
                  case AuthTokensSuccess(:final tokens):
                    Navigator.of(sheetContext).pop();
                    final registerBody = getRegisterBody();
                    // Optional post-registration 2FA step.
                    // User can dismiss via back arrow; in that case we still
                    // continue with the original `onSuccess()` callback.
                    try {
                      await showC2cTwoFaSetup(
                        context,
                        app: widget.app,
                        accessToken: tokens.cloudAccessToken,
                        refreshToken: tokens.cloudRefreshToken,
                        locale: widget.locale,
                        userEmail: registerBody['email']?.toString() ?? '',
                        currentMethod: null,
                      );
                    } finally {
                      await widget.onSuccess(tokens, registerBody);
                    }
                  case AuthTokensFailure(:final message):
                    showCustomMessage(context, message, isError: true);
                }
              } finally {
                if (sheetContext.mounted) {
                  setSheetState(() => verifying = false);
                }
              }
            }

            return Container(
              decoration: const BoxDecoration(
                color: KitColors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radius24),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 12,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: KitColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing24),
                  Text(
                    l10n.emailVerification,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: KitColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing12),
                  Text(
                    l10n.emailVerificationMessage(email),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: KitColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing24),
                  KitPinField(
                    length: _otpLength,
                    onChanged: (value) => enteredCode = value,
                  ),
                  const SizedBox(height: AppDimensions.spacing24),
                  CustomButton(
                    label: l10n.completeVerification,
                    isLoading: verifying,
                    onPressed: verifying ? null : verifyOtp,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _salutationDropdown(KitL10n l10n) {
    return DropdownButtonFormField<String>(
      decoration: kitInputDecoration(
        label: l10n.salutation,
        prefixIcon: Icons.person_3_outlined,
      ),
      initialValue: _gender,
      dropdownColor: KitColors.surface,
      icon: const Icon(Icons.arrow_drop_down, color: KitColors.primary),
      onChanged: (value) {
        if (value == null) return;
        setState(() => _gender = value);
      },
      items: [
        DropdownMenuItem(value: 'Herr', child: Text(l10n.mr)),
        DropdownMenuItem(value: 'Frau', child: Text(l10n.ms)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;

    return C2cAuthShell(
      app: widget.app,
      locale: widget.locale,
      title: l10n.createAccount,
      subtitle: l10n.createAccountSubtitle,
      compactHeader: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KitFormSection(
              title: l10n.personalDetails,
              child: Column(
                children: [
                  _salutationDropdown(l10n),
                  const SizedBox(height: AppDimensions.spacing16),
                  CustomTextField(
                    label: l10n.surname,
                    l10n: l10n,
                    controller: _surnameController,
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  CustomTextField(
                    label: l10n.name,
                    l10n: l10n,
                    controller: _nameController,
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  CustomTextField(
                    label: l10n.birthDate,
                    l10n: l10n,
                    controller: _birthDateController,
                    prefixIcon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: _pickBirthDate,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  CustomTextField(
                    label: l10n.birthPlace,
                    l10n: l10n,
                    controller: _birthPlaceController,
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  CustomTextField(
                    label: l10n.phone,
                    l10n: l10n,
                    controller: _phoneController,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            KitFormSection(
              title: l10n.address,
              child: Column(
                children: [
                  CustomTextField(
                    label: l10n.street,
                    l10n: l10n,
                    controller: _streetController,
                    prefixIcon: Icons.signpost_outlined,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          label: l10n.houseNumber,
                          l10n: l10n,
                          controller: _houseNumberController,
                          prefixIcon: Icons.numbers,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing12),
                      Expanded(
                        flex: 3,
                        child: CustomTextField(
                          label: l10n.postalCode,
                          l10n: l10n,
                          controller: _postalCodeController,
                          prefixIcon: Icons.local_post_office_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  CustomTextField(
                    label: l10n.city,
                    l10n: l10n,
                    controller: _cityController,
                    prefixIcon: Icons.location_city,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            KitFormSection(
              title: l10n.accountCredentials,
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
                  const SizedBox(height: AppDimensions.spacing16),
                  CustomTextField(
                    label: l10n.password,
                    l10n: l10n,
                    controller: _passwordController,
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.fieldRequired(l10n.password);
                      }
                      if (value.length < 8) return l10n.passwordTooShort;
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  CustomTextField(
                    label: l10n.confirmPassword,
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
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacing24),
            CustomButton(
              label: l10n.signUp,
              isLoading: _loading,
              onPressed: _loading ? null : _submit,
            ),
            if (widget.onLoginTap != null) ...[
              const SizedBox(height: AppDimensions.spacing8),
              TextButton(
                onPressed: widget.onLoginTap,
                child: Text(
                  l10n.alreadyHaveAccount,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: KitColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class C2cSignUpScreen extends StatelessWidget {
  const C2cSignUpScreen({
    super.key,
    required this.app,
    required this.onSuccess,
    this.locale = KitL10n.defaultLocale,
    this.onLoginTap,
    this.isDebugMode = false,
  });

  final C2cApp app;
  final Locale locale;
  final Future<void> Function(AuthTokens authTokens, Map<String, dynamic> body)
  onSuccess;
  final VoidCallback? onLoginTap;
  final bool isDebugMode;

  @override
  Widget build(BuildContext context) {
    final l10n = KitL10n(locale);
    return Scaffold(
      backgroundColor: KitColors.background,
      appBar: CustomAppBar(title: l10n.signUp, app: app),
      body: C2cSignUpView(
        app: app,
        locale: locale,
        onSuccess: onSuccess,
        onLoginTap: onLoginTap,
        isDebugMode: isDebugMode,
      ),
    );
  }
}

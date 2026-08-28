import '../src/ui/l10n/kit_l10n.dart';

/// Shared password rules used by sign-up and reset-password flows.
class PasswordValidation {
  PasswordValidation._();

  static const int minLength = 8;

  static final RegExp _uppercase = RegExp(r'[A-Z]');
  static final RegExp _specialChar = RegExp(
    r'''[!@#\$&*~_+\-=\$\${}|\\:;"\'<>,.?/^]''',
  );

  static bool hasMinLength(String value) => value.length >= minLength;

  static bool hasUppercase(String value) => _uppercase.hasMatch(value);

  static bool hasSpecialChar(String value) => _specialChar.hasMatch(value);

  static String? validate(String? value, KitL10n l10n) {
    if (value == null || value.isEmpty) {
      return l10n.fieldRequired(l10n.password);
    }
    if (!hasMinLength(value)) return l10n.passwordMinEightCharacters;
    if (!hasUppercase(value)) return l10n.passwordAtLeastOneUppercase;
    if (!hasSpecialChar(value)) return l10n.passwordOneSpecialCharacterMin;
    return null;
  }
}

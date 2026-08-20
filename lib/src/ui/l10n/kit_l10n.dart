import 'package:flutter/material.dart';

/// Built-in English / German copy for kit auth UI.
///
/// Host apps may pass a [Locale]; default is German ([defaultLocale]).
/// They do not pass individual string keys.
class KitL10n {
  KitL10n([Locale? locale]) : locale = locale ?? defaultLocale;

  /// Default UI locale (German).
  static const Locale defaultLocale = Locale('de');

  final Locale locale;

  /// German unless language is explicitly English.
  bool get isGerman => locale.languageCode.toLowerCase() != 'en';

  String _t(String en, String de) => isGerman ? de : en;

  String get continueSignIn => _t('Sign in', 'Anmelden');
  String welcomeTo(String appName) =>
      isGerman ? 'Willkommen bei $appName' : 'Welcome to $appName';
  String get createAccountSubtitle => _t(
        'Fill in your details to create your C2C account.',
        'Geben Sie Ihre Daten ein, um Ihr C2C-Konto zu erstellen.',
      );
  String get personalDetails => _t('Personal details', 'Persönliche Daten');
  String get address => _t('Address', 'Adresse');
  String get accountCredentials => _t('Account', 'Zugangsdaten');
  String get stepCode => _t('Code', 'Code');
  String get email => _t('Email', 'E-Mail');
  String get emailAddress => _t('Email Address', 'E-Mail-Adresse');
  String get password => _t('Password', 'Passwort');
  String get confirmPassword => _t('Confirm Password', 'Passwort bestätigen');
  String get login => _t('Login', 'Anmelden');
  String get signUp => _t('Sign Up', 'Registrieren');
  String get forgotPassword => _t('Forgot Password?', 'Passwort vergessen?');
  String get name => _t('Name', 'Vorname');
  String get surname => _t('Surname', 'Nachname');
  String get phone => _t('Phone', 'Telefon');
  String get street => _t('Street', 'Straße');
  String get houseNumber => _t('House Number', 'Hausnummer');
  String get city => _t('City', 'Stadt');
  String get postalCode => _t('Postal Code', 'Postleitzahl');
  String get salutation => _t('Salutation', 'Anrede');
  String get mr => _t('Mr.', 'Herr');
  String get ms => _t('Ms.', 'Frau');
  String get birthDate => _t('Birth Date', 'Geburtsdatum');
  String get birthPlace => _t('Birth Place', 'Geburtsort');
  String get createAccount => _t('Create Account', 'Konto erstellen');
  String get alreadyHaveAccount =>
      _t('Already have an account?', 'Bereits ein Konto?');
  String get invalidEmail =>
      _t('Enter a valid email', 'Gültige E-Mail-Adresse eingeben');
  String get passwordTooShort => _t(
        'Password should be at least 8 characters',
        'Das Passwort muss mindestens 8 Zeichen lang sein',
      );
  String get passwordsDoNotMatch =>
      _t("Passwords didn't match", 'Passwörter stimmen nicht überein');
  String get twoFactorAuth =>
      _t('Two-Factor Authentication', 'Zwei-Faktor-Authentifizierung');
  String get loginTwoFaTitle =>
      _t('Verify your identity', 'Identität bestätigen');
  String get loginTwoFaTotpSubtitle => _t(
        'Enter the 6-digit code from your authenticator app to continue.',
        'Geben Sie den 6-stelligen Code aus Ihrer Authenticator-App ein, um fortzufahren.',
      );
  String get verify => _t('Verify', 'Verifizieren');
  String get cancel => _t('Cancel', 'Abbrechen');
  String get continueLabel => _t('Continue', 'Weiter');
  String get completeSixDigitCode => _t(
        'Please enter the complete 6-digit code.',
        'Bitte geben Sie den vollständigen 6-stelligen Code ein.',
      );
  String get twoFaChooseMethod => _t('Choose a method', 'Methode wählen');
  String get twoFaChooseMethodSubtitle => _t(
        'Select how you want to receive verification codes.',
        'Wählen Sie, wie Sie Verifizierungscodes erhalten möchten.',
      );
  String get twoFaAuthenticatorApp =>
      _t('Authenticator App', 'Authenticator-App');
  String get twoFaAuthenticatorAppSubtitle => _t(
        'Use an app like Google Authenticator or Authy.',
        'Nutzen Sie eine App wie Google Authenticator oder Authy.',
      );
  String get twoFaEmailMethod => _t('Email', 'E-Mail');
  String get twoFaEmailMethodSubtitle => _t(
        'Receive a verification code by email.',
        'Erhalten Sie einen Verifizierungscode per E-Mail.',
      );
  String get twoFaScanQrTitle => _t('Scan QR code', 'QR-Code scannen');
  String get twoFaScanQrSubtitle => _t(
        'Scan this QR code with your authenticator app, or enter the secret manually.',
        'Scannen Sie diesen QR-Code mit Ihrer Authenticator-App oder geben Sie den Schlüssel manuell ein.',
      );
  String get twoFaManualSecret =>
      _t('Manual entry key', 'Manueller Schlüssel');
  String get twoFaSecretCopied => _t(
        'Secret copied to clipboard',
        'Schlüssel in die Zwischenablage kopiert',
      );
  String get twoFaEnterTotpCodeSubtitle => _t(
        'Enter the 6-digit code from your authenticator app.',
        'Geben Sie den 6-stelligen Code aus Ihrer Authenticator-App ein.',
      );
  String get twoFaDisableTitle => _t(
        'Disable two-factor authentication',
        'Zwei-Faktor-Authentifizierung deaktivieren',
      );
  String twoFaAlreadyEnabledTitle(String method) => _t(
        '2FA is enabled via $method',
        '2FA ist über $method aktiviert',
      );
  String get twoFaAlreadyEnabledSubtitle => _t(
        'Your account is already protected with two-factor authentication. Do you want to remove it?',
        'Ihr Konto ist bereits mit Zwei-Faktor-Authentifizierung geschützt. Möchten Sie sie entfernen?',
      );
  String get twoFaConfirmDisable =>
      _t('Yes, disable 2FA', 'Ja, 2FA deaktivieren');
  String get twoFaEnabledBadge => _t('Enabled', 'Aktiviert');
  String get twoFaDisableEmailSubtitle => _t(
        'Enter the verification code sent to your email to disable 2FA.',
        'Geben Sie den an Ihre E-Mail gesendeten Code ein, um 2FA zu deaktivieren.',
      );
  String get twoFaDisableTotpSubtitle => _t(
        'Enter the code from your authenticator app to disable 2FA.',
        'Geben Sie den Code aus Ihrer Authenticator-App ein, um 2FA zu deaktivieren.',
      );
  String get twoFaDisable => _t('Disable 2FA', '2FA deaktivieren');
  String get twoFaResendCode => _t('Resend code', 'Code erneut senden');
  String twoFaResendCodeIn(int seconds) => _t(
        'Resend code in ${seconds}s',
        'Code erneut senden in ${seconds}s',
      );
  String get twoFaEmailCodeSent =>
      _t('Verification code sent', 'Verifizierungscode gesendet');
  String get twoFaEnabledSuccess => _t(
        'Two-factor authentication enabled',
        'Zwei-Faktor-Authentifizierung aktiviert',
      );
  String get twoFaDisabledSuccess => _t(
        'Two-factor authentication disabled',
        'Zwei-Faktor-Authentifizierung deaktiviert',
      );
  String get somethingWentWrong =>
      _t('Something went wrong', 'Etwas ist schiefgelaufen');
  String get codeVerification =>
      _t('Code Verification', 'Code Verifizierung');
  String get emailVerification =>
      _t('Email Verification', 'E-Mail-Verifizierung');
  String get completeVerification =>
      _t('Complete Verification', 'Verifizierung abschließen');
  String get initializationFailed =>
      _t('Registration could not be started.', 'Registrierung konnte nicht gestartet werden.');

  // Forgot / Reset password
  String get resetPassword => _t('Reset Password', 'Passwort zurücksetzen');
  String get newPassword => _t('New Password', 'Neues Passwort');
  String get confirmNewPassword =>
      _t('Confirm New Password', 'Neues Passwort bestätigen');
  String get sendCode => _t('Send Code', 'Code senden');
  String get verifyCode => _t('Verify Code', 'Code verifizieren');
  String get forgotPasswordTitle =>
      _t('Forgot Password', 'Passwort vergessen');
  String get forgotPasswordSubtitle => _t(
        'Enter your email address and we will send you a verification code.',
        'Geben Sie Ihre E-Mail-Adresse ein und wir senden Ihnen einen Verifizierungscode.',
      );
  String get codeSent =>
      _t('Verification code sent', 'Verifizierungscode gesendet');
  String get codeVerified =>
      _t('Code verified successfully', 'Code erfolgreich verifiziert');
  String get passwordResetSuccess => _t(
        'Password reset successfully',
        'Passwort erfolgreich zurückgesetzt',
      );
  String get backToLogin => _t('Back to Login', 'Zurück zur Anmeldung');

  String fieldRequired(String field) => isGerman
      ? 'Bitte $field eingeben'
      : 'Please enter $field';

  String loginTwoFaEmailSubtitle(String email) => isGerman
      ? 'Geben Sie den 6-stelligen Code ein, der an $email gesendet wurde, um fortzufahren.'
      : 'Enter the 6-digit code sent to $email to continue.';

  String enterEmailCodeSubtitle(String email) => isGerman
      ? 'Ein Code wurde an $email gesendet. Bitte geben Sie ihn unten ein.'
      : 'A code was sent to $email. Please enter it below.';

  String emailVerificationMessage(String email) => isGerman
      ? 'Wir haben einen 6-stelligen Code an $email gesendet. Bitte geben Sie ihn unten ein.'
      : 'We sent a 6-digit code to $email. Please enter it below.';
}

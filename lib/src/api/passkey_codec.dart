import 'models.dart';

/// Longest `device_label` accepted by register/begin.
const int passkeyDeviceLabelMaxLength = 64;

/// Trims [raw] and caps it at [passkeyDeviceLabelMaxLength].
String? clipPasskeyDeviceLabel(String? raw) {
  if (raw == null) return null;
  final String trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.length <= passkeyDeviceLabelMaxLength) return trimmed;
  return trimmed.substring(0, passkeyDeviceLabelMaxLength);
}

/// Body for `POST /passkeys/register/begin`.
Map<String, dynamic> passkeyRegisterDeviceBody({
  required String platform,
  String? deviceLabel,
}) {
  final Map<String, dynamic> body = <String, dynamic>{'platform': platform};
  final String? label = clipPasskeyDeviceLabel(deviceLabel);
  if (label != null) {
    body['device_label'] = label;
  }
  return body;
}

/// WebAuthn options with the cloud `sessionId` removed.
Map<String, dynamic> passkeyOptionsWithoutSession(Map<String, dynamic> json) {
  final Map<String, dynamic> copy = Map<String, dynamic>.from(json);
  copy.remove('sessionId');
  return copy;
}

/// Session id from a begin response, or null when it is missing.
String? passkeySessionId(Map<String, dynamic> json) {
  final dynamic value = json['sessionId'];
  if (value == null) return null;
  final String sessionId = value.toString().trim();
  if (sessionId.isEmpty) return null;
  return sessionId;
}

/// Package register JSON plus `authenticatorAttachment`, which `toJson` omits.
Map<String, dynamic> passkeyRegisterCredential(
  Map<String, dynamic> packageJson,
) {
  final Map<String, dynamic> credential = Map<String, dynamic>.from(
    packageJson,
  );
  credential['authenticatorAttachment'] = 'platform';
  return credential;
}

/// Maps `authenticate/finish` JSON onto tokens, or a failure when tokens are absent.
PasskeyAuthResult passkeyAuthFromFinishBody(dynamic data) {
  if (data is! Map) {
    return const PasskeyAuthFailure(message: 'Invalid passkey login response');
  }
  final Map<String, dynamic> json = Map<String, dynamic>.from(data);
  if (json['cloud_token'] is! Map || json['application_token'] is! Map) {
    return const PasskeyAuthFailure(
      message: 'Missing tokens in passkey login response',
    );
  }
  try {
    return PasskeyAuthSuccess(AuthTokens.fromJson(json));
  } catch (_) {
    return const PasskeyAuthFailure(
      message: 'Missing tokens in passkey login response',
    );
  }
}

/// Maps a successful `GET /passkeys` body. HTTP errors stay with the caller.
PasskeyListResult passkeyListFromBody(dynamic data) {
  if (data is! Map) {
    return const PasskeyListFailure(message: 'Invalid passkey list response');
  }
  final dynamic raw = Map<String, dynamic>.from(data)['passkeys'];
  if (raw is! List) {
    return const PasskeyListFailure(message: 'Invalid passkey list response');
  }
  final List<C2cPasskey> passkeys = <C2cPasskey>[];
  for (final dynamic item in raw) {
    if (item is Map) {
      passkeys.add(C2cPasskey.fromJson(Map<String, dynamic>.from(item)));
    }
  }
  return PasskeyListSuccess(passkeys);
}

/// Passkey object from `register/finish`, when the server included one.
Map<String, dynamic>? passkeyMapFromRegisterFinish(dynamic data) {
  if (data is! Map) return null;
  final dynamic passkey = Map<String, dynamic>.from(data)['passkey'];
  if (passkey is! Map) return null;
  return Map<String, dynamic>.from(passkey);
}

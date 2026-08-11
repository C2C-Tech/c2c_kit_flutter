/// Access + refresh token pair returned by login / signup / 2FA verify.
class AuthTokens {
  const AuthTokens({
    required this.applicationAccessToken,
    required this.applicationRefreshToken,
    required this.cloudAccessToken,
    required this.cloudRefreshToken,
  });

  final String applicationAccessToken;
  final String applicationRefreshToken;

  final String cloudAccessToken;
  final String cloudRefreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    final application = Map<String, dynamic>.from(
      json['application_token'] as Map,
    );
    final cloud = Map<String, dynamic>.from(json['cloud_token'] as Map);

    return AuthTokens(
      applicationAccessToken: application['access_token'] as String,
      applicationRefreshToken: application['refresh_token'] as String,
      cloudAccessToken:
          (cloud['access_token'] ?? cloud['access_token_']) as String,
      cloudRefreshToken: cloud['refresh_token'] as String,
    );
  }
}

/// Supported two-factor authentication methods.
enum TwoFaMethod { email, totp }

TwoFaMethod? twoFaMethodFromName(String? name) {
  if (name == null || name.isEmpty) return null;
  try {
    return TwoFaMethod.values.byName(name);
  } catch (_) {
    return null;
  }
}

/// Simple HTTP result from [AuthApi].
class ApiResponse {
  const ApiResponse({
    required this.isOk,
    required this.statusCode,
    this.data,
    this.errorMessage = '',
  });

  final bool isOk;
  final int statusCode;
  final dynamic data;
  final String errorMessage;

  bool get isError => !isOk;
}

sealed class LoginResult {
  const LoginResult();
}

class LoginSuccess extends LoginResult {
  const LoginSuccess(this.tokens);
  final AuthTokens tokens;
}

class LoginRequires2Fa extends LoginResult {
  const LoginRequires2Fa({required this.tempToken, required this.method});

  final String tempToken;
  final TwoFaMethod method;
}

class LoginFailure extends LoginResult {
  const LoginFailure({required this.message, this.statusCode});
  final String message;
  final int? statusCode;
}

sealed class AuthTokensResult {
  const AuthTokensResult();
}

class AuthTokensSuccess extends AuthTokensResult {
  const AuthTokensSuccess(this.tokens);
  final AuthTokens tokens;
}

class AuthTokensFailure extends AuthTokensResult {
  const AuthTokensFailure({required this.message, this.statusCode});
  final String message;
  final int? statusCode;
}

import 'dart:convert';
import 'dart:developer';

import 'package:c2c_kit_flutter/c2c_kit_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';

import 'passkey_codec.dart';

/// Thin helpers for C2C auth endpoints. Fixed base URL; no app init required.
class C2cKitAuthApi {
  C2cKitAuthApi._();

  static const String baseUrl = 'https://c2ccloud.vercel.app';

  static Map<String, String> _headers({
    required C2cApp app,
    String? accessToken,
  }) {
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Application-ID': app.applicationId,
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
  }

  static Future<C2cKitApiResponse> _send({
    required C2cApp app,
    required String method,
    required String path,
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    final String normalizedPath = path.startsWith('/') ? path : '/$path';
    log('${method.toLowerCase()}: $baseUrl$normalizedPath');
    if (body != null) log('body: $body');

    final Uri uri = Uri.parse('$baseUrl$normalizedPath');
    final Map<String, String> headers = _headers(
      app: app,
      accessToken: accessToken,
    );

    try {
      final http.Response response = switch (method) {
        'GET' => await http.get(uri, headers: headers),
        'DELETE' => await http.delete(uri, headers: headers),
        _ => await http.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? const <String, dynamic>{}),
        ),
      };

      log(
        'response: $normalizedPath ${response.statusCode} -> ${response.body}',
      );

      final dynamic data = response.body.isEmpty
          ? null
          : jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return C2cKitApiResponse(
          isOk: true,
          statusCode: response.statusCode,
          data: data,
        );
      }

      String message = 'Request failed';
      if (data is Map) {
        message = (data['message'] ?? data['error'] ?? message).toString();
      }

      return C2cKitApiResponse(
        isOk: false,
        statusCode: response.statusCode,
        data: data,
        errorMessage: message,
      );
    } catch (e, x) {
      log(e.toString());
      log(x.toString());
      return C2cKitApiResponse(
        isOk: false,
        statusCode: 0,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<C2cKitApiResponse> post({
    required C2cApp app,
    required String path,
    Map<String, dynamic> body = const {},
    String? accessToken,
  }) {
    return _send(
      app: app,
      method: 'POST',
      path: path,
      body: body,
      accessToken: accessToken,
    );
  }

  static Future<C2cKitApiResponse> get({
    required C2cApp app,
    required String path,
    String? accessToken,
  }) {
    return _send(app: app, method: 'GET', path: path, accessToken: accessToken);
  }

  static Future<C2cKitApiResponse> delete({
    required C2cApp app,
    required String path,
    String? accessToken,
  }) {
    return _send(
      app: app,
      method: 'DELETE',
      path: path,
      accessToken: accessToken,
    );
  }

  // ---------------------------------------------------------------------------
  // Login / signup
  // ---------------------------------------------------------------------------

  static Future<LoginResult> login({
    required C2cApp app,
    required String email,
    required String password,
  }) async {
    final response = await post(
      app: app,
      path: '/login',
      body: {'email': email, 'password': password},
    );

    if (!response.isOk) {
      return LoginFailure(
        message: response.errorMessage,
        statusCode: response.statusCode,
      );
    }

    final data = response.data;
    if (data is! Map) {
      return const LoginFailure(message: 'Invalid login response');
    }

    if (data['requires_2fa'] == true) {
      final method = twoFaMethodFromName(data['method']?.toString());
      final tempToken = data['temp_token']?.toString();
      if (method == null || tempToken == null || tempToken.isEmpty) {
        return const LoginFailure(message: 'Invalid 2FA challenge response');
      }
      return LoginRequires2Fa(tempToken: tempToken, method: method);
    }

    try {
      return LoginSuccess(AuthTokens.fromJson(Map<String, dynamic>.from(data)));
    } catch (_) {
      return const LoginFailure(message: 'Missing tokens in login response');
    }
  }

  static Future<LoginResult> verifyLogin2Fa({
    required C2cApp app,
    required String tempToken,
    required String code,
  }) async {
    final response = await post(
      app: app,
      path: '/2fa/verify',
      body: {'temp_token': tempToken, 'code': code},
    );

    if (!response.isOk) {
      return LoginFailure(
        message: response.errorMessage,
        statusCode: response.statusCode,
      );
    }

    final data = response.data;
    if (data is! Map) {
      return const LoginFailure(message: 'Invalid 2FA verify response');
    }

    try {
      return LoginSuccess(AuthTokens.fromJson(Map<String, dynamic>.from(data)));
    } catch (_) {
      return const LoginFailure(
        message: 'Missing tokens in 2FA verify response',
      );
    }
  }

  static Future<C2cKitApiResponse> initializeRegistration({
    required C2cApp app,
    required String email,
  }) {
    return post(
      app: app,
      path: '/initializeregistration',
      body: {'email': email},
    );
  }

  static Future<AuthTokensResult> register({
    required C2cApp app,
    required Map<String, dynamic> body,
  }) async {
    final response = await post(app: app, path: '/register', body: body);
    if (!response.isOk) {
      return AuthTokensFailure(
        message: response.errorMessage,
        statusCode: response.statusCode,
      );
    }

    final data = response.data;
    if (data is! Map) {
      return const AuthTokensFailure(message: 'Invalid register response');
    }

    try {
      return AuthTokensSuccess(
        AuthTokens.fromJson(Map<String, dynamic>.from(data)),
      );
    } catch (_) {
      return const AuthTokensFailure(
        message: 'Missing tokens in register response',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 2FA management (authenticated — pass tokens from app storage)
  // ---------------------------------------------------------------------------

  static Future<C2cKitApiResponse> setupTotp2Fa({
    required C2cApp app,
    required String accessToken,
  }) {
    return post(app: app, path: '/2fa/setup/totp', accessToken: accessToken);
  }

  static Future<C2cKitApiResponse> sendEmail2FaCode({
    required C2cApp app,
    required String accessToken,
  }) {
    return post(
      app: app,
      path: '/2fa/send-email-code',
      accessToken: accessToken,
    );
  }

  static Future<C2cKitApiResponse> enable2Fa({
    required C2cApp app,
    required String accessToken,
    required TwoFaMethod method,
    required String code,
  }) {
    return post(
      app: app,
      path: '/2fa/enable',
      accessToken: accessToken,
      body: {'method': method.name, 'code': code},
    );
  }

  static Future<C2cKitApiResponse> disable2Fa({
    required C2cApp app,
    required String accessToken,
    required String code,
  }) {
    return post(
      app: app,
      path: '/2fa/disable',
      accessToken: accessToken,
      body: {'code': code},
    );
  }

  static Future<C2cKitApiResponse> refreshAccessToken({
    required C2cApp app,
    required String refreshToken,
  }) {
    return post(
      app: app,
      path: '/refresh',
      body: {'cloud_refresh_token': refreshToken},
    );
  }

  // ---------------------------------------------------------------------------
  // Forgot / Reset password
  // ---------------------------------------------------------------------------

  /// Sends a recovery verification code to [email].
  static Future<C2cKitApiResponse> forgotPassword({
    required C2cApp app,
    required String email,
  }) {
    return post(app: app, path: '/forgotpwd', body: {'email': email});
  }

  /// Validates the recovery [code] for the given [email].
  static Future<C2cKitApiResponse> verifyRecoveryCode({
    required C2cApp app,
    required String email,
    required String code,
  }) {
    return post(
      app: app,
      path: '/verify_code',
      body: {'email': email, 'code': code},
    );
  }

  /// Resets the password for [email] using the verified [otp].
  static Future<C2cKitApiResponse> resetPassword({
    required C2cApp app,
    required String email,
    required String otp,
    required String password,
  }) {
    return post(
      app: app,
      path: '/resetpwd',
      body: {'email': email, 'otp': otp, 'password': password},
    );
  }

  ///
  ///
  /// User Cloud Data
  ///
  ///
  ///

  static Future<UserCloudModel?> getCloudUserData({
    required C2cApp app,
    required String accessToken,
  }) {
    return post(app: app, path: '/get_user_data', accessToken: accessToken)
        .then((value) {
          try {
            return UserCloudModel.fromJson(value.data["response"]);
          } catch (_) {
            return null;
          }
        })
        .catchError((e, x) {
          log(e.toString());
          log(x.toString());
          return null;
        });
  }

  // ---------------------------------------------------------------------------
  // Passkeys
  // ---------------------------------------------------------------------------

  /// Registers a platform passkey for the signed-in cloud user.
  static Future<PasskeyRegisterResult> registerPasskey({
    required C2cApp app,
    required String cloudAccessToken,
    bool debugMode = false,
  }) async {
    final String platform = _passkeyPlatform();
    final String? deviceLabel = await _passkeyDeviceLabel();
    final C2cKitApiResponse begin = await post(
      app: app,
      path: '/passkeys/register/begin',
      accessToken: cloudAccessToken,
      body: passkeyRegisterDeviceBody(
        platform: platform,
        deviceLabel: deviceLabel,
      ),
    );
    if (!begin.isOk) {
      return PasskeyRegisterFailure(
        message: begin.errorMessage,
        statusCode: begin.statusCode,
      );
    }
    if (begin.data is! Map) {
      return const PasskeyRegisterFailure(
        message: 'Invalid passkey register response',
      );
    }

    final Map<String, dynamic> beginJson = Map<String, dynamic>.from(
      begin.data as Map,
    );
    final String? sessionId = passkeySessionId(beginJson);
    if (sessionId == null) {
      return const PasskeyRegisterFailure(message: 'Missing passkey session');
    }

    try {
      final PasskeyAuthenticator authenticator = PasskeyAuthenticator(
        debugMode: debugMode,
      );
      final RegisterResponseType created = await authenticator.register(
        RegisterRequestType.fromJson(passkeyOptionsWithoutSession(beginJson)),
      );
      final C2cKitApiResponse finish = await post(
        app: app,
        path: '/passkeys/register/finish',
        accessToken: cloudAccessToken,
        body: <String, dynamic>{
          'sessionId': sessionId,
          'credential': passkeyRegisterCredential(created.toJson()),
        },
      );
      if (!finish.isOk) {
        return PasskeyRegisterFailure(
          message: finish.errorMessage,
          statusCode: finish.statusCode,
        );
      }
      return PasskeyRegisterSuccess(
        passkey: passkeyMapFromRegisterFinish(finish.data),
      );
    } on PasskeyAuthCancelledException {
      return const PasskeyRegisterCancelled();
    } on AuthenticatorException catch (error) {
      return PasskeyRegisterFailure(message: _passkeyErrorMessage(error));
    } on PlatformException catch (error) {
      return PasskeyRegisterFailure(message: _platformPasskeyMessage(error));
    } catch (error) {
      return PasskeyRegisterFailure(message: error.toString());
    }
  }

  /// Signs in with a passkey for [email]. Does not send a password.
  static Future<PasskeyAuthResult> authenticateWithPasskey({
    required C2cApp app,
    required String email,
    bool debugMode = false,
  }) async {
    final C2cKitApiResponse begin = await post(
      app: app,
      path: '/passkeys/authenticate/begin',
      body: <String, dynamic>{'email': email},
    );
    if (!begin.isOk) {
      return PasskeyAuthFailure(
        message: begin.errorMessage,
        statusCode: begin.statusCode,
      );
    }
    if (begin.data is! Map) {
      return const PasskeyAuthFailure(
        message: 'Invalid passkey login response',
      );
    }

    final Map<String, dynamic> beginJson = Map<String, dynamic>.from(
      begin.data as Map,
    );
    final String? sessionId = passkeySessionId(beginJson);
    if (sessionId == null) {
      return const PasskeyAuthFailure(message: 'Missing passkey session');
    }

    try {
      final PasskeyAuthenticator authenticator = PasskeyAuthenticator(
        debugMode: debugMode,
      );
      final AuthenticateResponseType assertion = await authenticator
          .authenticate(
            AuthenticateRequestType.fromJson(
              passkeyOptionsWithoutSession(beginJson),
            ),
          );
      final C2cKitApiResponse finish = await post(
        app: app,
        path: '/passkeys/authenticate/finish',
        body: <String, dynamic>{
          'sessionId': sessionId,
          'credential': assertion.toJson(),
        },
      );
      if (!finish.isOk) {
        return PasskeyAuthFailure(
          message: finish.errorMessage,
          statusCode: finish.statusCode,
        );
      }
      final PasskeyAuthResult parsed = passkeyAuthFromFinishBody(finish.data);
      if (parsed is PasskeyAuthFailure && finish.statusCode != 0) {
        return PasskeyAuthFailure(
          message: parsed.message,
          statusCode: finish.statusCode,
        );
      }
      return parsed;
    } on PasskeyAuthCancelledException {
      return const PasskeyAuthCancelled();
    } on AuthenticatorException catch (error) {
      return PasskeyAuthFailure(message: _passkeyErrorMessage(error));
    } on PlatformException catch (error) {
      return PasskeyAuthFailure(message: _platformPasskeyMessage(error));
    } catch (error) {
      return PasskeyAuthFailure(message: error.toString());
    }
  }

  /// Lists passkeys for the cloud user. Includes other apps and platforms.
  static Future<PasskeyListResult> listPasskeys({
    required C2cApp app,
    required String cloudAccessToken,
  }) async {
    final C2cKitApiResponse response = await get(
      app: app,
      path: '/passkeys',
      accessToken: cloudAccessToken,
    );
    if (!response.isOk) {
      return PasskeyListFailure(
        message: response.errorMessage,
        statusCode: response.statusCode,
      );
    }
    final PasskeyListResult parsed = passkeyListFromBody(response.data);
    if (parsed is PasskeyListFailure) {
      return PasskeyListFailure(
        message: parsed.message,
        statusCode: response.statusCode,
      );
    }
    return parsed;
  }

  /// Revokes one passkey on the server. Does not open the system passkey sheet.
  static Future<PasskeyDeleteResult> deletePasskey({
    required C2cApp app,
    required String cloudAccessToken,
    required String passkeyId,
  }) async {
    final C2cKitApiResponse response = await delete(
      app: app,
      path: '/passkeys/${Uri.encodeComponent(passkeyId)}',
      accessToken: cloudAccessToken,
    );
    if (!response.isOk) {
      return PasskeyDeleteFailure(
        message: response.errorMessage,
        statusCode: response.statusCode,
      );
    }
    final dynamic data = response.data;
    if (data is Map && data['ok'] == true) {
      return const PasskeyDeleteSuccess();
    }
    return PasskeyDeleteFailure(
      message: 'Passkey could not be removed',
      statusCode: response.statusCode,
    );
  }

  static String _passkeyPlatform() {
    if (kIsWeb) return 'web';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    if (defaultTargetPlatform == TargetPlatform.android) return 'android';
    return 'web';
  }

  static Future<String?> _passkeyDeviceLabel() async {
    final DeviceInfoPlugin plugin = DeviceInfoPlugin();
    try {
      if (kIsWeb) {
        final WebBrowserInfo info = await plugin.webBrowserInfo;
        return clipPasskeyDeviceLabel(_browserLabel(info.browserName));
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final IosDeviceInfo info = await plugin.iosInfo;
        return clipPasskeyDeviceLabel(info.model);
      }
      if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidDeviceInfo info = await plugin.androidInfo;
        return clipPasskeyDeviceLabel(info.model);
      }
    } catch (error, stack) {
      log(error.toString());
      log(stack.toString());
    }
    return null;
  }

  static String? _browserLabel(BrowserName name) {
    return switch (name) {
      BrowserName.chrome => 'Chrome',
      BrowserName.firefox => 'Firefox',
      BrowserName.safari => 'Safari',
      BrowserName.edge => 'Edge',
      BrowserName.opera => 'Opera',
      BrowserName.samsungInternet => 'Samsung Internet',
      BrowserName.msie => 'Internet Explorer',
      BrowserName.unknown => null,
    };
  }

  static String _passkeyErrorMessage(AuthenticatorException error) {
    final String text = error.toString().trim();
    if (text.isNotEmpty && !text.startsWith('Instance of ')) return text;
    return switch (error) {
      NoCredentialsAvailableException() =>
        'No passkey is available on this device',
      MissingGoogleSignInException() =>
        'Sign in to a Google account on this device to use a passkey',
      ExcludeCredentialsCanNotBeRegisteredException() =>
        'A passkey for this account is already on this device',
      DeviceNotSupportedException() => 'This device does not support passkeys',
      _ => 'Passkey request failed',
    };
  }

  static String _platformPasskeyMessage(PlatformException error) {
    if (error.code == 'SecurityError') {
      return 'Passkeys in the browser only work when this page is opened on the passkey domain.';
    }
    final String? message = error.message?.trim();
    if (message != null && message.isNotEmpty) return message;
    return 'Passkey request failed';
  }
}

/// False on desktop. On web, iOS, and Android, asks whether passkeys exist.
Future<bool> c2cPasskeysSupported() async {
  if (!kIsWeb &&
      defaultTargetPlatform != TargetPlatform.iOS &&
      defaultTargetPlatform != TargetPlatform.android) {
    return false;
  }
  try {
    final PasskeyAuthenticator authenticator = PasskeyAuthenticator();
    if (kIsWeb) {
      final AvailabilityTypeWeb availability = await authenticator
          .getAvailability()
          .web();
      return availability.hasPasskeySupport;
    }
    // ignore: deprecated_member_use
    return await authenticator.canAuthenticate();
  } catch (_) {
    return false;
  }
}

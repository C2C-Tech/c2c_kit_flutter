import 'dart:convert';
import 'dart:developer';

import 'package:c2c_kit_flutter/c2c_kit_flutter.dart';
import 'package:http/http.dart' as http;

import '../../constants/app_ids.dart';
import 'models.dart';

/// Thin helpers for C2C auth endpoints. Fixed base URL; no app init required.
class AuthApi {
  AuthApi._();

  static const String baseUrl = 'https://c2ccloud.vercel.app';

  static Future<ApiResponse> post({
    required C2cApp app,
    required String path,
    Map<String, dynamic> body = const {},
    String? accessToken,
  }) async {
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    log('post: $baseUrl$normalizedPath');
    log('body: $body');

    final uri = Uri.parse('$baseUrl$normalizedPath');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Application-ID': app.applicationId,
          if (accessToken != null && accessToken.isNotEmpty)
            'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      log(
        'response: $normalizedPath ${response.statusCode} -> ${response.body}',
      );

      final dynamic data = response.body.isEmpty
          ? null
          : jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          isOk: true,
          statusCode: response.statusCode,
          data: data,
        );
      }

      String message = 'Request failed';
      if (data is Map) {
        message = (data['message'] ?? data['error'] ?? message).toString();
      }

      return ApiResponse(
        isOk: false,
        statusCode: response.statusCode,
        data: data,
        errorMessage: message,
      );
    } catch (e, x) {
      log(e.toString());
      log(x.toString());
      return ApiResponse(
        isOk: false,
        statusCode: 0,
        errorMessage: e.toString(),
      );
    }
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

  static Future<ApiResponse> initializeRegistration({
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

  static Future<ApiResponse> setupTotp2Fa({
    required C2cApp app,
    required String accessToken,
  }) {
    return post(app: app, path: '/2fa/setup/totp', accessToken: accessToken);
  }

  static Future<ApiResponse> sendEmail2FaCode({
    required C2cApp app,
    required String accessToken,
  }) {
    return post(
      app: app,
      path: '/2fa/send-email-code',
      accessToken: accessToken,
    );
  }

  static Future<ApiResponse> enable2Fa({
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

  static Future<ApiResponse> disable2Fa({
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

  static Future<ApiResponse> refreshAccessToken({
    required C2cApp app,
    required String refreshToken,
  }) {
    return post(
      app: app,
      path: '/refresh',
      body: {'refresh_token': refreshToken},
    );
  }

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
}

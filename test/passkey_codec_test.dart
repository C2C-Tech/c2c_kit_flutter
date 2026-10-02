import 'package:c2c_kit_flutter/src/api/models.dart';
import 'package:c2c_kit_flutter/src/api/passkey_codec.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passkeys/types.dart';

void main() {
  test('strips sessionId before the passkey package sees options', () {
    final Map<String, dynamic> options = passkeyOptionsWithoutSession(
      <String, dynamic>{
        'challenge': 'abc',
        'rpId': 'c2ccloud.vercel.app',
        'sessionId': 'eyJ-session',
      },
    );

    expect(
      passkeySessionId(<String, dynamic>{'sessionId': 'eyJ-session'}),
      'eyJ-session',
    );
    expect(options.containsKey('sessionId'), isFalse);
    expect(options['challenge'], 'abc');
    expect(options['rpId'], 'c2ccloud.vercel.app');
  });

  test('fills missing credential transports for the passkeys package', () {
    final Map<String, dynamic> options = passkeyOptionsWithoutSession(
      <String, dynamic>{
        'challenge': 'abc',
        'rpId': 'c2c-immoverwaltung-dashboard.web.app',
        'sessionId': 'eyJ-session',
        'allowCredentials': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'BPqkRtRW5fIRAz8GUhLFzA',
            'type': 'public-key',
          },
          <String, dynamic>{
            'id': 'other',
            'type': 'public-key',
            'transports': 'internal',
          },
          <String, dynamic>{
            'id': 'kept',
            'type': 'public-key',
            'transports': <String>['hybrid'],
          },
        ],
        'excludeCredentials': <Map<String, dynamic>>[
          <String, dynamic>{'id': 'reg', 'type': 'public-key'},
        ],
      },
    );

    expect(options.containsKey('sessionId'), isFalse);

    final List<dynamic> allow = options['allowCredentials'] as List<dynamic>;
    expect((allow[0] as Map<String, dynamic>)['transports'], <String>[]);
    expect((allow[1] as Map<String, dynamic>)['transports'], <String>[
      'internal',
    ]);
    expect((allow[2] as Map<String, dynamic>)['transports'], <String>[
      'hybrid',
    ]);

    final List<dynamic> exclude =
        options['excludeCredentials'] as List<dynamic>;
    expect((exclude.single as Map<String, dynamic>)['transports'], <String>[]);

    final AuthenticateRequestType request = AuthenticateRequestType.fromJson(
      options,
    );
    expect(request.allowCredentials, isNotNull);
    expect(request.allowCredentials!.length, 3);
    expect(request.allowCredentials!.first.transports, isEmpty);
  });

  test('maps authenticate/finish onto AuthTokens', () {
    final PasskeyAuthResult result = passkeyAuthFromFinishBody(
      <String, dynamic>{
        'message': 'Login successful',
        'cloud_token': <String, dynamic>{
          'access_token': 'cloud-access',
          'refresh_token': 'cloud-refresh',
        },
        'application_token': <String, dynamic>{
          'access_token': 'app-access',
          'refresh_token': 'app-refresh',
        },
      },
    );

    expect(result, isA<PasskeyAuthSuccess>());
    final PasskeyAuthSuccess success = result as PasskeyAuthSuccess;
    expect(success.tokens.cloudAccessToken, 'cloud-access');
    expect(success.tokens.cloudRefreshToken, 'cloud-refresh');
    expect(success.tokens.applicationAccessToken, 'app-access');
    expect(success.tokens.applicationRefreshToken, 'app-refresh');
  });

  test('treats a non-token finish body as failure', () {
    final PasskeyAuthResult result = passkeyAuthFromFinishBody(
      <String, dynamic>{'requires_2fa': true, 'temp_token': 'tmp'},
    );

    expect(result, isA<PasskeyAuthFailure>());
    expect(
      (result as PasskeyAuthFailure).message,
      'Missing tokens in passkey login response',
    );
  });

  test('parses the passkey list payload', () {
    final PasskeyListResult result = passkeyListFromBody(<String, dynamic>{
      'passkeys': <Map<String, dynamic>>[
        <String, dynamic>{
          'passkey_id': 'uuid-1',
          'platform': 'android',
          'device_label': 'Pixel 8',
          'registered_app': 'ppm',
          'created_at': '2026-10-02T12:00:00Z',
        },
      ],
    });

    expect(result, isA<PasskeyListSuccess>());
    final C2cPasskey passkey = (result as PasskeyListSuccess).passkeys.single;
    expect(passkey.passkeyId, 'uuid-1');
    expect(passkey.platform, 'android');
    expect(passkey.deviceLabel, 'Pixel 8');
    expect(passkey.registeredApp, 'ppm');
    expect(passkey.createdAt, '2026-10-02T12:00:00Z');
  });

  test('register body keeps platform and caps the device label at 64', () {
    final String longLabel = 'Pixel ${'8' * 80}';
    final Map<String, dynamic> body = passkeyRegisterDeviceBody(
      platform: 'android',
      deviceLabel: '  $longLabel  ',
    );

    expect(body['platform'], 'android');
    expect(
      (body['device_label'] as String).length,
      passkeyDeviceLabelMaxLength,
    );
    expect(body.containsKey('manufacturer'), isFalse);

    final Map<String, dynamic> withoutLabel = passkeyRegisterDeviceBody(
      platform: 'ios',
      deviceLabel: '   ',
    );
    expect(withoutLabel, <String, dynamic>{'platform': 'ios'});
  });
}

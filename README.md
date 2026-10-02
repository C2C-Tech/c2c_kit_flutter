# c2c_kit_flutter

Shared Flutter package for C2C apps: auth API + login / sign-up / 2FA UI.

Repo: [C2C-Tech/c2c_kit_flutter](https://github.com/C2C-Tech/c2c_kit_flutter)

## Use in any app

Add a **git** dependency in the app’s `pubspec.yaml`. Prefer a **tag** so the app stays on a known release:

```yaml
dependencies:
  c2c_kit_flutter:
    git:
      url: https://github.com/C2C-Tech/c2c_kit_flutter.git
      ref: v0.0.1   # pin to a release tag (recommended)
```

Alternatives for `ref`:

| `ref` | When to use |
|-------|-------------|
| `v0.0.1` (tag) | Stable apps — only updates when you change the tag |
| `main` | Always track latest branch (less predictable) |
| commit SHA | Exact pin for debugging / hotfix |

Then in the app:

```bash
flutter pub get
```

```dart
import 'package:c2c_kit_flutter/c2c_kit_flutter.dart';
```

No kit init required. Host apps own routes, token storage, and navigation.

### Getting package updates in an app

Pub **locks** the resolved git commit in `pubspec.lock`.

- **Pinned to a tag** (`ref: v0.0.1`): change `ref` to the new tag (e.g. `v0.1.0`), then run `flutter pub get`.
- **Pinned to `main`**: `flutter pub get` alone may **not** pull new commits. Run:

```bash
flutter pub upgrade c2c_kit_flutter
```

Commit the updated `pubspec.lock` in the app after upgrading.

### Local path (monorepo / active development)

If the package lives next to the app:

```yaml
dependencies:
  c2c_kit_flutter:
    path: ./c2c_kit_flutter
```

Path deps pick up file changes immediately — no tag / `pub upgrade` needed.

## Releasing (tags via GitHub Desktop)

Git tags and `version` in this package’s `pubspec.yaml` are **not** linked automatically. Keep them in sync by hand.

When a set of commits is ready to ship:

1. Bump `version` in `c2c_kit_flutter/pubspec.yaml` (e.g. `0.0.1` → `0.1.0`).
2. Commit that change (and any release commits) and push to GitHub.
3. In **GitHub Desktop**, open this package repo → **History**.
4. Right‑click the **final** commit → **Create Tag…**.
5. Name the tag like `v0.1.0` (same as `pubspec.yaml`, with a `v` prefix).
6. **Push** so the tag reaches GitHub (tags may need an explicit push).

Apps then depend on that tag with `ref: v0.1.0`.

You can also create a tag from github.com: **Releases → Draft a new release**.

## `C2cApp`

Pass on every UI / API call. Sent as `Application-ID` header:

| Enum | Header value |
|------|----------------|
| `C2cApp.maintenance` | `maintenance` |
| `C2cApp.ppm` | `ppm` |
| `C2cApp.authenticator` | `authenticator` |

## Auth API

- **Base URL (fixed):** `https://c2ccloud-cmu16bebo-serhans-projects-b26a7af2.vercel.app`
- **Headers:** `Application-ID` (+ `Authorization: Bearer <accessToken>` when provided)

```dart
AuthApi.login(app: app, email: e, password: p);           // → LoginResult
AuthApi.verifyLogin2Fa(app: app, tempToken: t, code: c);  // → AuthTokensResult
AuthApi.initializeRegistration(app: app, email: e);       // → ApiResponse
AuthApi.register(app: app, body: {...});                  // → AuthTokensResult

AuthApi.setupTotp2Fa(app: app, accessToken: a);
AuthApi.sendEmail2FaCode(app: app, accessToken: a);
AuthApi.enable2Fa(app: app, accessToken: a, method: m, code: c);
AuthApi.disable2Fa(app: app, accessToken: a, code: c);
AuthApi.refreshAccessToken(app: app, refreshToken: r);

AuthApi.forgotPassword(app: app, email: e);
AuthApi.verifyRecoveryCode(app: app, email: e, code: c);
AuthApi.resetPassword(app: app, email: e, otp: o, password: p);

AuthApi.post(app: app, path: '/custom', body: {}, accessToken: a); // low-level
```

**`LoginResult`:** `LoginSuccess` | `LoginRequires2Fa` | `LoginFailure`  
**`AuthTokens`:** `applicationAccessToken` / `applicationRefreshToken` + `cloudAccessToken` / `cloudRefreshToken`

## UI

Locale defaults to **German** (`KitL10n.defaultLocale`). Pass `locale: Locale('en')` for English. Copy lives in the kit — apps don’t pass string keys.

### Login

```dart
C2cLoginScreen(
  app: C2cApp.maintenance,
  onSignUp: () => ...,
  onSuccess: (tokens, email) async {
    await saveTokens(tokens); // app storage
  },
)
```

Uses the built-in kit logo (`C2cLogo` / `assets/c2c_logo.png`).

Passkey sign-in is on the same form when the host passes `onPasskeySuccess`. `initialEmail` fills the email field; if that field is empty the kit asks for an email. The button is hidden when the device cannot use passkeys.

```dart
C2cLoginView(
  app: C2cApp.ppm,
  initialEmail: savedEmail,
  onSuccess: handleKitLoginSuccess,
  onPasskeySuccess: handleKitLoginSuccess,
)
```

Handles login 2FA internally (`C2cLoginTwoFaView`) and forgot password
(`C2cForgotPasswordScreen`) — no host callback needed. Use `C2cLoginView` if
you only need the form body.

### Sign-up

```dart
C2cSignUpScreen(
  app: C2cApp.maintenance,
  // Flow: /initializeregistration → OTP sheet → /register (with code)
  onLoginTap: () => ...,
  onSuccess: (tokens) async { ... },
  // optional: extraFieldsBuilder / buildBody for app-specific fields
)
```

### 2FA setup / disable

Pass tokens from **app** local storage:

```dart
showC2cTwoFaSetup(
  context,
  app: C2cApp.maintenance,
  accessToken: storedAccessToken,
  refreshToken: storedRefreshToken,
  currentMethod: existingMethod, // null = enable, non-null = disable
  userEmail: email,
);
```

### Passkeys

Create and sign-in work on iOS, Android, and the web. List and delete work over HTTP, so this browser can remove a passkey that was registered on a phone.

Do not add the `passkeys` package in the host. Do not store a `passkeyEnabled` flag.

The relying party id is the hostname of **this app’s deployed web dashboard** (no scheme, no path). A dashboard at `https://dashboard.example.com` means `rp.id` is `dashboard.example.com`. Set the server `WEBAUTHN_RP_ID` and `WEBAUTHN_ORIGIN` to that deploy. `localhost` can show the buttons, and the browser refuses the ceremony until the page is that host.

Each host app must ship these files in its Flutter `web` folder. The deploy serves them at the well-known URLs:

| File | Live URL |
|------|----------|
| `web/.well-known/apple-app-site-association` | `https://<dashboard host>/.well-known/apple-app-site-association` |
| `web/.well-known/assetlinks.json` | `https://<dashboard host>/.well-known/assetlinks.json` |

`apple-app-site-association` has no extension. Serve it as `application/json`. Put this app’s Apple team id and iOS bundle id in it, and set the iOS Associated Domains entitlement to `webcredentials:<dashboard host>`. Add the Face ID usage string when iOS asks for it.

```json
{
  "webcredentials": {
    "apps": ["<Apple Team ID>.<iOS bundle id>"]
  }
}
```

`assetlinks.json` uses this app’s Android `applicationId` and the release SHA-256 (the Play app-signing certificate when Play App Signing is on).

```json
[
  {
    "relation": ["delegate_permission/common.get_login_creds"],
    "target": {
      "namespace": "android_app",
      "package_name": "<applicationId>",
      "sha256_cert_fingerprints": ["<release SHA-256>"]
    }
  }
]
```

Web apps must also load the passkeys browser SDK in `web/index.html`, before `flutter_bootstrap.js`. Without it, `passkeys_web` closes the tab on startup (`Passkeys Web SDK not loaded`). Copy `example/web/bundle.js` into the host `web/` folder (Corbado bundle 2.5.0, the file shipped with `passkeys` 2.23.1):

```html
<script src="bundle.js" type="application/javascript"></script>
<script src="flutter_bootstrap.js" async></script>
```

A full restart is required after changing `index.html`. One cloud user can sign in to ppm, maintenance, and authenticator when each app’s dashboard is associated with the same relying party host.

```dart
await showC2cPasskeySettings(
  context,
  app: C2cApp.ppm,
  accessToken: cloudAccessToken!,
  locale: locale,
);
```

When this device has no passkey, the screen shows **Create passkey** and registers one for this device only. Saved passkeys are listed under **Saved passkeys**. Remove calls `DELETE /passkeys/<passkey_id>` and does not open Face ID or fingerprint. Create calls `C2cKitAuthApi.registerPasskey` (cloud access token, no new login tokens).

```dart
final PasskeyAuthResult result = await C2cKitAuthApi.authenticateWithPasskey(
  app: C2cApp.ppm,
  email: email,
);
final PasskeyListResult list = await C2cKitAuthApi.listPasskeys(
  app: C2cApp.ppm,
  cloudAccessToken: cloudAccessToken!,
);
```

## Also exported

Widgets: `CustomButton`, `CustomTextField`, `CustomAppBar`, `CustomSectionTitle`, `showCustomMessage`  
Constants: `AppColors`, `AppDimensions`


### Forgot password

Handled from login via **Forgot Password?** → `C2cForgotPasswordScreen`
(email → OTP → new password). You can also push it yourself:

```dart
C2cForgotPasswordScreen(
  app: C2cApp.maintenance,
  initialEmail: email,
  onSuccess: () => Navigator.pop(context),
)
```

TODO: implement token refreshing ...
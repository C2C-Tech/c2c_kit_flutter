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
  onForgotPassword: () => ...,
  onSignUp: () => ...,
  onSuccess: (tokens, email) async {
    await saveTokens(tokens); // app storage
  },
)
```

Uses the built-in kit logo (`C2cLogo` / `assets/c2c_logo.png`).

Handles login 2FA internally (`C2cLoginTwoFaView`). Use `C2cLoginView` if you only need the form body.

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

## Also exported

Widgets: `CustomButton`, `CustomTextField`, `CustomAppBar`, `CustomSectionTitle`, `showCustomMessage`  
Constants: `AppColors`, `AppDimensions`

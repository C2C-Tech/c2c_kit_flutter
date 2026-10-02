# c2c_kit_example

Local harness for the kit. Uses `C2cApp.ppm` and English (`Locale('en')`).

```bash
cd example
flutter run
```

Sign in with a password or **Continue with passkey**. The signed-in screen opens **Passkeys** (`showC2cPasskeySettings`) with the cloud access token. Logout keeps the email and returns to login.

Passkey create and sign-in work in Chrome when `web/index.html` loads `bundle.js` before Flutter. Restart the web run after changing that file. The browser only completes the ceremony when the page origin is the relying party domain. `localhost` can show **Continue with passkey** and **Create passkey**, then refuse the prompt. Phone apps still need this example’s bundle id on the relying party’s Associated Domains and Digital Asset Links.

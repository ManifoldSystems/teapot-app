# Contributing

Use Flutter 3.47.4 (Dart 3.13.3) for the same environment as CI:

```sh
flutter pub get --enforce-lockfile
flutter gen-l10n
flutter analyze
flutter test
```

Edit translations in `lib/l10n/app_en.arb` and `lib/l10n/app_id.arb`, then
regenerate and commit `lib/l10n/gen`. Set your own Control URL in Settings for
device testing. Building an APK also needs the Android SDK/NDK; see `CLAUDE.md`.

## Release signing

Release builds require your own keystore and gitignored `android/key.properties`:

```properties
storeFile=/absolute/path/to/release.jks
storePassword=your-private-store-password
keyAlias=release
keyPassword=your-private-key-password
```

Keep the keystore and passwords outside Git. Debug builds still use the debug
key; release builds fail if release signing is not configured.

Keep pull requests focused and include verification steps. Wire changes start
with `ManifoldSystems/teapot/docs/protocol.md` and must stay compatible with the
Rust agent and control plane. Use fictional deployment details in examples;
never commit signing keys, environment secrets, or real device logs.

Contributions use MIT. Preserve the existing Omniflow.id copyright notice and
all notices required by reused code. For vulnerabilities, see [SECURITY.md](SECURITY.md).

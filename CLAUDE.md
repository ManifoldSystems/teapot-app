# teapot-app

Flutter app for [Teapot](https://github.com/ManifoldSystems/teapot). v1 turns an
**Android phone into an exit node**: other approved devices in the mesh leave
the internet through the phone's SIM. Built from `Omniflow-id/Omniflow-Flutter-Starter`
(provider, go_router, l10n en/id, talker, toastification). MIT licensed.

Related repos and notes:

- `ManifoldSystems/teapot` — Rust agent; **`docs/protocol.md` is the wire spec**
  this app must match byte for byte. Change it there first.
- `ManifoldSystems/teapot-control` — self-hosted control plane.
  Set its URL in Settings or with `--dart-define=TEAPOT_CONTROL=<URL>` at build time.

## Layout

```
lib/teapot/
  protocol.dart        ALPN teapot/proxy/0, CONNECT line, OK/ERR, LineReader (keeps payload after \n)
  lan_guard.dart       isLocal (same ranges as teapot-core net.rs) + dialGuarded on resolved IPs
  key_store.dart       32-byte secret key in Android Keystore (flutter_secure_storage)
  control_client.dart  Ed25519 challenge login, device API, presence WebSocket
  exit_node.dart       accept loop, live allowlist (drops removed clients), byte counters, path kind
  agent.dart           orchestration inside the service; emits snapshots for the UI
  service.dart         flutter_foreground_task: TeapotTaskHandler (agent isolate) + TeapotController (UI)
  settings.dart        control URL, device name, allow LAN (shared_preferences)
lib/screens/tabs/home_tab.dart        status: phase, approve link, exit, public IP, clients (+ recent targets), log
lib/screens/tabs/mesh_tab.dart        every approved device: online, exit, IPv4, "using this phone"
lib/widgets/teapot_settings_card.dart settings; saving restarts the service
test/teapot_test.dart                 protocol, LAN guard, status report
```

The agent runs **in the foreground-service isolate**, not the UI isolate, so it
survives the app being swiped away and starts on boot. The UI only renders
snapshots (`sendDataToMain`) and sends `refresh`.

## Commands

```bash
flutter pub get
flutter analyze            # must be clean
flutter test
flutter build apk --debug  # needs Android SDK licenses accepted + NDK r28 (28.2.13676358)
```

First Android build compiles iroh's Rust core per ABI through cargokit /
cargo-ndk (Rust Android targets are installed on the owner's Mac). Accepting
SDK licenses is the owner's action: `flutter doctor --android-licenses`.

## Gotchas

- `MainLayout` (from the starter) wraps every tab in a `SingleChildScrollView`.
  A tab's `ListView` must be `shrinkWrap: true` with
  `NeverScrollableScrollPhysics`, or it throws and a **release build shows a
  blank tab**. This hid the approve button on the first device test.
- `adb exec-out screencap` on some devices prints a "Multiple displays" warning
  into the PNG; use `adb shell screencap -p /sdcard/x.png` + `adb pull`.
- If Maven Central blocks a network IP ("open proxy"), build with Gradle going
  through the local teapot proxy, Google's repo direct:

  ```bash
  JAVA_TOOL_OPTIONS="-Dhttp.proxyHost=127.0.0.1 -Dhttp.proxyPort=1080 -Dhttps.proxyHost=127.0.0.1 -Dhttps.proxyPort=1080 -Dhttp.nonProxyHosts=localhost|127.0.0.1|dl.google.com|*.google.com|*.googleapis.com|*.gstatic.com -Dorg.gradle.internal.http.connectionTimeout=120000 -Dorg.gradle.internal.http.socketTimeout=120000" flutter build apk --release --target-platform android-arm64
  ```

## Decisions

- **Foreground service type `specialUse`**, not `dataSync`: Android 15 limits
  dataSync to 6 h per 24 h. Subtype text is in the manifest property.
- `iroh_flutter` (community, snowpine.io, Apache-2.0) binds with `presets::N0`, so
  peers dial this phone by endpoint id like the Rust agent. IDs use `toHex()`.
- iroh_flutter exposes no RTT: path entries send `rtt_ms: -1` (dashboard hides it);
  relay vs direct comes from `PathSelected.remoteAddr` containing `Relay`.
- Public IPv4/IPv6 come from `endpoint.addr.ipAddrs` minus local ranges.
- v1 is exit-only. Using the phone as a *client* for all its apps needs a
  `VpnService` (TUN) — out of scope; Android's Wi-Fi proxy does not cover mobile data.
- User agent `teapot-android/<version>` — Cloudflare blocks library defaults (1010).

## Testing on a device

1. Install the APK on a test phone; set your control URL in Settings, then Start.
2. Approve from the status screen ("Open approval page") or copy the link to a laptop.
3. Turn exit on for it in the dashboard.
4. From a Mac: `teapot service install --exit <phone name>` (or `teapot proxy <name>`),
   then `curl -x http://127.0.0.1:1080 https://ifconfig.me` → the phone's SIM IP.

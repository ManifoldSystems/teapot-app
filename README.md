# Teapot (Android)

Turns an Android phone into a Teapot **exit node**: approved devices in your
mesh can leave the internet through the phone's SIM. Peer-to-peer over
[iroh](https://iroh.computer), with a self-hosted
[teapot-control](https://github.com/ManifoldSystems/teapot-control) deployment.

Distributed as source code only. Build and sign your own app; no prebuilt APK
or app-store package is provided. Release signing is covered in
[CONTRIBUTING.md](CONTRIBUTING.md#release-signing).

```bash
git clone https://github.com/ManifoldSystems/teapot-app.git
cd teapot-app
flutter pub get
flutter test
flutter build apk --debug
```

Set your deployment's **Control URL** in Settings before starting the agent.
New installs have no default server. A custom build can supply one with
`--dart-define=TEAPOT_CONTROL=https://teapot.example.com` (replace the example URL).
Previously saved settings are retained. For iOS builds, select your own signing
team in Xcode.

## Logs

From 1.1.0+2, the service reports the installed package version/build and
presence protocol to control. Reconnects use randomized exponential backoff;
the control version and presence generation appear in handshake logs.

**Mesh logs** is available from Status (even when stopped) and Mesh. Tap a peer
in Mesh to follow its logs, or choose local history, this device's control
history, another approved device, all devices, or control itself. The viewer
has minimum-level and message filters, pause/resume, and copy, in English and
Indonesian. Its WebSocket is separate from the service's presence connection.

The foreground service keeps structured local JSONL history in the app support
directory (`teapot.log.jsonl` plus one rotated file, roughly 2 MiB each), and
uploads bounded batches every five seconds. The in-memory upload queue retains
up to 1,000 events during an outage; it does not survive a process restart.
Local history does. Control retains at most 10,000 events globally / seven days.
Remote events are displayed only and never re-uploaded.

See `CLAUDE.md` for layout, decisions, and the device test procedure. Wire
format: `ManifoldSystems/teapot` → `docs/protocol.md`.

Started from Omniflow-Flutter-Starter (MIT, see LICENSE).

## Contributing and security

See [CONTRIBUTING.md](CONTRIBUTING.md) for development checks and pull requests,
and [SECURITY.md](SECURITY.md) for vulnerability reporting.

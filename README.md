# Teapot (Android)

Turns an Android phone into a Teapot **exit node**: approved devices in your
mesh can leave the internet through the phone's SIM. Peer-to-peer over
[iroh](https://iroh.computer); control plane at `https://teapot.example.com`.

```bash
flutter pub get
flutter test
flutter build apk --debug
```

## Logs

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

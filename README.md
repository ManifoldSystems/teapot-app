# Teapot (Android)

Turns an Android phone into a Teapot **exit node**: approved devices in your
mesh can leave the internet through the phone's SIM. Peer-to-peer over
[iroh](https://iroh.computer); control plane at `https://teapot.example.com`.

```bash
flutter pub get
flutter test
flutter build apk --debug
```

See `CLAUDE.md` for layout, decisions, and the device test procedure. Wire
format: `ManifoldSystems/teapot` → `docs/protocol.md`.

Started from Omniflow-Flutter-Starter (MIT, see LICENSE).

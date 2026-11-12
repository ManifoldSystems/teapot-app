# Security

Security fixes target the current `main` branch; there is no separate long-term
support line. This application is experimental.

Use **Security → Report a vulnerability** on GitHub when available. Otherwise,
open an issue titled **Private security contact requested**, with no technical
details or credentials, so a maintainer can arrange a private channel.

Privately report the affected version/commit, reproduction steps, and impact.
Use your own test devices and deployment. Redact device keys, tokens, addresses,
and personal data from diagnostic logs.

Set the Control URL to a deployment you trust. Keep LAN access disabled unless
approved peers should reach the phone's local network. All approved devices can
view mesh logs. Signing credentials and real environment values must remain
outside Git. See the [agent security policy](https://github.com/ManifoldSystems/teapot/blob/main/SECURITY.md)
for the mesh's deployment boundaries.

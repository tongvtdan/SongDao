# Sống Đạo Web

Sống Đạo is a Vietnamese Catholic daily practice web MVP. It helps a user open today, understand the liturgical context, complete one clear action, and keep a private note on the device.

This release is a public web beta, not native app parity. Parish selection, important Mass logic, iOS widgets, and stronger reminders are part of the broader SongDao roadmap and must be labeled as coming soon until implemented.

## Run Locally

```bash
npm install
npm run dev
```

Open `http://localhost:3000`.

## Verification

Run these before sharing a public beta link:

```bash
npm run lint
npm run typecheck
npm run build
```

Manual release checks:

- `/` resolves to today's date in `Asia/Ho_Chi_Minh`.
- Completing today's action persists after reload.
- Private notes persist after reload.
- Deleting a note requires confirmation.
- Export creates a valid `songdao-web` JSON backup.
- Import restores logs, notes, and settings in a fresh browser profile.
- PWA manifest shows SongDao PNG icons.
- Offline mode shows a clear saved-content banner or cached Today page.
- Mobile `390px` and desktop `1440px` layouts have no horizontal overflow.

## Privacy

The web beta is local-first:

- No account is required.
- Practice history and notes stay in browser storage on the device.
- Backups are user-controlled JSON exports.
- Analytics are disabled unless `NEXT_PUBLIC_SONGDAO_ANALYTICS_URL` is configured.
- If analytics are enabled, only aggregate events are sent. Note text, practice details, location, and identity are not sent.

## Release Notes

Public beta readiness includes:

- Today loop with Vietnamese liturgical context.
- Completion tracking and private reflection notes.
- Local backup export/import.
- PWA manifest, service worker registration, cached shell assets, and offline messaging.
- In-app privacy page.
- Honest roadmap copy for features that are not yet available on web.

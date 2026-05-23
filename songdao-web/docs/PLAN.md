# SongDao Web App V1 Plan

## Summary

Build a new `songdao-web/` project inside the current repo as a Next.js PWA deployed on Vercel. V1 proves the daily SongDao habit loop on the web: open a link, see today’s Vietnamese Catholic context, complete one daily action, optionally save a private note, and share/install the experience without App Store friction.

Use the existing Flutter app as product truth, but do not depend on Flutter runtime code. The web app will reimplement only the minimal Today logic in TypeScript and include a committed copy of the required content pack JSON so Vercel builds are self-contained.

Defaults chosen:
- Stack: Next.js App Router + TypeScript + Tailwind + npm.
- Deployment: Vercel project with root directory set to `songdao-web`.
- V1 scope: Today loop only, not mobile parity.
- Locale/timezone: Vietnamese-first, `Asia/Ho_Chi_Minh`.
- Data: static local content pack + browser-local completion/note storage.

## Key Changes

- Create `songdao-web/` with:
  - Next.js App Router project scaffold.
  - Tailwind theme using SongDao tokens from the Flutter app: canvas `#FAF8F3`, surface `#FFFFFF`, primary green `#1F7A64`, gold `#B8892E`, burgundy `#8F2F3D`, subtle border `#E2DDD1`.
  - PWA manifest, icons, install metadata, and a lightweight service worker.
  - Vercel-ready scripts: `dev`, `build`, `start`, `lint`, `typecheck`.

- Implement routes:
  - `/` redirects or resolves to today’s Vietnamese date route.
  - `/today/[date]` renders the shareable daily practice page.
  - Unknown or out-of-pack dates use a gentle fallback daily action instead of failing.

- Implement V1 UI:
  - Liturgical context card.
  - Daily action card with completion state.
  - Reading references card, reference-only.
  - Optional private reflection note after completion.
  - Share button using Web Share API with clipboard fallback.
  - Install prompt/help surfaced after repeat engagement, not on first load.

- Keep the app usable first-screen:
  - No marketing landing page.
  - No account system.
  - No payment.
  - No full Bible/prayer corpus.
  - No parish dashboard.
  - No web push in V1; add later only after retention is proven.

## Interfaces And Data Flow

- Add TypeScript content/domain modules:
  - `ContentPack`, `CalendarDay`, `Celebration`, `Reading`, `ActionRule`, `DailyAction`, `TodayViewData`.
  - `getDateKey(date, timeZone = 'Asia/Ho_Chi_Minh')`.
  - `getTodayView(dateKey, locale = 'vi')`.
  - `selectDailyAction(dateKey, context, rules)` mirroring the Flutter priority order: solemnity/holy day, Sunday, feast, season, parish event placeholder, weekday/default.
  - `readingOrder(type)` matching the Flutter order.

- Store committed web content packs under `songdao-web/src/content/packs/`.
  - Start with the current Vietnamese 2026 pack needed for Today.
  - Keep copyrighted readings reference-only.
  - Preserve checksum/source/license fields for trust, even if V1 only reads a subset.

- Add browser-local persistence:
  - Use IndexedDB directly with localStorage fallback.
  - Store action logs by `actionId/date`.
  - Store optional notes locally only.
  - Do not upload practice data.

- PWA behavior:
  - Manifest name: `Sống Đạo`.
  - Start URL: `/`.
  - Display mode: `standalone`.
  - Cache app shell, icons, and content pack assets.
  - Offline fallback should still render the last cached Today page when available.

## Implementation Commands

When implementing, scaffold with:

```sh
npx create-next-app@latest songdao-web --yes --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --turbopack --use-npm
```

Then inside `songdao-web/`:
- Add `npm run typecheck`.
- Add PWA files manually instead of adding a heavy PWA dependency.
- Configure Vercel with root directory `songdao-web`.
- Use Vercel Git integration for preview/production deploys; local CLI is available as fallback.

## Test Plan

- Run:
  - `npm run lint`
  - `npm run typecheck`
  - `npm run build`

- Verify behavior:
  - `/` resolves to today’s VN date.
  - `/today/YYYY-MM-DD` renders from the content pack.
  - Out-of-pack date renders fallback action.
  - Complete action persists after reload.
  - Note persists after reload.
  - Share button works or copies URL fallback.
  - Offline reload shows cached shell/content.
  - Vietnamese diacritics wrap cleanly on mobile width.
  - Desktop layout remains centered and readable.

- Browser verification after implementation:
  - Run local dev server.
  - Check mobile and desktop screenshots.
  - Confirm no console errors.
  - Confirm PWA manifest is detected.

## Assumptions

- `songdao-web/` will be created inside the current Flutter repo root: `/Users/dantong/Projects/Mobile-Apps/SongDao/songdao/songdao-web`.
- V1 is a validation product, not a full replacement for the native app.
- Native iOS widget and local notifications remain future mobile advantages.
- No Supabase/backend is needed for V1.
- Web deployment should be self-contained, so Vercel must not rely on files outside the repo root.

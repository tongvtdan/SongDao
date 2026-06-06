# Sống Đạo Lovable Build Spec

## 1. Insight

Lovable should build a production-quality PWA prototype from the current SongDao web logic and updated Open Design theme. The goal is not to reproduce every Flutter-native capability. The goal is to validate the daily practice loop fast.

## 2. Decision

Recommended Lovable stack:

- React + TypeScript
- Vite or Next-style routing depending on Lovable defaults
- Tailwind or CSS variables for tokens
- Local persistence with `localStorage` for MVP
- Optional IndexedDB later if content packs grow
- Supabase only later for optional backup/content updates, not MVP critical path

Do not add authentication in MVP.

## 3. Source References

Use these repo references:

- Product source: `/Users/dantong/Projects/Mobile-Apps/SongDao/AGENTS.md`
- Existing PRD: `/Users/dantong/Projects/Mobile-Apps/SongDao/docs/Sống Đạo - A Local-First Catholic Daily Practice App — PRD and Flutter Architecture.md`
- Existing design system: `/Users/dantong/Projects/Mobile-Apps/SongDao/Design.md`
- Updated theme reference: `/Users/dantong/Projects/Mobile-Apps/SongDao/graphics-design/Song-Dao-Open-Design`
- Current web prototype: `/Users/dantong/Projects/Mobile-Apps/SongDao/songdao-web`

Updated design files to inspect first:

- `DESIGN-HANDOFF.md`
- `DESIGN-MANIFEST.json`
- `songdao.css`
- `index.html`
- `landing.html`
- `today.html`
- `practice.html`
- `calendar.html`
- `parish.html`
- `progress.html`

## 4. Visual System

Use the Open Design export as the visual target.

### Tokens

```css
:root {
  --bg: #f5f4ed;
  --surface: #faf9f5;
  --surface-warm: #e8e6dc;
  --fg: #141413;
  --fg-2: #3d3d3a;
  --muted: #5e5d59;
  --meta: #87867f;
  --border: #f0eee6;
  --border-soft: #e8e6dc;
  --accent: #c96442;
  --accent-on: #faf9f5;
  --success: #17a34a;
  --warn: #eab308;
  --danger: #b53333;
  --radius-sm: 8px;
  --radius-md: 12px;
  --radius-lg: 16px;
  --radius-pill: 9999px;
  --motion-fast: 150ms;
  --motion-base: 200ms;
  --ease-standard: cubic-bezier(0.2, 0, 0, 1);
}
```

### Typography

Use:

- Display: serif, close to `Anthropic Serif`, fallback `Georgia`
- Body: warm sans, fallback `system-ui`
- Mono/meta: `ui-monospace`

If Lovable supports font selection, prefer:

- Display: Source Serif 4 or Noto Serif
- Body: Be Vietnam Pro or Inter
- Meta: JetBrains Mono or system monospace

### Layout Rules

- Background is warm paper, not white.
- Cards are calm surfaces with thin borders.
- Use terracotta accent for primary actions and eyebrows.
- Use liturgical colors as compact dots/pills only.
- Do not use broad green dashboard styling from the current webapp.
- Do not use decorative gradients/orbs/glassmorphism.
- Keep `8-16px` radius range, with larger radius only for product mock/device frames.
- Preserve the Open Design screen-file-first model.

## 5. Responsive Contract

Test these viewports:

| Name | Size |
|---|---|
| Mobile compact | 360x800 |
| Mobile standard | 390x844 |
| Mobile large | 430x932 |
| Foldable/small tablet | 600x960 |
| Tablet portrait | 820x1180 |
| Tablet landscape | 1024x768 |
| Laptop | 1366x768 |
| Desktop | 1440x900 |
| Wide | 1920x1080 |

Acceptance:

- No horizontal overflow.
- Vietnamese diacritics wrap cleanly.
- Today action remains above reading references.
- Bottom/mobile navigation does not cover primary CTA.
- Desktop can use sidebar/right rail.
- Mobile should stack content in this order: liturgical context, daily action, completion/note, readings, Mass/parish, rhythm.

## 6. Architecture

Use a small, solo-founder-maintainable structure:

```text
src/
  app/
    App.tsx
    routes.tsx
  components/
    AppShell.tsx
    TopNav.tsx
    SideNav.tsx
    BottomNav.tsx
    TodayActionCard.tsx
    LiturgicalContext.tsx
    ReadingReferences.tsx
    ReflectionNote.tsx
    ProgressRhythm.tsx
    ParishMassCard.tsx
    PrayerLibrary.tsx
  data/
    seed.ts
    content.ts
    actionRules.ts
  lib/
    engine.ts
    dates.ts
    storage.ts
    backup.ts
    types.ts
  pages/
    LandingPage.tsx
    TodayPage.tsx
    PracticePage.tsx
    CalendarPage.tsx
    ParishPage.tsx
    PrayPage.tsx
    ProgressPage.tsx
    SettingsPage.tsx
```

Keep domain logic in `lib/engine.ts`, not inside React components.

## 7. Routes And Responsibilities

### `/`

Landing page.

Responsibilities:

- Explain "one small daily action."
- Show product UI proof/mock from app screens.
- CTA to `/today`.
- Optional waitlist capture as non-blocking local placeholder.

### `/today` and `/today/:date`

Primary product surface.

Responsibilities:

- Resolve today's Vietnam date.
- Load calendar day.
- Load celebrations.
- Load reading citations.
- Select daily action.
- Show completion state.
- Save note.

### `/practice`

Action engine surface.

Responsibilities:

- Explain/select seasonal context.
- Show sample actions.
- Display priority model.
- This is a product education/debug surface, not the main daily habit surface.

### `/calendar`

Secondary context surface.

Responsibilities:

- Week/month view.
- Search days/celebrations.
- Navigate into date-specific Today.
- Show actions as compact labels.

### `/parish`

Parish surface.

Responsibilities:

- Choose my parish.
- Persist selection locally.
- Show next important Mass.
- Show stale/verified state.

### `/pray`

Prayer basics.

Responsibilities:

- Seeded prayers only.
- Search/filter by tags.
- No full breviary.

### `/progress`

Private rhythm.

Responsibilities:

- Week completion.
- Recent actions.
- Journal/note list.
- No score/ranking language.

### `/settings`

Privacy and local data.

Responsibilities:

- Reminder setting placeholder or browser notification request if available.
- Show/hide lunar date.
- Export backup JSON.
- Import backup JSON.
- Privacy explanation.

## 8. Daily Action Engine

Implement deterministic action selection.

Rule priority:

1. Holy day or solemnity
2. Sunday
3. Feast
4. Liturgical season
5. Parish event
6. Weekday
7. Fallback

Minimal TypeScript:

```ts
export function selectDailyAction(context: RuleContext, rules: ActionRule[]): DailyAction {
  const matches = rules
    .filter((rule) => rule.enabled)
    .filter((rule) => matchesRule(rule, context))
    .sort(compareRulePriority);

  return matches[0]?.action ?? fallbackAction(context.date);
}
```

Fallback action:

> Bắt đầu nhẹ nhàng hôm nay: dành một phút thinh lặng và dâng ngày này cho Chúa.

## 9. Local Persistence

Use localStorage keys:

```ts
const KEYS = {
  logs: "songdao.actionLogs.v1",
  notes: "songdao.notes.v1",
  settings: "songdao.settings.v1",
  selectedParish: "songdao.selectedParish.v1",
};
```

Do not store sensitive notes remotely in MVP.

Implement:

- `getActionLog(actionId)`
- `markCompleted(actionId, date)`
- `saveNote(actionId, date, note)`
- `getWeekProgress()`
- `getSettings()`
- `saveSettings()`
- `exportBackup()`
- `importBackup()`

## 10. Seed Content

Use static seed data in TypeScript or JSON:

- 30-60 calendar days around the current demo window.
- Include May 29, 2026 example from Open Design.
- Reading citations only.
- 5+ action rules.
- 5+ prayers.
- 3 parishes.

Include this canonical demo date:

```ts
{
  date: "2026-05-29",
  celebration: "Thánh Phao-lô VI, giáo hoàng",
  liturgicalWeek: "Tuần Thường Niên",
  liturgicalColor: "white",
  lunarDate: "13 tháng 4, Bính Ngọ",
  gospel: "Mc 11,11-26",
  firstReading: "1 Pr 4,7-13",
  psalm: "Tv 96,10.11-12.13",
  acclamation: "x. Ga 15,16"
}
```

## 11. Component Specs

### TodayActionCard

Default:

- Eyebrow: `Việc hôm nay`
- Large action title
- Supporting prompt
- Duration pill
- Primary CTA

Completed:

- CTA changes to completed state.
- Show completion timestamp.
- Reveal reflection note.

### LiturgicalContext

Shows:

- Date
- Celebration
- Season
- Liturgical color
- Lunar date if enabled
- Previous/next date controls

### ReadingReferences

Shows:

- Gospel first or visually strongest
- First reading, psalm, acclamation
- Legal note: references only

### ParishMassCard

Shows:

- Selected parish
- Next Sunday/important Mass
- Language/time if available
- Last verified state

### ProgressRhythm

Shows:

- `x/7 ngày`
- Week day buttons/markers
- Recent completed actions
- Gentle copy

## 12. QA Checklist

Functional:

- Today loads on first visit.
- Completion persists after refresh.
- Note persists after refresh.
- Calendar date opens correct Today route.
- Parish selection persists.
- Backup export/import works.
- App still works offline after load.

Visual:

- Matches Open Design tokens.
- No broad green dashboard dominance.
- No horizontal scroll at responsive matrix.
- Cards are not nested visually.
- Primary action is the visual center.
- Landing is separate from app.

Privacy:

- No account required.
- No upload of notes/logs.
- Backup is user-initiated.
- No public score/proof language.

## 13. Lovable Iteration Plan

### Pass 1

Build shell, theme tokens, routes, seed data, Today screen, completion, note.

### Pass 2

Build Calendar, Progress, Parish, Pray, Settings.

### Pass 3

Polish responsive behavior and visual match to Open Design export.

### Pass 4

Add backup/import, reminder placeholder, PWA metadata.

### Pass 5

QA and copy polish.


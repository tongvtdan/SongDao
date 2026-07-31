# Paste-Ready Lovable Prompt

Build a polished local-first PWA for `Sống Đạo`, a Vietnamese Catholic daily practice app.

Use this product promise:

> Một việc nhỏ mỗi ngày để sống đức tin.

The app must answer: "What should I do today to live my faith?"

## Critical Product Direction

Do not build another Catholic calendar, Bible app, church map, social network, or content library.

Build the daily practice loop:

1. Today's liturgical context
2. One concrete Catholic action
3. One-tap completion
4. Private note
5. Private weekly rhythm
6. Parish/important Mass context
7. Local-first persistence

No login. No payment. No public ranking. No AI priest/confessor. No full Bible text.

## Visual Source Of Truth

Use the updated Open Design theme from:

`/Users/dantong/Projects/Mobile-Apps/SongDao/graphics-design/Song-Dao-Open-Design`

Match the exported visual direction:

- Warm paper background `#f5f4ed`
- Surface `#faf9f5`
- Warm surface `#e8e6dc`
- Ink text `#141413`
- Muted text `#5e5d59`
- Meta text `#87867f`
- Thin borders `#f0eee6` and `#e8e6dc`
- Terracotta accent `#c96442`
- Serif display headings
- Warm sans body text
- Calm cards, subtle borders, minimal shadow
- Screen-file-first product routes

Use these reference screens:

- `landing.html`
- `today.html`
- `practice.html`
- `calendar.html`
- `parish.html`
- `progress.html`
- `songdao.css`
- `songdao.js`

Preserve the visual geometry, spacing rhythm, buttons, pills, side navigation, responsive behavior, and calm editorial feel. Do not use generic SaaS gradients, decorative blobs, glossy UI, or heavy dashboards.

## Routes

Create these routes:

- `/` landing page
- `/today` today's practice
- `/today/:date` date-specific practice
- `/practice` Daily Action Engine explainer/control screen
- `/calendar` liturgical week/month context
- `/parish` parish selector + Important Mass
- `/pray` basic prayer library
- `/progress` private rhythm and notes
- `/settings` privacy, local backup/import, reminder preference

Landing page must be separate from app screens.

## Core Screens

### Today

Mobile order:

1. Liturgical context
2. Daily action
3. Completion state
4. Private reflection note after completion
5. Reading references
6. Parish/Important Mass
7. Weekly rhythm/privacy note

Desktop can use left sidebar, main content, and right rail.

Today must show:

- Vietnamese date
- Optional lunar date
- Liturgical season
- Liturgical color as compact pill/dot
- Primary celebration
- One daily action
- Duration
- Completion button
- Reading citations only
- Private note

### Daily Action Engine

Implement deterministic rule selection:

1. Holy day/solemnity
2. Sunday
3. Feast
4. Liturgical season
5. Parish event
6. Weekday
7. Fallback

Fallback:

`Bắt đầu nhẹ nhàng hôm nay: dành một phút thinh lặng và dâng ngày này cho Chúa.`

### Calendar

Calendar is secondary. It provides context and date navigation, not a content dump.

Show week/month days with compact action labels and reading references.

### Parish

Let the user choose one parish from seeded data. Persist it locally. Show next important Sunday/solemnity Mass. Do not require live location.

### Progress

Use language like:

- `Nhịp sống đạo`
- `Một việc nhỏ hôm nay là đủ để bắt đầu lại.`
- `Riêng tư`

Avoid:

- `Faith score`
- `You failed`
- `Prove attendance`
- Rankings or leaderboards

### Settings

Include:

- Show/hide lunar date
- Reminder time preference
- Export local backup JSON
- Import backup JSON
- Privacy statement

## Data And Persistence

Use local-first browser persistence for MVP.

Use localStorage keys:

- `songdao.actionLogs.v1`
- `songdao.notes.v1`
- `songdao.settings.v1`
- `songdao.selectedParish.v1`

Do not require Supabase. If Supabase is scaffolded, keep it optional for future backup/content updates only.

## Seed Data

Include demo content around this date:

Date: `2026-05-29`

Celebration:

`Thánh Phao-lô VI, giáo hoàng`

Liturgical context:

`Tuần Thường Niên`, `Trắng`, `13 tháng 4, Bính Ngọ`

Reading references:

- Tin Mừng: `Mc 11,11-26`
- Bài đọc I: `1 Pr 4,7-13`
- Đáp ca: `Tv 96,10.11-12.13`
- Tung hô Tin Mừng: `x. Ga 15,16`

Action:

`Chọn một điều nhỏ để tiết chế hoặc phục vụ âm thầm trong ngày thứ Sáu.`

Legal note:

`Bản beta chỉ hiển thị tham chiếu để tôn trọng bản quyền nội dung Kinh Thánh.`

Add at least:

- 30-60 calendar days
- 5 action rules
- 5 prayers
- 3 parishes
- Mass times for selected parishes

## Acceptance Criteria

Functional:

- App opens directly to Today.
- Completion persists after refresh.
- Note persists after refresh.
- Calendar date opens date-specific Today.
- Parish selection persists.
- Progress updates from local completions.
- Backup export/import works.
- Core app works without login.

Visual:

- Looks like the Open Design export, not generic Tailwind defaults.
- No horizontal overflow at 360, 390, 430, 600, 820, 1024, 1366, 1440, 1920 widths.
- Vietnamese text wraps cleanly.
- Today action is the visual center.
- Reading references do not dominate.
- Landing page shows product UI proof early.

Privacy:

- Practice logs and notes stay local.
- No account requirement.
- No public score.
- No AI confession or religious authority claims.

Build the smallest complete version first: Today -> completion -> note -> progress -> calendar/parish.


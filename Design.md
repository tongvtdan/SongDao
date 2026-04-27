# Sống Đạo Design System

Design direction for **Sống Đạo**, a local-first Catholic daily practice app. This file follows the `DESIGN.md` pattern referenced by VoltAgent's `awesome-design-md`: visual atmosphere, tokens, typography, components, layout, states, responsive behavior, and agent guardrails.

The product is not a Catholic content encyclopedia. It is a quiet daily practice surface: one action, today’s liturgical context, my parish, important Mass, private rhythm, and widget-first reminders.

---

## 1. Visual Theme & Atmosphere

Sống Đạo should feel like a calm chapel notebook translated into a modern mobile operating system.

The interface must be:

- **Quiet, sacred, and practical**: prayerful without becoming ornamental.
- **Daily-use friendly**: fast to scan in under 10 seconds.
- **Private and non-judgmental**: progress feels like rhythm, not scoring.
- **Vietnamese Catholic by default**: copy, dates, parish names, and feast names must render gracefully.
- **Local-first**: UI should never feel broken when offline.

The visual tone sits between:

- A clean habit tracker
- A liturgical calendar
- A parish reminder tool
- A private prayer journal

Avoid building a church brochure, saints encyclopedia, or devotional wallpaper app. The Today screen is an action dashboard, not a shrine.

### Core Feeling

Use warm whites, ink text, chapel green, deep burgundy, and restrained gold. The interface should feel human and grounded, but never sepia-heavy or old-fashioned.

### Distinctive Product Signal

Every primary surface should answer:

> What is today, and what one concrete act should I do?

This should be visually obvious on:

- Today screen
- Home screen widget
- Notification landing state
- Calendar day detail
- Weekly rhythm screen

---

## 2. Color Palette & Roles

Use semantic roles first. Liturgical colors are accents, not the whole UI.

### Core Surfaces

| Token | Hex | Role |
|---|---:|---|
| `surface.canvas` | `#FAF8F3` | Main app background, warm but not yellow |
| `surface.primary` | `#FFFFFF` | Cards, sheets, forms, widget content |
| `surface.secondary` | `#F3F0E8` | Calendar bands, secondary grouped sections |
| `surface.elevated` | `#FFFFFF` | Bottom sheets, modals, floating controls |
| `surface.inverse` | `#18221E` | Dark seasonal/widget surfaces |

### Text

| Token | Hex | Role |
|---|---:|---|
| `text.primary` | `#1F2522` | Main reading text and headings |
| `text.secondary` | `#5F6761` | Supporting labels, descriptions |
| `text.tertiary` | `#8A938D` | Metadata, captions, placeholders |
| `text.inverse` | `#F8F5ED` | Text on dark surfaces |
| `text.link` | `#1B6E5A` | Links and tappable text |

### Brand & Interaction

| Token | Hex | Role |
|---|---:|---|
| `brand.primary` | `#1F7A64` | Primary action, selected nav, focus |
| `brand.primaryPressed` | `#155744` | Pressed primary state |
| `brand.soft` | `#E2F1EA` | Selected chips, gentle success surfaces |
| `brand.deep` | `#123C32` | High-emphasis text on green surfaces |
| `accent.gold` | `#B8892E` | Solemnity, sacred emphasis, small highlights |
| `accent.burgundy` | `#8F2F3D` | Lent, sacrifice, confession preparation |
| `accent.blue` | `#2F5F8F` | Marian content, informational states |

### Liturgical Colors

Use liturgical colors as compact signals: left rails, small dots, badges, calendar markers, icon tints, widget accents.

| Liturgical Token | Hex | Use |
|---|---:|---|
| `liturgical.green` | `#2F7D4F` | Ordinary Time |
| `liturgical.white` | `#F7F3E8` | Christmas, Easter, solemnities |
| `liturgical.gold` | `#C69A3D` | High feast emphasis on white days |
| `liturgical.red` | `#B33A3A` | Martyrs, Palm Sunday, Good Friday |
| `liturgical.purple` | `#6B4A7A` | Advent, Lent, penance |
| `liturgical.rose` | `#C9788D` | Gaudete and Laetare Sundays |
| `liturgical.black` | `#242424` | Rare memorial usage only |

### Status Colors

| Token | Hex | Role |
|---|---:|---|
| `status.complete` | `#2F7D4F` | Completed daily action |
| `status.warning` | `#B8892E` | Missing content, stale Mass data |
| `status.error` | `#B33A3A` | Sync/import failures |
| `status.offline` | `#5F6761` | Offline indicator |

### Borders & Dividers

| Token | Value | Role |
|---|---|---|
| `border.subtle` | `#E2DDD1` | Cards, list dividers |
| `border.strong` | `#CFC7B7` | Inputs, selected boundaries |
| `border.focus` | `#1F7A64` | Accessibility focus ring |

---

## 3. Typography Rules

Use system fonts for speed and native feel.

### Font Family

Flutter default:

```dart
fontFamily: null
```

Prefer platform typography:

- iOS: SF Pro
- Android: Roboto
- Fallback: system sans

Do not introduce a custom font for MVP unless Vietnamese rendering is visibly poor.

### Type Scale

| Role | Size | Weight | Line Height | Use |
|---|---:|---:|---:|---|
| `display` | 32 | 700 | 1.15 | Today action title, onboarding headline |
| `headlineLarge` | 28 | 700 | 1.18 | Screen titles |
| `headline` | 24 | 700 | 1.22 | Major card title |
| `titleLarge` | 20 | 700 | 1.30 | Section title, widget large title |
| `title` | 18 | 600 | 1.35 | Card title, selected day title |
| `bodyLarge` | 17 | 400 | 1.50 | Reflection prompt, devotional reading |
| `body` | 15 | 400 | 1.45 | Standard UI body |
| `label` | 14 | 600 | 1.30 | Buttons, tabs, chips |
| `caption` | 13 | 500 | 1.30 | Metadata, feast rank, time labels |
| `micro` | 11 | 600 | 1.20 | Calendar dots, compact widget labels |

### Typography Principles

- Use **sentence case**, not all caps, except tiny metadata chips where space requires it.
- Do not use negative letter spacing. Vietnamese diacritics need room.
- Long Vietnamese feast names must wrap cleanly to two lines.
- The daily action title gets the strongest type treatment.
- Scripture citations should be compact and legible, never decorative.

### Copy Tone

Good:

- "Một việc nhỏ hôm nay"
- "Cầu nguyện 5 phút"
- "Viết một câu suy niệm"
- "Nhịp sống tuần này"
- "Dữ liệu này đang lưu trên thiết bị"

Avoid:

- "Faith score"
- "Prove you attended Mass"
- "You failed today"
- "Become a better Catholic"
- Overly sentimental religious copy

---

## 4. Component Styling

### App Shell

Primary navigation uses bottom tabs:

1. Today
2. Calendar
3. Pray
4. Church
5. Progress

Use icons plus short labels. Today is the home destination and should be visually privileged.

### Today Header

Purpose: identify the liturgical day quickly.

Structure:

- Solar date
- Optional lunar date
- Liturgical season
- Celebration or weekday title
- Liturgical color marker

Styling:

- White or warm-white surface
- 8px corner radius
- 1px subtle border
- Liturgical color as a 4px vertical rail or small circular marker
- No heavy religious imagery

### Daily Action Card

This is the most important component in the app.

Structure:

- Small context label: season or rule source
- Large action title
- Duration chip
- Prompt text
- Primary completion button
- Optional note affordance

Styling:

- Use `surface.primary`
- 8px radius
- 1px `border.subtle`
- A small liturgical accent rail
- Completion button uses `brand.primary`
- Completed state uses `brand.soft` with `status.complete`

Behavior:

- One primary action only.
- Secondary actions must not compete visually.
- Completion should be one tap.
- Note entry appears after completion or through a clear secondary action.

### Buttons

#### Primary

- Background: `brand.primary`
- Text: white
- Height: 48px minimum
- Radius: 8px
- Padding: 16px horizontal
- Pressed: `brand.primaryPressed`
- Disabled: `surface.secondary` with `text.tertiary`

Use for:

- "I did this"
- "Choose my parish"
- "Save reminder"

#### Secondary

- Background: `surface.primary`
- Border: `border.subtle`
- Text: `text.primary`
- Height: 44px minimum
- Radius: 8px

Use for:

- "Add note"
- "View readings"
- "Change parish"

#### Quiet / Text Button

- Background: transparent
- Text: `text.link`
- No border

Use for low-risk navigation and inline actions.

### Cards

Use cards for individual information units only:

- Daily action
- Reading references
- Important Mass
- Weekly rhythm summary
- Parish row
- Prayer item

Do not nest cards inside cards.

Card styling:

- Radius: 8px
- Border: `1px solid #E2DDD1`
- Background: `surface.primary`
- Shadow: none by default
- Shadow only for bottom sheets/modals

### Inputs

Use native-feeling input fields:

- Background: `surface.primary`
- Border: `border.strong`
- Focus border: `brand.primary`
- Radius: 8px
- Height: 48px minimum
- Placeholder: `text.tertiary`

Search inputs should include a search icon and clear button.

### Chips & Badges

Use chips for compact state:

- Liturgical season
- Duration
- Reading type
- Mass time
- Offline
- Last verified

Styling:

- Radius: full pill
- Height: 28px
- Background: semantic soft color
- Text: 13px, weight 600
- Avoid more than 3 chips in one row on mobile.

### Calendar

Calendar is secondary to Today.

Month view:

- Clear day numbers
- Liturgical color dot or rail
- Sunday visually distinct
- Selected day uses brand outline/fill
- Feast days use small accent marker

Week view:

- Favor horizontal week strip
- Show daily action preview below
- Keep tap targets 44px minimum

Avoid turning the calendar into a dense reference table.

### Progress

Progress must feel private and gentle.

Use:

- Weekly rhythm row
- Completed action list
- Reflection notes
- Soft streak language

Do not use:

- Public ranking
- Red failure states for missed days
- Aggressive gamification
- Shame-based empty states

### Church / Parish Components

Parish rows should emphasize trust and freshness:

- Church name
- Diocese
- Next Mass time
- Last verified
- Distance only if location permission is granted

Mass time components:

- Time first
- Context second: Sunday, weekday, solemnity
- Note third

Stale data gets `status.warning`, not error styling.

### Widgets

Widget design must be simpler than in-app screens.

Small widget:

- Date or weekday
- Liturgical color marker
- Short action title

Medium widget:

- Date
- Celebration
- Action
- Gospel reference or Mass time

Large widget:

- Today context
- Action
- Reflection prompt
- Important Mass

Widget styling:

- Use high contrast.
- Avoid tiny paragraphs.
- Prefer one clear action.
- Use liturgical accent as a small signal.
- Dark seasonal widgets may use `surface.inverse`.

---

## 5. Layout Principles

### Spacing Scale

Use an 8px base grid:

| Token | Value |
|---|---:|
| `space.1` | 4 |
| `space.2` | 8 |
| `space.3` | 12 |
| `space.4` | 16 |
| `space.5` | 20 |
| `space.6` | 24 |
| `space.8` | 32 |
| `space.10` | 40 |
| `space.12` | 48 |

### Screen Padding

- Mobile horizontal padding: 16px
- Dense utility screens: 12px allowed
- Tablet max content width: 720px
- Desktop/web max content width: 960px

### Information Hierarchy

Today screen order:

1. Liturgical context
2. Daily action
3. Completion state
4. Reading references
5. Important Mass
6. Reflection note

If a screen cannot be understood in 10 seconds, reduce content.

### Density

Use compact, scannable cards. This is a daily utility app, not a marketing page.

Avoid:

- Oversized hero sections
- Decorative full-screen gradients
- Floating card stacks
- Large background illustrations
- Excess religious ornament

### Empty States

Empty states should create the next action:

- No parish: "Choose your parish for Mass reminders"
- No content pack: "Open once online to prepare this year’s calendar"
- No completed actions: "Start with one small action today"
- Offline: "Offline mode. Today’s data is saved on this device."

---

## 6. Depth & Elevation

Keep the UI mostly flat.

| Level | Treatment | Use |
|---|---|---|
| 0 | No shadow | Page background |
| 1 | 1px border | Cards, inputs, list rows |
| 2 | Very soft shadow | Bottom sheets, sticky bars |
| 3 | Modal shadow | Dialogs only |

Shadow values:

```txt
level2: 0 6px 18px rgba(31, 37, 34, 0.08)
level3: 0 16px 40px rgba(31, 37, 34, 0.16)
```

Do not use glow effects, bokeh, decorative orbs, or heavy glassmorphism.

---

## 7. Motion & Interaction

Motion should be subtle and respectful.

Use:

- 120-180ms button press transitions
- 180-240ms sheet transitions
- Gentle completion check animation
- Calendar selection transition
- Widget-free static surfaces

Avoid:

- Confetti for religious practice
- Over-celebrating streaks
- Constant pulsing
- Decorative animations on prayer screens

Completion feedback:

- Button changes to completed state
- Small check icon appears
- Optional note prompt slides in
- Weekly rhythm updates quietly

---

## 8. Accessibility & States

### Touch Targets

- Minimum: 44px
- Preferred primary button height: 48px
- Calendar day cells: 44px minimum on mobile

### Contrast

All text must meet WCAG AA:

- `text.primary` on `surface.canvas`
- White text on `brand.primary`
- `text.secondary` on white
- Liturgical color badges with appropriate text contrast

### Focus

Keyboard and switch-control focus:

- 2px `border.focus`
- 2px offset when possible
- Never rely only on color

### Offline States

Offline is a normal mode, not an error.

Use:

- Small offline chip
- Neutral copy
- Cached content

Do not block Today screen because network is unavailable.

### Error States

Use human, specific copy:

- "Calendar pack could not be imported."
- "Mass times may be outdated."
- "Widget data will refresh after opening the app."

Avoid generic "Something went wrong" unless there is no recoverable detail.

---

## 9. Responsive Behavior

### Breakpoints

| Name | Width | Behavior |
|---|---:|---|
| Small mobile | `<360` | Single column, compact cards, shorter labels |
| Mobile | `360-599` | Primary target |
| Tablet | `600-899` | Centered content, optional two-column sections |
| Large tablet/web | `900+` | Max-width layout, Today content can use side panel |

### Mobile Rules

- Primary actions stay above the fold when possible.
- Long feast names wrap to two lines.
- Bottom navigation labels remain visible unless space is extremely tight.
- Avoid horizontal scrolling except week calendar strips.

### Tablet/Web Rules

Use a two-column Today layout:

- Left: daily action and completion
- Right: readings, Mass, rhythm

Do not turn the app into a desktop dashboard unless the platform actually needs it.

---

## 10. Screen-Specific Guidance

### Today Screen

User outcome: know today’s context and complete one act.

Required sections:

- Date and liturgical context
- One daily action
- Completion button
- Reading references
- Important Mass
- Optional note

Design priority:

- Daily action card is visually dominant.
- Reading references are supportive.
- Mass is planning-oriented.
- Notes are private and quiet.

### Calendar Screen

User outcome: see what is coming and prepare.

Required sections:

- Week strip or month view
- Liturgical color markers
- Upcoming solemnities/Sundays
- Action preview for selected day

Design priority:

- Scannable before comprehensive.
- The selected day should feel connected to Today/action.

### Pray Screen

User outcome: access a small useful prayer library.

Required sections:

- Daily prayer
- Rosary
- Confession preparation
- Common prayers
- Saved prayers

Design priority:

- Calm reading experience
- Large enough text
- Minimal controls while reading

### Church Screen

User outcome: know my parish and next important Mass.

Required sections:

- My parish
- Next Mass
- Search
- Mass schedule
- Suggest correction

Design priority:

- Time and location clarity beat visual polish.
- Always show last verified when available.

### Progress Screen

User outcome: reflect on private rhythm.

Required sections:

- This week
- Completed actions
- Notes
- Review prompt

Design priority:

- Gentle trend, not judgment.
- Use green for completion, not morality.

---

## 11. Do's and Don'ts

### Do

- Make Today screen the product center.
- Use one clear daily action.
- Use liturgical colors as signals.
- Keep progress private and kind.
- Design offline states as first-class states.
- Prioritize readable Vietnamese text.
- Use icons for navigation and compact actions.
- Keep cards flat, bordered, and purposeful.
- Make widgets highly scannable.

### Don't

- Lead with a content library.
- Turn the app into a full Bible reader in MVP.
- Use public virtue scoring.
- Add decorative religious clutter.
- Use giant landing-page hero layouts inside the app.
- Use purple or gold as dominant app-wide themes.
- Hide stale parish/Mass data.
- Use shame copy for missed practice.
- Promise live widget updates.
- Use dynamic app icons for daily information.

---

## 12. Flutter Token Mapping

Use a small token layer in `lib/app/theme.dart`.

```dart
class AppColors {
  static const canvas = Color(0xFFFAF8F3);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSecondary = Color(0xFFF3F0E8);
  static const inverse = Color(0xFF18221E);

  static const textPrimary = Color(0xFF1F2522);
  static const textSecondary = Color(0xFF5F6761);
  static const textTertiary = Color(0xFF8A938D);

  static const brand = Color(0xFF1F7A64);
  static const brandPressed = Color(0xFF155744);
  static const brandSoft = Color(0xFFE2F1EA);

  static const gold = Color(0xFFB8892E);
  static const burgundy = Color(0xFF8F2F3D);
  static const marianBlue = Color(0xFF2F5F8F);

  static const borderSubtle = Color(0xFFE2DDD1);
  static const borderStrong = Color(0xFFCFC7B7);
}
```

Liturgical color helper:

```dart
Color liturgicalColor(String value) {
  switch (value) {
    case 'green':
      return const Color(0xFF2F7D4F);
    case 'white':
      return const Color(0xFFF7F3E8);
    case 'gold':
      return const Color(0xFFC69A3D);
    case 'red':
      return const Color(0xFFB33A3A);
    case 'purple':
      return const Color(0xFF6B4A7A);
    case 'rose':
      return const Color(0xFFC9788D);
    case 'black':
      return const Color(0xFF242424);
    default:
      return AppColors.brand;
  }
}
```

---

## 13. Agent Prompt Guide

When generating UI for this project, follow this shorthand:

> Build a calm, local-first Catholic daily practice UI. Warm off-white canvas `#FAF8F3`, white cards, ink text `#1F2522`, chapel green primary `#1F7A64`, restrained liturgical accents. Use flat 8px-radius cards with subtle borders. Make Today/action the visual center. Vietnamese text must wrap cleanly. No decorative clutter, no public scoring, no giant marketing hero.

### Quick Color Reference

- Canvas: `#FAF8F3`
- Card: `#FFFFFF`
- Secondary surface: `#F3F0E8`
- Text: `#1F2522`
- Secondary text: `#5F6761`
- Primary: `#1F7A64`
- Primary soft: `#E2F1EA`
- Gold accent: `#B8892E`
- Burgundy accent: `#8F2F3D`
- Border: `#E2DDD1`

### Example Component Prompt

> Create the Today screen for Sống Đạo. At top, show the date and liturgical context in a flat white card with a 4px liturgical color rail. Below it, create a dominant daily action card with title, duration chip, reflection prompt, and a 48px green "I did this" button. Add smaller cards for readings and next important Mass. Use warm canvas, white cards, 8px radius, subtle borders, Vietnamese-ready wrapping, and no decorative imagery.

### Iteration Rules

1. If a new screen does not advance daily action, private rhythm, parish planning, or prayer access, challenge the feature.
2. Keep UI density high enough for daily utility.
3. Liturgical colors should mark meaning, not dominate the palette.
4. Use local/offline states everywhere content appears.
5. Prefer native Flutter Material components lightly themed over custom visual systems.
6. Use simple shippable layouts first; polish after the MVP loop works.

Draft a Linear ticket for SongDao work, following the project's ticketing conventions.

**Usage:** `/linear-ticket <description of the work>`

Example: `/linear-ticket Build the completion logging flow for the Today screen`

## What to do

1. Identify which milestone the work belongs to:
   - M1: Product/legal foundation
   - M2: Local-first core (Drift DB, seed, Today screen, action engine)
   - M3: Widget + notifications (WidgetKit, App Group, deep links)
   - M4: Parish / Mass MVP (church tables, parish selector, Mass times)
   - M5: Polish beta (progress, prayer, settings, onboarding, TestFlight)

2. Ask: does this advance **Today → completion → widget snapshot**? If not, flag it as lower priority.

3. Break the work into 1–3 day shippable pieces. Draft one ticket per piece.

4. Write each ticket in this format:

---
**Title:** `[DAN] <imperative verb> <surface or component>`

**User outcome:**
<One sentence: what the user can do after this ships>

**What to build:**
- <Step 1>
- <Step 2>

**Acceptance criteria:**
- [ ] <Specific, testable condition>
- [ ] <Another condition>

**Milestone:** M<N> — <name>

**Labels:** `flutter` | `local-first` | `widget` | `content` | `ios` | `ux` as appropriate
---

5. Do not create tickets for: full Bible reader, social features, AI priest/confessor, public scoring, payment, account system.

The argument provided by the user is: $ARGUMENTS

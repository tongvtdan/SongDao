Validate a SongDao content pack JSON file against the project's schema and legal content policy.

**Usage:** `/validate-pack <path_to_pack_file>`

Example: `/validate-pack content/packs/songdao-pack-calendar-vn-demo-2026-0.1.0.json`

## What to do

1. Read `schemas/content_pack.schema.json` — this is the authoritative schema.
2. Read the target pack file.
3. Validate:

**Required metadata fields (must all be present):**
- `pack_id` — string, matches naming convention `<type>-<locale>-<year>`
- `version` — semver string
- `locale` — `vi` for Vietnamese packs
- `created_at` — ISO 8601 datetime
- `source_summary` — non-empty string
- `license_summary` — non-empty string
- `checksum` — SHA-256 hex of the canonical `records` array

**Legal policy checks:**
- Reading records must be citation-only (`Ga 3,1-8`) — flag any full Bible/lectionary text
- Prayer bodies require `source` and `license_summary` — flag if missing
- Parish/Mass records require `source` and `verified_at` — flag if missing
- If `license_summary` is empty or `"unknown"` — block the pack

**Record structure checks:**
- Calendar day records: `date`, `season`, `color`, `cycle_year`, `locale`, `source`
- Celebration records: `date`, `title`, `rank`, `is_solemnity`, `is_sunday`, `locale`
- Action rule records: `priority`, `rule_json`, `action_template_json`, `locale`, `enabled`

4. Verify the checksum if possible (SHA-256 of `records` array as canonical JSON).

5. Output: **VALID** or **INVALID** with a list of specific issues and the field/record that caused each one.

The argument provided by the user is: $ARGUMENTS

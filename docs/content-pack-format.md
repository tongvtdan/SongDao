# Local Seed Content Pack Format

Status: beta schema v0.1 locked on 2026-04-27  
Linear: DAN-115

Implementation artifacts:

- Schema: `schemas/content_pack.schema.json`
- Demo pack: `content/packs/songdao-pack-calendar-vn-demo-2026-0.1.0.json`

## Insight

The content pack is the bridge between product decisions and the local-first app. It should be boring, inspectable JSON for beta, imported transactionally into Drift, and strict enough to prevent unlicensed content from sneaking into the app.

## Decision

Use signed JSON packs for beta. SQLite packs can come later if import time or size becomes a problem. The Flutter importer should validate each beta pack against `schemas/content_pack.schema.json` before writing to Drift.

Pack file naming:

```text
songdao-pack-{pack_id}-{version}.json
```

Example:

```text
songdao-pack-calendar-vn-2026-0.1.0.json
```

## Top-level Schema

```json
{
  "schema_version": "0.1",
  "pack_id": "calendar-vn-demo-2026",
  "version": "0.1.0",
  "locale": "vi",
  "created_at": "2026-04-27T00:00:00Z",
  "valid_from": "2026-04-27",
  "valid_to": "2026-05-10",
  "source_summary": "Demo Vietnamese liturgical metadata and reading references for beta development.",
  "license_summary": "Reading references only; no copyrighted full-text readings.",
  "checksum": "sha256:<hex>",
  "calendar_days": [],
  "celebrations": [],
  "readings": [],
  "action_rules": [],
  "prayers": [],
  "churches": [],
  "mass_times": []
}
```

## Shared Rules

- Dates use `YYYY-MM-DD`.
- Times use 24-hour local time: `HH:mm`.
- The checksum is calculated over canonical JSON with the `checksum` value temporarily set to an empty string.
- IDs are stable lowercase strings with hyphens or underscores.
- Locale is required wherever user-facing copy can vary.
- Source metadata is required for imported content.
- Unknown optional fields are ignored, but unknown required fields fail validation.
- Imports run inside one database transaction.
- The previous successful pack stays active until the new import fully succeeds.
- After import, regenerate daily actions and widget snapshots for the next 14 days.
- After import, refresh local notification schedules.

## Calendar Days

```json
{
  "id": "calendar-day-2026-04-27-vi",
  "date": "2026-04-27",
  "locale": "vi",
  "season": "easter",
  "liturgical_week": "Tuần II Phục Sinh",
  "liturgical_color": "white",
  "cycle_year": "A",
  "weekday": "monday",
  "is_sunday": false,
  "source": {
    "name": "SongDao demo calendar",
    "url": null,
    "license": "internal-demo",
    "retrieved_at": "2026-04-27"
  }
}
```

Required fields: `id`, `date`, `locale`, `season`, `liturgical_color`, `weekday`, `source`.

## Celebrations

```json
{
  "id": "celebration-2026-04-27-vi",
  "date": "2026-04-27",
  "locale": "vi",
  "title": "Thứ Hai tuần II Phục Sinh",
  "rank": "weekday",
  "is_solemnity": false,
  "is_holy_day": false,
  "is_sunday": false,
  "source": {
    "name": "SongDao demo calendar",
    "license": "internal-demo"
  }
}
```

Required fields: `id`, `date`, `locale`, `title`, `rank`, `source`.

## Readings

```json
{
  "id": "reading-2026-04-27-gospel-vi",
  "date": "2026-04-27",
  "locale": "vi",
  "type": "gospel",
  "citation": "Ga 3,1-8",
  "display_label": "Tin Mừng",
  "text": null,
  "source_url": "https://example.org/readings/2026-04-27",
  "license": "reference-only",
  "source": {
    "name": "Reference-only demo",
    "license": "reference-only"
  }
}
```

Required fields: `id`, `date`, `locale`, `type`, `citation`, `license`, `source`.

`text` must be `null` unless the license permits app redistribution and the source is recorded.

## Action Rules

```json
{
  "id": "easter_weekday_gospel_note_vi",
  "locale": "vi",
  "enabled": true,
  "priority": 50,
  "when": {
    "season": "easter",
    "weekday": null,
    "is_sunday": false,
    "is_solemnity": false,
    "is_holy_day": false
  },
  "action": {
    "type": "reflection",
    "title": "Viết một câu về Tin Mừng hôm nay",
    "short_title": "Một câu suy niệm",
    "duration_minutes": 5,
    "prompt": "Đọc câu Tin Mừng được gợi ý và viết lại một điều bạn muốn sống hôm nay.",
    "proof_type": "self_check"
  },
  "source": {
    "name": "SongDao core actions",
    "license": "internal"
  }
}
```

Required fields: `id`, `locale`, `enabled`, `priority`, `when`, `action`, `source`.

Priority order remains: holy day/solemnity, Sunday, liturgical season, parish event, default weekday.

## Prayers

```json
{
  "id": "kinh-lay-cha-vi",
  "locale": "vi",
  "title": "Kinh Lạy Cha",
  "body": null,
  "source_url": "https://example.org/prayers/kinh-lay-cha",
  "license": "pending-review",
  "tags": ["core", "daily"],
  "source": {
    "name": "Pending review",
    "license": "pending-review"
  }
}
```

Required fields: `id`, `locale`, `title`, `license`, `source`.

If licensing is unresolved, leave `body` as `null` and show an external link or omit from beta.

## Churches

```json
{
  "id": "giao-xu-demo-tan-dinh",
  "locale": "vi",
  "name": "Giáo xứ Demo Tân Định",
  "diocese": "Tổng Giáo phận Sài Gòn",
  "address": "Demo address, Quận 3, TP. Hồ Chí Minh",
  "latitude": null,
  "longitude": null,
  "phone": null,
  "website": null,
  "verified_at": "2026-04-27",
  "source": {
    "name": "SongDao beta seed",
    "license": "internal-demo"
  }
}
```

Required fields: `id`, `locale`, `name`, `diocese`, `address`, `verified_at`, `source`.

## Mass Times

```json
{
  "id": "mass-demo-tan-dinh-sunday-0730-vi",
  "church_id": "giao-xu-demo-tan-dinh",
  "weekday": "sunday",
  "context": "sunday",
  "time": "07:30",
  "language": "vi",
  "valid_from": "2026-04-27",
  "valid_to": null,
  "is_important_default": true,
  "source": {
    "name": "SongDao beta seed",
    "license": "internal-demo",
    "verified_at": "2026-04-27"
  }
}
```

Required fields: `id`, `church_id`, `weekday`, `context`, `time`, `language`, `valid_from`, `source`.

## Validation Checklist

Reject a pack when:

- `schema_version`, `pack_id`, `version`, `locale`, `created_at`, or `checksum` is missing.
- The checksum does not match the file payload.
- Any required field is missing.
- A reading has non-null `text` with `license: "reference-only"` or `license: "pending-review"`.
- A prayer has non-null `body` with unresolved license metadata.
- A Mass time references an unknown church.
- A celebration or reading references a date missing from `calendar_days`.

Warn but allow import when:

- A church has null coordinates.
- Mass time `valid_to` is null.
- Optional URLs are missing.
- A prayer body is null because licensing is pending.

## Drift Import Mapping

| Pack collection | Drift table |
|---|---|
| `calendar_days` | `calendar_days` |
| `celebrations` | `celebrations` |
| `readings` | `readings` |
| `action_rules` | `action_rules` |
| `prayers` | `prayers` |
| `churches` | `churches` |
| `mass_times` | `mass_times` |

Post-import jobs:

1. Generate or refresh `daily_actions` for today plus 14 days.
2. Refresh `widget_snapshots` for today plus 14 days.
3. Reschedule enabled local notifications.
4. Store the active pack manifest and checksum in local settings or a dedicated metadata table.

## Demo Pack

The checked-in demo pack is intentionally tiny. It exists to prove the contract and unblock the first importer test, not to represent final liturgical data.

Importer smoke test target:

1. Load `content/packs/songdao-pack-calendar-vn-demo-2026-0.1.0.json`.
2. Validate top-level structure against `schemas/content_pack.schema.json`.
3. Verify the checksum using canonical JSON with `checksum` temporarily empty.
4. Import inside one transaction.
5. Confirm one calendar day, one celebration, two reading references, one action rule, one prayer title, one church, and two Mass times are available locally.

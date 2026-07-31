#!/usr/bin/env python3
import hashlib
import json
import re
from collections import defaultdict
from datetime import date, datetime, timedelta
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ICS_PATH = Path("/tmp/songdao-2026-vi.ics")
OUT_PATH = ROOT / "content/packs/songdao-pack-calendar-vn-2026-0.2.0.json"
READING_CITATIONS_PATH = (
    ROOT / "content/sources/catholic-index-2026-reading-citations.json"
)

WEEKDAYS = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday",
]

COLOR_MAP = {
    "⚪": "white",
    "🟢": "green",
    "🟣": "purple",
    "🔴": "red",
    "🌹": "rose",
}

RANK_ORDER = {
    "solemnity": 0,
    "holy_day_of_obligation": 0,
    "sunday": 1,
    "feast": 2,
    "memorial": 3,
    "optional_memorial": 4,
    "weekday": 5,
}

BOOK_ABBREVIATIONS = {
    "Acts": "Cv",
    "Amos": "Am",
    "Baruch": "Br",
    "Colossians": "Cl",
    "Daniel": "Đn",
    "Deuteronomy": "Đnl",
    "Ecclesiastes": "Gv",
    "Ephesians": "Ep",
    "Exodus": "Xh",
    "Ezekiel": "Ed",
    "Galatians": "Gl",
    "Genesis": "St",
    "Habakkuk": "Kb",
    "Hebrews": "Hr",
    "Hosea": "Hs",
    "Isaiah": "Is",
    "James": "Gc",
    "Jeremiah": "Gr",
    "Job": "G",
    "Joel": "Ge",
    "John": "Ga",
    "Jonah": "Gn",
    "Jude": "Gđ",
    "Judges": "Tl",
    "Judith": "Gđt",
    "Lamentations": "Ac",
    "Leviticus": "Lv",
    "Luke": "Lc",
    "Malachi": "Ml",
    "Mark": "Mc",
    "Matthew": "Mt",
    "Micah": "Mk",
    "Nahum": "Nk",
    "Numbers": "Ds",
    "Phiippians": "Pl",
    "Philemon": "Plm",
    "Philippians": "Pl",
    "Phippians": "Pl",
    "Proverbs": "Cn",
    "Psalm": "Tv",
    "Revelation": "Kh",
    "Romans": "Rm",
    "Sirach": "Hc",
    "Song of Songs": "Dc",
    "Titus": "Tt",
    "Wisdom": "Kn",
    "Zechariah": "Dcr",
    "Zephaniah": "Xp",
    "1 Chronicles": "1 Sb",
    "1 Corinthians": "1 Cr",
    "1 John": "1 Ga",
    "1 Kings": "1 V",
    "1 Peter": "1 Pr",
    "1 Samuel": "1 Sm",
    "1 Thessalonians": "1 Tx",
    "1 Timothy": "1 Tm",
    "2 Chronicles": "2 Sb",
    "2 Corinthians": "2 Cr",
    "2 John": "2 Ga",
    "2 Kings": "2 V",
    "2 Peter": "2 Pr",
    "2 Samuel": "2 Sm",
    "2 Thessalonians": "2 Tx",
    "2 Timothy": "2 Tm",
    "3 John": "3 Ga",
}

REFLECTIONS = {
    "advent": (
        "Đợi Chúa trong một việc nhỏ",
        "Hôm nay, hãy chọn một khoảng lặng ngắn để dọn lòng và sống chậm lại trước mặt Chúa.",
    ),
    "christmas": (
        "Đón Chúa trong đời thường",
        "Hôm nay, hãy để một lời nói hiền hoặc một cử chỉ tử tế trở thành máng cỏ nhỏ cho Chúa hiện diện.",
    ),
    "lent": (
        "Trở về bằng một bước cụ thể",
        "Hôm nay, hãy bỏ bớt một điều không cần thiết và dùng khoảng trống đó để cầu nguyện thật lòng.",
    ),
    "easter": (
        "Sống như người đã được nâng dậy",
        "Hôm nay, hãy chọn một dấu chỉ hy vọng: tha thứ, bắt đầu lại, hoặc nâng đỡ một người đang mệt.",
    ),
    "ordinary": (
        "Trung tín trong điều nhỏ",
        "Hôm nay, hãy làm một việc bổn phận với lòng yêu mến, như một lời cầu nguyện âm thầm.",
    ),
}

ACTION_RULES = [
    {
        "id": "vn_solemnity_intention_2026_vi",
        "locale": "vi",
        "enabled": True,
        "priority": 10,
        "when": {"is_solemnity": True},
        "action": {
            "type": "solemnity",
            "title": "Mừng lễ trọng bằng một ý nguyện",
            "short_title": "Ý nguyện lễ trọng",
            "duration_minutes": 3,
            "prompt": "Dâng ngày hôm nay trong một ý nguyện rõ ràng và sống một cử chỉ vui mừng.",
            "proof_type": "self_check",
        },
        "source": {"name": "SongDao original actions", "license": "internal-original"},
    },
    {
        "id": "vn_sunday_mass_intention_2026_vi",
        "locale": "vi",
        "enabled": True,
        "priority": 20,
        "when": {"weekday": "sunday", "is_sunday": True},
        "action": {
            "type": "mass_preparation",
            "title": "Chuẩn bị một ý lễ",
            "short_title": "Ý lễ hôm nay",
            "duration_minutes": 3,
            "prompt": "Trước Thánh lễ hoặc giờ cầu nguyện, hãy chọn một người hay một việc để dâng lên Chúa.",
            "proof_type": "self_check",
        },
        "source": {"name": "SongDao original actions", "license": "internal-original"},
    },
    {
        "id": "vn_lent_friday_sacrifice_2026_vi",
        "locale": "vi",
        "enabled": True,
        "priority": 25,
        "when": {"season": "lent", "weekday": "friday", "is_sunday": False},
        "action": {
            "type": "sacrifice",
            "title": "Hy sinh Mùa Chay",
            "short_title": "Một hy sinh",
            "duration_minutes": 5,
            "prompt": "Chọn một hy sinh nhỏ hôm nay và cầu nguyện cho một người đang cần ơn nâng đỡ.",
            "proof_type": "self_check",
        },
        "source": {"name": "SongDao original actions", "license": "internal-original"},
    },
    {
        "id": "vn_friday_charity_2026_vi",
        "locale": "vi",
        "enabled": True,
        "priority": 35,
        "when": {"weekday": "friday", "is_sunday": False},
        "action": {
            "type": "sacrifice",
            "title": "Một việc bác ái thứ Sáu",
            "short_title": "Việc bác ái",
            "duration_minutes": 5,
            "prompt": "Dâng một hy sinh nhỏ hoặc làm một việc bác ái âm thầm trong ngày thứ Sáu.",
            "proof_type": "self_check",
        },
        "source": {"name": "SongDao original actions", "license": "internal-original"},
    },
    {
        "id": "vn_advent_waiting_2026_vi",
        "locale": "vi",
        "enabled": True,
        "priority": 45,
        "when": {"season": "advent", "is_sunday": False},
        "action": {
            "type": "reflection",
            "title": "Dọn lòng Mùa Vọng",
            "short_title": "Dọn lòng",
            "duration_minutes": 5,
            "prompt": "Dành năm phút thinh lặng và hỏi: hôm nay tôi cần dọn chỗ nào để Chúa đến?",
            "proof_type": "note_optional",
        },
        "source": {"name": "SongDao original actions", "license": "internal-original"},
    },
    {
        "id": "vn_easter_witness_2026_vi",
        "locale": "vi",
        "enabled": True,
        "priority": 50,
        "when": {"season": "easter", "is_sunday": False},
        "action": {
            "type": "reflection",
            "title": "Sống niềm vui Phục Sinh",
            "short_title": "Niềm vui",
            "duration_minutes": 5,
            "prompt": "Viết một câu về điều hôm nay làm bạn hy vọng, rồi sống câu đó bằng một việc nhỏ.",
            "proof_type": "note_optional",
        },
        "source": {"name": "SongDao original actions", "license": "internal-original"},
    },
    {
        "id": "vn_default_weekday_2026_vi",
        "locale": "vi",
        "enabled": True,
        "priority": 100,
        "when": {"is_sunday": False, "is_solemnity": False},
        "action": {
            "type": "prayer",
            "title": "Một phút dâng ngày",
            "short_title": "Dâng ngày",
            "duration_minutes": 1,
            "prompt": "Dành một phút thinh lặng và dâng công việc hôm nay cho Chúa.",
            "proof_type": "self_check",
        },
        "source": {"name": "SongDao original actions", "license": "internal-original"},
    },
]

PRAYERS = [
    {
        "id": "loi_nguyen_song_dao_sang_2026_vi",
        "locale": "vi",
        "title": "Lời nguyện dâng ngày",
        "body": "Lạy Chúa, xin nhận lấy ngày hôm nay của con. Xin dạy con sống trung tín trong điều nhỏ và yêu thương trong từng việc con làm.",
        "source_url": None,
        "license": "internal-original",
        "tags": ["core", "morning", "daily"],
        "source": {"name": "SongDao original prayers", "license": "internal-original"},
    },
    {
        "id": "loi_nguyen_xet_minh_toi_2026_vi",
        "locale": "vi",
        "title": "Lời nguyện xét mình cuối ngày",
        "body": "Lạy Chúa, xin cho con nhìn lại ngày sống trong bình an: điều gì cần tạ ơn, điều gì cần xin lỗi, và điều gì cần bắt đầu lại ngày mai.",
        "source_url": None,
        "license": "internal-original",
        "tags": ["core", "evening", "reflection"],
        "source": {"name": "SongDao original prayers", "license": "internal-original"},
    },
]


def unfold_ics(text):
    lines = text.splitlines()
    unfolded = []
    for line in lines:
        if line.startswith((" ", "\t")) and unfolded:
            unfolded[-1] += line[1:]
        else:
            unfolded.append(line)
    return unfolded


def parse_events():
    text = ICS_PATH.read_text(encoding="utf-8")
    events = []
    current = None
    for line in unfold_ics(text):
        if line == "BEGIN:VEVENT":
            current = {}
        elif line == "END:VEVENT":
            events.append(current)
            current = None
        elif current is not None and ":" in line:
            key, value = line.split(":", 1)
            current[key.split(";", 1)[0]] = value.replace("\\,", ",").replace("\\n", "\n")
    return events


def date_key(day):
    return day.isoformat()


def clean_summary(summary):
    text = re.sub(r"^[^\w\[]+\s*", "", summary).strip()
    text = re.sub(r"^\[[^\]]+\]\s*", "", text).strip()
    return text


def rank_for(summary, day):
    if "[T]" in summary:
        return "solemnity"
    if "[K]" in summary:
        return "feast"
    if "[N]" in summary:
        return "memorial"
    if "[n" in summary:
        return "optional_memorial"
    if day.weekday() == 6:
        return "sunday"
    return "weekday"


def color_for(summary):
    for emoji, color in COLOR_MAP.items():
        if emoji in summary:
            return color
    return "green"


def season_for(day):
    if day <= date(2026, 1, 11):
        return "christmas"
    if day <= date(2026, 2, 17):
        return "ordinary"
    if day <= date(2026, 4, 4):
        return "lent"
    if day <= date(2026, 5, 24):
        return "easter"
    if day <= date(2026, 11, 28):
        return "ordinary"
    if day <= date(2026, 12, 24):
        return "advent"
    return "christmas"


def liturgical_week_for(day, title, season):
    match = re.search(r"tuần thứ ([^\s]+(?: [^\s]+)?)", title, flags=re.IGNORECASE)
    if match:
        return f"Tuần {match.group(1)}"
    if season == "christmas":
        return "Tuần Giáng Sinh"
    if season == "advent":
        return "Tuần Mùa Vọng"
    if season == "lent":
        return "Tuần Mùa Chay"
    if season == "easter":
        return "Tuần Phục Sinh"
    return "Tuần Thường Niên"


def lunar_label(day):
    # Month starts for the Vietnamese lunar year around 2026, enough for display.
    starts = [
        (date(2025, 12, 20), 11, "Ất Tỵ"),
        (date(2026, 1, 19), 12, "Ất Tỵ"),
        (date(2026, 2, 17), 1, "Bính Ngọ"),
        (date(2026, 3, 19), 2, "Bính Ngọ"),
        (date(2026, 4, 17), 3, "Bính Ngọ"),
        (date(2026, 5, 17), 4, "Bính Ngọ"),
        (date(2026, 6, 15), 5, "Bính Ngọ"),
        (date(2026, 7, 14), 6, "Bính Ngọ"),
        (date(2026, 8, 13), 7, "Bính Ngọ"),
        (date(2026, 9, 11), 8, "Bính Ngọ"),
        (date(2026, 10, 11), 9, "Bính Ngọ"),
        (date(2026, 11, 9), 10, "Bính Ngọ"),
        (date(2026, 12, 9), 11, "Bính Ngọ"),
    ]
    current = starts[0]
    for start in starts:
        if start[0] <= day:
            current = start
        else:
            break
    lunar_day = (day - current[0]).days + 1
    return f"{lunar_day} tháng {current[1]}, {current[2]}"


def source_url(day):
    return f"https://gcatholic.org/calendar/2026/VN-D-vi#{day.strftime('%m%d')}"


def usccb_url(day):
    return f"https://bible.usccb.org/bible/readings/{day.strftime('%m%d%y')}.cfm"


def load_reading_citation_source():
    if not READING_CITATIONS_PATH.exists():
        return {}
    return json.loads(READING_CITATIONS_PATH.read_text(encoding="utf-8"))


def normalize_source_text(text):
    return (
        text.replace("Â\xa0", " ")
        .replace("â\x80\x94", "-")
        .replace("â\x80\x93", "-")
        .replace("Ã¦", "ae")
        .strip()
    )


def reading_type_for(name, order):
    normalized = normalize_source_text(name).lower()
    if "gospel" in normalized and "before" not in normalized:
        return "gospel"
    if "psalm" in normalized or normalized == "responsorial":
        return "psalm"
    if "alleluia" in normalized or "verse before the gospel" in normalized:
        return "gospel_acclamation"
    if "reading 2" in normalized or "reading ii" in normalized:
        return "second_reading"
    if order == 1 or "reading 1" in normalized or "reading i" in normalized:
        return "first_reading"
    return "reading"


def reading_label_for(reading_type, name):
    normalized = normalize_source_text(name).lower()
    if normalized in {"or", "or:", "or at afternoon or evening mass", "or"}:
        return "Hoặc"
    return {
        "first_reading": "Bài đọc I",
        "second_reading": "Bài đọc II",
        "psalm": "Đáp ca",
        "gospel_acclamation": "Tung hô Tin Mừng",
        "gospel": "Tin Mừng",
    }.get(reading_type, "Bài đọc")


def translate_citation(citation):
    text = normalize_source_text(citation)
    if not text:
        return ""
    text = re.sub(r"\s+and\s+", " và ", text)
    text = re.sub(r"\s+or\s+", " hoặc ", text)
    for book in sorted(BOOK_ABBREVIATIONS, key=len, reverse=True):
        text = re.sub(
            rf"\bSee {re.escape(book)}(?=\s+\d)",
            f"x. {BOOK_ABBREVIATIONS[book]}",
            text,
        )
        text = re.sub(
            rf"\b{re.escape(book)}(?=\s+\d)",
            BOOK_ABBREVIATIONS[book],
            text,
        )
    text = re.sub(r"(\d):(\d)", r"\1,\2", text)
    text = re.sub(r"(?<=\d),\s+(?=\d)", ".", text)
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def reading_citations(day, title, citation_source):
    source_rows = citation_source.get(date_key(day), [])
    readings = []
    for index, source_row in enumerate(source_rows, start=1):
        citation = translate_citation(source_row.get("citation", ""))
        if not citation:
            continue
        reading_type = reading_type_for(
            source_row.get("name", ""),
            int(source_row.get("order", index)),
        )
        readings.append(
            {
                "id": f"reading_{day.strftime('%Y_%m_%d')}_{index}_{reading_type}_vi",
                "date": date_key(day),
                "locale": "vi",
                "type": reading_type,
                "citation": citation,
                "display_label": reading_label_for(
                    reading_type,
                    source_row.get("name", ""),
                ),
                "text": None,
                "source_url": source_row.get("citation_url") or usccb_url(day),
                "license": "reference-only",
                "source": {
                    "name": "Catholic Index daily readings citation reference",
                    "url": f"https://catholicindex.org/daily-readings/{date_key(day)}",
                    "license": "reference-only",
                    "retrieved_at": "2026-05-19",
                },
            }
        )
    if readings:
        return readings

    label = "Lịch bài đọc phụng vụ trong ngày"
    if day.weekday() == 6:
        label = "Bài đọc Chúa Nhật và lễ trọng trong ngày"
    return [
        {
            "id": f"reading_{day.strftime('%Y_%m_%d')}_reference_vi",
            "date": date_key(day),
            "locale": "vi",
            "type": "gospel",
            "citation": label,
            "display_label": "Bài đọc",
            "text": None,
            "source_url": usccb_url(day),
            "license": "reference-only",
            "source": {
                "name": "Reference-only daily readings link",
                "url": usccb_url(day),
                "license": "reference-only",
                "retrieved_at": "2026-05-14",
            },
        }
    ]


def reflection_for(day, season, celebration_title):
    title, body = REFLECTIONS[season]
    if "Thánh" in celebration_title or "Đức Mẹ" in celebration_title:
        title = "Học một nét thánh thiện"
        body = "Hôm nay, hãy chọn một nhân đức nhỏ từ ngày lễ này và sống nó trong một cuộc gặp gỡ cụ thể."
    if day.weekday() == 6:
        title = "Chuẩn bị lòng cho Chúa Nhật"
        body = "Hôm nay, hãy mang một ý nguyện rõ ràng vào Thánh lễ hoặc giờ cầu nguyện của bạn."
    return {
        "id": f"reflection_{day.strftime('%Y_%m_%d')}_vi",
        "date": date_key(day),
        "locale": "vi",
        "title": title,
        "body": body,
        "source_url": None,
        "license": "internal-original",
        "source": {"name": "SongDao original daily reflections", "license": "internal-original"},
    }


def canonical_json(value):
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"), sort_keys=True)


def main():
    citation_source = load_reading_citation_source()
    by_date = defaultdict(list)
    for event in parse_events():
        raw = event.get("DTSTART")
        summary = event.get("SUMMARY", "")
        if not raw or not raw.startswith("2026"):
            continue
        day = datetime.strptime(raw, "%Y%m%d").date()
        by_date[day].append(
            {
                "summary": summary,
                "title": clean_summary(summary),
                "rank": rank_for(summary, day),
                "color": color_for(summary),
            }
        )

    calendar_days = []
    celebrations = []
    readings = []
    reflections = []
    day = date(2026, 1, 1)
    while day <= date(2026, 12, 31):
        events = by_date.get(day, [])
        if not events:
            title = "Chưa có tên lễ trong nguồn lịch"
            events = [{"summary": title, "title": title, "rank": "weekday", "color": "green"}]
        events.sort(key=lambda item: RANK_ORDER[item["rank"]])
        primary = events[0]
        season = season_for(day)
        calendar_days.append(
            {
                "id": f"calendar_day_{day.strftime('%Y_%m_%d')}_vi",
                "date": date_key(day),
                "locale": "vi",
                "season": season,
                "liturgical_week": liturgical_week_for(day, primary["title"], season),
                "liturgical_color": primary["color"],
                "cycle_year": "A",
                "lunar_date": lunar_label(day),
                "weekday": WEEKDAYS[day.weekday()],
                "is_sunday": day.weekday() == 6,
                "source": {
                    "name": "GCatholic Vietnam liturgical calendar 2026",
                    "url": source_url(day),
                    "license": "reference-derived",
                    "retrieved_at": "2026-05-14",
                },
            }
        )
        for index, event in enumerate(events, start=1):
            celebrations.append(
                {
                    "id": f"celebration_{day.strftime('%Y_%m_%d')}_{index}_vi",
                    "date": date_key(day),
                    "locale": "vi",
                    "title": event["title"],
                    "rank": event["rank"],
                    "is_solemnity": event["rank"] == "solemnity",
                    "is_holy_day": event["rank"] == "holy_day_of_obligation",
                    "is_sunday": day.weekday() == 6,
                    "source": {
                        "name": "GCatholic Vietnam liturgical calendar 2026",
                        "url": source_url(day),
                        "license": "reference-derived",
                        "retrieved_at": "2026-05-14",
                    },
                }
            )
        readings.extend(reading_citations(day, primary["title"], citation_source))
        reflections.append(reflection_for(day, season, primary["title"]))
        day += timedelta(days=1)

    pack = {
        "schema_version": "0.2",
        "pack_id": "calendar-vn-2026",
        "version": "0.2.0",
        "locale": "vi",
        "created_at": "2026-05-14T00:00:00Z",
        "valid_from": "2026-01-01",
        "valid_to": "2026-12-31",
        "source_summary": "Vietnam-first Catholic liturgical calendar references for 2026, derived from GCatholic Vietnam calendar with SongDao-original daily reflections.",
        "license_summary": "Calendar metadata and reading links are reference-derived; reading text is not included. Daily reflections and prayers are SongDao-original.",
        "checksum": "",
        "calendar_days": calendar_days,
        "celebrations": celebrations,
        "readings": readings,
        "daily_reflections": reflections,
        "action_rules": ACTION_RULES,
        "prayers": PRAYERS,
        "churches": [],
        "mass_times": [],
    }
    pack["checksum"] = "sha256:" + hashlib.sha256(canonical_json(pack).encode("utf-8")).hexdigest()
    OUT_PATH.write_text(json.dumps(pack, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {OUT_PATH}")
    print(f"days={len(calendar_days)} celebrations={len(celebrations)} readings={len(readings)} reflections={len(reflections)}")


if __name__ == "__main__":
    main()

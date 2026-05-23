import {
  ActionRule,
  CalendarDay,
  Celebration,
  DailyReflection,
  Prayer,
  Reading,
} from "./types";

import calendarDemoPack from "../content/packs/songdao-pack-calendar-vn-demo-2026-0.1.0.json";
import calendarFullPack from "../content/packs/songdao-pack-calendar-vn-2026-0.2.0.json";
import calendarPostDemoPack from "../content/packs/songdao-pack-calendar-vn-post-demo-2026-0.1.0.json";

type Maybe<T> = T | null | undefined;

interface PackJson {
  schema_version?: string;
  pack_id?: string;
  version?: string;
  locale?: string;
  calendar_days?: Array<{
    id: string;
    date: string;
    locale?: string;
    season?: string;
    liturgical_week?: string | number;
    liturgical_color?: string;
    color?: string;
    cycle_year?: string;
    lunar_date?: string;
    weekday?: string;
    is_sunday?: boolean;
  }>;
  celebrations?: Array<{
    id: string;
    date: string;
    locale?: string;
    title?: string;
    name?: string;
    rank?: string;
    is_solemnity?: boolean;
    is_holy_day?: boolean;
    is_sunday?: boolean;
  }>;
  readings?: Array<{
    id: string;
    date: string;
    locale?: string;
    type?: string;
    citation?: string;
    display_label?: string;
    text?: Maybe<string>;
    source_url?: Maybe<string>;
    license?: string;
  }>;
  action_rules?: Array<{
    id: string;
    locale?: string | null;
    enabled?: boolean;
    priority?: number;
    type?: string;
    when?: Partial<ActionRule["when"]>;
    action?: Partial<ActionRule["action"]>;
  }>;
  prayers?: Array<{
    id: string;
    locale?: string;
    title?: string;
    body?: Maybe<string>;
    source_url?: Maybe<string>;
    license?: string;
    tags?: string[];
  }>;
  daily_reflections?: Array<{
    id: string;
    date: string;
    locale?: string;
    title?: string;
    body?: string;
    source_url?: Maybe<string>;
    license?: string;
  }>;
}

class ContentPackLoader {
  private calendarDaysMap = new Map<string, CalendarDay>();
  private celebrationsMap = new Map<string, Celebration[]>();
  private readingsMap = new Map<string, Reading[]>();
  private reflectionsMap = new Map<string, DailyReflection>();
  private prayersMap = new Map<string, Prayer>();
  private actionRules: ActionRule[] = [];

  constructor() {
    this.loadPack(calendarFullPack as PackJson);
    this.loadPack(calendarDemoPack as PackJson);
    this.loadPack(calendarPostDemoPack as PackJson);
  }

  private loadPack(pack: PackJson) {
    const locale = pack.locale || "vi";

    for (const day of pack.calendar_days || []) {
      const liturgicalWeek = day.liturgical_week ?? "";
      this.calendarDaysMap.set(day.date, {
        id: day.id,
        date: day.date,
        locale: day.locale || locale,
        season: day.season || "unknown",
        liturgicalWeek: String(liturgicalWeek),
        liturgicalColor: day.liturgical_color || day.color || "green",
        cycleYear: day.cycle_year || "",
        lunarDate: day.lunar_date || undefined,
        weekday: day.weekday || "monday",
        isSunday: day.is_sunday || day.weekday === "sunday",
      });
    }

    for (const celebration of pack.celebrations || []) {
      const list = this.celebrationsMap.get(celebration.date) || [];
      if (list.some((item) => item.id === celebration.id)) continue;
      const title = celebration.title || celebration.name || "Ngày phụng vụ";
      const rank = celebration.rank || "weekday";
      list.push({
        id: celebration.id,
        date: celebration.date,
        locale: celebration.locale || locale,
        title,
        rank,
        isSolemnity: celebration.is_solemnity || rank === "solemnity",
        isHolyDay:
          celebration.is_holy_day ||
          rank === "holy_day" ||
          rank === "holy_day_of_obligation",
        isSunday: celebration.is_sunday || rank === "sunday",
      });
      list.sort((a, b) => rankOrder(a.rank) - rankOrder(b.rank));
      this.celebrationsMap.set(celebration.date, list);
    }

    for (const reading of pack.readings || []) {
      const list = this.readingsMap.get(reading.date) || [];
      if (list.some((item) => item.id === reading.id)) continue;
      list.push({
        id: reading.id,
        date: reading.date,
        locale: reading.locale || locale,
        type: reading.type || "reading",
        citation: reading.citation || "",
        displayLabel: reading.display_label || undefined,
        textContent: reading.text || undefined,
        sourceUrl: reading.source_url || undefined,
        license: reading.license || "reference-only",
      });
      this.readingsMap.set(reading.date, list);
    }

    for (const reflection of pack.daily_reflections || []) {
      if (!reflection.body) continue;
      this.reflectionsMap.set(reflection.date, {
        id: reflection.id,
        date: reflection.date,
        locale: reflection.locale || locale,
        title: reflection.title || "Suy niệm trong ngày",
        body: reflection.body,
        sourceUrl: reflection.source_url || undefined,
        license: reflection.license || "internal-original",
      });
    }

    for (const prayer of pack.prayers || []) {
      if (this.prayersMap.has(prayer.id)) continue;
      this.prayersMap.set(prayer.id, {
        id: prayer.id,
        locale: prayer.locale || locale,
        title: prayer.title || "Kinh nguyện",
        body: prayer.body || undefined,
        sourceUrl: prayer.source_url || undefined,
        license: prayer.license || "reference-only",
        tags: Array.isArray(prayer.tags) ? prayer.tags : [],
      });
    }

    for (const rule of pack.action_rules || []) {
      if (this.actionRules.some((item) => item.id === rule.id)) continue;
      this.actionRules.push({
        id: rule.id,
        locale: rule.locale ?? locale,
        enabled: rule.enabled !== false,
        priority: rule.priority ?? 100,
        type: rule.action?.type || rule.type || "prayer",
        when: {
          season: rule.when?.season ?? null,
          weekday: rule.when?.weekday ?? null,
          is_sunday: rule.when?.is_sunday ?? null,
          is_solemnity: rule.when?.is_solemnity ?? null,
          is_holy_day: rule.when?.is_holy_day ?? null,
          is_feast: rule.when?.is_feast ?? null,
          has_parish_event: rule.when?.has_parish_event ?? null,
        },
        action: {
          type: rule.action?.type || rule.type || "prayer",
          title: rule.action?.title || "Hành động hôm nay",
          short_title: rule.action?.short_title || "Việc hôm nay",
          duration_minutes: rule.action?.duration_minutes ?? 5,
          prompt: rule.action?.prompt || "Dành một phút thinh lặng và dâng ngày này cho Chúa.",
          proof_type: rule.action?.proof_type || "self_check",
        },
      });
    }
    this.actionRules.sort((a, b) => a.priority - b.priority);
  }

  getCalendarDay(date: string): CalendarDay | null {
    return this.calendarDaysMap.get(date) || null;
  }

  getCalendarDaysInRange(startDate: string, endDate: string): CalendarDay[] {
    return [...this.calendarDaysMap.values()]
      .filter((day) => day.date >= startDate && day.date <= endDate)
      .sort((a, b) => a.date.localeCompare(b.date));
  }

  getCelebrations(date: string): Celebration[] {
    return this.celebrationsMap.get(date) || [];
  }

  getReadings(date: string): Reading[] {
    return this.readingsMap.get(date) || [];
  }

  getReflection(date: string): DailyReflection | null {
    return this.reflectionsMap.get(date) || null;
  }

  getActionRules(): ActionRule[] {
    return this.actionRules;
  }

  getPrayers(locale = "vi"): Prayer[] {
    return [...this.prayersMap.values()]
      .filter((prayer) => prayer.locale === locale)
      .sort((a, b) => a.title.localeCompare(b.title, "vi"));
  }
}

function rankOrder(rank: string): number {
  switch (rank) {
    case "solemnity":
    case "holy_day":
    case "holy_day_of_obligation":
      return 0;
    case "sunday":
      return 1;
    case "feast":
      return 2;
    case "memorial":
      return 3;
    case "optional_memorial":
      return 4;
    default:
      return 5;
  }
}

export const contentLoader = new ContentPackLoader();

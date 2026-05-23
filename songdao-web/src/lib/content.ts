import { 
  CalendarDay, 
  Celebration, 
  Reading, 
  ActionRule, 
  Church, 
  MassTime,
  DailyReflection
} from "./types";

// Import local content packs
import calendarDemoPack from "../content/packs/songdao-pack-calendar-vn-demo-2026-0.1.0.json";
import calendarFullPack from "../content/packs/songdao-pack-calendar-vn-2026-0.2.0.json";
import parishesPack from "../content/packs/songdao-pack-parishes-vn-beta-2026-0.1.0.json";

// Type assertions for JSON contents
interface PackJson {
  schema_version: string;
  pack_id: string;
  version: string;
  locale: string;
  calendar_days: Array<{
    id: string;
    date: string;
    locale?: string;
    season: string;
    liturgical_week?: string;
    liturgical_color?: string;
    cycle_year?: string;
    lunar_date?: string;
    weekday?: string;
    is_sunday?: boolean;
  }>;
  celebrations: Array<{
    id: string;
    date: string;
    locale?: string;
    title: string;
    rank?: string;
    is_solemnity?: boolean;
    is_holy_day?: boolean;
    is_sunday?: boolean;
  }>;
  readings: Array<{
    id: string;
    date: string;
    locale?: string;
    type: string;
    citation: string;
    display_label?: string;
    text?: string;
    source_url?: string;
    license?: string;
  }>;
  action_rules: Array<{
    id: string;
    locale?: string;
    enabled?: boolean;
    priority?: number;
    action?: {
      type?: string;
      title?: string;
      short_title?: string;
      duration_minutes?: number;
      prompt?: string;
      proof_type?: string;
    };
    when?: {
      season?: string | null;
      weekday?: string | null;
      is_sunday?: boolean | null;
      is_solemnity?: boolean | null;
      is_holy_day?: boolean | null;
      is_feast?: boolean | null;
      has_parish_event?: boolean | null;
    };
  }>;
  prayers: Array<{
    id: string;
    locale?: string;
    title: string;
    body?: string;
    source_url?: string;
    license: string;
  }>;
  churches: Array<{
    id: string;
    locale?: string;
    name: string;
    diocese?: string;
    address?: string;
    latitude?: number;
    longitude?: number;
    phone?: string;
    website?: string;
    verified_at?: string;
  }>;
  mass_times: Array<{
    id: string;
    church_id: string;
    weekday?: string;
    context?: string;
    time?: string;
    language?: string;
    valid_from?: string;
    valid_to?: string;
    is_important_default?: boolean;
  }>;
  daily_reflections?: Array<{
    id: string;
    date: string;
    locale?: string;
    title: string;
    body: string;
    source_url?: string;
    license?: string;
  }>;
}

const fullPack = calendarFullPack as unknown as PackJson;
const demoPack = calendarDemoPack as unknown as PackJson;
const parishes = parishesPack as unknown as PackJson;

// Index structures for fast lookup
class ContentPackLoader {
  private calendarDaysMap = new Map<string, CalendarDay>();
  private celebrationsMap = new Map<string, Celebration[]>();
  private readingsMap = new Map<string, Reading[]>();
  private reflectionsMap = new Map<string, DailyReflection>();
  private actionRules: ActionRule[] = [];
  private churches: Church[] = [];
  private massTimesMap = new Map<string, MassTime[]>();

  constructor() {
    this.loadPack(fullPack);
    this.loadPack(demoPack); // Overlay demo dates
    this.loadParishPack(parishes);
  }

  private loadPack(pack: PackJson) {
    const locale = pack.locale || "vi";

    // Calendar Days
    if (pack.calendar_days) {
      for (const d of pack.calendar_days) {
        this.calendarDaysMap.set(d.date, {
          id: d.id,
          date: d.date,
          locale: d.locale || locale,
          season: d.season,
          liturgicalWeek: d.liturgical_week || "",
          liturgicalColor: d.liturgical_color || "green",
          cycleYear: d.cycle_year || "",
          lunarDate: d.lunar_date,
          weekday: d.weekday || "monday",
          isSunday: d.is_sunday || false,
        });
      }
    }

    // Celebrations
    if (pack.celebrations) {
      for (const c of pack.celebrations) {
        const list = this.celebrationsMap.get(c.date) || [];
        // Prevent exact duplicates
        if (!list.some(x => x.id === c.id)) {
          list.push({
            id: c.id,
            date: c.date,
            locale: c.locale || locale,
            title: c.title,
            rank: c.rank || "weekday",
            isSolemnity: c.is_solemnity || false,
            isHolyDay: c.is_holy_day || false,
            isSunday: c.is_sunday || false,
          });
          this.celebrationsMap.set(c.date, list);
        }
      }
    }

    // Readings
    if (pack.readings) {
      for (const r of pack.readings) {
        const list = this.readingsMap.get(r.date) || [];
        if (!list.some(x => x.id === r.id)) {
          list.push({
            id: r.id,
            date: r.date,
            locale: r.locale || locale,
            type: r.type,
            citation: r.citation,
            displayLabel: r.display_label,
            textContent: r.text || undefined,
            sourceUrl: r.source_url || undefined,
            license: r.license || "reference-only",
          });
          this.readingsMap.set(r.date, list);
        }
      }
    }

    // Reflections
    if (pack.daily_reflections) {
      for (const rf of pack.daily_reflections) {
        this.reflectionsMap.set(rf.date, {
          id: rf.id,
          date: rf.date,
          locale: rf.locale || locale,
          title: rf.title,
          body: rf.body,
          sourceUrl: rf.source_url || undefined,
          license: rf.license || "reference-only",
        });
      }
    }

    // Action Rules
    if (pack.action_rules) {
      for (const ar of pack.action_rules) {
        if (!this.actionRules.some(x => x.id === ar.id)) {
          this.actionRules.push({
            id: ar.id,
            locale: ar.locale || locale,
            enabled: ar.enabled !== false,
            priority: ar.priority || 100,
            type: ar.action?.type || "prayer",
            when: {
              season: ar.when?.season || null,
              weekday: ar.when?.weekday || null,
              is_sunday: ar.when?.is_sunday !== undefined ? ar.when.is_sunday : null,
              is_solemnity: ar.when?.is_solemnity !== undefined ? ar.when.is_solemnity : null,
              is_holy_day: ar.when?.is_holy_day !== undefined ? ar.when.is_holy_day : null,
              is_feast: ar.when?.is_feast !== undefined ? ar.when.is_feast : null,
              has_parish_event: ar.when?.has_parish_event !== undefined ? ar.when.has_parish_event : null,
            },
            action: {
              type: ar.action?.type || "prayer",
              title: ar.action?.title || "",
              short_title: ar.action?.short_title || "",
              duration_minutes: ar.action?.duration_minutes || 5,
              prompt: ar.action?.prompt || "",
              proof_type: ar.action?.proof_type || "self_check",
            },
          });
        }
      }
    }
  }

  private loadParishPack(pack: PackJson) {
    const locale = pack.locale || "vi";

    // Churches
    if (pack.churches) {
      this.churches = pack.churches.map(ch => ({
        id: ch.id,
        locale: ch.locale || locale,
        name: ch.name,
        diocese: ch.diocese || "",
        address: ch.address || "",
        latitude: ch.latitude || undefined,
        longitude: ch.longitude || undefined,
        phone: ch.phone || undefined,
        website: ch.website || undefined,
        verifiedAt: ch.verified_at || undefined,
      }));
    }

    // Mass Times
    if (pack.mass_times) {
      for (const mt of pack.mass_times) {
        const list = this.massTimesMap.get(mt.church_id) || [];
        list.push({
          id: mt.id,
          churchId: mt.church_id,
          weekday: mt.weekday || "monday",
          context: mt.context || "ordinary",
          time: mt.time || "05:00",
          language: mt.language || "vi",
          validFrom: mt.valid_from || "2026-01-01",
          validTo: mt.valid_to || undefined,
          isImportantDefault: mt.is_important_default || false,
        });
        this.massTimesMap.set(mt.church_id, list);
      }
    }
  }

  public getCalendarDay(date: string): CalendarDay | null {
    return this.calendarDaysMap.get(date) || null;
  }

  public getCelebrations(date: string): Celebration[] {
    return this.celebrationsMap.get(date) || [];
  }

  public getReadings(date: string): Reading[] {
    return this.readingsMap.get(date) || [];
  }

  public getReflection(date: string): DailyReflection | null {
    return this.reflectionsMap.get(date) || null;
  }

  public getActionRules(): ActionRule[] {
    return this.actionRules;
  }

  public getChurches(): Church[] {
    return this.churches;
  }

  public getMassTimes(churchId: string): MassTime[] {
    return this.massTimesMap.get(churchId) || [];
  }
}

export const contentLoader = new ContentPackLoader();

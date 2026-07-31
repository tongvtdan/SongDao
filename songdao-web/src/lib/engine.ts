import { ActionRule, CalendarDay, Celebration, DailyAction, Reading } from "./types";

export const FALLBACK_SOURCE_RULE = "fallback_gentle_action";
export const FALLBACK_PROMPT =
  "Bắt đầu nhẹ nhàng hôm nay: dành một phút thinh lặng và dâng ngày này cho Chúa.";
export const FALLBACK_TYPE = "prayer";
export const FALLBACK_PRIORITY = 1000;
export const DEFAULT_LOCALE = "vi";
export const VN_TIME_ZONE = "Asia/Ho_Chi_Minh";

export function getDateKey(date: Date = new Date()): string {
  const formatter = new Intl.DateTimeFormat("en-CA", {
    timeZone: VN_TIME_ZONE,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  });
  return formatter.format(date);
}

export function createDateFromKey(dateKey: string): Date {
  const [year, month, day] = dateKey.split("-").map(Number);
  return new Date(year, month - 1, day);
}

export function addDays(dateKey: string, offset: number): string {
  const date = createDateFromKey(dateKey);
  date.setDate(date.getDate() + offset);
  return formatDateKey(date);
}

export function formatDateKey(date: Date): string {
  const year = String(date.getFullYear()).padStart(4, "0");
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

export function getWeekdayName(dateKey: string): string {
  const date = createDateFromKey(dateKey);
  return ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"][date.getDay()];
}

export function monthBounds(monthKey: string): { start: string; end: string } {
  const [year, month] = monthKey.split("-").map(Number);
  const start = new Date(year, month - 1, 1);
  const end = new Date(year, month, 0);
  return { start: formatDateKey(start), end: formatDateKey(end) };
}

export function readingOrder(type: string): number {
  switch (type) {
    case "first":
    case "first_reading":
      return 0;
    case "psalm":
      return 1;
    case "second":
    case "second_reading":
      return 2;
    case "alleluia":
    case "gospel_acclamation":
      return 3;
    case "gospel":
      return 4;
    default:
      return 5;
  }
}

export function sortReadings(readings: Reading[]): Reading[] {
  return [...readings].sort((a, b) => readingOrder(a.type) - readingOrder(b.type));
}

interface RuleContext {
  season: string;
  weekday: string;
  isSunday: boolean;
  isSolemnity: boolean;
  isFeast: boolean;
  isHolyDay: boolean;
  hasParishEvent: boolean;
}

function fieldMatches(expected: unknown, actual: unknown): boolean {
  return expected === undefined || expected === null || expected === actual;
}

function matches(rule: ActionRule, context: RuleContext): boolean {
  return (
    fieldMatches(rule.when.season, context.season) &&
    fieldMatches(rule.when.weekday, context.weekday) &&
    fieldMatches(rule.when.is_sunday, context.isSunday) &&
    fieldMatches(rule.when.is_solemnity, context.isSolemnity) &&
    fieldMatches(rule.when.is_holy_day, context.isHolyDay) &&
    fieldMatches(rule.when.is_feast, context.isFeast) &&
    fieldMatches(rule.when.has_parish_event, context.hasParishEvent)
  );
}

function ruleCategory(rule: ActionRule): number {
  const condition = rule.when;
  if (condition.is_solemnity === true || condition.is_holy_day === true) return 0;
  if (condition.is_sunday === true || condition.weekday === "sunday") return 1;
  if (condition.is_feast === true) return 2;
  if (condition.season !== null) return 3;
  if (condition.has_parish_event === true) return 4;
  if (condition.weekday !== null) return 5;
  return 6;
}

export function fallbackCalendarDay(dateKey: string, locale = DEFAULT_LOCALE): CalendarDay {
  const weekday = getWeekdayName(dateKey);
  return {
    id: `calendar_day_${dateKey}_${locale}`,
    date: dateKey,
    locale,
    season: "unknown",
    liturgicalWeek: "",
    liturgicalColor: "green",
    cycleYear: "",
    weekday,
    isSunday: weekday === "sunday",
  };
}

export function selectDailyAction(
  dateKey: string,
  calendarDay: CalendarDay | null,
  celebrations: Celebration[],
  rules: ActionRule[],
  locale = DEFAULT_LOCALE
): DailyAction {
  const weekday = calendarDay?.weekday || getWeekdayName(dateKey);
  const hasSeededCalendar = Boolean(calendarDay && calendarDay.season !== "unknown");

  if (!hasSeededCalendar) {
    return fallbackAction(dateKey, locale);
  }

  const context: RuleContext = {
    season: calendarDay?.season || "unknown",
    weekday,
    isSunday: weekday === "sunday" || calendarDay?.isSunday || false,
    isSolemnity: celebrations.some((item) => item.rank === "solemnity" || item.isSolemnity),
    isFeast: celebrations.some((item) => item.rank === "feast"),
    isHolyDay: celebrations.some(
      (item) => item.rank === "holy_day" || item.rank === "holy_day_of_obligation" || item.isHolyDay
    ),
    hasParishEvent: false,
  };

  const matchedRules = rules
    .filter((rule) => rule.enabled && (rule.locale === null || rule.locale === locale))
    .filter((rule) => matches(rule, context))
    .sort((a, b) => {
      const category = ruleCategory(a) - ruleCategory(b);
      return category === 0 ? a.priority - b.priority : category;
    });

  if (matchedRules.length === 0) {
    return fallbackAction(dateKey, locale);
  }

  const selected = matchedRules[0];
  return {
    id: actionId(dateKey, locale),
    date: dateKey,
    sourceRule: selected.id,
    prompt: selected.action.prompt,
    type: selected.action.type,
    priority: selected.priority,
    locale,
    durationMinutes: selected.action.duration_minutes,
    title: selected.action.title,
    shortTitle: selected.action.short_title,
    proofType: selected.action.proof_type,
  };
}

export function actionId(dateKey: string, locale = DEFAULT_LOCALE): string {
  return `daily_action_${dateKey}_${locale}`;
}

function fallbackAction(dateKey: string, locale: string): DailyAction {
  return {
    id: actionId(dateKey, locale),
    date: dateKey,
    sourceRule: FALLBACK_SOURCE_RULE,
    prompt: FALLBACK_PROMPT,
    type: FALLBACK_TYPE,
    priority: FALLBACK_PRIORITY,
    locale,
    durationMinutes: 5,
    title: "Bắt đầu nhẹ nhàng hôm nay",
    shortTitle: "Ý nguyện thinh lặng",
    proofType: "self_check",
  };
}

import { CalendarDay, Celebration, ActionRule, DailyAction } from "./types";

export const FALLBACK_SOURCE_RULE = "fallback_gentle_action";
export const FALLBACK_PROMPT =
  "Bắt đầu nhẹ nhàng hôm nay: dành một phút thinh lặng và dâng ngày này cho Chúa.";
export const FALLBACK_TYPE = "prayer";
export const FALLBACK_PRIORITY = 1000;

export function getDateKey(date: Date = new Date()): string {
  try {
    const formatter = new Intl.DateTimeFormat("en-CA", {
      timeZone: "Asia/Ho_Chi_Minh",
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    });
    return formatter.format(date);
  } catch {
    // Fallback if browser environment lacks timezone or throws
    const offsetDate = new Date(date.getTime() + 7 * 60 * 60 * 1000); // UTC+7 offset
    return offsetDate.toISOString().slice(0, 10);
  }
}

export function getWeekdayName(dateKey: string): string {
  const parsed = new Date(dateKey);
  const weekdayIndex = parsed.getDay(); // 0 is Sunday, 1 is Monday, etc.
  const weekdayMap = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"];
  return weekdayMap[weekdayIndex];
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
  if (expected === undefined || expected === null) {
    return true;
  }
  return expected === actual;
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

function getRuleCategory(rule: ActionRule): number {
  const cond = rule.when;
  if (cond.is_solemnity === true || cond.is_holy_day === true) {
    return 0;
  }
  if (cond.is_sunday === true || cond.weekday === "sunday") {
    return 1;
  }
  if (cond.is_feast === true) {
    return 2;
  }
  if (cond.season !== null) {
    return 3;
  }
  // (Parish events placeholder - 4)
  if (cond.weekday !== null) {
    return 5;
  }
  return 6;
}

export function selectDailyAction(
  dateKey: string,
  calendarDay: CalendarDay | null,
  celebrations: Celebration[],
  rules: ActionRule[]
): DailyAction {
  const weekday = getWeekdayName(dateKey);
  
  // Build evaluation context
  const context: RuleContext = {
    season: calendarDay?.season || "unknown",
    weekday,
    isSunday: weekday === "sunday" || calendarDay?.isSunday || false,
    isSolemnity: celebrations.some((c) => c.rank === "solemnity" || c.isSolemnity),
    isFeast: celebrations.some((c) => c.rank === "feast"),
    isHolyDay: celebrations.some((c) => c.rank === "holy_day" || c.rank === "holy_day_of_obligation" || c.isHolyDay),
    hasParishEvent: false,
  };

  // Find enabled rules matching this day's context
  const activeRules = rules.filter((r) => r.enabled);
  const matchedRules = activeRules.filter((r) => matches(r, context));

  if (matchedRules.length === 0) {
    return {
      id: `daily_action_${dateKey}_vi`,
      date: dateKey,
      sourceRule: FALLBACK_SOURCE_RULE,
      prompt: FALLBACK_PROMPT,
      type: FALLBACK_TYPE,
      priority: FALLBACK_PRIORITY,
      locale: "vi",
      durationMinutes: 5,
      title: "Bắt đầu nhẹ nhàng hôm nay",
      shortTitle: "Ý nguyện thinh lặng",
      proofType: "self_check",
    };
  }

  // Sort rules based on category precedence (0 is highest) and priority within categories (lowest priority number wins)
  matchedRules.sort((a, b) => {
    const catA = getRuleCategory(a);
    const catB = getThemeCategory(b);
    if (catA !== catB) {
      return catA - catB;
    }
    return a.priority - b.priority;
  });

  function getThemeCategory(r: ActionRule) {
    return getRuleCategory(r);
  }

  const selected = matchedRules[0];
  
  return {
    id: `daily_action_${dateKey}_vi`,
    date: dateKey,
    sourceRule: selected.id,
    prompt: selected.action.prompt,
    type: selected.action.type,
    priority: selected.priority,
    locale: "vi",
    durationMinutes: selected.action.duration_minutes,
    title: selected.action.title,
    shortTitle: selected.action.short_title,
    proofType: selected.action.proof_type,
  };
}

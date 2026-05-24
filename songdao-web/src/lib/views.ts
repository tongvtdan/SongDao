import { contentLoader } from "./content";
import {
  addDays,
  createDateFromKey,
  fallbackCalendarDay,
  formatDateKey,
  getDateKey,
  monthBounds,
  selectDailyAction,
  sortReadings,
} from "./engine";
import { getActionLog, getAllLogs, getShowLunarDate } from "./storage";
import {
  CalendarDayDetail,
  CalendarMonthViewData,
  DailyAction,
  JournalEntry,
  Prayer,
  ProgressViewData,
  TodayViewData,
} from "./types";

export function getTodayView(dateKey: string, includeClientState = true): TodayViewData {
  const locale = "vi";
  const calendarDay = contentLoader.getCalendarDay(dateKey) || fallbackCalendarDay(dateKey, locale);
  const celebrations = contentLoader.getCelebrations(dateKey);
  const readings = sortReadings(contentLoader.getReadings(dateKey));
  const action = selectDailyAction(dateKey, calendarDay, celebrations, contentLoader.getActionRules(), locale);
  return {
    date: dateKey,
    locale,
    showLunarDate: includeClientState ? getShowLunarDate() : true,
    calendarDay,
    celebrations,
    readings,
    action,
    log: includeClientState ? getActionLog(action.id) : null,
    reflection: contentLoader.getReflection(dateKey),
  };
}

export function getCalendarMonthView(monthKey: string, selectedDate: string, includeClientState = true): CalendarMonthViewData {
  const { start, end } = monthBounds(monthKey);
  const days = contentLoader.getCalendarDaysInRange(start, end);
  const detail = getCalendarDayDetail(selectedDate, includeClientState);
  return {
    ...detail,
    visibleMonth: monthKey,
    days: Object.fromEntries(days.map((day) => [day.date, day])),
  };
}

export function getCalendarDayDetail(dateKey: string, includeClientState = true): CalendarDayDetail {
  const locale = "vi";
  const calendarDay = contentLoader.getCalendarDay(dateKey);
  const celebrations = contentLoader.getCelebrations(dateKey);
  const readings = sortReadings(contentLoader.getReadings(dateKey));
  const action = calendarDay
    ? selectDailyAction(dateKey, calendarDay, celebrations, contentLoader.getActionRules(), locale)
    : null;
  return {
    date: dateKey,
    locale,
    showLunarDate: includeClientState ? getShowLunarDate() : true,
    calendarDay,
    celebrations,
    readings,
    action,
    reflection: contentLoader.getReflection(dateKey),
  };
}

export function getPrayerLibrary(): Prayer[] {
  return contentLoader.getPrayers("vi");
}

export function getProgressView(includeClientState = true): ProgressViewData {
  const logs = includeClientState ? getAllLogs() : [];
  const today = createDateFromKey(getDateKey());
  const monday = new Date(today);
  monday.setDate(today.getDate() - ((today.getDay() + 6) % 7));
  const weekKeys = Array.from({ length: 7 }, (_, index) => {
    const date = new Date(monday);
    date.setDate(monday.getDate() + index);
    return formatDateKey(date);
  });

  const completedLogs = logs
    .filter((log) => log.status === "completed")
    .map((log) => ({ log, action: actionForDate(log.date) }))
    .filter((item): item is { log: typeof item.log; action: DailyAction } => Boolean(item.action));

  return {
    weekKeys,
    weekCompleted: Object.fromEntries(
      weekKeys.map((key) => [key, completedLogs.some((item) => item.log.date === key)])
    ),
    recentLogs: completedLogs.slice(0, 8),
    completedLogs,
  };
}

export function getJournalEntries(query = "", includeClientState = true): JournalEntry[] {
  const normalizedQuery = query.trim().toLowerCase();
  return (includeClientState ? getAllLogs() : [])
    .filter((log) => Boolean(log.note?.trim()))
    .map((log) => ({ log, action: actionForDate(log.date), note: log.note?.trim() || "" }))
    .filter((entry): entry is JournalEntry => Boolean(entry.action && entry.note))
    .filter((entry) => {
      if (!normalizedQuery) return true;
      return `${entry.action.prompt} ${entry.note}`.toLowerCase().includes(normalizedQuery);
    });
}

export function nextDateKey(dateKey: string): string {
  return addDays(dateKey, 1);
}

export function previousDateKey(dateKey: string): string {
  return addDays(dateKey, -1);
}

function actionForDate(dateKey: string): DailyAction | null {
  const calendarDay = contentLoader.getCalendarDay(dateKey) || fallbackCalendarDay(dateKey);
  const celebrations = contentLoader.getCelebrations(dateKey);
  return selectDailyAction(dateKey, calendarDay, celebrations, contentLoader.getActionRules());
}

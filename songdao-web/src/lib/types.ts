export interface CalendarDay {
  id: string;
  date: string;
  locale: string;
  season: string;
  liturgicalWeek: string;
  liturgicalColor: string;
  cycleYear: string;
  lunarDate?: string;
  weekday: string;
  isSunday: boolean;
}

export interface Celebration {
  id: string;
  date: string;
  locale: string;
  title: string;
  rank: string;
  isSolemnity: boolean;
  isHolyDay: boolean;
  isSunday: boolean;
}

export interface Reading {
  id: string;
  date: string;
  locale: string;
  type: string;
  citation: string;
  displayLabel?: string;
  textContent?: string;
  sourceUrl?: string;
  license: string;
}

export interface DailyReflection {
  id: string;
  date: string;
  locale: string;
  title: string;
  body: string;
  sourceUrl?: string;
  license: string;
}

export interface Prayer {
  id: string;
  locale: string;
  title: string;
  body?: string;
  sourceUrl?: string;
  license: string;
  tags: string[];
}

export interface ActionRule {
  id: string;
  locale: string | null;
  enabled: boolean;
  priority: number;
  type: string;
  when: {
    season: string | null;
    weekday: string | null;
    is_sunday: boolean | null;
    is_solemnity: boolean | null;
    is_holy_day: boolean | null;
    is_feast: boolean | null;
    has_parish_event: boolean | null;
  };
  action: {
    type: string;
    title: string;
    short_title: string;
    duration_minutes: number;
    prompt: string;
    proof_type: string;
  };
}

export interface DailyAction {
  id: string;
  date: string;
  sourceRule: string;
  prompt: string;
  type: string;
  priority: number;
  locale: string;
  durationMinutes?: number;
  title?: string;
  shortTitle?: string;
  proofType?: string;
}

export type ActionLogStatus = "pending" | "completed" | "skipped";

export interface ActionLog {
  id: string;
  actionId: string;
  date: string;
  status: ActionLogStatus;
  completedAt?: string;
  note?: string;
  updatedAt: string;
}

export interface UserSettings {
  locale: string;
  showLunarDate: boolean;
  dailyReminderEnabled: boolean;
  dailyReminderHour: number;
  dailyReminderMinute: number;
}

export interface TodayViewData {
  date: string;
  locale: string;
  showLunarDate: boolean;
  calendarDay: CalendarDay;
  celebrations: Celebration[];
  readings: Reading[];
  action: DailyAction;
  log: ActionLog | null;
  reflection: DailyReflection | null;
}

export interface CalendarDayDetail {
  date: string;
  locale: string;
  showLunarDate: boolean;
  calendarDay: CalendarDay | null;
  celebrations: Celebration[];
  readings: Reading[];
  action: DailyAction | null;
  reflection: DailyReflection | null;
}

export interface CalendarMonthViewData extends CalendarDayDetail {
  visibleMonth: string;
  days: Record<string, CalendarDay>;
}

export interface CompletedLog {
  log: ActionLog;
  action: DailyAction;
}

export interface ProgressViewData {
  weekKeys: string[];
  weekCompleted: Record<string, boolean>;
  recentLogs: CompletedLog[];
  completedLogs: CompletedLog[];
}

export interface JournalEntry {
  log: ActionLog;
  action: DailyAction;
  note: string;
}

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

export interface ActionRule {
  id: string;
  locale: string;
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

export interface ActionLog {
  id: string;
  actionId: string;
  date: string;
  status: 'completed' | 'skipped';
  completedAt?: string;
  note?: string;
  updatedAt: string;
}

export interface Church {
  id: string;
  locale: string;
  name: string;
  diocese: string;
  address: string;
  latitude?: number;
  longitude?: number;
  phone?: string;
  website?: string;
  verifiedAt?: string;
}

export interface MassTime {
  id: string;
  churchId: string;
  weekday: string;
  context: string;
  time: string;
  language: string;
  validFrom: string;
  validTo?: string;
  isImportantDefault: boolean;
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

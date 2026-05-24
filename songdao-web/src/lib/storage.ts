import { ActionLog, UserSettings } from "./types";

const LOG_KEY_PREFIX = "sd_log_";
const SETTINGS_KEY = "sd_settings_v1";

export const DEFAULT_SETTINGS: UserSettings = {
  locale: "vi",
  showLunarDate: true,
  dailyReminderEnabled: false,
  dailyReminderHour: 7,
  dailyReminderMinute: 0,
};

function isClient(): boolean {
  return typeof window !== "undefined";
}

function logKey(actionId: string): string {
  return `${LOG_KEY_PREFIX}${actionId}`;
}

function parseLog(raw: string | null): ActionLog | null {
  if (!raw) return null;
  try {
    return JSON.parse(raw) as ActionLog;
  } catch {
    return null;
  }
}

export function getActionLog(actionId: string): ActionLog | null {
  if (!isClient()) return null;
  return parseLog(localStorage.getItem(logKey(actionId)));
}

export function markCompleted(actionId: string, date: string, note?: string): ActionLog {
  const existing = getActionLog(actionId);
  const now = new Date().toISOString();
  const normalizedNote = normalizeNote(note);
  const log: ActionLog = {
    id: `log_${actionId}`,
    actionId,
    date,
    status: "completed",
    completedAt: existing?.completedAt || now,
    note: normalizedNote === undefined ? existing?.note : normalizedNote,
    updatedAt: now,
  };
  saveLog(log);
  return log;
}

export function saveNote(actionId: string, date: string, note: string): ActionLog {
  const existing = getActionLog(actionId);
  const now = new Date().toISOString();
  const normalizedNote = normalizeNote(note);
  const log: ActionLog = {
    id: `log_${actionId}`,
    actionId,
    date,
    status: existing?.status || "pending",
    completedAt: existing?.completedAt,
    note: normalizedNote,
    updatedAt: now,
  };
  saveLog(log);
  return log;
}

export function clearNote(actionId: string, date: string): ActionLog {
  return saveNote(actionId, date, "");
}

export function deleteNote(actionId: string): void {
  if (!isClient()) return;
  const existing = getActionLog(actionId);
  if (!existing) return;
  if (existing.status === "completed") {
    const updated: ActionLog = {
      ...existing,
      note: undefined,
      updatedAt: new Date().toISOString(),
    };
    saveLog(updated);
    return;
  }
  localStorage.removeItem(logKey(actionId));
}

export function getAllLogs(): ActionLog[] {
  if (!isClient()) return [];
  const logs: ActionLog[] = [];
  for (let i = 0; i < localStorage.length; i += 1) {
    const key = localStorage.key(i);
    if (!key?.startsWith(LOG_KEY_PREFIX)) continue;
    const log = parseLog(localStorage.getItem(key));
    if (log) logs.push(log);
  }
  return logs.sort((a, b) => {
    const byDate = b.date.localeCompare(a.date);
    return byDate === 0 ? b.updatedAt.localeCompare(a.updatedAt) : byDate;
  });
}

export function getUserSettings(): UserSettings {
  if (!isClient()) return DEFAULT_SETTINGS;
  try {
    const raw = localStorage.getItem(SETTINGS_KEY);
    if (!raw) return DEFAULT_SETTINGS;
    return { ...DEFAULT_SETTINGS, ...JSON.parse(raw) };
  } catch {
    return DEFAULT_SETTINGS;
  }
}

export function saveUserSettings(settings: Partial<UserSettings>): UserSettings {
  const updated = { ...getUserSettings(), ...settings };
  if (isClient()) localStorage.setItem(SETTINGS_KEY, JSON.stringify(updated));
  return updated;
}

export function getShowLunarDate(): boolean {
  const settings = getUserSettings();
  return settings.locale === "vi" && settings.showLunarDate;
}

export function setShowLunarDate(value: boolean): UserSettings {
  return saveUserSettings({ showLunarDate: value });
}

function saveLog(log: ActionLog): void {
  if (!isClient()) return;
  localStorage.setItem(logKey(log.actionId), JSON.stringify(log));
}

function normalizeNote(note?: string): string | undefined {
  if (note === undefined) return undefined;
  const trimmed = note.trim();
  return trimmed.length === 0 ? undefined : trimmed;
}

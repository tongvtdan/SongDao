import { ActionLog } from "./types";

const LOG_KEY_PREFIX = "sd_log_";
const SETTINGS_KEY = "sd_settings_v1";

export interface UserSettings {
  locale: string;
  selectedChurchId: string | null;
  showLunarDate: boolean;
}

const DEFAULT_SETTINGS: UserSettings = {
  locale: "vi",
  selectedChurchId: null,
  showLunarDate: true,
};

function isClient(): boolean {
  return typeof window !== "undefined";
}

export function getActionLog(actionId: string): ActionLog | null {
  if (!isClient()) return null;
  try {
    const raw = localStorage.getItem(`${LOG_KEY_PREFIX}${actionId}`);
    if (!raw) return null;
    return JSON.parse(raw) as ActionLog;
  } catch (e) {
    console.error("Failed to load action log:", e);
    return null;
  }
}

export function markCompleted(actionId: string, date: string, note?: string): ActionLog {
  const existing = getActionLog(actionId);
  const now = new Date().toISOString();
  
  const log: ActionLog = {
    id: `log_${actionId}`,
    actionId,
    date,
    status: "completed",
    completedAt: existing?.completedAt || now,
    note: note !== undefined ? note.trim() : existing?.note,
    updatedAt: now,
  };
  
  if (isClient()) {
    try {
      localStorage.setItem(`${LOG_KEY_PREFIX}${actionId}`, JSON.stringify(log));
    } catch (e) {
      console.error("Failed to save action log:", e);
    }
  }
  return log;
}

export function saveNote(actionId: string, date: string, note: string): ActionLog {
  const existing = getActionLog(actionId);
  const now = new Date().toISOString();
  
  const log: ActionLog = {
    id: `log_${actionId}`,
    actionId,
    date,
    status: existing?.status || "completed", // If they write a note, we consider it completed
    completedAt: existing?.completedAt || now,
    note: note.trim(),
    updatedAt: now,
  };
  
  if (isClient()) {
    try {
      localStorage.setItem(`${LOG_KEY_PREFIX}${actionId}`, JSON.stringify(log));
    } catch (e) {
      console.error("Failed to save action log note:", e);
    }
  }
  return log;
}

export function getAllLogs(): ActionLog[] {
  if (!isClient()) return [];
  const logs: ActionLog[] = [];
  try {
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      if (key && key.startsWith(LOG_KEY_PREFIX)) {
        const raw = localStorage.getItem(key);
        if (raw) {
          logs.push(JSON.parse(raw) as ActionLog);
        }
      }
    }
    // Sort descending by date
    logs.sort((a, b) => b.date.localeCompare(a.date));
  } catch (e) {
    console.error("Failed to retrieve all logs:", e);
  }
  return logs;
}

export function getUserSettings(): UserSettings {
  if (!isClient()) return DEFAULT_SETTINGS;
  try {
    const raw = localStorage.getItem(SETTINGS_KEY);
    if (!raw) return DEFAULT_SETTINGS;
    return { ...DEFAULT_SETTINGS, ...JSON.parse(raw) };
  } catch (e) {
    console.error("Failed to load user settings:", e);
    return DEFAULT_SETTINGS;
  }
}

export function saveUserSettings(settings: Partial<UserSettings>): UserSettings {
  const current = getUserSettings();
  const updated = { ...current, ...settings };
  if (isClient()) {
    try {
      localStorage.setItem(SETTINGS_KEY, JSON.stringify(updated));
    } catch (e) {
      console.error("Failed to save user settings:", e);
    }
  }
  return updated;
}

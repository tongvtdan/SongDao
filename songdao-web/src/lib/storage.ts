import { ActionLog, ImportResult, UserDataBackup, UserSettings } from "./types";

const LOG_KEY_PREFIX = "sd_log_";
const SETTINGS_KEY = "sd_settings_v1";
const BACKUP_APP = "songdao-web";
const BACKUP_VERSION = 1;

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

export function exportUserData(): string {
  const backup: UserDataBackup = {
    app: BACKUP_APP,
    version: BACKUP_VERSION,
    exportedAt: new Date().toISOString(),
    logs: getAllLogs(),
    settings: getUserSettings(),
  };
  return JSON.stringify(backup, null, 2);
}

export function importUserData(json: string): ImportResult {
  if (!isClient()) {
    return { ok: false, importedLogs: 0, importedSettings: false, error: "Chỉ có thể nhập dữ liệu trong trình duyệt." };
  }

  try {
    const parsed = JSON.parse(json) as Partial<UserDataBackup>;
    if (parsed.app !== BACKUP_APP || parsed.version !== BACKUP_VERSION) {
      return { ok: false, importedLogs: 0, importedSettings: false, error: "Tệp sao lưu không đúng định dạng Sống Đạo." };
    }

    const logs = Array.isArray(parsed.logs) ? parsed.logs.filter(isValidActionLog) : [];
    for (const log of logs) {
      saveLog(log);
    }

    let importedSettings = false;
    if (parsed.settings && isValidSettings(parsed.settings)) {
      saveUserSettings(parsed.settings);
      importedSettings = true;
    }

    return { ok: true, importedLogs: logs.length, importedSettings };
  } catch {
    return { ok: false, importedLogs: 0, importedSettings: false, error: "Không đọc được tệp sao lưu." };
  }
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

function isValidActionLog(value: unknown): value is ActionLog {
  if (!value || typeof value !== "object") return false;
  const log = value as Partial<ActionLog>;
  return (
    typeof log.id === "string" &&
    typeof log.actionId === "string" &&
    typeof log.date === "string" &&
    (log.status === "pending" || log.status === "completed" || log.status === "skipped") &&
    typeof log.updatedAt === "string"
  );
}

function isValidSettings(value: unknown): value is UserSettings {
  if (!value || typeof value !== "object") return false;
  const settings = value as Partial<UserSettings>;
  return (
    typeof settings.locale === "string" &&
    typeof settings.showLunarDate === "boolean" &&
    typeof settings.dailyReminderEnabled === "boolean" &&
    typeof settings.dailyReminderHour === "number" &&
    typeof settings.dailyReminderMinute === "number"
  );
}

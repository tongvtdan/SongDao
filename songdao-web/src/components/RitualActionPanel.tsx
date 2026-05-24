"use client";

import { Check, CheckCircle2, Clock, Sparkles } from "lucide-react";
import { ActionLog, DailyAction } from "@/lib/types";
import { AppSignalChip } from "./ui";

interface RitualActionPanelProps {
  action: DailyAction;
  log: ActionLog | null;
  accentColor: string;
  onComplete: () => void;
  isCompleting: boolean;
}

export default function RitualActionPanel({ action, log, accentColor, onComplete, isCompleting }: RitualActionPanelProps) {
  const isCompleted = log?.status === "completed";

  return (
    <section className="ritual-enter relative flex h-full min-h-[470px] overflow-hidden rounded-lg border border-border-subtle bg-surface-primary p-7 shadow-sm">
      <div className="absolute inset-x-0 top-0 h-1" style={{ backgroundColor: isCompleted ? "#2F7D4F" : accentColor }} />
      <div className="absolute right-7 top-7 h-28 w-28 rounded-full opacity-10" style={{ backgroundColor: accentColor }} aria-hidden="true" />

      <div className="relative flex flex-1 flex-col justify-between gap-8">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <AppSignalChip label="Hành động hôm nay" color={accentColor} icon={<Sparkles className="h-3.5 w-3.5" />} />
          {action.durationMinutes && (
            <span className="inline-flex items-center gap-1.5 rounded-lg border border-border-subtle bg-surface-secondary px-3 py-1.5 text-xs font-bold text-text-secondary">
              <Clock className="h-4 w-4 text-brand-primary" />
              {action.durationMinutes} phút
            </span>
          )}
        </div>

        <div>
          {action.title && <p className="text-sm font-extrabold uppercase text-brand-primary">{action.title}</p>}
          <p className="mt-4 max-w-3xl font-serif text-4xl font-extrabold leading-tight text-text-primary">{action.prompt}</p>
        </div>

        {isCompleted ? (
          <div className="ritual-complete-reveal flex items-center gap-4 rounded-lg border border-brand-primary/20 bg-brand-soft/70 p-4 text-brand-deep">
            <span className="ritual-check-pulse flex h-11 w-11 items-center justify-center rounded-full bg-status-complete text-white shadow-sm">
              <Check className="h-6 w-6" />
            </span>
            <div>
              <p className="font-serif text-lg font-extrabold">Bạn đã sống đạo hôm nay.</p>
              <p className="mt-0.5 text-xs font-semibold text-text-secondary">{formatCompletedTime(log?.completedAt || log?.updatedAt)}</p>
            </div>
          </div>
        ) : (
          <button
            type="button"
            onClick={onComplete}
            disabled={isCompleting}
            className="ritual-primary-button inline-flex min-h-14 w-full max-w-sm items-center justify-center gap-2 rounded-lg bg-brand-primary px-5 py-4 text-sm font-extrabold text-white shadow-sm transition hover:bg-brand-primary-pressed disabled:cursor-wait disabled:opacity-75"
          >
            <CheckCircle2 className="h-5 w-5" />
            {isCompleting ? "Đang ghi nhận..." : "Hoàn thành hôm nay"}
          </button>
        )}
      </div>
    </section>
  );
}

function formatCompletedTime(value?: string): string {
  if (!value) return "Đã hoàn thành";
  try {
    return `Hoàn thành lúc ${new Intl.DateTimeFormat("vi-VN", { hour: "2-digit", minute: "2-digit" }).format(new Date(value))}`;
  } catch {
    return "Đã hoàn thành";
  }
}

"use client";

import { Check, CheckCircle2, Clock, Sparkles } from "lucide-react";
import { ActionLog, DailyAction } from "@/lib/types";
import { AppBentoCard, AppSignalChip } from "./ui";

interface DailyActionCardProps {
  action: DailyAction;
  log: ActionLog | null;
  accentColor: string;
  onComplete: () => void;
  isCompleting: boolean;
}

export default function DailyActionCard({ action, log, accentColor, onComplete, isCompleting }: DailyActionCardProps) {
  const isCompleted = log?.status === "completed";

  return (
    <AppBentoCard accentColor={isCompleted ? "#2F7D4F" : accentColor}>
      <div className="flex flex-col gap-4">
        <div className="flex items-start justify-between gap-3">
          <AppSignalChip label="Hành động hôm nay" color={accentColor} icon={<Sparkles className="h-3.5 w-3.5" />} />
          {action.durationMinutes && (
            <span className="inline-flex items-center gap-1 rounded-full bg-surface-secondary px-2.5 py-1 text-xs font-semibold text-text-secondary">
              <Clock className="h-3.5 w-3.5 text-brand-primary" />
              {action.durationMinutes} phút
            </span>
          )}
        </div>
        <p className="font-serif text-xl font-extrabold leading-snug text-text-primary">{action.prompt}</p>
        {isCompleted ? (
          <div className="flex items-center gap-3 rounded-lg bg-brand-soft/70 px-4 py-3 text-brand-deep">
            <span className="flex h-7 w-7 items-center justify-center rounded-full bg-status-complete text-white">
              <Check className="h-4 w-4" />
            </span>
            <div>
              <p className="text-sm font-bold">Bạn đã sống đạo hôm nay!</p>
              <p className="text-xs text-text-secondary">{formatCompletedTime(log?.completedAt || log?.updatedAt)}</p>
            </div>
          </div>
        ) : (
          <button
            type="button"
            onClick={onComplete}
            disabled={isCompleting}
            className="inline-flex min-h-12 w-full items-center justify-center gap-2 rounded-lg bg-brand-primary px-4 py-3 text-sm font-bold text-white transition-colors hover:bg-brand-primary-pressed disabled:cursor-wait disabled:opacity-75"
          >
            <CheckCircle2 className="h-5 w-5" />
            {isCompleting ? "Đang ghi nhận..." : "Hoàn thành"}
          </button>
        )}
      </div>
    </AppBentoCard>
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

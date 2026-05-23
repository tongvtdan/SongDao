"use client";

import React from "react";
import { CheckCircle2, Clock, Check } from "lucide-react";
import { DailyAction, ActionLog } from "../lib/types";

interface DailyActionCardProps {
  action: DailyAction;
  log: ActionLog | null;
  onComplete: () => void;
  isCompleting: boolean;
}

export default function DailyActionCard({
  action,
  log,
  onComplete,
  isCompleting,
}: DailyActionCardProps) {
  const isCompleted = log?.status === "completed";

  // Formatter for timestamp
  const formatCompletedTime = (isoString?: string) => {
    if (!isoString) return "";
    try {
      const d = new Date(isoString);
      const h = d.getHours().toString().padStart(2, "0");
      const m = d.getMinutes().toString().padStart(2, "0");
      return `Hoàn thành lúc ${h}:${m}`;
    } catch {
      return "Đã hoàn thành";
    }
  };

  return (
    <div
      className={`relative bg-surface-primary rounded-lg border shadow-sm p-6 overflow-hidden transition-all duration-500 ease-out ${
        isCompleted
          ? "border-status-complete/30 bg-[#E2F1EA]"
          : "border-border-subtle hover:border-brand-primary/40"
      }`}
    >
      {/* Dynamic top banner or status ribbon */}
      <div className="flex items-start justify-between gap-4 mb-4">
        <span className="text-[11px] uppercase tracking-wider text-text-secondary font-bold bg-surface-secondary px-2.5 py-1 rounded">
          Một việc nhỏ hôm nay
        </span>
        {action.durationMinutes && (
          <span className="flex items-center gap-1 text-xs text-text-secondary font-semibold bg-surface-container/60 px-2.5 py-1 rounded-full">
            <Clock className="w-3.5 h-3.5 text-brand-primary" />
            {action.durationMinutes} phút
          </span>
        )}
      </div>

      {/* Main prompt body */}
      <div className="flex flex-col gap-3">
        {action.title && (
          <h2 className="font-serif text-xl md:text-2xl font-bold text-text-primary leading-tight">
            {action.title}
          </h2>
        )}
        <p className="text-sm md:text-base leading-relaxed text-text-secondary">
          {action.prompt}
        </p>
      </div>

      {/* Interactive Bottom Completion CTA Panel */}
      <div className="mt-6 flex flex-col gap-3">
        {isCompleted ? (
          <div className="flex items-center gap-3 p-3 bg-surface-primary/70 rounded-md border border-status-complete/20 transition-all duration-300">
            <div className="w-6 h-6 rounded-full bg-status-complete flex items-center justify-center text-white shrink-0">
              <Check className="w-4 h-4" />
            </div>
            <div className="flex flex-col">
              <span className="text-sm font-bold text-brand-deep">
                Hoàn thành xuất sắc!
              </span>
              <span className="text-xs text-text-secondary">
                {formatCompletedTime(log?.completedAt || log?.updatedAt)}
              </span>
            </div>
          </div>
        ) : (
          <button
            onClick={onComplete}
            disabled={isCompleting}
            className={`w-full py-3 px-4 rounded-lg bg-brand-primary hover:bg-brand-primary-pressed text-white font-semibold text-sm md:text-base flex items-center justify-center gap-2 shadow-sm active:translate-y-px transition-all duration-150 ${
              isCompleting ? "opacity-80 cursor-wait" : ""
            }`}
          >
            <CheckCircle2 className="w-5 h-5" />
            {isCompleting ? "Đang ghi nhận..." : "Tôi đã làm việc này"}
          </button>
        )}
      </div>
    </div>
  );
}

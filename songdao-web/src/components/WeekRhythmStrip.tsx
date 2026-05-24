"use client";

import { Check, Circle, Sparkles } from "lucide-react";
import { createDateFromKey, getDateKey } from "@/lib/engine";
import { getProgressView } from "@/lib/views";
import { useHydrated } from "@/lib/useHydrated";
import { AppBentoCard, weekdayShortFromDate } from "./ui";

interface WeekRhythmStripProps {
  selectedDate: string;
  onSelectDate: (date: string) => void;
}

export default function WeekRhythmStrip({ selectedDate, onSelectDate }: WeekRhythmStripProps) {
  const hydrated = useHydrated();
  const data = getProgressView(hydrated);
  const completedCount = Object.values(data.weekCompleted).filter(Boolean).length;
  const todayKey = getDateKey();

  return (
    <AppBentoCard accentColor="#1F7A64">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h2 className="font-serif text-base font-extrabold text-text-primary">Nhịp tuần này</h2>
          <p className="mt-1 text-xs text-text-secondary">
            {completedCount === 0 ? "Một việc nhỏ hôm nay là đủ để bắt đầu lại." : `Bạn đã giữ nhịp ${completedCount}/7 ngày tuần này.`}
          </p>
        </div>
        <span className="inline-flex items-center gap-1.5 rounded-lg bg-brand-soft px-3 py-1.5 text-xs font-bold text-brand-deep">
          <Sparkles className="h-3.5 w-3.5" />
          Riêng tư
        </span>
      </div>

      <div className="mt-4 grid grid-cols-7 gap-2">
        {data.weekKeys.map((key) => {
          const date = createDateFromKey(key);
          const completed = data.weekCompleted[key];
          const selected = key === selectedDate;
          const today = key === todayKey;

          return (
            <button
              key={key}
              type="button"
              onClick={() => onSelectDate(key)}
              className="group flex min-w-0 flex-col items-center gap-1 rounded-lg border border-border-subtle bg-canvas px-2 py-2 text-center transition hover:-translate-y-0.5 hover:border-brand-primary/50 hover:bg-brand-soft/40"
              style={{
                borderColor: selected ? "#1F7A64" : undefined,
                backgroundColor: selected ? "#E2F1EA" : undefined,
              }}
              aria-label={`Mở ngày ${key}`}
            >
              <span className="text-[10px] font-extrabold text-text-secondary">{weekdayShortFromDate(date)}</span>
              <span className="text-sm font-black text-text-primary">{date.getDate()}</span>
              <span
                className="flex h-5 w-5 items-center justify-center rounded-full border text-[10px]"
                style={{
                  backgroundColor: completed ? "#1F7A64" : today ? "#FFFFFF" : "#F3F0E8",
                  borderColor: completed || today ? "#1F7A64" : "#E2DDD1",
                  color: completed ? "#FFFFFF" : "#5F6761",
                }}
              >
                {completed ? <Check className="h-3 w-3" /> : <Circle className="h-2.5 w-2.5" />}
              </span>
            </button>
          );
        })}
      </div>

      <div className="mt-4 h-1.5 overflow-hidden rounded-full bg-surface-secondary">
        <div className="h-full rounded-full bg-brand-primary transition-all duration-500" style={{ width: `${(completedCount / 7) * 100}%` }} />
      </div>
    </AppBentoCard>
  );
}

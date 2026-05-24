"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import { BookOpen, Check, Circle } from "lucide-react";
import { getProgressView } from "@/lib/views";
import { useHydrated } from "@/lib/useHydrated";
import { AppBentoCard, weekdayShortFromDate } from "./ui";
import { createDateFromKey } from "@/lib/engine";

interface ProgressTrackerProps {
  compact?: boolean;
}

export default function ProgressTracker({ compact = false }: ProgressTrackerProps) {
  const [selectedDate, setSelectedDate] = useState<string | null>(null);
  const hydrated = useHydrated();
  const data = useMemo(() => getProgressView(hydrated), [hydrated]);
  const count = Object.values(data.weekCompleted).filter(Boolean).length;
  const logs = selectedDate ? data.completedLogs.filter((item) => item.log.date === selectedDate) : data.recentLogs;

  return (
    <div className="flex flex-col gap-4">
      {!compact && (
        <Link href="/progress/journal" className="block">
          <AppBentoCard accentColor="#B8892E">
            <div className="flex items-center gap-3">
              <span className="flex h-10 w-10 items-center justify-center rounded-lg bg-[#B8892E]/15 text-accent-gold"><BookOpen className="h-5 w-5" /></span>
              <span className="min-w-0 flex-1">
                <span className="block font-serif text-lg font-bold text-text-primary">Nhật ký riêng</span>
                <span className="block text-sm text-text-secondary">Xem, tìm và sửa ghi chú lưu trên thiết bị.</span>
              </span>
            </div>
          </AppBentoCard>
        </Link>
      )}

      <AppBentoCard accentColor="#1F7A64">
        <h3 className="font-serif text-base font-bold text-text-primary">Tuần này</h3>
        <div className="mt-3 flex justify-between gap-1">
          {data.weekKeys.map((key) => {
            const completed = data.weekCompleted[key];
            const selected = selectedDate === key;
            return (
              <button key={key} type="button" onClick={() => setSelectedDate(selected ? null : key)} className="flex flex-col items-center gap-1 text-[10px] font-bold text-text-secondary cursor-pointer">
                <span className="flex h-8 w-8 items-center justify-center rounded-full border transition-transform hover:scale-105" style={{ backgroundColor: completed ? "#1F7A64" : "#F3F0E8", borderColor: selected ? "#B8892E" : "#E2DDD1", color: completed ? "white" : "#8A938D" }}>
                  {completed ? <Check className="h-3 w-3" /> : <Circle className="h-3 w-3" />}
                </span>
                {weekdayShortFromDate(createDateFromKey(key))}
              </button>
            );
          })}
        </div>
        <div className="mt-3 h-1.5 overflow-hidden rounded-full bg-surface-secondary">
          <div className="h-full rounded-full bg-brand-primary transition-all duration-500" style={{ width: `${(count / 7) * 100}%` }} />
        </div>
        <p className="mt-2 text-xs text-text-secondary">
          {count === 0 ? "Một việc nhỏ hôm nay là đủ để bắt đầu lại." : `Bạn đã giữ nhịp ${count}/7 ngày tuần này.`}
        </p>
      </AppBentoCard>

      <div className="relative">
      <AppBentoCard className="max-h-[300px] overflow-y-auto pr-1 scrollbar-thin">
        <h3 className="font-serif text-base font-bold text-text-primary">{selectedDate ? "Việc ngày này" : "Đã hoàn thành"}</h3>
        {selectedDate && <p className="mt-0.5 text-[10px] font-bold text-text-tertiary">{selectedDate}</p>}
        <div className="mt-2 flex flex-col divide-y divide-border-subtle">
          {logs.length === 0 ? (
            <p className="py-3 text-xs text-text-secondary">{selectedDate ? "Chưa có việc hoàn thành." : "Chưa có lịch sử hoàn thành."}</p>
          ) : (
            logs.map((item) => (
              <div key={item.log.id} className="py-2.5">
                <p className="text-xs font-bold text-text-primary leading-snug">{item.action.prompt}</p>
                <p className="mt-1 text-[9px] text-text-tertiary">{formatLogDate(item.log.completedAt || item.log.updatedAt)}</p>
                {item.log.note && <p className="mt-1.5 rounded bg-surface-secondary p-2 text-xs italic text-text-secondary leading-relaxed">{item.log.note}</p>}
              </div>
            ))
          )}
        </div>
      </AppBentoCard>
      <div className="pointer-events-none absolute inset-x-0 bottom-0 h-10 rounded-b-lg bg-gradient-to-t from-surface-primary to-transparent" />
      </div>
    </div>
  );
}

function formatLogDate(value: string): string {
  return new Intl.DateTimeFormat("vi-VN", { dateStyle: "short", timeStyle: "short" }).format(new Date(value));
}

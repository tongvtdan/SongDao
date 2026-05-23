"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import { BookOpen, Check, Circle } from "lucide-react";
import AppShell from "@/components/AppShell";
import { getProgressView } from "@/lib/views";
import { useHydrated } from "@/lib/useHydrated";
import { AppBentoCard, weekdayShortFromDate } from "@/components/ui";
import { createDateFromKey } from "@/lib/engine";

export default function ProgressPage() {
  const [selectedDate, setSelectedDate] = useState<string | null>(null);
  const hydrated = useHydrated();
  const data = useMemo(() => getProgressView(hydrated), [hydrated]);
  const count = Object.values(data.weekCompleted).filter(Boolean).length;
  const logs = selectedDate ? data.completedLogs.filter((item) => item.log.date === selectedDate) : data.recentLogs;

  return (
    <AppShell>
      <div>
        <h1 className="font-serif text-2xl font-bold">Nhịp sống đức tin</h1>
        <p className="mt-1 text-sm text-text-secondary">Riêng tư, nhẹ nhàng, chỉ lưu trên thiết bị.</p>
      </div>
      <Link href="/progress/journal" className="block">
        <AppBentoCard accentColor="#B8892E">
          <div className="flex items-center gap-3">
            <span className="flex h-10 w-10 items-center justify-center rounded-lg bg-[#B8892E]/15 text-accent-gold"><BookOpen className="h-5 w-5" /></span>
            <span className="min-w-0 flex-1">
              <span className="block font-serif text-lg font-bold">Nhật ký riêng</span>
              <span className="block text-sm text-text-secondary">Xem, tìm và sửa ghi chú chỉ lưu trên thiết bị.</span>
            </span>
          </div>
        </AppBentoCard>
      </Link>
      <AppBentoCard accentColor="#1F7A64">
        <h2 className="font-serif text-xl font-bold">Tuần này</h2>
        <div className="mt-4 flex justify-between gap-2">
          {data.weekKeys.map((key) => {
            const completed = data.weekCompleted[key];
            const selected = selectedDate === key;
            return (
              <button key={key} type="button" onClick={() => setSelectedDate(selected ? null : key)} className="flex flex-col items-center gap-1 text-xs font-bold text-text-secondary">
                <span className="flex h-9 w-9 items-center justify-center rounded-full border" style={{ backgroundColor: completed ? "#1F7A64" : "#F3F0E8", borderColor: selected ? "#B8892E" : "#E2DDD1", color: completed ? "white" : "#8A938D" }}>
                  {completed ? <Check className="h-4 w-4" /> : <Circle className="h-4 w-4" />}
                </span>
                {weekdayShortFromDate(createDateFromKey(key))}
              </button>
            );
          })}
        </div>
        <div className="mt-4 h-2 overflow-hidden rounded-full bg-surface-secondary">
          <div className="h-full rounded-full bg-brand-primary" style={{ width: `${(count / 7) * 100}%` }} />
        </div>
        <p className="mt-3 text-sm text-text-secondary">{count === 0 ? "Một việc nhỏ hôm nay là đủ để bắt đầu lại." : `Bạn đã giữ nhịp ${count}/7 ngày trong tuần này.`}</p>
      </AppBentoCard>
      <AppBentoCard>
        <h2 className="font-serif text-xl font-bold">{selectedDate ? "Việc đã hoàn thành ngày này" : "Việc đã hoàn thành"}</h2>
        {selectedDate && <p className="mt-1 text-xs font-bold text-text-secondary">{selectedDate}</p>}
        <div className="mt-3 flex flex-col divide-y divide-border-subtle">
          {logs.length === 0 ? (
            <p className="py-2 text-sm text-text-secondary">{selectedDate ? "Chưa có việc hoàn thành trong ngày này." : "Chưa có lịch sử hoàn thành. Khi bạn ghi nhận một việc nhỏ, nó sẽ hiện ở đây."}</p>
          ) : (
            logs.map((item) => (
              <div key={item.log.id} className="py-3">
                <p className="text-sm font-bold text-text-primary">{item.action.prompt}</p>
                <p className="mt-1 text-xs text-text-secondary">{formatLogDate(item.log.completedAt || item.log.updatedAt)}</p>
                {item.log.note && <p className="mt-2 rounded-lg bg-surface-secondary p-3 text-sm italic text-text-secondary">{item.log.note}</p>}
              </div>
            ))
          )}
        </div>
      </AppBentoCard>
    </AppShell>
  );
}

function formatLogDate(value: string): string {
  return new Intl.DateTimeFormat("vi-VN", { dateStyle: "short", timeStyle: "short" }).format(new Date(value));
}

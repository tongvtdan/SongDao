"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import { ChevronLeft, ChevronRight } from "lucide-react";
import AppShell from "@/components/AppShell";
import DailyReflectionCard from "@/components/DailyReflectionCard";
import ReadingReferencesCard from "@/components/ReadingReferencesCard";
import { createDateFromKey, formatDateKey, getDateKey } from "@/lib/engine";
import { getCalendarMonthView } from "@/lib/views";
import { useHydrated } from "@/lib/useHydrated";
import { AppBentoCard, AppSignalChip, colorLabel, formatVietnameseDate, liturgicalAccent, seasonLabel, weekdayShortFromDate } from "@/components/ui";

export default function CalendarPage() {
  const todayKey = getDateKey();
  const [selectedDate, setSelectedDate] = useState(todayKey);
  const [visibleMonth, setVisibleMonth] = useState(todayKey.slice(0, 7));
  const hydrated = useHydrated();
  const data = useMemo(() => getCalendarMonthView(visibleMonth, selectedDate, hydrated), [visibleMonth, selectedDate, hydrated]);
  const monthDate = createDateFromKey(`${visibleMonth}-01`);

  const changeMonth = (offset: number) => {
    const next = new Date(monthDate);
    next.setMonth(monthDate.getMonth() + offset);
    setVisibleMonth(formatDateKey(next).slice(0, 7));
  };

  return (
    <AppShell>
      <div className="flex items-center justify-between gap-3">
        <button type="button" onClick={() => changeMonth(-1)} className="rounded-lg p-2 hover:bg-surface-secondary" aria-label="Tháng trước">
          <ChevronLeft className="h-5 w-5" />
        </button>
        <div className="text-center">
          <h1 className="font-serif text-2xl font-bold">Tháng {monthDate.getMonth() + 1}, {monthDate.getFullYear()}</h1>
          <p className="text-xs font-semibold text-text-secondary">Dữ liệu phụng vụ trên thiết bị</p>
        </div>
        <button type="button" onClick={() => changeMonth(1)} className="rounded-lg p-2 hover:bg-surface-secondary" aria-label="Tháng sau">
          <ChevronRight className="h-5 w-5" />
        </button>
      </div>
      <MonthGrid visibleMonth={monthDate} days={data.days} selectedDate={selectedDate} onSelect={setSelectedDate} />
      <SelectedDay data={data} />
    </AppShell>
  );
}

function MonthGrid({ visibleMonth, days, selectedDate, onSelect }: { visibleMonth: Date; days: ReturnType<typeof getCalendarMonthView>["days"]; selectedDate: string; onSelect: (date: string) => void }) {
  const first = new Date(visibleMonth.getFullYear(), visibleMonth.getMonth(), 1);
  const gridStart = new Date(first);
  gridStart.setDate(first.getDate() - first.getDay());
  const cells = Array.from({ length: 42 }, (_, index) => {
    const date = new Date(gridStart);
    date.setDate(gridStart.getDate() + index);
    return date;
  });

  return (
    <AppBentoCard>
      <div className="mb-2 grid grid-cols-7 text-center text-[11px] font-extrabold text-text-secondary">
        {["CN", "T2", "T3", "T4", "T5", "T6", "T7"].map((label) => <span key={label}>{label}</span>)}
      </div>
      <div className="grid grid-cols-7 gap-1.5">
        {cells.map((date) => {
          const key = formatDateKey(date);
          const day = days[key];
          const selected = key === selectedDate;
          const inMonth = date.getMonth() === visibleMonth.getMonth();
          const accent = liturgicalAccent(day?.liturgicalColor);
          return (
            <button
              key={key}
              type="button"
              onClick={() => onSelect(key)}
              className="aspect-square rounded-lg border text-sm font-bold transition-colors"
              style={{
                backgroundColor: selected ? "#1F7A64" : day ? `${accent}1f` : "transparent",
                borderColor: selected ? "#1F7A64" : day ? "#E2DDD1" : "transparent",
                color: selected ? "white" : inMonth ? "#1F2522" : "#8A938D",
              }}
              aria-label={`${weekdayShortFromDate(date)} ${key}`}
            >
              <span>{date.getDate()}</span>
              <span className="mx-auto mt-1 block h-1.5 w-1.5 rounded-full" style={{ backgroundColor: selected ? "white" : day ? accent : "transparent" }} />
            </button>
          );
        })}
      </div>
    </AppBentoCard>
  );
}

function SelectedDay({ data }: { data: ReturnType<typeof getCalendarMonthView> }) {
  const day = data.calendarDay;
  if (!day) {
    return <AppBentoCard>Chưa có dữ liệu phụng vụ cho ngày này trong gói nội dung trên thiết bị.</AppBentoCard>;
  }
  const accent = liturgicalAccent(day.liturgicalColor);
  return (
    <>
      <AppBentoCard accentColor={accent}>
        <h2 className="font-serif text-xl font-bold text-text-primary">{data.celebrations[0]?.title || formatVietnameseDate(data.date, day)}</h2>
        <div className="mt-3 flex flex-wrap gap-2">
          <AppSignalChip label={seasonLabel(day.season)} color={accent} />
          <AppSignalChip label={colorLabel(day.liturgicalColor)} />
          {data.showLunarDate && day.lunarDate && <AppSignalChip label={day.lunarDate} />}
        </div>
        {data.action && (
          <div className="mt-4 border-t border-border-subtle pt-4">
            <p className="text-xs font-extrabold uppercase tracking-wide text-brand-primary">Việc sống đạo</p>
            <p className="mt-1 text-sm leading-relaxed text-text-secondary">{data.action.prompt}</p>
            <Link href={`/today/${data.date}`} className="mt-3 inline-flex rounded-lg bg-brand-soft px-3 py-2 text-xs font-bold text-brand-deep">
              Mở Today ngày này
            </Link>
          </div>
        )}
      </AppBentoCard>
      <ReadingReferencesCard readings={data.readings} />
      {data.reflection && <DailyReflectionCard reflection={data.reflection} />}
    </>
  );
}

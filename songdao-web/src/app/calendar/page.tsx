"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import { BookOpen, CalendarDays, List } from "lucide-react";
import AppShell from "@/components/AppShell";
import CalendarGrid from "@/components/CalendarGrid";
import DailyReflectionCard from "@/components/DailyReflectionCard";
import ReadingReferencesCard from "@/components/ReadingReferencesCard";
import { getDateKey } from "@/lib/engine";
import { getCalendarDayDetail, getCalendarMonthAgenda } from "@/lib/views";
import { useHydrated } from "@/lib/useHydrated";
import { CalendarAgendaItem, CalendarDayDetail } from "@/lib/types";
import { AppBentoCard, AppSignalChip, cn, colorLabel, formatVietnameseDate, liturgicalAccent, readingLabel, seasonLabel } from "@/components/ui";

type CalendarMode = "month" | "agenda";

export default function CalendarPage() {
  const todayKey = getDateKey();
  const [selectedDate, setSelectedDate] = useState(todayKey);
  const [visibleMonth, setVisibleMonth] = useState(todayKey.slice(0, 7));
  const [mode, setMode] = useState<CalendarMode>("month");
  const hydrated = useHydrated();
  const data = useMemo(() => getCalendarDayDetail(selectedDate, hydrated), [selectedDate, hydrated]);
  const agenda = useMemo(() => getCalendarMonthAgenda(visibleMonth), [visibleMonth]);

  const selectDate = (date: string) => {
    setSelectedDate(date);
    if (date.slice(0, 7) !== visibleMonth) {
      setVisibleMonth(date.slice(0, 7));
    }
  };

  return (
    <AppShell>
      <div className="flex flex-col gap-4 lg:gap-5">
        <div className="flex flex-col gap-3 lg:flex-row lg:items-end lg:justify-between">
          <div>
            <h1 className="font-serif text-2xl font-bold text-text-primary lg:text-3xl">Lịch phụng vụ</h1>
            <p className="mt-1 max-w-2xl text-sm text-text-secondary">
              Chọn một ngày để xem bối cảnh phụng vụ, bài đọc và suy niệm ngay dưới lịch tháng.
            </p>
          </div>
          <CalendarModeSwitch mode={mode} onChange={setMode} />
        </div>

        {mode === "month" ? (
          <CalendarGrid
            selectedDate={selectedDate}
            onSelectDate={selectDate}
            visibleMonth={visibleMonth}
            onVisibleMonthChange={setVisibleMonth}
          />
        ) : (
          <MonthAgenda items={agenda} selectedDate={selectedDate} onSelectDate={selectDate} />
        )}

        <SelectedDay key={data.date} data={data} />
      </div>
    </AppShell>
  );
}

function CalendarModeSwitch({ mode, onChange }: { mode: CalendarMode; onChange: (mode: CalendarMode) => void }) {
  return (
    <div className="grid grid-cols-2 gap-1 rounded-lg border border-border-subtle bg-surface-secondary p-1 lg:w-[320px]" aria-label="Kiểu xem lịch">
      <ModeButton
        active={mode === "month"}
        icon={<CalendarDays className="h-4 w-4" />}
        label="Lịch tháng"
        onClick={() => onChange("month")}
      />
      <ModeButton
        active={mode === "agenda"}
        icon={<List className="h-4 w-4" />}
        label="Danh sách"
        onClick={() => onChange("agenda")}
      />
    </div>
  );
}

function ModeButton({ active, icon, label, onClick }: { active: boolean; icon: React.ReactNode; label: string; onClick: () => void }) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        "inline-flex min-h-10 items-center justify-center gap-2 rounded-md px-3 text-xs font-extrabold transition-colors",
        active ? "bg-surface-primary text-brand-primary shadow-sm" : "text-text-secondary hover:text-text-primary"
      )}
    >
      {icon}
      {label}
    </button>
  );
}

function MonthAgenda({
  items,
  selectedDate,
  onSelectDate,
}: {
  items: CalendarAgendaItem[];
  selectedDate: string;
  onSelectDate: (date: string) => void;
}) {
  if (items.length === 0) {
    return <AppBentoCard>Chưa có dữ liệu phụng vụ cho tháng này trong gói nội dung trên thiết bị.</AppBentoCard>;
  }

  return (
    <AppBentoCard className="p-0">
      <div className="divide-y divide-border-subtle">
        {items.map((item) => {
          const selected = item.date === selectedDate;
          const accent = liturgicalAccent(item.calendarDay.liturgicalColor);
          const gospel = item.readings.find((reading) => reading.type === "gospel");
          return (
            <button
              key={item.date}
              type="button"
              onClick={() => onSelectDate(item.date)}
              className={cn(
                "grid w-full gap-3 px-4 py-3 text-left transition-colors hover:bg-brand-soft/35 md:grid-cols-[88px_minmax(0,1fr)_minmax(210px,0.55fr)] md:items-center",
                selected && "bg-brand-soft/70"
              )}
            >
              <div className="flex items-center gap-3 md:block">
                <span className="font-serif text-2xl font-black leading-none" style={{ color: selected ? "#1F7A64" : accent }}>
                  {item.date.slice(-2)}
                </span>
                <span className="text-xs font-bold text-text-secondary md:mt-1 md:block">
                  {formatVietnameseDate(item.date, item.calendarDay).split(",")[0]}
                </span>
              </div>
              <div className="min-w-0">
                <p className="truncate font-serif text-sm font-extrabold text-text-primary">
                  {item.celebrations[0]?.title || item.calendarDay.liturgicalWeek || "Ngày phụng vụ"}
                </p>
                <div className="mt-2 flex flex-wrap gap-2">
                  <AppSignalChip label={seasonLabel(item.calendarDay.season)} color={accent} />
                  <AppSignalChip label={colorLabel(item.calendarDay.liturgicalColor)} />
                </div>
              </div>
              <div className="min-w-0 text-xs leading-relaxed text-text-secondary">
                <p className="line-clamp-2 font-semibold text-text-primary">{item.action.prompt}</p>
                {gospel && (
                  <p className="mt-1 flex items-center gap-1 font-bold text-brand-primary">
                    <BookOpen className="h-3.5 w-3.5" />
                    {readingLabel(gospel.type)}: {gospel.citation}
                  </p>
                )}
              </div>
            </button>
          );
        })}
      </div>
    </AppBentoCard>
  );
}

function SelectedDay({ data }: { data: CalendarDayDetail }) {
  const day = data.calendarDay;
  if (!day) {
    return <AppBentoCard>Chưa có dữ liệu phụng vụ cho ngày này trong gói nội dung trên thiết bị.</AppBentoCard>;
  }
  const accent = liturgicalAccent(day.liturgicalColor);
  const title = data.celebrations[0]?.title || formatVietnameseDate(data.date, day);
  const gospel = data.readings.find((reading) => reading.type === "gospel");

  return (
    <section className="grid gap-4 lg:grid-cols-[minmax(0,0.92fr)_minmax(360px,1.08fr)]" aria-label="Chi tiết ngày đã chọn">
      <AppBentoCard accentColor={accent} accentPlacement="top" className="p-5">
        <p className="text-xs font-extrabold uppercase text-brand-primary">Ngày đã chọn</p>
        <h2 className="mt-2 font-serif text-2xl font-black leading-tight text-text-primary lg:text-3xl">{title}</h2>
        <p className="mt-2 text-sm font-semibold text-text-secondary">{formatVietnameseDate(data.date, day)}</p>
        <div className="mt-4 flex flex-wrap gap-2">
          <AppSignalChip label={seasonLabel(day.season)} color={accent} />
          <AppSignalChip label={colorLabel(day.liturgicalColor)} />
          {day.liturgicalWeek && <AppSignalChip label={day.liturgicalWeek} />}
          {data.showLunarDate && day.lunarDate && <AppSignalChip label={day.lunarDate} />}
        </div>
        {gospel && (
          <div className="mt-5 rounded-lg border border-border-subtle bg-surface-secondary p-3">
            <p className="flex items-center gap-2 text-xs font-extrabold uppercase text-brand-primary">
              <BookOpen className="h-4 w-4" />
              Tin Mừng
            </p>
            <p className="mt-1 font-serif text-lg font-bold text-text-primary">{gospel.citation}</p>
          </div>
        )}
        <Link
          href={`/today/${data.date}`}
          className="mt-5 inline-flex min-h-11 w-full items-center justify-center gap-2 rounded-lg bg-brand-primary px-4 py-3 text-sm font-bold text-white transition-colors hover:bg-brand-primary-pressed sm:w-auto"
        >
          <CalendarDays className="h-5 w-5" />
          Xem ngày này
        </Link>
      </AppBentoCard>

      <div className="grid gap-4">
        <ReadingReferencesCard readings={data.readings} />
        {data.reflection && <DailyReflectionCard reflection={data.reflection} />}
      </div>
    </section>
  );
}

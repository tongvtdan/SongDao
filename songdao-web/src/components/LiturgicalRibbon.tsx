"use client";

import { Calendar, CalendarDays, ChevronLeft, ChevronRight, Quote } from "lucide-react";
import { CalendarDay, Celebration } from "@/lib/types";
import { AppSignalChip, colorLabel, dailyQuoteFor, formatVietnameseDate, seasonLabel } from "./ui";

interface LiturgicalRibbonProps {
  date: string;
  calendarDay: CalendarDay;
  celebrations: Celebration[];
  showLunarDate: boolean;
  isToday: boolean;
  accentColor: string;
  onNavigate: (offset: number) => void;
  onGoToToday: () => void;
  onOpenCalendar: () => void;
}

export default function LiturgicalRibbon({
  date,
  calendarDay,
  celebrations,
  showLunarDate,
  isToday,
  accentColor,
  onNavigate,
  onGoToToday,
  onOpenCalendar,
}: LiturgicalRibbonProps) {
  const celebration = celebrations[0]?.title || formatVietnameseDate(date, calendarDay);
  const showLunar = showLunarDate && Boolean(calendarDay.lunarDate);
  const [year, month, day] = date.split("-");

  return (
    <section className="ritual-enter h-full overflow-hidden rounded-lg border border-border-subtle bg-surface-primary shadow-sm">
      <div className="flex items-center justify-between px-4 py-3 text-white" style={{ backgroundColor: accentColor }}>
        <button type="button" onClick={() => onNavigate(-1)} className="rounded-full p-1.5 transition hover:bg-white/15" aria-label="Ngày trước">
          <ChevronLeft className="h-5 w-5" />
        </button>
        <span className="text-sm font-extrabold">Tháng {month} - {year}</span>
        <button type="button" onClick={() => onNavigate(1)} className="rounded-full p-1.5 transition hover:bg-white/15" aria-label="Ngày sau">
          <ChevronRight className="h-5 w-5" />
        </button>
      </div>

      <div className="flex min-h-[470px] flex-col justify-between bg-surface-secondary p-5">
        <div className="rounded-lg border border-border-subtle bg-surface-primary/75 p-5 text-center">
          <p className="mx-auto mb-2 flex items-center justify-center gap-1.5 text-sm font-bold text-text-secondary">
            <Calendar className="h-4 w-4 text-brand-primary" />
            {formatVietnameseDate(date, calendarDay)}
          </p>
          <p className="font-serif text-[8.5rem] font-black leading-none tracking-normal" style={{ color: accentColor }}>
            {day}
          </p>
          {showLunar && <p className="mt-1 text-xs font-bold text-text-secondary">{calendarDay.lunarDate}</p>}
          <h1 className="mx-auto mt-3 max-w-sm font-serif text-xl font-extrabold leading-tight text-text-primary">{celebration}</h1>
        </div>

        <div className="flex flex-wrap justify-center gap-2">
          <AppSignalChip label={seasonLabel(calendarDay.season)} color={accentColor} />
          <AppSignalChip label={colorLabel(calendarDay.liturgicalColor)} />
          {calendarDay.liturgicalWeek && <AppSignalChip label={calendarDay.liturgicalWeek} />}
        </div>

        <div className="rounded-lg border border-border-subtle bg-surface-primary/80 p-4 text-center">
          <Quote className="mx-auto mb-2 h-4 w-4 text-accent-gold" />
          <p className="text-sm font-semibold leading-relaxed text-text-primary">{dailyQuoteFor(date)}</p>
          <div className="mt-3 flex flex-wrap justify-center gap-2">
            <button type="button" onClick={onOpenCalendar} className="inline-flex items-center gap-2 rounded-lg bg-surface-secondary px-3 py-2 text-xs font-extrabold text-text-secondary transition hover:bg-brand-soft hover:text-brand-primary">
              <CalendarDays className="h-4 w-4" />
              Mở lịch tháng
            </button>
            {!isToday && (
              <button type="button" onClick={onGoToToday} className="inline-flex items-center rounded-lg bg-brand-soft px-3 py-2 text-xs font-extrabold text-brand-deep transition-colors hover:bg-brand-soft/80">
                Hôm nay
              </button>
            )}
          </div>
        </div>
      </div>
    </section>
  );
}

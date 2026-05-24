"use client";

import { Calendar, ChevronLeft, ChevronRight, Quote } from "lucide-react";
import { CalendarDay, Celebration } from "@/lib/types";
import {
  AppBentoCard,
  AppSignalChip,
  colorLabel,
  dailyQuoteFor,
  formatVietnameseDate,
  liturgicalAccent,
  seasonLabel,
} from "./ui";

interface Props {
  date: string;
  calendarDay: CalendarDay;
  celebrations: Celebration[];
  showLunarDate: boolean;
  isToday: boolean;
  onNavigate: (offset: number) => void;
  onGoToToday: () => void;
}

export default function LiturgicalContextCard({
  date,
  calendarDay,
  celebrations,
  showLunarDate,
  isToday,
  onNavigate,
  onGoToToday,
}: Props) {
  const accent = liturgicalAccent(calendarDay.liturgicalColor);
  const [year, month, day] = date.split("-");
  const celebration = celebrations[0]?.title || formatVietnameseDate(date, calendarDay);
  const showLunar = showLunarDate && Boolean(calendarDay.lunarDate);

  return (
    <div className="flex flex-col gap-2">
      <AppBentoCard accentColor={accent} accentPlacement="top" className="p-3">
        <div className="rounded-lg border border-border-subtle bg-surface-secondary">
          <div className="flex items-center justify-between rounded-t-lg px-3 py-2 text-white" style={{ backgroundColor: accent }}>
            <button type="button" onClick={() => onNavigate(-1)} className="rounded-full p-1 hover:bg-white/15" aria-label="Ngày trước">
              <ChevronLeft className="h-5 w-5" />
            </button>
            <span className="text-sm font-extrabold">Tháng {month} - {year}</span>
            <button type="button" onClick={() => onNavigate(1)} className="rounded-full p-1 hover:bg-white/15" aria-label="Ngày sau">
              <ChevronRight className="h-5 w-5" />
            </button>
          </div>
          <div className="flex min-h-[330px] flex-col items-center justify-center px-4 py-5 text-center">
            <p className="mb-1 flex items-center gap-1.5 text-sm font-bold text-text-secondary">
              <Calendar className="h-4 w-4 text-brand-primary" />
              {formatVietnameseDate(date, calendarDay)}
            </p>
            <p className="font-serif text-[7rem] font-black leading-none" style={{ color: accent }}>{day}</p>
            {showLunar && <p className="mb-2 text-xs font-bold text-text-secondary">{calendarDay.lunarDate}</p>}
            <h1 className="max-w-sm font-serif text-base font-bold leading-snug text-text-primary">{celebration}</h1>
            <div className="mt-4 w-full rounded-lg border border-border-subtle bg-surface-primary/75 p-3">
              <Quote className="mx-auto mb-1 h-4 w-4 text-accent-gold" />
              <p className="text-xs font-semibold leading-relaxed text-text-primary">{dailyQuoteFor(date)}</p>
              <p className="mt-1 text-[10px] font-bold text-text-secondary">Lời gợi hứng hôm nay</p>
            </div>
          </div>
        </div>
        <div className="mt-3 flex flex-wrap justify-center gap-2">
          <AppSignalChip label={seasonLabel(calendarDay.season)} color={accent} />
          <AppSignalChip label={colorLabel(calendarDay.liturgicalColor)} />
          {calendarDay.liturgicalWeek && <AppSignalChip label={calendarDay.liturgicalWeek} />}
          {!isToday && (
            <button type="button" onClick={onGoToToday} className="rounded-full bg-brand-soft px-3 py-1 text-xs font-bold text-brand-deep">
              Hôm nay
            </button>
          )}
        </div>
      </AppBentoCard>
      {!isToday && <p className="text-center text-xs font-semibold text-text-secondary">Đang xem ngày khác. Hành động bên dưới là của ngày đang mở.</p>}
    </div>
  );
}

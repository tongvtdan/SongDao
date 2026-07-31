"use client";

import { useMemo, useState } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { createDateFromKey, formatDateKey } from "@/lib/engine";
import { getCalendarMonthView } from "@/lib/views";
import { useHydrated } from "@/lib/useHydrated";
import { AppBentoCard, liturgicalAccent, weekdayShortFromDate } from "./ui";

interface CalendarGridProps {
  selectedDate: string;
  onSelectDate: (date: string) => void;
  visibleMonth?: string;
  onVisibleMonthChange?: (month: string) => void;
}

export default function CalendarGrid({ selectedDate, onSelectDate, visibleMonth, onVisibleMonthChange }: CalendarGridProps) {
  const [internalVisibleMonth, setInternalVisibleMonth] = useState(selectedDate.slice(0, 7));
  const activeVisibleMonth = visibleMonth || internalVisibleMonth;
  const hydrated = useHydrated();
  const data = useMemo(() => getCalendarMonthView(activeVisibleMonth, selectedDate, hydrated), [activeVisibleMonth, selectedDate, hydrated]);
  const monthDate = createDateFromKey(`${activeVisibleMonth}-01`);

  const changeMonth = (offset: number) => {
    const next = new Date(monthDate);
    next.setMonth(monthDate.getMonth() + offset);
    const nextMonth = formatDateKey(next).slice(0, 7);
    if (onVisibleMonthChange) {
      onVisibleMonthChange(nextMonth);
      return;
    }
    setInternalVisibleMonth(nextMonth);
  };

  const first = new Date(monthDate.getFullYear(), monthDate.getMonth(), 1);
  const gridStart = new Date(first);
  gridStart.setDate(first.getDate() - first.getDay());
  const cells = Array.from({ length: 42 }, (_, index) => {
    const date = new Date(gridStart);
    date.setDate(gridStart.getDate() + index);
    return date;
  });

  return (
    <div className="flex flex-col gap-3">
      <div className="flex items-center justify-between gap-3 px-1">
        <button type="button" onClick={() => changeMonth(-1)} className="rounded-lg p-2 hover:bg-surface-secondary text-text-secondary hover:text-text-primary transition-colors cursor-pointer" aria-label="Tháng trước">
          <ChevronLeft className="h-5 w-5" />
        </button>
        <div className="text-center">
          <h3 className="font-serif text-lg font-bold text-text-primary">Tháng {monthDate.getMonth() + 1}, {monthDate.getFullYear()}</h3>
          <p className="text-[10px] font-semibold text-text-tertiary">Dữ liệu phụng vụ thiết bị</p>
        </div>
        <button type="button" onClick={() => changeMonth(1)} className="rounded-lg p-2 hover:bg-surface-secondary text-text-secondary hover:text-text-primary transition-colors cursor-pointer" aria-label="Tháng sau">
          <ChevronRight className="h-5 w-5" />
        </button>
      </div>

      <AppBentoCard className="p-3 lg:p-3">
        <div className="mb-2 grid grid-cols-7 text-center text-[10px] font-extrabold text-text-secondary">
          {["CN", "T2", "T3", "T4", "T5", "T6", "T7"].map((label) => <span key={label}>{label}</span>)}
        </div>
        <div className="grid grid-cols-7 gap-1">
          {cells.map((date) => {
            const key = formatDateKey(date);
            const day = data.days[key];
            const selected = key === selectedDate;
            const inMonth = date.getMonth() === monthDate.getMonth();
            const accent = liturgicalAccent(day?.liturgicalColor);
            return (
              <button
                key={key}
                type="button"
                onClick={() => onSelectDate(key)}
                className="aspect-square rounded-lg border text-xs font-bold transition-all flex flex-col items-center justify-center py-1 cursor-pointer hover:border-brand-primary/50 lg:aspect-auto lg:h-16 xl:h-[72px]"
                style={{
                  backgroundColor: selected ? "#1F7A64" : day ? `${accent}12` : "transparent",
                  borderColor: selected ? "#1F7A64" : day ? "#E2DDD1" : "transparent",
                  color: selected ? "white" : inMonth ? "#1F2522" : "#8A938D",
                }}
                aria-label={`${weekdayShortFromDate(date)} ${key}`}
              >
                <span>{date.getDate()}</span>
                <span className="mt-0.5 block h-1 w-1 rounded-full" style={{ backgroundColor: selected ? "white" : day ? accent : "transparent" }} />
              </button>
            );
          })}
        </div>
      </AppBentoCard>
    </div>
  );
}

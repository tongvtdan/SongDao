"use client";

import React from "react";
import { ChevronLeft, ChevronRight, Calendar } from "lucide-react";
import { CalendarDay, Celebration } from "../lib/types";

interface LiturgicalContextCardProps {
  date: string;
  calendarDay: CalendarDay;
  celebrations: Celebration[];
  onNavigate: (daysOffset: number) => void;
  onGoToToday: () => void;
  isToday: boolean;
}

// Liturgical color styling selectors
const railColorMap: Record<string, string> = {
  green: "border-l-4 border-l-[#2F7D4F]",
  white: "border-l-4 border-l-[#E2DDD1]",
  gold: "border-l-4 border-l-[#C69A3D]",
  red: "border-l-4 border-l-[#B33A3A]",
  purple: "border-l-4 border-l-[#6B4A7A]",
  rose: "border-l-4 border-l-[#C9788D]",
  black: "border-l-4 border-l-[#242424]",
};

const badgeColorMap: Record<string, string> = {
  green: "bg-[#2F7D4F] text-white",
  white: "bg-[#F7F3E8] border border-[#E2DDD1] text-[#1F2522]",
  gold: "bg-[#C69A3D] text-[#1F2522]",
  red: "bg-[#B33A3A] text-white",
  purple: "bg-[#6B4A7A] text-white",
  rose: "bg-[#C9788D] text-white",
  black: "bg-[#242424] text-white",
};

// Vietnamese label formatter for seasons
const seasonLabelMap: Record<string, string> = {
  ordinary: "Mùa Thường Niên",
  advent: "Mùa Vọng",
  christmas: "Mùa Giáng Sinh",
  lent: "Mùa Chay",
  easter: "Mùa Phục Sinh",
  unknown: "Ngoại Phụ Phụng Vụ",
};

export default function LiturgicalContextCard({
  date,
  calendarDay,
  celebrations,
  onNavigate,
  onGoToToday,
  isToday,
}: LiturgicalContextCardProps) {
  // Format solar date beautifully
  const formatSolarDate = (dateStr: string) => {
    try {
      const d = new Date(dateStr);
      const weekdayNames = [
        "Chúa Nhật",
        "Thứ Hai",
        "Thứ Ba",
        "Thứ Tư",
        "Thứ Năm",
        "Thứ Sáu",
        "Thứ Bảy",
      ];
      const day = d.getDate();
      const month = d.getMonth() + 1;
      const year = d.getFullYear();
      const dayOfWeek = weekdayNames[d.getDay()];
      return `${dayOfWeek}, ngày ${day} tháng ${month} năm ${year}`;
    } catch {
      return dateStr;
    }
  };

  const liturgicalColor = calendarDay.liturgicalColor?.toLowerCase() || "green";
  const railStyle = railColorMap[liturgicalColor] || "border-l-4 border-l-border-subtle";
  const badgeStyle = badgeColorMap[liturgicalColor] || "bg-brand-primary text-white";

  return (
    <div className={`bg-surface-primary rounded-lg border border-border-subtle shadow-sm overflow-hidden p-5 flex flex-col gap-4 ${railStyle} transition-all duration-300`}>
      {/* Upper Navigation Row */}
      <div className="flex items-center justify-between pb-3 border-b border-border-subtle">
        <button
          onClick={() => onNavigate(-1)}
          className="p-1.5 rounded-full hover:bg-surface-secondary text-text-secondary transition-colors"
          title="Ngày trước"
        >
          <ChevronLeft className="w-5 h-5" />
        </button>
        
        <div className="flex items-center gap-2">
          <span className="font-serif font-semibold text-lg text-text-primary">
            Sống Đạo
          </span>
          {!isToday && (
            <button
              onClick={onGoToToday}
              className="text-xs px-2.5 py-1 rounded-full bg-brand-soft text-brand-deep hover:bg-brand-primary hover:text-white font-semibold transition-all"
            >
              Hôm nay
            </button>
          )}
        </div>

        <button
          onClick={() => onNavigate(1)}
          className="p-1.5 rounded-full hover:bg-surface-secondary text-text-secondary transition-colors"
          title="Ngày sau"
        >
          <ChevronRight className="w-5 h-5" />
        </button>
      </div>

      {/* Date and Season details */}
      <div className="flex flex-col gap-2">
        <div className="flex items-start justify-between gap-3">
          <div className="flex flex-col gap-1">
            <h1 className="text-sm font-semibold text-text-secondary flex items-center gap-1.5">
              <Calendar className="w-4 h-4 text-brand-primary" />
              {formatSolarDate(date)}
            </h1>
            {calendarDay.lunarDate && (
              <p className="text-xs text-text-tertiary">
                Âm lịch: {calendarDay.lunarDate}
              </p>
            )}
          </div>
          <span className={`text-xs px-2.5 py-1 rounded-full font-bold uppercase tracking-wider select-none ${badgeStyle}`}>
            {calendarDay.liturgicalColor}
          </span>
        </div>

        {/* Liturgical season name and week */}
        <div className="mt-2 bg-surface-secondary p-3 rounded-md border border-border-subtle flex flex-col gap-1">
          <div className="flex items-center justify-between">
            <span className="text-xs text-text-secondary font-semibold">
              {seasonLabelMap[calendarDay.season?.toLowerCase()] || calendarDay.season}
            </span>
            {calendarDay.cycleYear && (
              <span className="text-xs px-2 py-0.5 rounded bg-surface-container font-mono text-text-secondary font-bold">
                Năm {calendarDay.cycleYear}
              </span>
            )}
          </div>
          {calendarDay.liturgicalWeek && (
            <h2 className="font-serif text-base font-semibold text-text-primary">
              {calendarDay.liturgicalWeek}
            </h2>
          )}
        </div>

        {/* Feast celebrations */}
        {celebrations.length > 0 && (
          <div className="mt-3 flex flex-col gap-1.5">
            <span className="text-[11px] uppercase tracking-wider text-text-tertiary font-bold">
              Phụng vụ trong ngày
            </span>
            <ul className="flex flex-col gap-1.5">
              {celebrations.map((c) => (
                <li
                  key={c.id}
                  className="text-sm text-text-primary font-medium pl-3 relative before:content-[''] before:absolute before:left-0 before:top-2 before:w-1.5 before:h-1.5 before:rounded-full before:bg-accent-gold"
                >
                  {c.title}
                  {c.rank && c.rank !== "weekday" && c.rank !== "sunday" && (
                    <span className="ml-1.5 text-[10px] px-1.5 py-0.5 bg-surface-container text-text-secondary rounded-sm font-semibold capitalize">
                      {c.rank === "optional_memorial" ? "Lễ nhớ tự do" : c.rank === "memorial" ? "Lễ nhớ" : c.rank}
                    </span>
                  )}
                </li>
              ))}
            </ul>
          </div>
        )}
      </div>
    </div>
  );
}

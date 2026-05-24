"use client";

import React from "react";
import { Shield } from "lucide-react";
import LiturgicalContextCard from "./LiturgicalContextCard";
import DailyActionCard from "./DailyActionCard";
import ReflectionNoteCard from "./ReflectionNoteCard";
import ReadingReferencesCard from "./ReadingReferencesCard";
import DailyReflectionCard from "./DailyReflectionCard";
import CalendarGrid from "./CalendarGrid";
import ProgressTracker from "./ProgressTracker";
import PrayerLibrary from "./PrayerLibrary";
import SettingsPanel from "./SettingsPanel";
import { TodayViewData } from "@/lib/types";
import { liturgicalAccent } from "./ui";

interface DesktopDashboardProps {
  data: TodayViewData;
  isToday: boolean;
  todayKey: string;
  isCompleting: boolean;
  isSavingNote: boolean;
  onComplete: () => void;
  onSaveNote: (note: string) => void;
  onNavigate: (offset: number) => void;
  onGoToToday: () => void;
  onSelectDate: (date: string) => void;
  onSettingsChange: () => void;
}

export default function DesktopDashboard({
  data,
  isToday,
  todayKey,
  isCompleting,
  isSavingNote,
  onComplete,
  onSaveNote,
  onNavigate,
  onGoToToday,
  onSelectDate,
  onSettingsChange,
}: DesktopDashboardProps) {
  const accent = liturgicalAccent(data.calendarDay.liturgicalColor);

  return (
    <div className="hidden lg:grid lg:grid-cols-12 lg:gap-6 w-full mx-auto max-w-7xl px-2">
      {/* LEFT COLUMN: Date & Calendar (col-span-3) */}
      <aside className="col-span-3 flex flex-col gap-4 lg:sticky lg:top-[73px] lg:h-[calc(100vh-95px)] lg:overflow-y-auto pr-1 scrollbar-thin">
        <div className="shrink-0">
          <LiturgicalContextCard
            date={data.date}
            calendarDay={data.calendarDay}
            celebrations={data.celebrations}
            showLunarDate={data.showLunarDate}
            isToday={isToday}
            onNavigate={onNavigate}
            onGoToToday={onGoToToday}
          />
        </div>
        <div className="border-t border-border-subtle pt-4 shrink-0">
          <CalendarGrid selectedDate={data.date} onSelectDate={onSelectDate} />
        </div>
      </aside>

      {/* CENTER COLUMN: Main Content / Today Action (col-span-5) */}
      <main className="col-span-5 flex flex-col gap-4">
        <DailyActionCard
          action={data.action}
          log={data.log}
          accentColor={accent}
          onComplete={onComplete}
          isCompleting={isCompleting}
        />
        {data.log?.status === "completed" && (
          <ReflectionNoteCard
            key={`${data.log.id}_${data.log.updatedAt}`}
            initialNote={data.log.note || ""}
            onSave={onSaveNote}
            isSaving={isSavingNote}
          />
        )}
        <ReadingReferencesCard readings={data.readings} />
        {data.reflection && <DailyReflectionCard reflection={data.reflection} />}
        
        <div className="flex items-start gap-2 rounded-lg border border-border-subtle bg-surface-secondary p-3 text-xs leading-relaxed text-text-secondary">
          <Shield className="mt-0.5 h-4 w-4 shrink-0 text-brand-primary" />
          <span>Lịch sử hoàn thành và ghi chú cá nhân chỉ lưu trong trình duyệt trên thiết bị này.</span>
        </div>
      </main>

      {/* RIGHT COLUMN: Progress & Library (col-span-4) */}
      <aside className="col-span-4 flex flex-col gap-6 lg:sticky lg:top-[73px] lg:h-[calc(100vh-95px)] lg:overflow-y-auto pl-1 scrollbar-thin">
        <div className="shrink-0">
          <h2 className="font-serif text-lg font-bold text-text-primary px-1 mb-2">Thực hành tuần này</h2>
          <ProgressTracker compact={true} />
        </div>
        <div className="border-t border-border-subtle pt-4 shrink-0">
          <PrayerLibrary maxHeight="300px" />
        </div>
        <div className="border-t border-border-subtle pt-4 pb-4 shrink-0">
          <h2 className="font-serif text-lg font-bold text-text-primary px-1 mb-2">Cài đặt & Bảo mật</h2>
          <SettingsPanel onSettingsChange={onSettingsChange} />
        </div>
      </aside>
    </div>
  );
}

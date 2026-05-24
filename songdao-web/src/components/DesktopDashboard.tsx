"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { CalendarDays, ChartNoAxesColumnIncreasing, Church, Library, Settings, Shield } from "lucide-react";
import ReflectionNoteCard from "./ReflectionNoteCard";
import ReadingReferencesCard from "./ReadingReferencesCard";
import DailyReflectionCard from "./DailyReflectionCard";
import CalendarGrid from "./CalendarGrid";
import ProgressTracker from "./ProgressTracker";
import PrayerLibrary from "./PrayerLibrary";
import SettingsPanel from "./SettingsPanel";
import LiturgicalRibbon from "./LiturgicalRibbon";
import RitualActionPanel from "./RitualActionPanel";
import DesktopSideDrawer from "./DesktopSideDrawer";
import WeekRhythmStrip from "./WeekRhythmStrip";
import { TodayViewData } from "@/lib/types";
import { cn, liturgicalAccent } from "./ui";

interface DesktopDashboardProps {
  data: TodayViewData;
  isToday: boolean;
  isCompleting: boolean;
  isSavingNote: boolean;
  onComplete: () => void;
  onSaveNote: (note: string) => void;
  onNavigate: (offset: number) => void;
  onGoToToday: () => void;
  onSelectDate: (date: string) => void;
  onSettingsChange: () => void;
}

type DrawerView = "calendar" | "prayers" | "progress" | "settings";

export default function DesktopDashboard({
  data,
  isToday,
  isCompleting,
  isSavingNote,
  onComplete,
  onSaveNote,
  onNavigate,
  onGoToToday,
  onSelectDate,
  onSettingsChange,
}: DesktopDashboardProps) {
  const router = useRouter();
  const accent = liturgicalAccent(data.calendarDay.liturgicalColor);
  const [drawerView, setDrawerView] = useState<DrawerView | null>(null);
  const drawerTitle = drawerView ? drawerLabels[drawerView] : "Bảng phụ";
  const primaryCelebration = data.celebrations[0];
  const eventLabel = primaryCelebration
    ? eventRankLabel(primaryCelebration.rank, primaryCelebration.isSolemnity, primaryCelebration.isHolyDay, primaryCelebration.isSunday)
    : "Ngày phụng vụ";

  const openDrawer = (view: DrawerView) => setDrawerView(view);

  return (
    <div className="hidden w-full lg:block">
      <div className="mx-auto flex max-w-6xl flex-col gap-5">
        <header className="ritual-enter flex flex-wrap items-center justify-between gap-4 rounded-lg border border-border-subtle bg-surface-primary/95 p-4 shadow-sm backdrop-blur">
          <div className="flex min-w-0 items-center gap-3">
            <span
              className="flex h-12 w-12 shrink-0 items-center justify-center rounded-lg text-white shadow-sm"
              style={{ backgroundColor: accent }}
              aria-hidden="true"
            >
              <Church className="h-6 w-6" />
            </span>
            <div className="min-w-0">
              <p className="text-xs font-extrabold uppercase text-brand-primary">{eventLabel}</p>
              <h2 className="truncate font-serif text-xl font-extrabold text-text-primary">
                {primaryCelebration?.title || "Sống đạo hôm nay"}
              </h2>
              <p className="mt-1 text-xs font-semibold text-text-secondary">
                {data.calendarDay.liturgicalWeek || "Ngữ cảnh phụng vụ"} · {data.action.durationMinutes || 5} phút thực hành
              </p>
            </div>
          </div>

          <nav className="flex flex-wrap items-center gap-3" aria-label="Today desktop menu">
            <DrawerButton icon={<CalendarDays className="h-6 w-6" />} label="Lịch" onClick={() => router.push("/calendar")} />
            <DrawerButton icon={<ChartNoAxesColumnIncreasing className="h-6 w-6" />} label="Nhịp sống" onClick={() => openDrawer("progress")} />
            <DrawerButton icon={<Library className="h-6 w-6" />} label="Kinh nguyện" onClick={() => openDrawer("prayers")} />
            <DrawerButton icon={<Settings className="h-6 w-6" />} label="Cài đặt" onClick={() => openDrawer("settings")} />
          </nav>
        </header>

        <main className="grid gap-5">
          <div className="grid gap-5 xl:grid-cols-[minmax(330px,0.82fr)_minmax(0,1.18fr)]">
            <LiturgicalRibbon
              key={`ribbon-${data.date}`}
              date={data.date}
              calendarDay={data.calendarDay}
              celebrations={data.celebrations}
              showLunarDate={data.showLunarDate}
              isToday={isToday}
              accentColor={accent}
              onNavigate={onNavigate}
              onGoToToday={onGoToToday}
              onOpenCalendar={() => router.push("/calendar")}
            />
            <div className="grid gap-4">
              <RitualActionPanel
                key={`action-${data.date}-${data.log?.status || "pending"}`}
                action={data.action}
                log={data.log}
                accentColor={accent}
                onComplete={onComplete}
                isCompleting={isCompleting}
              />
            </div>
          </div>

          {data.log?.status === "completed" && (
            <div className="ritual-note-reveal">
              <ReflectionNoteCard
                key={`${data.log.id}_${data.log.updatedAt}`}
                initialNote={data.log.note || ""}
                onSave={onSaveNote}
                isSaving={isSavingNote}
              />
            </div>
          )}

          <div className="grid gap-5 xl:grid-cols-[minmax(0,1.15fr)_minmax(320px,0.85fr)]">
            <div className="grid gap-5">
              <ReadingReferencesCard readings={data.readings} />
              {data.reflection && <DailyReflectionCard reflection={data.reflection} />}
            </div>
            <div className="grid content-start gap-5">
              <WeekRhythmStrip selectedDate={data.date} onSelectDate={onSelectDate} />
              <div className="flex items-start gap-2 rounded-lg border border-border-subtle bg-surface-secondary p-3 text-xs leading-relaxed text-text-secondary">
                <Shield className="mt-0.5 h-4 w-4 shrink-0 text-brand-primary" />
                <span>Lịch sử hoàn thành và ghi chú cá nhân chỉ lưu trong trình duyệt trên thiết bị này.</span>
              </div>
            </div>
          </div>
        </main>
      </div>

      <DesktopSideDrawer isOpen={Boolean(drawerView)} title={drawerTitle} onClose={() => setDrawerView(null)}>
        <div className="mb-5 grid grid-cols-4 gap-2 rounded-lg bg-surface-secondary p-1">
          {(Object.keys(drawerLabels) as DrawerView[]).map((view) => (
            <button
              key={view}
              type="button"
              onClick={() => setDrawerView(view)}
              className={cn(
                "rounded-md px-2 py-2 text-xs font-extrabold transition-colors",
                drawerView === view ? "bg-surface-primary text-brand-primary shadow-sm" : "text-text-secondary hover:text-text-primary"
              )}
            >
              {drawerShortLabels[view]}
            </button>
          ))}
        </div>

        {drawerView === "calendar" && <CalendarGrid selectedDate={data.date} onSelectDate={onSelectDate} />}
        {drawerView === "progress" && <ProgressTracker compact={false} />}
        {drawerView === "prayers" && <PrayerLibrary />}
        {drawerView === "settings" && <SettingsPanel onSettingsChange={onSettingsChange} />}
      </DesktopSideDrawer>
    </div>
  );
}

function DrawerButton({ icon, label, onClick }: { icon: React.ReactNode; label: string; onClick: () => void }) {
  return (
    <button
      type="button"
      onClick={onClick}
      className="inline-flex min-h-16 items-center gap-3 rounded-lg border border-border-subtle bg-surface-primary px-5 py-3 text-lg font-extrabold text-text-secondary shadow-sm transition hover:-translate-y-0.5 hover:border-brand-primary/40 hover:bg-brand-soft/35 hover:text-brand-primary"
    >
      {icon}
      {label}
    </button>
  );
}

const drawerLabels: Record<DrawerView, string> = {
  calendar: "Lịch phụng vụ",
  progress: "Nhịp sống đạo",
  prayers: "Kinh nguyện",
  settings: "Cài đặt & bảo mật",
};

const drawerShortLabels: Record<DrawerView, string> = {
  calendar: "Lịch",
  progress: "Nhịp",
  prayers: "Kinh",
  settings: "Cài đặt",
};

function eventRankLabel(rank: string, isSolemnity: boolean, isHolyDay: boolean, isSunday: boolean): string {
  if (isHolyDay) return "Lễ buộc hôm nay";
  if (isSolemnity) return "Lễ trọng hôm nay";
  if (isSunday) return "Chúa Nhật hôm nay";
  switch (rank) {
    case "feast":
      return "Lễ kính hôm nay";
    case "memorial":
      return "Lễ nhớ hôm nay";
    default:
      return "Sự kiện hôm nay";
  }
}

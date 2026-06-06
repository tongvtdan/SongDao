"use client";

import React, { use, useState } from "react";
import { useRouter } from "next/navigation";
import { Shield } from "lucide-react";
import AppShell from "@/components/AppShell";
import DailyActionCard from "@/components/DailyActionCard";
import DailyReflectionCard from "@/components/DailyReflectionCard";
import LiturgicalContextCard from "@/components/LiturgicalContextCard";
import ReadingReferencesCard from "@/components/ReadingReferencesCard";
import ReflectionNoteCard from "@/components/ReflectionNoteCard";
import DesktopDashboard from "@/components/DesktopDashboard";
import { trackEvent } from "@/lib/analytics";
import { getDateKey } from "@/lib/engine";
import { markCompleted, saveNote } from "@/lib/storage";
import { getTodayView, nextDateKey, previousDateKey } from "@/lib/views";
import { useHydrated } from "@/lib/useHydrated";
import { liturgicalAccent } from "@/components/ui";

interface TodayPageProps {
  params: Promise<{ date: string }>;
}

export default function TodayPage({ params }: TodayPageProps) {
  const { date } = use(params);
  const router = useRouter();
  const [refreshKey, setRefreshKey] = useState(0);
  const [isCompleting, setIsCompleting] = useState(false);
  const [isSavingNote, setIsSavingNote] = useState(false);
  const hydrated = useHydrated();
  const data = getTodayView(date, hydrated);
  void refreshKey;
  const todayKey = getDateKey();


  const complete = () => {
    if (isCompleting) return;
    setIsCompleting(true);
    window.setTimeout(() => {
      markCompleted(data.action.id, data.date);
      trackEvent("action_completed");
      setIsCompleting(false);
      setRefreshKey((value) => value + 1);
    }, 220);
  };

  const persistNote = (note: string) => {
    if (isSavingNote) return;
    setIsSavingNote(true);
    window.setTimeout(() => {
      saveNote(data.action.id, data.date, note);
      trackEvent("note_saved");
      setIsSavingNote(false);
      setRefreshKey((value) => value + 1);
    }, 180);
  };

  const isToday = data.date === todayKey;

  return (
    <AppShell>
      {/* Mobile/Tablet Layout (< 1024px) */}
      <div className="flex flex-col gap-4 lg:hidden">
        <LiturgicalContextCard
          date={data.date}
          calendarDay={data.calendarDay}
          celebrations={data.celebrations}
          showLunarDate={data.showLunarDate}
          isToday={isToday}
          onNavigate={(offset) => router.push(`/today/${offset < 0 ? previousDateKey(data.date) : nextDateKey(data.date)}`)}
          onGoToToday={() => router.push(`/today/${todayKey}`)}
        />
        <DailyActionCard
          action={data.action}
          log={data.log}
          accentColor={liturgicalAccent(data.calendarDay.liturgicalColor)}
          onComplete={complete}
          isCompleting={isCompleting}
        />
        {data.log?.status === "completed" && (
          <ReflectionNoteCard key={`${data.log.id}_${data.log.updatedAt}`} initialNote={data.log.note || ""} onSave={persistNote} isSaving={isSavingNote} />
        )}
        <ReadingReferencesCard readings={data.readings} />
        {data.reflection && <DailyReflectionCard reflection={data.reflection} />}
        <div className="flex items-start gap-2 rounded-lg border border-border-subtle bg-surface-secondary p-3 text-xs leading-relaxed text-text-secondary">
          <Shield className="mt-0.5 h-4 w-4 shrink-0 text-brand-primary" />
          <span>Lịch sử hoàn thành và ghi chú cá nhân chỉ lưu trong trình duyệt trên thiết bị này.</span>
        </div>
      </div>

      {/* Desktop Dashboard Layout (>= 1024px) */}
      <DesktopDashboard
        data={data}
        isToday={isToday}
        isCompleting={isCompleting}
        isSavingNote={isSavingNote}
        onComplete={complete}
        onSaveNote={persistNote}
        onNavigate={(offset) => router.push(`/today/${offset < 0 ? previousDateKey(data.date) : nextDateKey(data.date)}`)}
        onGoToToday={() => router.push(`/today/${todayKey}`)}
        onSelectDate={(newDate) => router.push(`/today/${newDate}`)}
        onSettingsChange={() => setRefreshKey((value) => value + 1)}
      />
    </AppShell>
  );
}

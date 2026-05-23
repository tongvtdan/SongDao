/* eslint-disable react-hooks/set-state-in-effect */
"use client";

import React, { use, useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { MapPin, Shield, Check } from "lucide-react";

// Domain logic & services
import { contentLoader } from "@/lib/content";
import { selectDailyAction, getDateKey } from "@/lib/engine";
import { getActionLog, markCompleted, saveNote } from "@/lib/storage";
import { ActionLog } from "@/lib/types";

// UI Components
import LiturgicalContextCard from "@/components/LiturgicalContextCard";
import DailyActionCard from "@/components/DailyActionCard";
import ReflectionNoteCard from "@/components/ReflectionNoteCard";
import ReadingReferencesCard from "@/components/ReadingReferencesCard";
import DailyReflectionCard from "@/components/DailyReflectionCard";
import BottomNav from "@/components/BottomNav";

interface TodayPageProps {
  params: Promise<{ date: string }>;
}

export default function TodayPage({ params }: TodayPageProps) {
  const { date } = use(params);
  const router = useRouter();

  // Log state (loaded from client-side localStorage)
  const [log, setLog] = useState<ActionLog | null>(null);
  
  const [isCompleting, setIsCompleting] = useState(false);
  const [isSavingNote, setIsSavingNote] = useState(false);

  // 1. Fetch Calendar day synchronously in render path
  let calendarDay = contentLoader.getCalendarDay(date);
  if (!calendarDay) {
    // Fallback CalendarDay if not seeded in calendar packs
    calendarDay = {
      id: `calendar_day_${date}_vi`,
      date,
      locale: "vi",
      season: "unknown",
      liturgicalWeek: "",
      liturgicalColor: "green",
      cycleYear: "",
      lunarDate: undefined,
      weekday: "monday",
      isSunday: false,
    };
  }

  // 2. Fetch Celebrations & Readings & Reflections synchronously
  const celebrations = contentLoader.getCelebrations(date);
  const dayReadings = contentLoader.getReadings(date);
  
  // Sort readings by type hierarchy: First Reading -> Psalm -> Second Reading -> Gospel
  const sortedReadings = [...dayReadings].sort((a, b) => {
    const orderMap: Record<string, number> = {
      first: 0,
      first_reading: 0,
      psalm: 1,
      second: 2,
      second_reading: 2,
      alleluia: 3,
      gospel_acclamation: 3,
      gospel: 4,
    };
    const orderA = orderMap[a.type?.toLowerCase()] ?? 5;
    const orderB = orderMap[b.type?.toLowerCase()] ?? 5;
    return orderA - orderB;
  });

  const reflection = contentLoader.getReflection(date);

  // 3. Evaluate Daily Action synchronously
  const rules = contentLoader.getActionRules();
  const action = selectDailyAction(date, calendarDay, celebrations, rules);

  // 4. Load log client-side inside useEffect to avoid hydration mismatches
  useEffect(() => {
    setLog(getActionLog(action.id));
  }, [action.id]);

  // Navigate back/forward by days offset
  const handleNavigateDays = (offset: number) => {
    try {
      const current = new Date(date);
      current.setDate(current.getDate() + offset);
      const newDateKey = current.toISOString().slice(0, 10);
      router.push(`/today/${newDateKey}`);
    } catch (e) {
      console.error("Navigation error:", e);
    }
  };

  const handleGoToToday = () => {
    const todayKey = getDateKey(new Date());
    router.push(`/today/${todayKey}`);
  };

  // Complete action trigger
  const handleCompleteAction = () => {
    if (isCompleting) return;
    setIsCompleting(true);
    
    // Perform simulated latency for responsive checking animations
    setTimeout(() => {
      const updatedLog = markCompleted(action.id, date);
      setLog(updatedLog);
      setIsCompleting(false);
    }, 450);
  };

  // Save private reflection note trigger
  const handleSaveNote = (noteText: string) => {
    if (isSavingNote) return;
    setIsSavingNote(true);

    setTimeout(() => {
      const updatedLog = saveNote(action.id, date, noteText);
      setLog(updatedLog);
      setIsSavingNote(false);
    }, 400);
  };

  const isToday = date === getDateKey(new Date());
  const isSunday = calendarDay.weekday?.toLowerCase() === "sunday";

  return (
    <div className="flex flex-col flex-1 min-h-screen bg-canvas">
      {/* Header Bar */}
      <header className="sticky top-0 bg-surface-primary/95 backdrop-blur-md border-b border-border-subtle z-30 py-3.5 px-4 shadow-sm select-none">
        <div className="max-w-md mx-auto flex items-center justify-between">
          <span className="font-serif text-lg font-bold text-brand-primary tracking-tight">
            Sống Đạo
          </span>
          <div className="flex items-center gap-2">
            <span className="text-[10px] bg-brand-soft text-brand-deep px-2 py-0.5 rounded-full font-bold">
              Local-first
            </span>
          </div>
        </div>
      </header>

      {/* Main Column Scrollable Canvas */}
      <main className="flex-1 w-full max-w-md mx-auto px-4 py-5 flex flex-col gap-4">
        {/* 1. Liturgical Day Context */}
        <LiturgicalContextCard
          date={date}
          calendarDay={calendarDay}
          celebrations={celebrations}
          onNavigate={handleNavigateDays}
          onGoToToday={handleGoToToday}
          isToday={isToday}
        />

        {/* 2. Primary Daily Action Card */}
        <DailyActionCard
          action={action}
          log={log}
          onComplete={handleCompleteAction}
          isCompleting={isCompleting}
        />

        {/* 3. Reflection Note Card (Appears on Completion) */}
        {log?.status === "completed" && (
          <ReflectionNoteCard
            key={log.id + "_" + log.updatedAt}
            initialNote={log.note || ""}
            onSave={handleSaveNote}
            isSaving={isSavingNote}
          />
        )}

        {/* 4. Scripture Reading Citations */}
        <ReadingReferencesCard readings={sortedReadings} />

        {/* 5. Static Daily Reflection (If pack provides) */}
        {reflection && <DailyReflectionCard reflection={reflection} />}

        {/* 6. High-fidelity Parish / Mass schedule finder V1 */}
        <div className="bg-surface-primary rounded-lg border border-border-subtle shadow-sm p-5 flex flex-col gap-3">
          <div className="flex items-center justify-between pb-2 border-b border-border-subtle">
            <h4 className="font-serif text-sm font-bold text-text-primary flex items-center gap-1.5">
              <MapPin className="w-4 h-4 text-brand-primary" />
              Giáo xứ của tôi
            </h4>
            <span className="text-[10px] bg-brand-soft text-[#1F7A64] font-bold px-2 py-0.5 rounded-full flex items-center gap-0.5">
              <Check className="w-3 h-3" />
              Đã lưu
            </span>
          </div>

          <div className="flex flex-col gap-1.5">
            <span className="text-xs font-bold text-text-primary">
              Nhà thờ Tân Định
            </span>
            <p className="text-[11px] text-text-secondary leading-normal">
              289 Hai Bà Trưng, Phường 8, Quận 3, TP. Hồ Chí Minh
            </p>
          </div>

          {/* Dynamic Mass Times listing depending on day context */}
          <div className="mt-1.5 p-3 bg-surface-secondary rounded border border-border-subtle flex flex-col gap-1">
            <span className="text-[10px] font-bold text-text-secondary uppercase tracking-wider">
              {isSunday ? "Thánh Lễ Chúa Nhật Hôm Nay" : "Lễ Chúa Nhật Sắp Tới"}
            </span>
            <span className="text-xs font-serif font-bold text-brand-primary">
              05:00 • 06:15 • 07:30 • 09:00 • 16:00 • 17:30 • 19:00
            </span>
            <p className="text-[9px] text-text-tertiary mt-1">
              Giờ lễ thường ngày: 05:00 và 17:30 hàng ngày.
            </p>
          </div>
        </div>

        {/* Informative Security Banner */}
        <div className="flex items-center gap-2 p-3.5 bg-surface-secondary border border-border-subtle rounded-lg text-text-secondary text-[11px] leading-relaxed">
          <Shield className="w-4.5 h-4.5 text-brand-primary shrink-0" />
          <span>
            SongDao bảo vệ quyền riêng tư tuyệt đối của bạn. Lịch sử hoàn thành hành động và ghi chú cá nhân của bạn lưu trữ 100% trong bộ nhớ máy, không bao giờ gửi về máy chủ.
          </span>
        </div>

        {/* Bottom padding spacing */}
        <div className="h-10" />
      </main>

      {/* Sticky footer bottom navigation */}
      <BottomNav activeTab="today" />
    </div>
  );
}

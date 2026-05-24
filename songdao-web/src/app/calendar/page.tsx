"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import AppShell from "@/components/AppShell";
import CalendarGrid from "@/components/CalendarGrid";
import DailyReflectionCard from "@/components/DailyReflectionCard";
import ReadingReferencesCard from "@/components/ReadingReferencesCard";
import { getDateKey } from "@/lib/engine";
import { getCalendarDayDetail } from "@/lib/views";
import { useHydrated } from "@/lib/useHydrated";
import { AppBentoCard, AppSignalChip, colorLabel, formatVietnameseDate, liturgicalAccent, seasonLabel } from "@/components/ui";

export default function CalendarPage() {
  const todayKey = getDateKey();
  const [selectedDate, setSelectedDate] = useState(todayKey);
  const hydrated = useHydrated();
  const router = useRouter();
  const data = useMemo(() => getCalendarDayDetail(selectedDate, hydrated), [selectedDate, hydrated]);

  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth >= 1024) {
        router.replace(`/today/${selectedDate}`);
      }
    };
    handleResize();
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, [router, selectedDate]);

  return (
    <AppShell>
      <div>
        <h1 className="font-serif text-2xl font-bold text-text-primary">Lịch phụng vụ</h1>
        <p className="mt-1 text-sm text-text-secondary">Xem lịch phụng vụ và các bài đọc theo ngày.</p>
      </div>
      <CalendarGrid selectedDate={selectedDate} onSelectDate={setSelectedDate} />
      <SelectedDay data={data} />
    </AppShell>
  );
}

function SelectedDay({ data }: { data: ReturnType<typeof getCalendarDayDetail> }) {
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
            <Link href={`/today/${data.date}`} className="mt-3 inline-flex rounded-lg bg-brand-soft px-3 py-2 text-xs font-bold text-brand-deep cursor-pointer hover:bg-brand-soft/85 transition-colors">
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

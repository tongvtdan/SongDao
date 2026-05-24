"use client";

import { BookOpen, Clock } from "lucide-react";
import { getPrayerLibrary } from "@/lib/views";
import { AppBentoCard, AppSignalChip } from "./ui";

interface PrayerLibraryProps {
  maxHeight?: string;
}

export default function PrayerLibrary({ maxHeight }: PrayerLibraryProps) {
  const prayers = getPrayerLibrary();

  return (
    <div className="flex flex-col gap-4">
      <AppBentoCard accentColor="#1F7A64">
        <AppSignalChip label="5 phút" color="#1F7A64" icon={<Clock className="h-3.5 w-3.5" />} />
        <h3 className="mt-2.5 font-serif text-base font-bold text-text-primary">Kinh hằng ngày</h3>
        <p className="mt-1.5 text-xs leading-relaxed text-text-secondary">Bắt đầu hoặc kết thúc ngày bằng một lời kinh ngắn, không cần mở mạng.</p>
      </AppBentoCard>

      <h3 className="font-serif text-base font-bold px-1 text-text-primary">Thư viện kinh</h3>
      
      <div className="flex flex-col gap-3 scrollbar-thin" style={maxHeight ? { maxHeight, overflowY: "auto", paddingRight: "4px" } : undefined}>
        {prayers.length === 0 ? (
          <div className="shrink-0">
            <AppBentoCard>Chưa có kinh nguyện trong gói nội dung.</AppBentoCard>
          </div>
        ) : (
          prayers.map((prayer) => (
            <div key={prayer.id} className="shrink-0 hover:translate-x-0.5 transition-transform duration-200">
              <AppBentoCard>
                <details className="group">
                  <summary className="flex cursor-pointer list-none items-start gap-2.5 outline-none select-none">
                    <BookOpen className="mt-0.5 h-4 w-4 shrink-0 text-brand-primary" />
                    <span className="min-w-0 flex-1">
                      <span className="block text-sm font-semibold text-text-primary group-hover:text-brand-primary transition-colors">{prayer.title}</span>
                      <span className="mt-0.5 block text-[10px] text-text-secondary">{displayTags(prayer.tags)}</span>
                    </span>
                  </summary>
                  <p className="mt-2.5 whitespace-pre-line border-t border-border-subtle pt-2.5 text-xs leading-relaxed text-text-secondary">
                    {prayer.body || "Nội dung kinh đang chờ rà soát bản quyền. Bản beta chỉ lưu tiêu đề và nguồn để tránh dùng nội dung chưa được phép."}
                  </p>
                </details>
              </AppBentoCard>
            </div>
          ))
        )}
        <div className="h-1 shrink-0" />
      </div>
    </div>
  );
}

function displayTags(tags: string[]): string {
  const labels = tags.map((tag) => {
    switch (tag) {
      case "daily":
        return "Hằng ngày";
      case "morning":
        return "Buổi sáng";
      case "evening":
        return "Buổi tối";
      case "core":
        return "Cốt lõi";
      default:
        return null;
    }
  }).filter(Boolean);
  return labels.length ? labels.join(" · ") : "Kinh nguyện Công giáo";
}

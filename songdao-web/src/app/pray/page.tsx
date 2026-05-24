"use client";

import { BookOpen, Clock } from "lucide-react";
import AppShell from "@/components/AppShell";
import { getPrayerLibrary } from "@/lib/views";
import { AppBentoCard, AppSignalChip } from "@/components/ui";

export default function PrayPage() {
  const prayers = getPrayerLibrary();
  return (
    <AppShell>
      <div>
        <h1 className="font-serif text-2xl font-bold">Cầu nguyện</h1>
        <p className="mt-1 text-sm text-text-secondary">Một thư viện nhỏ để hỗ trợ việc sống đạo hằng ngày.</p>
      </div>
      <AppBentoCard accentColor="#1F7A64">
        <AppSignalChip label="5 phút" color="#1F7A64" icon={<Clock className="h-3.5 w-3.5" />} />
        <h2 className="mt-3 font-serif text-xl font-bold">Kinh hằng ngày</h2>
        <p className="mt-2 text-sm leading-relaxed text-text-secondary">Bắt đầu hoặc kết thúc ngày bằng một lời kinh ngắn, không cần mở mạng.</p>
      </AppBentoCard>
      <h2 className="font-serif text-xl font-bold">Thư viện kinh</h2>
      {prayers.length === 0 ? (
        <AppBentoCard>Chưa có kinh nguyện trong gói nội dung hiện tại.</AppBentoCard>
      ) : (
        prayers.map((prayer) => (
          <AppBentoCard key={prayer.id}>
            <details className="group">
              <summary className="flex cursor-pointer list-none items-start gap-3">
                <BookOpen className="mt-0.5 h-5 w-5 shrink-0 text-brand-primary" />
                <span className="min-w-0 flex-1">
                  <span className="block font-semibold text-text-primary">{prayer.title}</span>
                  <span className="mt-1 block text-xs text-text-secondary">{displayTags(prayer.tags)}</span>
                </span>
              </summary>
              <p className="mt-3 whitespace-pre-line border-t border-border-subtle pt-3 text-sm leading-relaxed text-text-secondary">
                {prayer.body || "Nội dung kinh đang chờ rà soát bản quyền. Bản beta chỉ lưu tiêu đề và nguồn để tránh dùng nội dung chưa được phép."}
              </p>
            </details>
          </AppBentoCard>
        ))
      )}
    </AppShell>
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

"use client";

import { BookOpen, ExternalLink } from "lucide-react";
import { Reading } from "@/lib/types";
import { AppSectionCard, readingLabel } from "./ui";

const MASS_READING_URL = "https://ktcgkpv.org/readings/mass-reading";

export default function ReadingReferencesCard({ readings }: { readings: Reading[] }) {
  const gospel = readings.find((reading) => reading.type === "gospel");
  const supporting = gospel ? readings.filter((reading) => reading.id !== gospel.id) : readings;

  return (
    <AppSectionCard title="Lời Chúa" icon={<BookOpen className="h-5 w-5 text-brand-primary" />}>
      {readings.length === 0 ? (
        <p>Chưa có tham chiếu bài đọc cho ngày này. Bạn vẫn có thể sống một hành động nhỏ hôm nay.</p>
      ) : (
        <div className="flex flex-col gap-3">
          {gospel && <ReadingLink reading={gospel} featured />}
          {supporting.length > 0 && <div className="h-px bg-border-subtle" />}
          {supporting.map((reading) => (
            <ReadingLink key={reading.id} reading={reading} />
          ))}
          <p className="border-t border-border-subtle pt-2 text-[10px] text-text-tertiary">
            Bản beta chỉ hiển thị tham chiếu để tôn trọng bản quyền nội dung Kinh Thánh.
          </p>
        </div>
      )}
    </AppSectionCard>
  );
}

function ReadingLink({ reading, featured = false }: { reading: Reading; featured?: boolean }) {
  const title = reading.displayLabel || readingLabel(reading.type);
  return (
    <a
      href={MASS_READING_URL}
      target="_blank"
      rel="noreferrer"
      className="flex items-center justify-between gap-3 rounded-lg p-2 transition-colors hover:bg-surface-secondary"
    >
      <span className="min-w-0">
        <span className="block text-[11px] font-extrabold uppercase tracking-wide text-brand-primary">{featured ? "Tin Mừng hôm nay" : title}</span>
        <span className={featured ? "font-serif text-xl font-semibold text-text-primary" : "text-sm font-semibold text-text-primary"}>{reading.citation}</span>
      </span>
      <ExternalLink className="h-4 w-4 shrink-0 text-brand-primary" />
    </a>
  );
}

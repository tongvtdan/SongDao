"use client";

import React from "react";
import { BookOpen, ExternalLink } from "lucide-react";
import { Reading } from "../lib/types";

interface ReadingReferencesCardProps {
  readings: Reading[];
}

const typeLabelMap: Record<string, string> = {
  first: "Bài đọc I",
  first_reading: "Bài đọc I",
  psalm: "Đáp ca",
  second: "Bài đọc II",
  second_reading: "Bài đọc II",
  alleluia: "Alleluia",
  gospel_acclamation: "Alleluia",
  gospel: "Tin Mừng",
};

export default function ReadingReferencesCard({ readings }: ReadingReferencesCardProps) {
  if (readings.length === 0) {
    return (
      <div className="bg-surface-primary rounded-lg border border-border-subtle p-5 text-center">
        <p className="text-sm text-text-secondary">Không tìm thấy tham chiếu bài đọc cho ngày này.</p>
      </div>
    );
  }

  return (
    <div className="bg-surface-primary rounded-lg border border-border-subtle shadow-sm p-5 flex flex-col gap-4">
      <h3 className="font-serif text-base font-bold text-text-primary flex items-center gap-2 pb-2 border-b border-border-subtle">
        <BookOpen className="w-4.5 h-4.5 text-brand-primary" />
        Tham chiếu Lời Chúa hôm nay
      </h3>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
        {readings.map((r) => {
          const typeLabel = typeLabelMap[r.type?.toLowerCase()] || r.displayLabel || "Bài đọc";
          const isGospel = r.type?.toLowerCase() === "gospel";
          
          return (
            <div
              key={r.id}
              className={`p-3 rounded-md border flex items-center justify-between gap-3 transition-colors ${
                isGospel 
                  ? "bg-[#FAF8F3] border-[#B8892E]/20" 
                  : "bg-surface-secondary border-border-subtle"
              }`}
            >
              <div className="flex flex-col gap-0.5">
                <span className={`text-[10px] uppercase font-bold tracking-wider ${
                  isGospel ? "text-accent-gold" : "text-text-secondary"
                }`}>
                  {typeLabel}
                </span>
                <span className="text-sm font-semibold text-text-primary font-serif">
                  {r.citation}
                </span>
              </div>
              
              {r.sourceUrl ? (
                <a
                  href={r.sourceUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="p-1 rounded-full hover:bg-surface-container text-brand-primary hover:text-brand-primary-pressed transition-colors"
                  title="Đọc toàn văn"
                >
                  <ExternalLink className="w-4 h-4" />
                </a>
              ) : (
                <span className="text-[10px] text-text-tertiary select-none">
                  Reference
                </span>
              )}
            </div>
          );
        })}
      </div>

      <p className="text-[10px] text-text-tertiary mt-2 border-t border-border-subtle pt-2 text-center">
        Lưu ý bản quyền: Tham chiếu trực tiếp đến Lời Chúa trong Thánh lễ theo lịch Phụng vụ Việt Nam.
      </p>
    </div>
  );
}

"use client";

import React from "react";
import { MessageSquareQuote, Quote } from "lucide-react";
import { DailyReflection } from "../lib/types";

interface DailyReflectionCardProps {
  reflection: DailyReflection;
}

export default function DailyReflectionCard({ reflection }: DailyReflectionCardProps) {
  return (
    <div className="bg-surface-primary rounded-lg border border-border-subtle shadow-sm p-5 flex flex-col gap-4 relative overflow-hidden">
      {/* Editorial backdrop quote element */}
      <Quote className="absolute right-4 top-4 w-16 h-16 text-brand-soft opacity-20 pointer-events-none" />

      <h3 className="font-serif text-base font-bold text-text-primary flex items-center gap-2 pb-2 border-b border-border-subtle z-10">
        <MessageSquareQuote className="w-4.5 h-4.5 text-brand-primary" />
        Suy niệm trong ngày
      </h3>

      <div className="flex flex-col gap-3.5 z-10">
        {reflection.title && (
          <h4 className="font-serif text-lg font-bold text-[#B8892E] leading-snug">
            {reflection.title}
          </h4>
        )}
        
        <p className="text-sm leading-relaxed text-text-secondary whitespace-pre-line font-serif italic">
          {reflection.body}
        </p>
      </div>
    </div>
  );
}

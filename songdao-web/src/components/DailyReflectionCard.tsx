"use client";

import { Lightbulb } from "lucide-react";
import { DailyReflection } from "@/lib/types";
import { AppBentoCard, AppSignalChip } from "./ui";

export default function DailyReflectionCard({ reflection }: { reflection: DailyReflection }) {
  return (
    <AppBentoCard>
      <AppSignalChip label="Suy niệm" color="#B8892E" icon={<Lightbulb className="h-3.5 w-3.5" />} />
      <h2 className="mt-3 font-serif text-base font-extrabold text-text-primary">{reflection.title}</h2>
      <p className="mt-2 text-sm leading-relaxed text-text-secondary">{reflection.body}</p>
    </AppBentoCard>
  );
}

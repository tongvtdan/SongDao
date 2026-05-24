"use client";

import Link from "next/link";
import { BookMarked, CalendarRange, Compass, LineChart } from "lucide-react";
import { cn } from "./ui";

const tabs = [
  { href: "/", match: "/today", label: "Hôm nay", icon: Compass },
  { href: "/calendar", match: "/calendar", label: "Lịch", icon: CalendarRange },
  { href: "/pray", match: "/pray", label: "Cầu nguyện", icon: BookMarked },
  { href: "/progress", match: "/progress", label: "Tiến trình", icon: LineChart },
];

export default function BottomNav({ activePath }: { activePath: string }) {
  return (
    <nav className="fixed inset-x-0 bottom-0 z-40 border-t border-border-subtle bg-surface-secondary/98 px-3 py-2 shadow-lg backdrop-blur lg:hidden">
      <div className="mx-auto grid max-w-2xl grid-cols-4 gap-1">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const active = tab.match === "/today" ? activePath.startsWith("/today") : activePath.startsWith(tab.match);
          return (
            <Link
              key={tab.match}
              href={tab.href}
              className={cn(
                "flex min-h-12 flex-col items-center justify-center gap-1 rounded-lg px-2 text-[10px] font-semibold transition-colors",
                active ? "bg-brand-soft text-brand-primary" : "text-text-secondary hover:bg-surface-primary hover:text-text-primary"
              )}
            >
              <Icon className="h-5 w-5" />
              <span className="truncate">{tab.label}</span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}

"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Settings } from "lucide-react";
import BottomNav from "./BottomNav";

export default function AppShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  return (
    <div className="flex min-h-screen flex-col bg-canvas text-text-primary">
      <header className="sticky top-0 z-30 border-b border-border-subtle bg-canvas/95 px-4 py-3 backdrop-blur">
        <div className="mx-auto flex max-w-2xl items-center justify-between">
          <Link href="/" className="font-serif text-lg font-bold text-brand-primary">
            Sống Đạo
          </Link>
          <Link
            href="/settings"
            className="rounded-lg p-2 text-text-secondary transition-colors hover:bg-surface-secondary hover:text-brand-primary"
            aria-label="Cài đặt"
          >
            <Settings className="h-5 w-5" />
          </Link>
        </div>
      </header>
      <main className="mx-auto flex w-full max-w-2xl flex-1 flex-col gap-4 px-4 py-4 pb-24">{children}</main>
      <BottomNav activePath={pathname} />
    </div>
  );
}

"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import AppShell from "@/components/AppShell";
import PrayerLibrary from "@/components/PrayerLibrary";
import { getDateKey } from "@/lib/engine";

export default function PrayPage() {
  const router = useRouter();

  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth >= 1024) {
        router.replace(`/today/${getDateKey()}`);
      }
    };
    handleResize();
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, [router]);

  return (
    <AppShell>
      <div>
        <h1 className="font-serif text-2xl font-bold text-text-primary">Cầu nguyện</h1>
        <p className="mt-1 text-sm text-text-secondary">Một thư viện nhỏ để hỗ trợ việc sống đạo hằng ngày.</p>
      </div>
      <PrayerLibrary />
    </AppShell>
  );
}

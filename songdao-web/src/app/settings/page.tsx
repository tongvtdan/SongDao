"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import AppShell from "@/components/AppShell";
import SettingsPanel from "@/components/SettingsPanel";
import { getDateKey } from "@/lib/engine";

export default function SettingsPage() {
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
      <h1 className="font-serif text-2xl font-bold text-text-primary">Cài đặt</h1>
      <SettingsPanel />
    </AppShell>
  );
}

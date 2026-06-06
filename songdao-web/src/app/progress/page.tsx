"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import AppShell from "@/components/AppShell";
import ProgressTracker from "@/components/ProgressTracker";
import { getDateKey } from "@/lib/engine";

export default function ProgressPage() {
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
        <h1 className="font-serif text-2xl font-bold text-text-primary">Nhịp sống đức tin</h1>
        <p className="mt-1 text-sm text-text-secondary">Riêng tư, nhẹ nhàng, chỉ lưu trên thiết bị.</p>
      </div>
      <ProgressTracker />
    </AppShell>
  );
}

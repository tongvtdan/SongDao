"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { getDateKey } from "@/lib/engine";

export default function Home() {
  const router = useRouter();

  useEffect(() => {
    if ("serviceWorker" in navigator) {
      navigator.serviceWorker.register("/sw.js").catch(() => undefined);
    }
    router.replace(`/today/${getDateKey(new Date())}`);
  }, [router]);

  return (
    <div className="flex min-h-screen items-center justify-center bg-canvas px-4 text-center text-text-secondary">
      <div className="flex flex-col items-center gap-4">
        <div className="h-10 w-10 animate-spin rounded-full border-4 border-brand-primary border-t-transparent" />
        <p className="text-sm font-bold">Đang mở nhịp sống đức tin hôm nay...</p>
      </div>
    </div>
  );
}

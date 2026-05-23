"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { getDateKey } from "@/lib/engine";

export default function Home() {
  const router = useRouter();

  useEffect(() => {
    // Register service worker for offline support
    if (typeof window !== "undefined" && "serviceWorker" in navigator) {
      window.addEventListener("load", () => {
        navigator.serviceWorker
          .register("/sw.js")
          .then((registration) => {
            console.log("ServiceWorker registered successfully with scope: ", registration.scope);
          })
          .catch((err) => {
            console.error("ServiceWorker registration failed: ", err);
          });
      });
    }

    // Resolve date and navigate
    const todayKey = getDateKey(new Date());
    router.replace(`/today/${todayKey}`);
  }, [router]);

  return (
    <div className="flex flex-col flex-1 items-center justify-center min-h-screen bg-canvas font-sans text-text-secondary">
      <div className="flex flex-col items-center gap-4">
        <div className="w-10 h-10 border-4 border-brand-primary border-t-transparent rounded-full animate-spin"></div>
        <p className="text-sm font-semibold animate-pulse">Đang kết nối nhịp sống đức tin...</p>
      </div>
    </div>
  );
}

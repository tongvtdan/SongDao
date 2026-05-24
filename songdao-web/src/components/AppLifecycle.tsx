"use client";

import { useEffect, useState } from "react";
import { WifiOff } from "lucide-react";
import { trackEvent } from "@/lib/analytics";
import { registerServiceWorker } from "@/lib/pwa";

export default function AppLifecycle() {
  const [offline, setOffline] = useState(false);

  useEffect(() => {
    registerServiceWorker();
    trackEvent("app_opened");

    const updateOnlineState = () => setOffline(!navigator.onLine);
    const handleBeforeInstallPrompt = () => trackEvent("pwa_install_prompt_shown");
    const handleAppInstalled = () => trackEvent("pwa_install_prompt_accepted");

    updateOnlineState();
    window.addEventListener("online", updateOnlineState);
    window.addEventListener("offline", updateOnlineState);
    window.addEventListener("beforeinstallprompt", handleBeforeInstallPrompt);
    window.addEventListener("appinstalled", handleAppInstalled);

    return () => {
      window.removeEventListener("online", updateOnlineState);
      window.removeEventListener("offline", updateOnlineState);
      window.removeEventListener("beforeinstallprompt", handleBeforeInstallPrompt);
      window.removeEventListener("appinstalled", handleAppInstalled);
    };
  }, []);

  if (!offline) return null;

  return (
    <div className="border-b border-border-subtle bg-surface-secondary px-4 py-2 text-xs font-semibold text-text-secondary">
      <div className="mx-auto flex max-w-7xl items-center gap-2">
        <WifiOff className="h-4 w-4 shrink-0 text-brand-primary" />
        <span>Bạn đang ngoại tuyến. Sống Đạo đang dùng nội dung đã lưu trên thiết bị.</span>
      </div>
    </div>
  );
}

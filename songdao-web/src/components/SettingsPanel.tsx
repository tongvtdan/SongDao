"use client";

import { useEffect, useState } from "react";
import { DEFAULT_SETTINGS, getUserSettings, setShowLunarDate } from "@/lib/storage";
import { AppBentoCard } from "./ui";
import { UserSettings } from "@/lib/types";

const privacyPolicyUrl = "https://songdao.dantino.com/privacy";

interface SettingsPanelProps {
  onSettingsChange?: (settings: UserSettings) => void;
}

export default function SettingsPanel({ onSettingsChange }: SettingsPanelProps) {
  const [settings, setSettings] = useState<UserSettings>(DEFAULT_SETTINGS);

  useEffect(() => {
    const id = window.setTimeout(() => setSettings(getUserSettings()), 0);
    return () => window.clearTimeout(id);
  }, []);

  const toggleLunar = (value: boolean) => {
    const updated = setShowLunarDate(value);
    setSettings(updated);
    if (onSettingsChange) {
      onSettingsChange(updated);
    }
  };

  return (
    <div className="flex flex-col gap-3">
      <AppBentoCard>
        <h3 className="font-serif text-sm font-bold text-text-primary">Lịch Việt</h3>
        <label className="mt-2.5 flex items-center justify-between gap-3 cursor-pointer">
          <span>
            <span className="block text-xs font-bold text-text-primary">Hiển thị ngày âm</span>
            <span className="mt-0.5 block text-[10px] text-text-secondary">Áp dụng cho tiếng Việt.</span>
          </span>
          <input type="checkbox" checked={settings.showLunarDate} onChange={(event) => toggleLunar(event.target.checked)} className="h-4 w-4 accent-brand-primary cursor-pointer" />
        </label>
      </AppBentoCard>

      <AppBentoCard>
        <h3 className="font-serif text-sm font-bold text-text-primary">Quyền riêng tư</h3>
        <div className="mt-1.5 text-[10px] leading-relaxed text-text-secondary flex flex-col gap-1">
          <p>Lịch sử thực hành và ghi chú lưu cục bộ trong trình duyệt.</p>
          <a href={privacyPolicyUrl} className="font-bold text-brand-primary hover:underline mt-1 inline-block" target="_blank" rel="noreferrer">
            Chính sách quyền riêng tư
          </a>
        </div>
      </AppBentoCard>

      <AppBentoCard className="py-2.5">
        <div className="flex items-center justify-between text-[10px]">
          <span className="text-text-secondary">Phiên bản web</span>
          <span className="font-bold text-text-primary">0.1.0</span>
        </div>
      </AppBentoCard>
    </div>
  );
}

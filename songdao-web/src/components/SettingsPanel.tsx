"use client";

import { useEffect, useRef, useState } from "react";
import { Download, Upload } from "lucide-react";
import { trackEvent } from "@/lib/analytics";
import { DEFAULT_SETTINGS, exportUserData, getUserSettings, importUserData, setShowLunarDate } from "@/lib/storage";
import { AppBentoCard } from "./ui";
import { ImportResult, UserSettings } from "@/lib/types";

const privacyPolicyUrl = "/privacy";

interface SettingsPanelProps {
  onSettingsChange?: (settings: UserSettings) => void;
}

export default function SettingsPanel({ onSettingsChange }: SettingsPanelProps) {
  const [settings, setSettings] = useState<UserSettings>(DEFAULT_SETTINGS);
  const [importResult, setImportResult] = useState<ImportResult | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

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

  const exportData = () => {
    const backup = exportUserData();
    const blob = new Blob([backup], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `songdao-backup-${new Date().toISOString().slice(0, 10)}.json`;
    link.click();
    URL.revokeObjectURL(url);
    trackEvent("export_used");
  };

  const importData = async (file: File | null) => {
    if (!file) return;
    const result = importUserData(await file.text());
    setImportResult(result);
    if (result.ok) {
      setSettings(getUserSettings());
      trackEvent("import_used");
      if (onSettingsChange) onSettingsChange(getUserSettings());
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
          <p>Lịch sử thực hành của bạn sẽ giữ nguyên trên thiết bị này trừ khi bạn xuất ra.</p>
          <a href={privacyPolicyUrl} className="font-bold text-brand-primary hover:underline mt-1 inline-block">
            Chính sách quyền riêng tư
          </a>
        </div>
      </AppBentoCard>

      <AppBentoCard>
        <h3 className="font-serif text-sm font-bold text-text-primary">Sao lưu cục bộ</h3>
        <p className="mt-1.5 text-[10px] leading-relaxed text-text-secondary">
          Xuất hoặc nhập lịch sử hoàn thành, ghi chú riêng và cài đặt. Tệp sao lưu không được gửi lên máy chủ.
        </p>
        <div className="mt-3 grid grid-cols-2 gap-2">
          <button type="button" onClick={exportData} className="inline-flex min-h-10 items-center justify-center gap-2 rounded-lg bg-brand-primary px-3 py-2 text-xs font-bold text-white">
            <Download className="h-4 w-4" />
            Xuất
          </button>
          <button type="button" onClick={() => fileInputRef.current?.click()} className="inline-flex min-h-10 items-center justify-center gap-2 rounded-lg border border-border-strong px-3 py-2 text-xs font-bold text-text-secondary">
            <Upload className="h-4 w-4" />
            Nhập
          </button>
        </div>
        <input
          ref={fileInputRef}
          type="file"
          accept="application/json,.json"
          className="hidden"
          onChange={(event) => {
            importData(event.target.files?.[0] || null);
            event.currentTarget.value = "";
          }}
        />
        {importResult && (
          <p className="mt-2 text-[10px] font-semibold text-text-secondary">
            {importResult.ok
              ? `Đã nhập ${importResult.importedLogs} mục thực hành${importResult.importedSettings ? " và cài đặt" : ""}.`
              : importResult.error}
          </p>
        )}
      </AppBentoCard>

      <AppBentoCard>
        <h3 className="font-serif text-sm font-bold text-text-primary">Lộ trình Sống Đạo</h3>
        <div className="mt-2 flex flex-col gap-2 text-[10px] leading-relaxed text-text-secondary">
          <p><strong className="text-text-primary">Có trong web beta:</strong> hành động hôm nay, lịch phụng vụ, tham chiếu bài đọc, ghi chú riêng, lưu cục bộ và PWA cơ bản.</p>
          <p><strong className="text-text-primary">Sắp tới:</strong> giáo xứ, giờ lễ quan trọng, widget iOS và nhắc nhở mạnh hơn trên app native.</p>
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

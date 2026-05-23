"use client";

import { useEffect, useState } from "react";
import AppShell from "@/components/AppShell";
import { DEFAULT_SETTINGS, getUserSettings, setShowLunarDate } from "@/lib/storage";
import { AppBentoCard } from "@/components/ui";
import { UserSettings } from "@/lib/types";

const privacyPolicyUrl = "https://songdao.dantino.com/privacy";

export default function SettingsPage() {
  const [settings, setSettings] = useState<UserSettings>(DEFAULT_SETTINGS);

  useEffect(() => {
    const id = window.setTimeout(() => setSettings(getUserSettings()), 0);
    return () => window.clearTimeout(id);
  }, []);

  const toggleLunar = (value: boolean) => {
    setSettings(setShowLunarDate(value));
  };

  return (
    <AppShell>
      <h1 className="font-serif text-2xl font-bold">Cài đặt</h1>
      <AppBentoCard>
        <h2 className="font-serif text-lg font-bold">Lịch Việt</h2>
        <label className="mt-3 flex items-center justify-between gap-3">
          <span>
            <span className="block text-sm font-bold text-text-primary">Hiển thị ngày âm</span>
            <span className="mt-1 block text-xs text-text-secondary">Ngày âm áp dụng cho giao diện tiếng Việt.</span>
          </span>
          <input type="checkbox" checked={settings.showLunarDate} onChange={(event) => toggleLunar(event.target.checked)} className="h-5 w-5 accent-brand-primary" />
        </label>
      </AppBentoCard>
      <AppBentoCard>
        <h2 className="font-serif text-lg font-bold">Nhắc nhở</h2>
        <p className="mt-2 text-sm leading-relaxed text-text-secondary">Thông báo cục bộ là lợi thế của ứng dụng di động. Bản web giữ dữ liệu riêng tư trong trình duyệt và không bật web push ở phiên bản này.</p>
      </AppBentoCard>
      <AppBentoCard>
        <h2 className="font-serif text-lg font-bold">Biểu tượng</h2>
        <p className="mt-2 text-sm leading-relaxed text-text-secondary">Biểu tượng theo mùa phụng vụ chỉ hỗ trợ trong ứng dụng iOS/Flutter, nơi Sống Đạo có thể dùng icon đã chuẩn bị sẵn.</p>
      </AppBentoCard>
      <AppBentoCard>
        <h2 className="font-serif text-lg font-bold">Quyền riêng tư</h2>
        <div className="mt-2 flex flex-col gap-2 text-sm leading-relaxed text-text-secondary">
          <p>Lịch sử thực hành và ghi chú của bạn được lưu trên thiết bị này, trừ khi bạn chủ động chọn sao lưu trong một phiên bản tương lai.</p>
          <p>Sống Đạo web hoạt động local-first cho Today, lịch, tiến trình và ghi chú. Không cần tài khoản.</p>
          <a href={privacyPolicyUrl} className="font-bold text-brand-primary" target="_blank" rel="noreferrer">Chính sách quyền riêng tư</a>
        </div>
      </AppBentoCard>
      <AppBentoCard>
        <div className="flex items-center justify-between gap-3 text-sm">
          <span className="text-text-secondary">Phiên bản</span>
          <span className="font-bold text-text-primary">0.1.0 web</span>
        </div>
      </AppBentoCard>
    </AppShell>
  );
}

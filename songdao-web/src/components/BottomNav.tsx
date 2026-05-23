"use client";

import React, { useState } from "react";
import { 
  CalendarRange, 
  BookMarked, 
  MapPin, 
  LineChart, 
  Smartphone,
  X,
  Compass
} from "lucide-react";

interface BottomNavProps {
  activeTab: string;
}

interface FeatureDetail {
  title: string;
  description: string;
  illustration: string;
}

const featureDetailsMap: Record<string, FeatureDetail> = {
  calendar: {
    title: "Lịch Phụng Vụ 2026 Toàn Diện",
    description: "Tra cứu đầy đủ mùa phụng vụ, các ngày lễ trọng, lễ kính, lễ nhớ và lễ nhớ tự do trong năm. Dữ liệu chuẩn xác, tự động tính âm lịch và các ngày đại lễ Công giáo.",
    illustration: "Xem trước lịch phụng vụ cả năm",
  },
  pray: {
    title: "Thư Viện Kinh Nguyện Offline",
    description: "Tổng hợp các kinh nguyện Công giáo cốt lõi, chuỗi hạt Mân Côi, chặng đàng Thánh Giá và hướng dẫn xét mình chuẩn bị xưng tội chi tiết, dễ đọc.",
    illustration: "Dành riêng cho giờ kinh gia đình",
  },
  church: {
    title: "Tìm Giờ Lễ & Giáo Xứ Gần Nhất",
    description: "Bản đồ số định vị các nhà thờ xung quanh bạn, cập nhật chính xác giờ lễ ngày thường và Chúa Nhật. Lưu thông tin giáo xứ của bạn để nhận thông báo quan trọng.",
    illustration: "Định vị nhà thờ & tra cứu giờ lễ",
  },
  progress: {
    title: "Theo Dõi Tiến Trình & Chuỗi Sống Đạo",
    description: "Biểu đồ trực quan ghi nhận nhịp điệu thực hành đức tin hằng tuần. Lưu giữ chuỗi ngày hoàn thành (streaks) nhẹ nhàng không áp lực, bảo mật tuyệt đối.",
    illustration: "Rèn luyện nhịp sống đức tin mỗi ngày",
  },
};

export default function BottomNav({ activeTab = "today" }: BottomNavProps) {
  const [modalOpen, setModalOpen] = useState(false);
  const [selectedFeature, setSelectedFeature] = useState<FeatureDetail | null>(null);

  const handleTabClick = (tabId: string) => {
    if (tabId === "today") return;
    
    const detail = featureDetailsMap[tabId];
    if (detail) {
      setSelectedFeature(detail);
      setModalOpen(true);
    }
  };

  return (
    <>
      <nav className="sticky bottom-0 left-0 right-0 bg-surface-secondary border-t border-border-subtle shadow-lg py-2 z-40 select-none">
        <div className="max-w-md mx-auto px-6 flex justify-between items-center gap-1">
          {/* Today tab */}
          <button
            onClick={() => handleTabClick("today")}
            className={`flex flex-col items-center gap-1 py-1 px-3.5 rounded-lg transition-all ${
              activeTab === "today"
                ? "text-brand-primary font-bold"
                : "text-text-secondary hover:text-text-primary"
            }`}
          >
            <Compass className="w-5.5 h-5.5" />
            <span className="text-[10px] tracking-tight">Hôm nay</span>
          </button>

          {/* Calendar tab */}
          <button
            onClick={() => handleTabClick("calendar")}
            className="flex flex-col items-center gap-1 py-1 px-3.5 rounded-lg text-text-secondary hover:text-text-primary transition-all"
          >
            <CalendarRange className="w-5.5 h-5.5" />
            <span className="text-[10px] tracking-tight">Lịch</span>
          </button>

          {/* Pray tab */}
          <button
            onClick={() => handleTabClick("pray")}
            className="flex flex-col items-center gap-1 py-1 px-3.5 rounded-lg text-text-secondary hover:text-text-primary transition-all"
          >
            <BookMarked className="w-5.5 h-5.5" />
            <span className="text-[10px] tracking-tight">Cầu nguyện</span>
          </button>

          {/* Church tab */}
          <button
            onClick={() => handleTabClick("church")}
            className="flex flex-col items-center gap-1 py-1 px-3.5 rounded-lg text-text-secondary hover:text-text-primary transition-all"
          >
            <MapPin className="w-5.5 h-5.5" />
            <span className="text-[10px] tracking-tight">Giáo xứ</span>
          </button>

          {/* Progress tab */}
          <button
            onClick={() => handleTabClick("progress")}
            className="flex flex-col items-center gap-1 py-1 px-3.5 rounded-lg text-text-secondary hover:text-text-primary transition-all"
          >
            <LineChart className="w-5.5 h-5.5" />
            <span className="text-[10px] tracking-tight">Tiến trình</span>
          </button>
        </div>
      </nav>

      {/* Elegant Beta feature overlay modal */}
      {modalOpen && selectedFeature && (
        <div className="fixed inset-0 bg-surface-inverse/40 backdrop-blur-sm z-50 flex items-end sm:items-center justify-center p-4 transition-all duration-300">
          <div 
            className="bg-surface-primary w-full max-w-md rounded-t-2xl sm:rounded-2xl border border-border-subtle shadow-2xl p-6 relative flex flex-col gap-5 animate-slide-up"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Close button */}
            <button
              onClick={() => setModalOpen(false)}
              className="absolute right-4 top-4 p-1.5 rounded-full hover:bg-surface-secondary text-text-secondary transition-colors"
            >
              <X className="w-4 h-4" />
            </button>

            {/* Smart Phone Graphics Indicator */}
            <div className="w-12 h-12 rounded-full bg-brand-soft flex items-center justify-center text-brand-primary">
              <Smartphone className="w-6 h-6" />
            </div>

            <div className="flex flex-col gap-2">
              <span className="text-[10px] uppercase font-bold text-accent-gold tracking-wider">
                Ứng dụng Sống Đạo di động
              </span>
              <h3 className="font-serif text-lg font-bold text-text-primary">
                {selectedFeature.title}
              </h3>
              <p className="text-xs md:text-sm leading-relaxed text-text-secondary">
                {selectedFeature.description}
              </p>
            </div>

            {/* In-app mockup visual note */}
            <div className="p-3 bg-surface-secondary rounded border border-border-subtle text-xs text-text-secondary italic text-center">
              📌 {selectedFeature.illustration}
            </div>

            {/* Action buttons */}
            <div className="flex flex-col gap-2 mt-2">
              <button
                onClick={() => setModalOpen(false)}
                className="w-full py-2.5 rounded bg-brand-primary hover:bg-brand-primary-pressed text-white text-sm font-semibold shadow-sm transition-colors"
              >
                Đăng ký tải App phiên bản Beta
              </button>
              <button
                onClick={() => setModalOpen(false)}
                className="w-full py-2 rounded bg-surface-primary hover:bg-surface-secondary text-text-secondary text-xs font-semibold border border-border-strong transition-colors"
              >
                Trở lại Hôm nay
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}

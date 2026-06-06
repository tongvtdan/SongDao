import React from "react";
import { CalendarDay } from "@/lib/types";

export function cn(...classes: Array<string | false | null | undefined>): string {
  return classes.filter(Boolean).join(" ");
}

export function AppBentoCard({
  children,
  className,
  accentColor,
  accentPlacement = "left",
  onClick,
}: {
  children: React.ReactNode;
  className?: string;
  accentColor?: string;
  accentPlacement?: "left" | "top";
  onClick?: () => void;
}) {
  const content = (
    <div className="relative overflow-hidden rounded-lg border border-border-subtle bg-surface-primary shadow-sm">
      {accentColor && (
        <div
          className={cn(
            "absolute bg-current",
            accentPlacement === "top" ? "left-0 right-0 top-0 h-1" : "bottom-0 left-0 top-0 w-1"
          )}
          style={{ color: accentColor }}
        />
      )}
      <div className={cn("p-4", className)}>{children}</div>
    </div>
  );

  if (!onClick) return content;
  return (
    <button type="button" onClick={onClick} className="block w-full rounded-lg text-left focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-primary focus-visible:ring-offset-1">
      {content}
    </button>
  );
}

export function AppSignalChip({
  label,
  color,
  icon,
}: {
  label: string;
  color?: string;
  icon?: React.ReactNode;
}) {
  return (
    <span
      className="inline-flex max-w-full items-center gap-1.5 rounded-full border border-border-subtle px-2.5 py-1 text-[11px] font-bold leading-tight text-text-secondary"
      style={{ backgroundColor: color ? `${color}24` : "#F3F0E8" }}
    >
      {icon}
      <span className="truncate">{label}</span>
    </span>
  );
}

export function AppSectionCard({
  title,
  icon,
  children,
}: {
  title: string;
  icon?: React.ReactNode;
  children: React.ReactNode;
}) {
  return (
    <AppBentoCard>
      <div className="mb-3 flex min-w-0 items-center gap-2">
        {icon}
        <h2 className="truncate font-serif text-base font-bold text-text-primary">{title}</h2>
      </div>
      <div className="text-sm leading-relaxed text-text-secondary">{children}</div>
    </AppBentoCard>
  );
}

export const liturgicalHex: Record<string, string> = {
  green: "#2F7D4F",
  white: "#F7F3E8",
  gold: "#C69A3D",
  red: "#B33A3A",
  purple: "#6B4A7A",
  rose: "#C9788D",
  black: "#242424",
};

const liturgicalDisplayHex: Record<string, string> = {
  ...liturgicalHex,
  white: "#B8892E",
};

export function liturgicalAccent(color?: string): string {
  return liturgicalDisplayHex[color || "green"] || "#1F7A64";
}

export function seasonLabel(season: string): string {
  switch (season) {
    case "advent":
      return "Mùa Vọng";
    case "christmas":
      return "Mùa Giáng Sinh";
    case "lent":
      return "Mùa Chay";
    case "easter":
      return "Mùa Phục Sinh";
    case "ordinary":
      return "Thường niên";
    default:
      return "Dữ liệu địa phương";
  }
}

export function colorLabel(color: string): string {
  switch (color) {
    case "green":
      return "Xanh";
    case "white":
      return "Trắng";
    case "gold":
      return "Vàng";
    case "red":
      return "Đỏ";
    case "purple":
      return "Tím";
    case "rose":
      return "Hồng";
    case "black":
      return "Đen";
    default:
      return "Phụng vụ";
  }
}

export function weekdayLabel(weekday: string): string {
  switch (weekday) {
    case "monday":
      return "Thứ Hai";
    case "tuesday":
      return "Thứ Ba";
    case "wednesday":
      return "Thứ Tư";
    case "thursday":
      return "Thứ Năm";
    case "friday":
      return "Thứ Sáu";
    case "saturday":
      return "Thứ Bảy";
    case "sunday":
      return "Chúa Nhật";
    default:
      return "Ngày";
  }
}

export function weekdayShortFromDate(date: Date): string {
  return ["CN", "T2", "T3", "T4", "T5", "T6", "T7"][date.getDay()];
}

export function formatVietnameseDate(dateKey: string, day?: CalendarDay): string {
  const [year, month, date] = dateKey.split("-").map(Number);
  const weekday = day?.weekday || new Date(year, month - 1, date).toLocaleDateString("en", { weekday: "long" }).toLowerCase();
  return `${weekdayLabel(weekday)}, ${String(date).padStart(2, "0")}/${String(month).padStart(2, "0")}/${year}`;
}

export function readingLabel(type: string): string {
  switch (type) {
    case "first":
    case "first_reading":
      return "Bài đọc I";
    case "second":
    case "second_reading":
      return "Bài đọc II";
    case "psalm":
      return "Đáp ca";
    case "alleluia":
    case "gospel_acclamation":
      return "Alleluia";
    case "gospel":
      return "Tin Mừng";
    default:
      return "Bài đọc";
  }
}

export const dailyQuotes = [
  "Một việc nhỏ được làm với lòng yêu mến có thể đổi hướng cả ngày.",
  "Bình an bắt đầu khi con trao cho Chúa điều con không tự giữ nổi.",
  "Đức tin lớn lên trong những lựa chọn rất nhỏ và rất thật.",
  "Hãy bắt đầu lại nhẹ nhàng; lòng thương xót luôn đi trước con.",
  "Yêu thương hôm nay không cần lớn tiếng, chỉ cần cụ thể.",
  "Một phút thinh lặng có thể mở lại cánh cửa của lòng mình.",
  "Chúa thường gặp ta trong bổn phận nhỏ đang ở ngay trước mặt.",
];

export function dailyQuoteFor(dateKey: string): string {
  const date = new Date(dateKey);
  const start = new Date(date.getFullYear(), 0, 0);
  const dayOfYear = Math.floor((date.getTime() - start.getTime()) / 86400000);
  return dailyQuotes[dayOfYear % dailyQuotes.length];
}

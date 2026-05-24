"use client";

import { useEffect } from "react";
import { X } from "lucide-react";

interface DesktopSideDrawerProps {
  isOpen: boolean;
  title: string;
  onClose: () => void;
  children: React.ReactNode;
}

export default function DesktopSideDrawer({ isOpen, title, onClose, children }: DesktopSideDrawerProps) {
  useEffect(() => {
    if (!isOpen) return;
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") onClose();
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-40">
      <button
        type="button"
        className="absolute inset-0 animate-[ritual-fade-in_180ms_ease_both] bg-text-primary/20 backdrop-blur-sm"
        onClick={onClose}
        aria-label="Đóng bảng phụ"
      />
      <aside
        className="absolute bottom-0 right-0 top-0 flex w-full max-w-md animate-[ritual-drawer-in_260ms_ease_both] flex-col border-l border-border-subtle bg-canvas shadow-xl"
        role="dialog"
        aria-modal="true"
        aria-label={title}
      >
        <div className="flex items-center justify-between border-b border-border-subtle bg-surface-primary px-5 py-4">
          <h2 className="font-serif text-lg font-extrabold text-text-primary">{title}</h2>
          <button type="button" onClick={onClose} className="ritual-icon-button" aria-label="Đóng">
            <X className="h-5 w-5" />
          </button>
        </div>
        <div className="flex-1 overflow-y-auto p-5 scrollbar-thin">{children}</div>
      </aside>
    </div>
  );
}

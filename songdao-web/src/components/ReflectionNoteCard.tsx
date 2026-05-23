/* eslint-disable react-hooks/set-state-in-effect */
"use client";

import React, { useState, useEffect } from "react";
import { PenLine, ShieldCheck, Check } from "lucide-react";

interface ReflectionNoteCardProps {
  initialNote: string;
  onSave: (note: string) => void;
  isSaving: boolean;
}

export default function ReflectionNoteCard({
  initialNote,
  onSave,
  isSaving,
}: ReflectionNoteCardProps) {
  const [note, setNote] = useState(initialNote);
  const [showSavedMsg, setShowSavedMsg] = useState(false);

  // Sync state if initialNote changes
  useEffect(() => {
    setNote(initialNote);
  }, [initialNote]);

  const handleSave = (val: string) => {
    onSave(val);
    setShowSavedMsg(true);
    setTimeout(() => {
      setShowSavedMsg(false);
    }, 2000);
  };

  const handleBlur = () => {
    if (note.trim() !== initialNote.trim()) {
      handleSave(note);
    }
  };

  const handleSaveClick = () => {
    handleSave(note);
  };

  return (
    <div className="bg-surface-primary rounded-lg border border-border-subtle shadow-sm p-5 flex flex-col gap-4 transition-all duration-300">
      <div className="flex items-center justify-between pb-2 border-b border-border-subtle">
        <h3 className="font-serif text-base font-bold text-text-primary flex items-center gap-2">
          <PenLine className="w-4 h-4 text-brand-primary" />
          Nhật ký suy niệm cá nhân
        </h3>
        <div className="flex items-center gap-1">
          {isSaving ? (
            <span className="text-xs text-text-secondary animate-pulse">Đang lưu...</span>
          ) : showSavedMsg ? (
            <span className="text-xs text-status-complete font-semibold flex items-center gap-1 animate-fade-in">
              <Check className="w-3.5 h-3.5" />
              Đã tự động lưu
            </span>
          ) : null}
        </div>
      </div>

      <div className="flex flex-col gap-2">
        <textarea
          value={note}
          onChange={(e) => setNote(e.target.value)}
          onBlur={handleBlur}
          placeholder="Hôm nay bạn rút ra bài học gì từ Tin Mừng, hay muốn dâng lời cầu nguyện nào..."
          className="w-full min-h-[100px] p-3 text-sm rounded-md bg-canvas border border-border-strong focus:outline-none focus:border-brand-primary focus:ring-1 focus:ring-brand-primary placeholder:text-text-tertiary transition-all"
        />
        
        <div className="flex items-center justify-between gap-3 mt-1">
          {/* Privacy promise */}
          <span className="text-[11px] text-text-secondary font-medium flex items-center gap-1.5 leading-none">
            <ShieldCheck className="w-4 h-4 text-brand-primary shrink-0" />
            Lưu offline, tuyệt đối riêng tư trên máy
          </span>

          <button
            onClick={handleSaveClick}
            disabled={isSaving || note.trim() === initialNote.trim()}
            className="text-xs px-3.5 py-1.5 rounded bg-brand-soft hover:bg-brand-primary hover:text-white font-semibold text-brand-deep border border-brand-primary/10 disabled:opacity-50 disabled:cursor-not-allowed transition-all"
          >
            Lưu ngay
          </button>
        </div>
      </div>
    </div>
  );
}

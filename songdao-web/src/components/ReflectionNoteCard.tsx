"use client";

import { useState } from "react";
import { Lock, Save } from "lucide-react";
import { AppSectionCard, cn } from "./ui";

interface Props {
  initialNote: string;
  onSave: (note: string) => void;
  isSaving: boolean;
}

export default function ReflectionNoteCard({ initialNote, onSave, isSaving }: Props) {
  const [note, setNote] = useState(initialNote);
  const isDirty = note.trim() !== initialNote.trim();

  return (
    <AppSectionCard title="Ghi chú riêng" icon={<Lock className="h-5 w-5 text-brand-primary" />}>
      <textarea
        value={note}
        onChange={(event) => setNote(event.target.value)}
        onBlur={() => {
          if (note.trim() !== initialNote.trim()) onSave(note);
        }}
        rows={4}
        placeholder="Viết một câu bạn muốn giữ lại cho hôm nay."
        className={cn(
          "min-h-28 w-full resize-y rounded-lg border bg-canvas p-3 text-sm text-text-primary outline-none transition-colors placeholder:text-text-tertiary",
          isDirty ? "border-accent-gold" : "border-border-subtle focus:border-border-focus"
        )}
      />
      <div className="mt-2 flex items-center justify-between gap-3">
        <p className="text-xs text-text-secondary">
          {isDirty ? <span className="font-semibold text-accent-gold">Chưa lưu</span> : "Lưu trên thiết bị của bạn."}
        </p>
        <button
          type="button"
          onClick={() => onSave(note)}
          disabled={isSaving || note.trim() === initialNote.trim()}
          className="inline-flex items-center gap-1.5 rounded-lg bg-brand-soft px-3 py-2 text-xs font-bold text-brand-deep disabled:cursor-not-allowed disabled:opacity-50"
        >
          <Save className="h-3.5 w-3.5" />
          {isSaving ? "Đang lưu..." : "Lưu"}
        </button>
      </div>
    </AppSectionCard>
  );
}

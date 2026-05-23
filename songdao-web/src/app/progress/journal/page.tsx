"use client";

import { useMemo, useState } from "react";
import { Edit, Plus, Search, Trash2 } from "lucide-react";
import AppShell from "@/components/AppShell";
import { getDateKey } from "@/lib/engine";
import { deleteNote, saveNote } from "@/lib/storage";
import { getJournalEntries, getTodayView } from "@/lib/views";
import { useHydrated } from "@/lib/useHydrated";
import { AppBentoCard, AppSectionCard } from "@/components/ui";
import { JournalEntry } from "@/lib/types";

export default function JournalPage() {
  const [query, setQuery] = useState("");
  const [editing, setEditing] = useState<JournalEntry | null>(null);
  const [draftDate, setDraftDate] = useState(getDateKey());
  const [draftNote, setDraftNote] = useState("");
  const [version, setVersion] = useState(0);
  const hydrated = useHydrated();
  const entries = useMemo(() => {
    void version;
    return getJournalEntries(query, hydrated);
  }, [query, version, hydrated]);

  const startNew = () => {
    setEditing(null);
    setDraftDate(getDateKey());
    setDraftNote("");
  };

  const startEdit = (entry: JournalEntry) => {
    setEditing(entry);
    setDraftDate(entry.log.date);
    setDraftNote(entry.note);
  };

  const persist = () => {
    const note = draftNote.trim();
    if (!note) return;
    const view = getTodayView(draftDate);
    saveNote(view.action.id, draftDate, note);
    setDraftNote("");
    setEditing(null);
    setVersion((value) => value + 1);
  };

  const remove = (entry: JournalEntry) => {
    deleteNote(entry.action.id);
    if (editing?.action.id === entry.action.id) startNew();
    setVersion((value) => value + 1);
  };

  return (
    <AppShell>
      <div>
        <h1 className="font-serif text-2xl font-bold">Ghi chú đức tin</h1>
        <p className="mt-1 text-sm text-text-secondary">Riêng tư và chỉ lưu trên thiết bị.</p>
      </div>
      <div className="relative">
        <Search className="pointer-events-none absolute left-3 top-3 h-4 w-4 text-text-tertiary" />
        <input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Tìm ghi chú hoặc việc đã làm" className="w-full rounded-lg border border-border-subtle bg-surface-secondary py-2.5 pl-9 pr-3 text-sm outline-none focus:border-border-focus" />
      </div>
      <AppBentoCard accentColor="#B8892E">
        <h2 className="font-serif text-lg font-bold">{editing ? "Sửa ghi chú" : "Thêm ghi chú"}</h2>
        <div className="mt-3 flex flex-col gap-3">
          <input type="date" value={draftDate} min="2026-01-01" max="2026-12-31" onChange={(event) => setDraftDate(event.target.value)} className="rounded-lg border border-border-subtle bg-canvas px-3 py-2 text-sm outline-none focus:border-border-focus" />
          <textarea value={draftNote} onChange={(event) => setDraftNote(event.target.value)} rows={4} placeholder="Viết một câu bạn muốn giữ lại." className="rounded-lg border border-border-subtle bg-canvas p-3 text-sm outline-none focus:border-border-focus" />
          <div className="flex justify-between gap-2">
            <button type="button" onClick={startNew} className="rounded-lg border border-border-strong px-3 py-2 text-xs font-bold text-text-secondary">Làm mới</button>
            <button type="button" onClick={persist} disabled={!draftNote.trim()} className="inline-flex items-center gap-1.5 rounded-lg bg-brand-primary px-4 py-2 text-xs font-bold text-white disabled:opacity-50">
              <Plus className="h-3.5 w-3.5" />
              Lưu
            </button>
          </div>
        </div>
      </AppBentoCard>
      {entries.length === 0 ? (
        <AppSectionCard title="Chưa có ghi chú">{query.trim() ? "Không tìm thấy ghi chú phù hợp." : "Khi bạn ghi lại một câu riêng tư, nó sẽ hiện ở đây."}</AppSectionCard>
      ) : (
        entries.map((entry) => (
          <AppBentoCard key={entry.log.id}>
            <div className="flex items-start gap-3">
              <div className="min-w-0 flex-1">
                <p className="text-xs font-extrabold text-brand-primary">{entry.log.date}</p>
                <p className="mt-1 text-sm font-bold text-text-secondary">{entry.action.prompt}</p>
              </div>
              <button type="button" onClick={() => startEdit(entry)} className="rounded-lg p-2 text-text-secondary hover:bg-surface-secondary" aria-label="Sửa">
                <Edit className="h-4 w-4" />
              </button>
              <button type="button" onClick={() => remove(entry)} className="rounded-lg p-2 text-text-secondary hover:bg-surface-secondary" aria-label="Xóa">
                <Trash2 className="h-4 w-4" />
              </button>
            </div>
            <p className="mt-3 whitespace-pre-line text-sm leading-relaxed text-text-primary">{entry.note}</p>
          </AppBentoCard>
        ))
      )}
    </AppShell>
  );
}

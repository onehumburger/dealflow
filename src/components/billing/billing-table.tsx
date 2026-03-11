"use client";

import { useState, useTransition } from "react";
import { useLocale, useTranslations } from "next-intl";
import { Pencil, Trash2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { updateTimeEntry, deleteTimeEntry } from "@/actions/time-entries";
import type { getFilteredTimeEntries } from "@/actions/billing";

export type EntryData = Awaited<ReturnType<typeof getFilteredTimeEntries>>[number];

function formatHours(minutes: number, precision: number): string {
  return (minutes / 60).toFixed(precision) + "h";
}

interface BillingTableProps {
  entries: EntryData[];
  precision: number;
  onRefresh: () => void;
}

export function BillingTable({ entries, precision, onRefresh }: BillingTableProps) {
  const locale = useLocale();
  const tBilling = useTranslations("billing");
  const tTimer = useTranslations("timer");
  const tCommon = useTranslations("common");
  const [isPending, startTransition] = useTransition();

  const [editingEntry, setEditingEntry] = useState<string | null>(null);
  const [editDuration, setEditDuration] = useState("");
  const [editDescription, setEditDescription] = useState("");

  function handleToggleBillable(entryId: string, current: boolean) {
    startTransition(async () => {
      await updateTimeEntry(entryId, { isBillable: !current });
      onRefresh();
    });
  }

  function handleDelete(entryId: string) {
    if (!confirm(tTimer("deleteConfirm"))) return;
    startTransition(async () => {
      await deleteTimeEntry(entryId);
      onRefresh();
    });
  }

  function handleStartEdit(entry: EntryData) {
    setEditingEntry(entry.id);
    setEditDuration((entry.durationMinutes / 60).toFixed(2));
    setEditDescription(entry.description || "");
  }

  function handleSaveEdit() {
    if (!editingEntry) return;
    const hours = parseFloat(editDuration);
    if (isNaN(hours) || hours <= 0) return;

    startTransition(async () => {
      await updateTimeEntry(editingEntry, {
        durationMinutes: Math.round(hours * 60),
        description: editDescription,
      });
      setEditingEntry(null);
      onRefresh();
    });
  }

  return (
    <div className="rounded-lg border overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr className="border-b bg-muted/30">
            <th className="px-3 py-2 text-left font-medium">{tTimer("date")}</th>
            <th className="px-3 py-2 text-left font-medium">{tBilling("member")}</th>
            <th className="px-3 py-2 text-left font-medium">{tBilling("deal")}</th>
            <th className="px-3 py-2 text-left font-medium">{tBilling("task")}</th>
            <th className="px-3 py-2 text-right font-medium">{tTimer("duration")}</th>
            <th className="px-3 py-2 text-center font-medium">{tBilling("billable")}</th>
            <th className="px-3 py-2 text-right font-medium"></th>
          </tr>
        </thead>
        <tbody>
          {entries.map((entry) => (
            <tr key={entry.id} className="border-b last:border-b-0 hover:bg-muted/30">
              <td className="px-3 py-1.5 text-muted-foreground">
                {entry.startedAt
                  ? new Intl.DateTimeFormat(locale, { month: "numeric", day: "numeric" }).format(new Date(entry.startedAt))
                  : "—"}
              </td>
              <td className="px-3 py-1.5">{entry.user.name}</td>
              <td className="px-3 py-1.5">{entry.deal.name}</td>
              <td className="px-3 py-1.5">
                <div className="flex flex-col">
                  <span className="truncate max-w-[200px]">{entry.task.title}</span>
                  {editingEntry === entry.id ? (
                    <Input value={editDescription} onChange={(e) => setEditDescription(e.target.value)} className="h-6 text-xs mt-0.5" placeholder={tTimer("description")} />
                  ) : entry.description ? (
                    <span className="text-xs text-muted-foreground truncate max-w-[200px]">{entry.description}</span>
                  ) : null}
                </div>
              </td>
              <td className="px-3 py-1.5 text-right">
                {editingEntry === entry.id ? (
                  <Input type="number" step="0.25" value={editDuration} onChange={(e) => setEditDuration(e.target.value)} className="h-6 w-16 text-sm ml-auto" onKeyDown={(e) => e.key === "Enter" && handleSaveEdit()} />
                ) : (
                  formatHours(entry.durationMinutes, precision)
                )}
              </td>
              <td className="px-3 py-1.5 text-center">
                <button onClick={() => handleToggleBillable(entry.id, entry.isBillable)} disabled={isPending} className="text-sm">
                  {entry.isBillable ? "✓" : "✗"}
                </button>
              </td>
              <td className="px-3 py-1.5 text-right">
                <div className="flex items-center justify-end gap-1">
                  {editingEntry === entry.id ? (
                    <Button size="xs" onClick={handleSaveEdit} disabled={isPending}>{tCommon("save")}</Button>
                  ) : (
                    <button onClick={() => handleStartEdit(entry)} className="text-muted-foreground hover:text-foreground">
                      <Pencil className="size-3.5" />
                    </button>
                  )}
                  <button onClick={() => handleDelete(entry.id)} disabled={isPending} className="text-muted-foreground hover:text-red-500">
                    <Trash2 className="size-3.5" />
                  </button>
                </div>
              </td>
            </tr>
          ))}

          {entries.length === 0 && (
            <tr>
              <td colSpan={7} className="px-3 py-6 text-center text-muted-foreground">{tTimer("noEntries")}</td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}

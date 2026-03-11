"use client";

import { useTransition } from "react";
import { useLocale, useTranslations } from "next-intl";
import { Trash2, Clock } from "lucide-react";
import { cn } from "@/lib/utils";
import { deleteTimeEntry } from "@/actions/time-entries";

interface TimeEntryData {
  id: string;
  description: string | null;
  startedAt: Date | null;
  durationMinutes: number;
  isManual: boolean;
  isBillable: boolean;
  user: { id: string; name: string };
}

interface TimeEntryListProps {
  entries: TimeEntryData[];
  onRefresh: () => void;
}

function formatDuration(minutes: number): string {
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  if (h === 0) return `${m}m`;
  if (m === 0) return `${h}h`;
  return `${h}h ${m}m`;
}

export function TimeEntryList({ entries, onRefresh }: TimeEntryListProps) {
  const locale = useLocale();
  const t = useTranslations("timer");
  const [isPending, startTransition] = useTransition();

  const totalMinutes = entries.reduce((sum, e) => sum + e.durationMinutes, 0);

  if (entries.length === 0) {
    return (
      <p className="text-xs text-muted-foreground">{t("noEntries")}</p>
    );
  }

  function handleDelete(entryId: string) {
    if (!confirm(t("deleteConfirm"))) return;
    startTransition(async () => {
      await deleteTimeEntry(entryId);
      onRefresh();
    });
  }

  return (
    <div className="flex flex-col gap-1">
      <div className="flex items-center justify-between text-xs text-muted-foreground mb-1">
        <span>{t("timeEntries")}</span>
        <span>{t("totalTime")}: {formatDuration(totalMinutes)}</span>
      </div>

      {entries.map((entry) => (
        <div
          key={entry.id}
          className={cn(
            "flex items-center gap-2 rounded px-2 py-1 text-xs group/entry hover:bg-muted/50",
            isPending && "opacity-50"
          )}
        >
          <span className="text-muted-foreground w-16 shrink-0">
            {entry.startedAt
              ? new Intl.DateTimeFormat(locale, {
                  month: "short",
                  day: "numeric",
                }).format(new Date(entry.startedAt))
              : "—"}
          </span>

          <span className="shrink-0 text-muted-foreground truncate max-w-[80px]">
            {entry.user.name}
          </span>

          <span className="shrink-0 font-medium w-12 text-right">
            {formatDuration(entry.durationMinutes)}
          </span>

          <span className="flex-1 truncate text-muted-foreground">
            {entry.description || ""}
          </span>

          {entry.isManual && (
            <span title={t("manual")} className="shrink-0">
              <Clock className="size-3 text-muted-foreground" />
            </span>
          )}

          <button
            type="button"
            onClick={() => handleDelete(entry.id)}
            disabled={isPending}
            className="hidden group-hover/entry:inline-flex shrink-0 text-muted-foreground hover:text-red-500"
          >
            <Trash2 className="size-3" />
          </button>
        </div>
      ))}
    </div>
  );
}

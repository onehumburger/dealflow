"use client";

import { useEffect, useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Square, Clock } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useTimer } from "@/hooks/use-timer";
import { stopTimer } from "@/actions/time-entries";

function formatElapsed(ms: number): string {
  const totalSeconds = Math.floor(ms / 1000);
  const h = Math.floor(totalSeconds / 3600);
  const m = Math.floor((totalSeconds % 3600) / 60);
  const s = totalSeconds % 60;
  return `${String(h).padStart(2, "0")}:${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`;
}

export function TimerBar() {
  const t = useTranslations("timer");
  const activeEntryId = useTimer((s) => s.activeEntryId);
  const taskTitle = useTimer((s) => s.taskTitle);
  const dealName = useTimer((s) => s.dealName);
  const startedAt = useTimer((s) => s.startedAt);
  const stop = useTimer((s) => s.stop);

  const [elapsed, setElapsed] = useState(0);
  const [showDescription, setShowDescription] = useState(false);
  const [description, setDescription] = useState("");
  const [isPending, startTransition] = useTransition();

  useEffect(() => {
    if (!startedAt) {
      setElapsed(0);
      return;
    }
    setElapsed(Date.now() - startedAt);
    const interval = setInterval(() => {
      setElapsed(Date.now() - startedAt);
    }, 1000);
    return () => clearInterval(interval);
  }, [startedAt]);

  if (!activeEntryId) return null;

  function handleStop() {
    setShowDescription(true);
  }

  function handleSave() {
    startTransition(async () => {
      await stopTimer(activeEntryId!, description.trim() || undefined);
      stop();
      setShowDescription(false);
      setDescription("");
    });
  }

  function handleSaveWithoutDescription() {
    startTransition(async () => {
      await stopTimer(activeEntryId!);
      stop();
      setShowDescription(false);
      setDescription("");
    });
  }

  return (
    <div className="fixed bottom-0 left-0 right-0 z-50 border-t bg-background shadow-lg">
      <div className="mx-auto flex max-w-7xl items-center gap-3 px-4 py-2 sm:px-6">
        <Clock className="size-4 text-emerald-600 animate-pulse" />

        <div className="flex items-center gap-2 text-sm">
          <span className="font-medium truncate max-w-[200px]">{taskTitle}</span>
          <span className="text-muted-foreground">—</span>
          <span className="text-muted-foreground truncate max-w-[150px]">{dealName}</span>
        </div>

        <div className="ml-auto flex items-center gap-3">
          <span className="font-mono text-sm font-medium tabular-nums">
            {formatElapsed(elapsed)}
          </span>

          {showDescription ? (
            <div className="flex items-center gap-2">
              <Input
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder={t("description")}
                className="h-7 w-48 text-sm"
                autoFocus
                onKeyDown={(e) => {
                  if (e.key === "Enter") handleSave();
                  if (e.key === "Escape") handleSaveWithoutDescription();
                }}
              />
              <Button size="xs" onClick={handleSave} disabled={isPending}>
                {t("stopTimer")}
              </Button>
            </div>
          ) : (
            <Button
              size="sm"
              variant="destructive"
              onClick={handleStop}
              disabled={isPending}
            >
              <Square className="size-3 fill-current" />
              {t("stopTimer")}
            </Button>
          )}
        </div>
      </div>
    </div>
  );
}

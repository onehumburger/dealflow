"use client";

import { useEffect, useState, useRef, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Square, Clock, Pause, Play } from "lucide-react";
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
  const accumulatedMs = useTimer((s) => s.accumulatedMs);
  const paused = useTimer((s) => s.paused);
  const requestStop = useTimer((s) => s.requestStop);
  const stop = useTimer((s) => s.stop);
  const pause = useTimer((s) => s.pause);
  const resume = useTimer((s) => s.resume);

  const [elapsed, setElapsed] = useState(0);
  const [frozenElapsed, setFrozenElapsed] = useState<number | null>(null);
  const [showDescription, setShowDescription] = useState(false);
  const [description, setDescription] = useState("");
  const [isPending, startTransition] = useTransition();
  const descInputRef = useRef<HTMLInputElement>(null);

  // Calculate total elapsed: accumulated + current segment
  useEffect(() => {
    if (!activeEntryId) {
      setElapsed(0);
      return;
    }
    if (paused) {
      setElapsed(accumulatedMs);
      return;
    }
    if (!startedAt) {
      setElapsed(accumulatedMs);
      return;
    }
    const update = () => setElapsed(accumulatedMs + (Date.now() - startedAt));
    update();
    const interval = setInterval(update, 1000);
    return () => clearInterval(interval);
  }, [activeEntryId, startedAt, accumulatedMs, paused]);

  // Handle requestStop from timer-button
  useEffect(() => {
    if (requestStop && activeEntryId && !showDescription) {
      handleStop();
    }
  }, [requestStop]); // eslint-disable-line react-hooks/exhaustive-deps

  // Auto-focus description input
  useEffect(() => {
    if (showDescription) {
      descInputRef.current?.focus();
    }
  }, [showDescription]);

  if (!activeEntryId) return null;

  function handleStop() {
    // Pause first if running, to freeze the time
    if (!paused && startedAt) {
      pause();
    }
    setFrozenElapsed(elapsed);
    setShowDescription(true);
  }

  function handleSave() {
    const totalMs = frozenElapsed ?? elapsed;
    const durationMinutes = Math.max(1, Math.round(totalMs / 60000));
    startTransition(async () => {
      await stopTimer(activeEntryId!, description.trim() || undefined, durationMinutes);
      stop();
      setShowDescription(false);
      setFrozenElapsed(null);
      setDescription("");
    });
  }

  function handleSaveWithoutDescription() {
    const totalMs = frozenElapsed ?? elapsed;
    const durationMinutes = Math.max(1, Math.round(totalMs / 60000));
    startTransition(async () => {
      await stopTimer(activeEntryId!, undefined, durationMinutes);
      stop();
      setShowDescription(false);
      setFrozenElapsed(null);
      setDescription("");
    });
  }

  return (
    <div className="fixed bottom-0 left-0 right-0 z-50 border-t bg-background shadow-lg">
      <div className="mx-auto flex max-w-7xl items-center gap-3 px-4 py-2 sm:px-6">
        <Clock className={`size-4 ${paused ? "text-amber-500" : "text-emerald-600 animate-pulse"}`} />

        <div className="flex items-center gap-2 text-sm">
          <span className="font-medium truncate max-w-[200px]">{taskTitle}</span>
          <span className="text-muted-foreground">—</span>
          <span className="text-muted-foreground truncate max-w-[150px]">{dealName}</span>
          {paused && !showDescription && (
            <span className="text-xs font-medium text-amber-600 bg-amber-50 px-1.5 py-0.5 rounded">
              {t("paused")}
            </span>
          )}
        </div>

        <div className="ml-auto flex items-center gap-2">
          <span className={`font-mono text-sm font-medium tabular-nums ${paused && !showDescription ? "text-amber-600" : ""}`}>
            {formatElapsed(frozenElapsed ?? elapsed)}
          </span>

          {showDescription ? (
            <div className="flex items-center gap-2">
              <Input
                ref={descInputRef}
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder={t("description")}
                className="h-7 w-48 text-sm"
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
            <>
              {/* Pause / Resume button */}
              {paused ? (
                <Button
                  size="sm"
                  variant="outline"
                  onClick={resume}
                  disabled={isPending}
                  className="text-emerald-600 border-emerald-200 hover:bg-emerald-50"
                >
                  <Play className="size-3 fill-current" />
                  {t("resume")}
                </Button>
              ) : (
                <Button
                  size="sm"
                  variant="outline"
                  onClick={pause}
                  disabled={isPending}
                  className="text-amber-600 border-amber-200 hover:bg-amber-50"
                >
                  <Pause className="size-3" />
                  {t("pause")}
                </Button>
              )}
              {/* Stop button */}
              <Button
                size="sm"
                variant="destructive"
                onClick={handleStop}
                disabled={isPending}
              >
                <Square className="size-3 fill-current" />
                {t("stopTimer")}
              </Button>
            </>
          )}
        </div>
      </div>
    </div>
  );
}

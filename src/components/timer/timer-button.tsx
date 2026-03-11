"use client";

import { useTransition } from "react";
import { useTranslations } from "next-intl";
import { Play, Square } from "lucide-react";
import { cn } from "@/lib/utils";
import { useTimer } from "@/hooks/use-timer";
import { startTimer, stopTimer } from "@/actions/time-entries";

interface TimerButtonProps {
  taskId: string;
  size?: "sm" | "md";
  className?: string;
}

export function TimerButton({ taskId, size = "sm", className }: TimerButtonProps) {
  const t = useTranslations("timer");
  const [isPending, startTransition] = useTransition();
  const activeEntryId = useTimer((s) => s.activeEntryId);
  const activeTaskId = useTimer((s) => s.taskId);
  const start = useTimer((s) => s.start);
  const stop = useTimer((s) => s.stop);

  const isRunningOnThisTask = activeTaskId === taskId;
  const isRunningOnOther = activeEntryId !== null && !isRunningOnThisTask;

  function handleClick(e: React.MouseEvent) {
    e.stopPropagation();

    if (isRunningOnThisTask) {
      // Stop timer
      startTransition(async () => {
        await stopTimer(activeEntryId!);
        stop();
      });
      return;
    }

    if (isRunningOnOther) {
      if (!confirm(t("switchTimer"))) return;
      // Stop current, then start new
      startTransition(async () => {
        await stopTimer(activeEntryId!);
        stop();
        const result = await startTimer(taskId);
        start(result.entryId, result.taskId, result.taskTitle, result.dealName);
      });
      return;
    }

    // Start new timer
    startTransition(async () => {
      const result = await startTimer(taskId);
      start(result.entryId, result.taskId, result.taskTitle, result.dealName);
    });
  }

  const iconSize = size === "sm" ? "size-3" : "size-3.5";

  return (
    <button
      type="button"
      onClick={handleClick}
      disabled={isPending}
      title={isRunningOnThisTask ? t("stopTimer") : t("startTimer")}
      className={cn(
        "flex items-center justify-center rounded transition-colors disabled:opacity-50",
        size === "sm" ? "size-5" : "size-7",
        isRunningOnThisTask
          ? "text-red-500 hover:bg-red-50"
          : "text-muted-foreground hover:text-emerald-600 hover:bg-emerald-50",
        className
      )}
    >
      {isRunningOnThisTask ? (
        <Square className={cn(iconSize, "fill-current")} />
      ) : (
        <Play className={cn(iconSize, "fill-current")} />
      )}
    </button>
  );
}

"use client";

import { useTransition } from "react";
import { useLocale, useTranslations } from "next-intl";
import { cn } from "@/lib/utils";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { updateTaskStatus } from "@/actions/tasks";
import { useTaskPanel } from "@/hooks/use-task-panel";
import type { TaskPriority, TaskStatus } from "@/generated/prisma/client";
import { TimerButton } from "@/components/timer/timer-button";

interface TaskRowProps {
  task: {
    id: string;
    title: string;
    status: TaskStatus;
    priority: TaskPriority;
    dueDate: Date | null;
    completedAt: Date | null;
    assignee: { name: string } | null;
  };
}

function formatRelativeDate(
  date: Date,
  locale: string,
  t: ReturnType<typeof useTranslations<"task">>
): string {
  const now = new Date();
  const diff = date.getTime() - now.getTime();
  const days = Math.ceil(diff / (1000 * 60 * 60 * 24));

  if (days < 0) return t("daysOverdue", { days: Math.abs(days) });
  if (days === 0) return t("today");
  if (days === 1) return t("tomorrow");
  if (days <= 7) return `${days}d`;
  return new Intl.DateTimeFormat(locale, {
    month: "short",
    day: "numeric",
  }).format(date);
}

export function TaskRow({ task }: TaskRowProps) {
  const locale = useLocale();
  const t = useTranslations("task");
  const [isPending, startTransition] = useTransition();
  const openPanel = useTaskPanel((s) => s.open);

  const isDone = task.status === "Done";
  const isOverdue =
    task.dueDate && !isDone && task.dueDate < new Date();

  function handleToggle(e: React.MouseEvent) {
    e.stopPropagation();
    const newStatus = isDone ? "ToDo" : "Done";
    startTransition(async () => {
      await updateTaskStatus(task.id, newStatus as TaskStatus);
    });
  }

  function handleTitleClick() {
    openPanel(task.id);
  }

  return (
    <div
      className={cn(
        "group/row flex items-center gap-3 rounded-md px-2 py-1.5 hover:bg-muted/50",
        isPending && "opacity-50"
      )}
    >
      {/* Checkbox */}
      <button
        type="button"
        onClick={handleToggle}
        disabled={isPending}
        className={cn(
          "flex size-4 shrink-0 items-center justify-center rounded border transition-colors",
          isDone
            ? "border-emerald-600 bg-emerald-600 text-white"
            : "border-input hover:border-emerald-400"
        )}
      >
        {isDone && (
          <svg className="size-3" viewBox="0 0 12 12" fill="none">
            <path
              d="M2.5 6L5 8.5L9.5 3.5"
              stroke="currentColor"
              strokeWidth="1.5"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
        )}
      </button>

      {/* Timer button */}
      <span className="inline-flex shrink-0">
        <TimerButton taskId={task.id} size="sm" />
      </span>

      {/* Title — clickable to open panel */}
      <button
        type="button"
        onClick={handleTitleClick}
        className={cn(
          "flex-1 truncate text-left text-sm hover:underline",
          isDone && "text-muted-foreground line-through"
        )}
      >
        {task.title}
      </button>

      {/* Priority indicator */}
      {task.priority === "High" && (
        <span className="size-2 shrink-0 rounded-full bg-red-500" title="High" />
      )}

      {/* Date: completed date for done tasks, due date otherwise */}
      {isDone && task.completedAt ? (
        <span className="shrink-0 text-xs text-emerald-600">
          {new Intl.DateTimeFormat(locale, {
            month: "short",
            day: "numeric",
          }).format(new Date(task.completedAt))}
        </span>
      ) : task.dueDate && !isDone ? (
        <span
          className={cn(
            "shrink-0 text-xs",
            isOverdue ? "text-red-500 font-medium" : "text-muted-foreground"
          )}
        >
          {formatRelativeDate(task.dueDate, locale, t)}
        </span>
      ) : null}

      {/* Assignee */}
      {task.assignee && (
        <Avatar size="sm">
          <AvatarFallback>
            {task.assignee.name.charAt(0).toUpperCase()}
          </AvatarFallback>
        </Avatar>
      )}
    </div>
  );
}

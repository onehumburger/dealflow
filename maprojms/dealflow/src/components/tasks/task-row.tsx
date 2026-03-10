import { cn } from "@/lib/utils";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import type { TaskPriority, TaskStatus } from "@/generated/prisma/client";

interface TaskRowProps {
  task: {
    id: string;
    title: string;
    status: TaskStatus;
    priority: TaskPriority;
    dueDate: Date | null;
    assignee: { name: string } | null;
  };
}

function formatRelativeDate(date: Date): string {
  const now = new Date();
  const diff = date.getTime() - now.getTime();
  const days = Math.ceil(diff / (1000 * 60 * 60 * 24));

  if (days < 0) return `${Math.abs(days)}d overdue`;
  if (days === 0) return "Today";
  if (days === 1) return "Tomorrow";
  if (days <= 7) return `${days}d`;
  return new Intl.DateTimeFormat("en", {
    month: "short",
    day: "numeric",
  }).format(date);
}

export function TaskRow({ task }: TaskRowProps) {
  const isDone = task.status === "Done";
  const isOverdue =
    task.dueDate && !isDone && task.dueDate < new Date();

  return (
    <div className="flex items-center gap-3 rounded-md px-2 py-1.5 hover:bg-muted/50">
      {/* Checkbox placeholder */}
      <div
        className={cn(
          "flex size-4 shrink-0 items-center justify-center rounded border",
          isDone
            ? "border-emerald-600 bg-emerald-600 text-white"
            : "border-input"
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
      </div>

      {/* Title */}
      <span
        className={cn(
          "flex-1 truncate text-sm",
          isDone && "text-muted-foreground line-through"
        )}
      >
        {task.title}
      </span>

      {/* Priority indicator */}
      {task.priority === "High" && (
        <span className="size-2 shrink-0 rounded-full bg-red-500" title="High" />
      )}

      {/* Due date */}
      {task.dueDate && (
        <span
          className={cn(
            "shrink-0 text-xs",
            isOverdue ? "text-red-500 font-medium" : "text-muted-foreground"
          )}
        >
          {formatRelativeDate(task.dueDate)}
        </span>
      )}

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

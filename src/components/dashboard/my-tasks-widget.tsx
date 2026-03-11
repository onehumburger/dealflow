import Link from "next/link";
import { cn } from "@/lib/utils";
import { Badge } from "@/components/ui/badge";
import type { TaskPriority } from "@/generated/prisma/client";

interface TaskItem {
  id: string;
  title: string;
  priority: TaskPriority;
  dueDate: Date | null;
  dealId: string;
  dealName: string;
}

interface MyTasksWidgetProps {
  tasks: TaskItem[];
  locale: string;
  translations: {
    myTasks: string;
    high: string;
    overdue: string;
    noTasks: string;
  };
}

function formatDueDate(date: Date, locale: string): string {
  const now = new Date();
  const diffMs = date.getTime() - now.getTime();
  const diffDays = Math.ceil(diffMs / (1000 * 60 * 60 * 24));

  if (diffDays < 0) {
    return `${Math.abs(diffDays)}d`;
  }
  if (diffDays === 0) {
    return locale === "zh" ? "\u4eca\u5929" : "Today";
  }
  if (diffDays === 1) {
    return locale === "zh" ? "\u660e\u5929" : "Tmrw";
  }
  return new Intl.DateTimeFormat(locale, {
    month: "short",
    day: "numeric",
  }).format(date);
}

function isOverdue(date: Date): boolean {
  return date < new Date();
}

export function MyTasksWidget({ tasks, locale, translations }: MyTasksWidgetProps) {
  return (
    <div className="rounded-lg border bg-card">
      <div className="border-b px-4 py-3">
        <h3 className="text-sm font-semibold">{translations.myTasks}</h3>
      </div>
      <div className="divide-y">
        {tasks.length === 0 ? (
          <p className="px-4 py-6 text-center text-sm text-muted-foreground">
            {translations.noTasks}
          </p>
        ) : (
          tasks.map((task) => (
            <Link
              key={task.id}
              href={`/${locale}/deals/${task.dealId}`}
              className="flex items-center gap-3 px-4 py-2.5 text-sm hover:bg-muted/50 transition-colors"
            >
              <div className="min-w-0 flex-1">
                <p className="truncate font-medium">{task.title}</p>
                <p className="truncate text-xs text-muted-foreground">
                  {task.dealName}
                </p>
              </div>
              <div className="flex shrink-0 items-center gap-2">
                {task.priority === "High" && (
                  <Badge variant="destructive" className="text-[10px] px-1.5 py-0">
                    {translations.high}
                  </Badge>
                )}
                {task.dueDate && (
                  <span
                    className={cn(
                      "text-xs tabular-nums",
                      isOverdue(task.dueDate)
                        ? "font-semibold text-red-600"
                        : "text-muted-foreground"
                    )}
                  >
                    {isOverdue(task.dueDate) && "! "}
                    {formatDueDate(task.dueDate, locale)}
                  </span>
                )}
              </div>
            </Link>
          ))
        )}
      </div>
    </div>
  );
}

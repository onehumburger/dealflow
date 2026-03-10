"use client";

import { useTranslations } from "next-intl";
import Link from "next/link";
import { Badge } from "@/components/ui/badge";
import { TaskRow } from "./task-row";
import { TaskPanel } from "./task-panel";
import type { TaskPriority, TaskStatus } from "@/generated/prisma/client";

interface TaskData {
  id: string;
  title: string;
  status: TaskStatus;
  priority: TaskPriority;
  dueDate: Date | null;
  assignee: { name: string } | null;
  workstreamName: string;
}

interface DealGroup {
  dealId: string;
  dealName: string;
  tasks: TaskData[];
}

interface MyTaskListProps {
  dealGroups: DealGroup[];
  locale: string;
}

export function MyTaskList({ dealGroups, locale }: MyTaskListProps) {
  const t = useTranslations("task");

  return (
    <div className="flex flex-col gap-6">
      {dealGroups.map((group) => {
        const overdue = group.tasks.filter(
          (t) => t.dueDate && t.dueDate < new Date() && t.status !== "Done"
        ).length;

        return (
          <div key={group.dealId} className="rounded-lg border bg-card">
            <div className="flex items-center gap-2 border-b px-4 py-3">
              <Link
                href={`/${locale}/deals/${group.dealId}`}
                className="text-sm font-medium hover:underline"
              >
                {group.dealName}
              </Link>
              <span className="text-xs text-muted-foreground">
                {group.tasks.length} {t("tasks")}
              </span>
              {overdue > 0 && (
                <Badge variant="destructive">
                  {overdue} {t("overdue")}
                </Badge>
              )}
            </div>
            <div className="px-2 py-1">
              {group.tasks.map((task) => (
                <TaskRow key={task.id} task={task} />
              ))}
            </div>
          </div>
        );
      })}

      {/* Task panel for My Tasks page */}
      <TaskPanel />
    </div>
  );
}

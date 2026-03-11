"use client";

import { useTranslations } from "next-intl";
import { WorkstreamSection } from "./workstream-section";
import { WorkstreamForm } from "./workstream-form";
import { useTaskFilters } from "@/hooks/use-task-filters";
import type { TaskPriority, TaskStatus } from "@/generated/prisma/client";

interface WorkstreamTask {
  id: string;
  title: string;
  status: TaskStatus;
  priority: TaskPriority;
  dueDate: Date | null;
  completedAt: Date | null;
  assigneeId: string | null;
  assignee: { name: string } | null;
}

interface WorkstreamData {
  id: string;
  name: string;
  tasks: WorkstreamTask[];
}

interface WorkstreamListProps {
  workstreams: WorkstreamData[];
  dealId: string;
}

export function WorkstreamList({ workstreams, dealId }: WorkstreamListProps) {
  const tWs = useTranslations("workstream");
  const statusFilter = useTaskFilters((s) => s.statusFilter);
  const assigneeFilter = useTaskFilters((s) => s.assigneeFilter);

  // Apply filters to tasks within each workstream
  const filteredWorkstreams = workstreams.map((ws) => ({
    ...ws,
    tasks: ws.tasks.filter((task) => {
      if (statusFilter !== "all" && task.status !== statusFilter) return false;
      if (assigneeFilter !== "all" && task.assigneeId !== assigneeFilter)
        return false;
      return true;
    }),
  }));

  return (
    <div className="flex flex-col gap-3">
      {filteredWorkstreams.map((ws) => (
        <WorkstreamSection key={ws.id} workstream={ws} dealId={dealId} />
      ))}

      {/* Add Workstream dialog button */}
      <WorkstreamForm
        dealId={dealId}
        trigger={
          <button className="rounded-lg border border-dashed px-4 py-2 text-sm text-muted-foreground hover:bg-muted/50">
            + {tWs("addWorkstream")}
          </button>
        }
      />
    </div>
  );
}

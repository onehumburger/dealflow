"use client";

import { useTranslations } from "next-intl";
import { WorkstreamSection } from "./workstream-section";
import type { TaskPriority, TaskStatus } from "@/generated/prisma/client";

interface WorkstreamTask {
  id: string;
  title: string;
  status: TaskStatus;
  priority: TaskPriority;
  dueDate: Date | null;
  assignee: { name: string } | null;
}

interface WorkstreamData {
  id: string;
  name: string;
  tasks: WorkstreamTask[];
}

interface WorkstreamListProps {
  workstreams: WorkstreamData[];
}

export function WorkstreamList({ workstreams }: WorkstreamListProps) {
  const tCommon = useTranslations("common");
  const tWs = useTranslations("workstream");

  return (
    <div className="flex flex-col gap-3">
      {/* Filter bar placeholder */}
      <div className="flex items-center justify-between">
        <span className="text-sm font-medium text-muted-foreground">
          {tCommon("filter")}
        </span>
      </div>

      {workstreams.map((ws) => (
        <WorkstreamSection key={ws.id} workstream={ws} />
      ))}

      {/* Add Workstream placeholder button */}
      <button className="rounded-lg border border-dashed px-4 py-2 text-sm text-muted-foreground hover:bg-muted/50">
        + {tWs("addWorkstream")}
      </button>
    </div>
  );
}

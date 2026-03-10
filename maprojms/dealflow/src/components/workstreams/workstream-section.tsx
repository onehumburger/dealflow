"use client";

import { useState } from "react";
import { ChevronDown, ChevronRight } from "lucide-react";
import { TaskRow } from "@/components/tasks/task-row";
import type { TaskPriority, TaskStatus } from "@/generated/prisma/client";

interface WorkstreamTask {
  id: string;
  title: string;
  status: TaskStatus;
  priority: TaskPriority;
  dueDate: Date | null;
  assignee: { name: string } | null;
}

interface WorkstreamSectionProps {
  workstream: {
    id: string;
    name: string;
    tasks: WorkstreamTask[];
  };
}

export function WorkstreamSection({ workstream }: WorkstreamSectionProps) {
  const [expanded, setExpanded] = useState(true);
  const doneCount = workstream.tasks.filter((t) => t.status === "Done").length;
  const totalCount = workstream.tasks.length;

  return (
    <div className="rounded-lg border bg-card">
      <button
        onClick={() => setExpanded(!expanded)}
        className="flex w-full items-center gap-2 px-4 py-3 text-left hover:bg-muted/50"
      >
        {expanded ? (
          <ChevronDown className="size-4 text-muted-foreground" />
        ) : (
          <ChevronRight className="size-4 text-muted-foreground" />
        )}
        <span className="flex-1 text-sm font-medium">{workstream.name}</span>
        <span className="text-xs text-muted-foreground">
          {doneCount}/{totalCount}
        </span>
      </button>

      {expanded && workstream.tasks.length > 0 && (
        <div className="border-t px-2 py-1">
          {workstream.tasks.map((task) => (
            <TaskRow key={task.id} task={task} />
          ))}
        </div>
      )}
    </div>
  );
}

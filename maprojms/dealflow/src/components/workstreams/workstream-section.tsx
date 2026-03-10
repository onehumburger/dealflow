"use client";

import { useState, useTransition, useRef } from "react";
import { useTranslations } from "next-intl";
import { ChevronDown, ChevronRight, MoreHorizontal, Pencil, Trash2, Plus } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { TaskRow } from "@/components/tasks/task-row";
import { WorkstreamRenameDialog } from "./workstream-form";
import { deleteWorkstream } from "@/actions/workstreams";
import { createTask } from "@/actions/tasks";
import type { TaskPriority, TaskStatus } from "@/generated/prisma/client";

interface WorkstreamTask {
  id: string;
  title: string;
  status: TaskStatus;
  priority: TaskPriority;
  dueDate: Date | null;
  assigneeId: string | null;
  assignee: { name: string } | null;
}

interface WorkstreamSectionProps {
  workstream: {
    id: string;
    name: string;
    tasks: WorkstreamTask[];
  };
  dealId: string;
}

export function WorkstreamSection({ workstream, dealId }: WorkstreamSectionProps) {
  const t = useTranslations("workstream");
  const tTask = useTranslations("task");
  const tCommon = useTranslations("common");
  const [expanded, setExpanded] = useState(true);
  const [showAddTask, setShowAddTask] = useState(false);
  const [showRename, setShowRename] = useState(false);
  const [isPending, startTransition] = useTransition();
  const taskInputRef = useRef<HTMLInputElement>(null);
  const doneCount = workstream.tasks.filter((t) => t.status === "Done").length;
  const totalCount = workstream.tasks.length;

  function handleDelete() {
    if (!confirm(t("deleteConfirm"))) return;
    startTransition(async () => {
      await deleteWorkstream(workstream.id);
    });
  }

  function handleAddTask(formData: FormData) {
    formData.set("workstreamId", workstream.id);
    startTransition(async () => {
      await createTask(formData);
      if (taskInputRef.current) {
        taskInputRef.current.value = "";
      }
    });
  }

  return (
    <>
      <div className="rounded-lg border bg-card">
        <div className="flex w-full items-center gap-2 px-4 py-3">
          <button
            onClick={() => setExpanded(!expanded)}
            className="flex flex-1 items-center gap-2 text-left hover:bg-muted/50 rounded -m-1 p-1"
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

          {/* Workstream actions dropdown */}
          <DropdownMenu>
            <DropdownMenuTrigger
              render={
                <Button variant="ghost" size="icon-xs" />
              }
            >
              <MoreHorizontal className="size-3.5" />
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem onClick={() => setShowRename(true)}>
                <Pencil className="size-3.5" />
                {t("renameWorkstream")}
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem
                variant="destructive"
                onClick={handleDelete}
                disabled={isPending}
              >
                <Trash2 className="size-3.5" />
                {tCommon("delete")}
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>

        {expanded && (
          <div className="border-t px-2 py-1">
            {workstream.tasks.length > 0 && (
              <>
                {workstream.tasks.map((task) => (
                  <TaskRow key={task.id} task={task} />
                ))}
              </>
            )}

            {/* Add task inline form */}
            {showAddTask ? (
              <form
                action={handleAddTask}
                className="flex items-center gap-2 px-2 py-1.5"
              >
                <Input
                  ref={taskInputRef}
                  name="title"
                  placeholder={tTask("addTask")}
                  required
                  autoFocus
                  className="h-7 text-sm"
                />
                <Button type="submit" size="xs" disabled={isPending}>
                  <Plus className="size-3" />
                </Button>
                <Button
                  type="button"
                  variant="ghost"
                  size="xs"
                  onClick={() => setShowAddTask(false)}
                >
                  {tCommon("cancel")}
                </Button>
              </form>
            ) : (
              <button
                onClick={() => setShowAddTask(true)}
                className="flex w-full items-center gap-2 rounded-md px-2 py-1.5 text-sm text-muted-foreground hover:bg-muted/50"
              >
                <Plus className="size-3.5" />
                {tTask("addTask")}
              </button>
            )}
          </div>
        )}
      </div>

      {/* Rename dialog — state-driven, outside the dropdown */}
      <WorkstreamRenameDialog
        dealId={dealId}
        workstream={{ id: workstream.id, name: workstream.name }}
        open={showRename}
        onOpenChange={setShowRename}
      />
    </>
  );
}

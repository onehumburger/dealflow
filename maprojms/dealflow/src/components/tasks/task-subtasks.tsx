"use client";

import { useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { cn } from "@/lib/utils";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Plus, X } from "lucide-react";
import { addSubtask, toggleSubtask, deleteSubtask } from "@/actions/tasks";

interface SubtaskData {
  id: string;
  title: string;
  isDone: boolean;
  sortOrder: number;
}

interface TaskSubtasksProps {
  taskId: string;
  subtasks: SubtaskData[];
  onRefresh: () => void;
}

export function TaskSubtasks({ taskId, subtasks, onRefresh }: TaskSubtasksProps) {
  const t = useTranslations("task");
  const [isPending, startTransition] = useTransition();
  const [newTitle, setNewTitle] = useState("");
  const [showInput, setShowInput] = useState(false);

  const doneCount = subtasks.filter((s) => s.isDone).length;

  function handleAdd() {
    if (!newTitle.trim()) return;
    startTransition(async () => {
      await addSubtask(taskId, newTitle.trim());
      setNewTitle("");
      setShowInput(false);
      onRefresh();
    });
  }

  function handleToggle(subtaskId: string, isDone: boolean) {
    startTransition(async () => {
      await toggleSubtask(subtaskId, !isDone);
      onRefresh();
    });
  }

  function handleDelete(subtaskId: string) {
    startTransition(async () => {
      await deleteSubtask(subtaskId);
      onRefresh();
    });
  }

  return (
    <div>
      <div className="mb-1.5 flex items-center justify-between">
        <span className="text-xs font-medium text-muted-foreground">
          {t("subtasks")}
          {subtasks.length > 0 && (
            <span className="ml-1">
              ({doneCount}/{subtasks.length})
            </span>
          )}
        </span>
        <Button
          variant="ghost"
          size="icon-xs"
          onClick={() => setShowInput(!showInput)}
        >
          <Plus className="size-3" />
        </Button>
      </div>

      {/* Subtask list */}
      <div className="flex flex-col gap-0.5">
        {subtasks.map((sub) => (
          <div
            key={sub.id}
            className={cn(
              "group flex items-center gap-2 rounded px-1 py-0.5 hover:bg-muted/50",
              isPending && "opacity-50"
            )}
          >
            <button
              type="button"
              onClick={() => handleToggle(sub.id, sub.isDone)}
              disabled={isPending}
              className={cn(
                "flex size-3.5 shrink-0 items-center justify-center rounded border transition-colors",
                sub.isDone
                  ? "border-emerald-600 bg-emerald-600 text-white"
                  : "border-input hover:border-emerald-400"
              )}
            >
              {sub.isDone && (
                <svg className="size-2.5" viewBox="0 0 12 12" fill="none">
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
            <span
              className={cn(
                "flex-1 text-xs",
                sub.isDone && "text-muted-foreground line-through"
              )}
            >
              {sub.title}
            </span>
            <button
              type="button"
              onClick={() => handleDelete(sub.id)}
              disabled={isPending}
              className="invisible text-muted-foreground hover:text-destructive group-hover:visible"
            >
              <X className="size-3" />
            </button>
          </div>
        ))}
      </div>

      {/* Add subtask input */}
      {showInput && (
        <form
          onSubmit={(e) => {
            e.preventDefault();
            handleAdd();
          }}
          className="mt-1.5 flex items-center gap-1.5"
        >
          <Input
            value={newTitle}
            onChange={(e) => setNewTitle(e.target.value)}
            placeholder={t("addTask")}
            className="h-7 text-xs"
            autoFocus
          />
          <Button type="submit" size="xs" disabled={isPending || !newTitle.trim()}>
            <Plus className="size-3" />
          </Button>
        </form>
      )}
    </div>
  );
}

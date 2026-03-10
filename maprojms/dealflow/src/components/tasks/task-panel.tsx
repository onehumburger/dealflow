"use client";

import { useCallback, useEffect, useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetDescription,
} from "@/components/ui/sheet";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Trash2, Loader2 } from "lucide-react";
import { useTaskPanel } from "@/hooks/use-task-panel";
import {
  getTaskDetail,
  updateTask,
  deleteTask,
  updateTaskStatus,
} from "@/actions/tasks";
import { TaskComments } from "./task-comments";
import { TaskDependencies } from "./task-dependencies";
import { TaskSubtasks } from "./task-subtasks";
import type { TaskStatus, TaskPriority } from "@/generated/prisma/client";

type TaskData = Awaited<ReturnType<typeof getTaskDetail>>;

export function TaskPanel() {
  const t = useTranslations("task");
  const tCommon = useTranslations("common");

  const taskId = useTaskPanel((s) => s.taskId);
  const close = useTaskPanel((s) => s.close);
  const isOpen = taskId !== null;

  const [task, setTask] = useState<TaskData | null>(null);
  const [loading, setLoading] = useState(false);
  const [isPending, startTransition] = useTransition();

  // Editable fields
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [status, setStatus] = useState<TaskStatus>("ToDo");
  const [priority, setPriority] = useState<TaskPriority>("Normal");
  const [assigneeId, setAssigneeId] = useState<string | null>(null);
  const [dueDate, setDueDate] = useState("");

  const loadTask = useCallback(async (id: string) => {
    setLoading(true);
    try {
      const data = await getTaskDetail(id);
      setTask(data);
      setTitle(data.title);
      setDescription(data.description || "");
      setStatus(data.status);
      setPriority(data.priority);
      setAssigneeId(data.assigneeId);
      setDueDate(
        data.dueDate
          ? new Date(data.dueDate).toISOString().split("T")[0]
          : ""
      );
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    if (taskId) {
      loadTask(taskId);
    } else {
      setTask(null);
    }
  }, [taskId, loadTask]);

  function handleSave() {
    if (!taskId) return;
    startTransition(async () => {
      await updateTask(taskId, {
        title: title.trim() || undefined,
        description: description.trim() || null,
        assigneeId: assigneeId || null,
        priority,
        dueDate: dueDate ? new Date(dueDate) : null,
      });
      await loadTask(taskId);
    });
  }

  function handleStatusChange(newStatus: TaskStatus) {
    if (!taskId) return;
    setStatus(newStatus);
    startTransition(async () => {
      await updateTaskStatus(taskId, newStatus);
      await loadTask(taskId);
    });
  }

  function handleDelete() {
    if (!taskId) return;
    startTransition(async () => {
      await deleteTask(taskId);
      close();
    });
  }

  const teamMembers = task?.workstream?.deal?.members?.map((m) => m.user) ?? [];

  const statusOptions: { value: TaskStatus; label: string }[] = [
    { value: "ToDo", label: t("toDo") },
    { value: "InProgress", label: t("inProgress") },
    { value: "Done", label: t("done") },
  ];

  const priorityOptions: { value: TaskPriority; label: string }[] = [
    { value: "Normal", label: t("normal") },
    { value: "High", label: t("high") },
  ];

  return (
    <Sheet open={isOpen} onOpenChange={(open) => !open && close()}>
      <SheetContent
        side="right"
        className="sm:max-w-lg w-full overflow-y-auto"
      >
        {loading ? (
          <div className="flex h-full items-center justify-center">
            <Loader2 className="size-6 animate-spin text-muted-foreground" />
          </div>
        ) : task ? (
          <div className="flex flex-col gap-5">
            <SheetHeader className="px-0">
              <SheetTitle className="sr-only">{task.title}</SheetTitle>
              <SheetDescription className="sr-only">
                {t("tasks")}
              </SheetDescription>
              {/* Editable title */}
              <Input
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                onBlur={handleSave}
                className="text-base font-medium border-none shadow-none px-0 focus-visible:ring-0"
              />
            </SheetHeader>

            {/* Status + Priority row */}
            <div className="flex items-center gap-3">
              <div className="flex-1">
                <Label className="mb-1.5 text-xs text-muted-foreground">
                  {t("status")}
                </Label>
                <div className="flex gap-1.5">
                  {statusOptions.map((opt) => (
                    <button
                      key={opt.value}
                      type="button"
                      onClick={() => handleStatusChange(opt.value)}
                      disabled={isPending}
                    >
                      <Badge
                        variant={status === opt.value ? "default" : "outline"}
                      >
                        {opt.label}
                      </Badge>
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <Label className="mb-1.5 text-xs text-muted-foreground">
                  {t("high")} / {t("normal")}
                </Label>
                <div className="flex gap-1.5">
                  {priorityOptions.map((opt) => (
                    <button
                      key={opt.value}
                      type="button"
                      onClick={() => {
                        setPriority(opt.value);
                        if (taskId) {
                          startTransition(async () => {
                            await updateTask(taskId, { priority: opt.value });
                          });
                        }
                      }}
                      disabled={isPending}
                    >
                      <Badge
                        variant={
                          priority === opt.value
                            ? opt.value === "High"
                              ? "destructive"
                              : "default"
                            : "outline"
                        }
                      >
                        {opt.label}
                      </Badge>
                    </button>
                  ))}
                </div>
              </div>
            </div>

            {/* Assignee */}
            <div>
              <Label className="mb-1.5 text-xs text-muted-foreground">
                {t("assignee")}
              </Label>
              <Select
                value={assigneeId ?? ""}
                onValueChange={(val) => {
                  const newId = val || null;
                  setAssigneeId(newId);
                  if (taskId) {
                    startTransition(async () => {
                      await updateTask(taskId, { assigneeId: newId });
                      await loadTask(taskId);
                    });
                  }
                }}
              >
                <SelectTrigger className="w-full">
                  <SelectValue placeholder={t("assignee")} />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="">--</SelectItem>
                  {teamMembers.map((u) => (
                    <SelectItem key={u.id} value={u.id}>
                      {u.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* Due date */}
            <div>
              <Label className="mb-1.5 text-xs text-muted-foreground">
                {t("dueDate")}
              </Label>
              <Input
                type="date"
                value={dueDate}
                onChange={(e) => setDueDate(e.target.value)}
                onBlur={handleSave}
              />
            </div>

            {/* Description */}
            <div>
              <Label className="mb-1.5 text-xs text-muted-foreground">
                {t("description")}
              </Label>
              <Textarea
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                onBlur={handleSave}
                placeholder="..."
                rows={3}
              />
            </div>

            {/* Subtasks */}
            <TaskSubtasks
              taskId={task.id}
              subtasks={task.subtasks}
              onRefresh={() => taskId && loadTask(taskId)}
            />

            {/* Dependencies */}
            <TaskDependencies
              taskId={task.id}
              blockedBy={task.blockedBy}
              blocks={task.blocks}
              dealId={task.workstream.dealId}
              onRefresh={() => taskId && loadTask(taskId)}
            />

            {/* Comments */}
            <TaskComments
              taskId={task.id}
              comments={task.comments}
              onRefresh={() => taskId && loadTask(taskId)}
            />

            {/* Delete */}
            <div className="border-t pt-4">
              <Button
                variant="destructive"
                size="sm"
                onClick={handleDelete}
                disabled={isPending}
              >
                <Trash2 className="size-3.5" />
                {tCommon("delete")}
              </Button>
            </div>
          </div>
        ) : null}
      </SheetContent>
    </Sheet>
  );
}

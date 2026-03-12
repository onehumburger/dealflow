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
} from "@/components/ui/select";
import {
  Tabs,
  TabsList,
  TabsTrigger,
  TabsContent,
} from "@/components/ui/tabs";
import { Trash2, Loader2, MessageSquare } from "lucide-react";
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
import { TaskDocumentsTab } from "@/components/documents/task-documents-tab";
import { TimerButton } from "@/components/timer/timer-button";
import { TimeEntryList } from "@/components/time/time-entry-list";
import { ManualTimeForm } from "@/components/time/manual-time-form";
import { getTaskTimeEntries } from "@/actions/time-entries";
import type { TaskStatus, TaskPriority } from "@/generated/prisma/client";

type TaskData = Awaited<ReturnType<typeof getTaskDetail>>;

export function TaskPanel({ canManageTasks }: { canManageTasks?: boolean }) {
  const t = useTranslations("task");
  const tCommon = useTranslations("common");
  const tTimer = useTranslations("timer");
  const tDocument = useTranslations("document");

  const taskId = useTaskPanel((s) => s.taskId);
  const close = useTaskPanel((s) => s.close);
  const isOpen = taskId !== null;

  const [task, setTask] = useState<TaskData | null>(null);
  const [loading, setLoading] = useState(false);
  const [isPending, startTransition] = useTransition();
  const [activeTab, setActiveTab] = useState<number>(0);

  // Editable fields
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [status, setStatus] = useState<TaskStatus>("ToDo");
  const [priority, setPriority] = useState<TaskPriority>("Normal");
  const [assigneeId, setAssigneeId] = useState<string | null>(null);
  const [dueDate, setDueDate] = useState("");
  const [timeEntries, setTimeEntries] = useState<Awaited<ReturnType<typeof getTaskTimeEntries>>>([]);

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
      // Load time entries
      const entries = await getTaskTimeEntries(id);
      setTimeEntries(entries);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    if (taskId) {
      setActiveTab(0);
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
    if (!confirm(tCommon("confirmDelete"))) return;
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
        className="data-[side=right]:sm:max-w-xl w-full overflow-y-auto"
      >
        {loading ? (
          <div className="flex h-full items-center justify-center">
            <Loader2 className="size-6 animate-spin text-muted-foreground" />
          </div>
        ) : task ? (
          <div className="flex flex-col gap-3 px-4 pb-4">
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

            <Tabs value={activeTab} onValueChange={setActiveTab}>
              <TabsList className="w-full">
                <TabsTrigger value={0} className="flex-1">
                  {tDocument("details")}
                </TabsTrigger>
                <TabsTrigger value={1} className="flex-1">
                  {tDocument("documentsTab")}
                </TabsTrigger>
                <TabsTrigger value={2} className="flex-1">
                  {tDocument("activity")}
                  {task.comments.length > 0 && (
                    <span className="ml-1 text-xs text-muted-foreground">
                      ({task.comments.length})
                    </span>
                  )}
                </TabsTrigger>
              </TabsList>

              {/* Panel 0: Details */}
              <TabsContent value={0}>
                <div className="flex flex-col gap-5 pt-3">
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
                              variant={
                                status === opt.value ? "default" : "outline"
                              }
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
                                  await updateTask(taskId, {
                                    priority: opt.value,
                                  });
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
                        <span className="flex flex-1 text-left truncate">
                          {assigneeId
                            ? teamMembers.find((u) => u.id === assigneeId)
                                ?.name ?? t("assignee")
                            : t("assignee")}
                        </span>
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

                  {/* Time Entries */}
                  <div>
                    <Label className="mb-1.5 text-xs text-muted-foreground">
                      {tTimer("timeEntries")}
                    </Label>
                    <TimeEntryList
                      entries={timeEntries}
                      onRefresh={() => taskId && loadTask(taskId)}
                    />
                    <div className="mt-2 flex items-center gap-2">
                      <ManualTimeForm
                        taskId={task.id}
                        onDone={() => taskId && loadTask(taskId)}
                      />
                      <TimerButton taskId={task.id} size="lg" />
                    </div>
                  </div>

                  {/* Recent Comments Preview */}
                  {task.comments.length > 0 && (
                    <div>
                      <div className="flex items-center justify-between mb-1.5">
                        <Label className="text-xs text-muted-foreground flex items-center gap-1">
                          <MessageSquare className="size-3" />
                          {tDocument("activity")}
                        </Label>
                        <button
                          type="button"
                          onClick={() => setActiveTab(2)}
                          className="text-xs text-primary hover:underline"
                        >
                          {t("viewAll")} ({task.comments.length}) →
                        </button>
                      </div>
                      <div className="flex flex-col gap-2 rounded-md border p-2">
                        {task.comments.slice(-3).map((c) => (
                          <div key={c.id} className="flex gap-2 text-xs">
                            <span className="font-medium shrink-0">
                              {c.author.name}
                            </span>
                            <span className="text-muted-foreground truncate">
                              {c.content}
                            </span>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Delete — only for deal lead / admin */}
                  {canManageTasks !== false && (
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
                  )}
                </div>
              </TabsContent>

              {/* Panel 1: Documents */}
              <TabsContent value={1}>
                <TaskDocumentsTab
                  taskId={task.id}
                  dealId={task.workstream.dealId}
                  workstreamId={task.workstreamId}
                />
              </TabsContent>

              {/* Panel 2: Activity */}
              <TabsContent value={2}>
                <div className="pt-3">
                  <TaskComments
                    taskId={task.id}
                    comments={task.comments}
                    onRefresh={() => taskId && loadTask(taskId)}
                  />
                </div>
              </TabsContent>
            </Tabs>
          </div>
        ) : null}
      </SheetContent>
    </Sheet>
  );
}

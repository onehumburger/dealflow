"use client";

import { useTranslations } from "next-intl";
import { Badge } from "@/components/ui/badge";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { X } from "lucide-react";
import { useTaskFilters } from "@/hooks/use-task-filters";
import type { TaskStatus } from "@/generated/prisma/client";

interface TaskFiltersProps {
  members: { id: string; name: string }[];
}

export function TaskFilters({ members }: TaskFiltersProps) {
  const t = useTranslations("task");

  const statusFilter = useTaskFilters((s) => s.statusFilter);
  const assigneeFilter = useTaskFilters((s) => s.assigneeFilter);
  const setStatusFilter = useTaskFilters((s) => s.setStatusFilter);
  const setAssigneeFilter = useTaskFilters((s) => s.setAssigneeFilter);
  const reset = useTaskFilters((s) => s.reset);

  const hasFilters = statusFilter !== "all" || assigneeFilter !== "all";

  const statusOptions: { value: TaskStatus | "all"; label: string }[] = [
    { value: "all", label: t("allStatuses") },
    { value: "ToDo", label: t("toDo") },
    { value: "InProgress", label: t("inProgress") },
    { value: "Done", label: t("done") },
  ];

  return (
    <div className="mb-3 flex items-center gap-2">
      {/* Status filter */}
      <div className="flex gap-1">
        {statusOptions.map((opt) => (
          <button
            key={opt.value}
            type="button"
            onClick={() => setStatusFilter(opt.value)}
          >
            <Badge
              variant={statusFilter === opt.value ? "default" : "outline"}
            >
              {opt.label}
            </Badge>
          </button>
        ))}
      </div>

      {/* Assignee filter */}
      <Select
        value={assigneeFilter}
        onValueChange={(val) => setAssigneeFilter(val ?? "all")}
      >
        <SelectTrigger size="sm">
          <span className="flex flex-1 text-left truncate">
            {assigneeFilter === "all"
              ? t("allAssignees")
              : members.find((m) => m.id === assigneeFilter)?.name ?? t("assignee")}
          </span>
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">{t("allAssignees")}</SelectItem>
          {members.map((m) => (
            <SelectItem key={m.id} value={m.id}>
              {m.name}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>

      {/* Clear */}
      {hasFilters && (
        <Button variant="ghost" size="icon-xs" onClick={reset}>
          <X className="size-3" />
        </Button>
      )}
    </div>
  );
}

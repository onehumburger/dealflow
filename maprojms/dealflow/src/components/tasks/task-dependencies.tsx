"use client";

import { useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Link2, Plus, X, Search } from "lucide-react";
import {
  addTaskDependency,
  removeTaskDependency,
} from "@/actions/tasks";
import { useTaskPanel } from "@/hooks/use-task-panel";
import type { DependencyType, TaskStatus } from "@/generated/prisma/client";

interface DependencyLink {
  id: string;
  type: DependencyType;
  dependsOn: { id: string; title: string; status: TaskStatus };
}

interface BlocksLink {
  id: string;
  type: DependencyType;
  task: { id: string; title: string; status: TaskStatus };
}

interface TaskDependenciesProps {
  taskId: string;
  blockedBy: DependencyLink[];
  blocks: BlocksLink[];
  dealId: string;
  onRefresh: () => void;
}

export function TaskDependencies({
  taskId,
  blockedBy,
  blocks,
  dealId,
  onRefresh,
}: TaskDependenciesProps) {
  const t = useTranslations("task");
  const tCommon = useTranslations("common");
  const openPanel = useTaskPanel((s) => s.open);
  const [isPending, startTransition] = useTransition();
  const [showSearch, setShowSearch] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const [searchResults, setSearchResults] = useState<
    { id: string; title: string }[]
  >([]);
  const [depType, setDepType] = useState<DependencyType>("Blocks");

  async function handleSearch(query: string) {
    setSearchQuery(query);
    if (!query.trim()) {
      setSearchResults([]);
      return;
    }

    // Search tasks in the same deal via a lightweight fetch
    try {
      const res = await fetch(
        `/api/tasks/search?dealId=${dealId}&q=${encodeURIComponent(query)}&exclude=${taskId}`
      );
      if (res.ok) {
        const data = await res.json();
        setSearchResults(data);
      }
    } catch {
      setSearchResults([]);
    }
  }

  function handleAddDependency(dependsOnTaskId: string) {
    startTransition(async () => {
      await addTaskDependency(taskId, dependsOnTaskId, depType);
      setShowSearch(false);
      setSearchQuery("");
      setSearchResults([]);
      onRefresh();
    });
  }

  function handleRemove(dependencyId: string) {
    startTransition(async () => {
      await removeTaskDependency(dependencyId);
      onRefresh();
    });
  }

  const statusColor: Record<TaskStatus, string> = {
    ToDo: "outline",
    InProgress: "secondary",
    Done: "default",
  };

  return (
    <div>
      <div className="mb-1.5 flex items-center justify-between">
        <span className="text-xs font-medium text-muted-foreground">
          <Link2 className="mr-1 inline size-3" />
          {t("dependencies")}
        </span>
        <Button
          variant="ghost"
          size="icon-xs"
          onClick={() => setShowSearch(!showSearch)}
        >
          <Plus className="size-3" />
        </Button>
      </div>

      {/* Blocked by */}
      {blockedBy.length > 0 && (
        <div className="mb-2">
          <span className="text-[10px] uppercase text-muted-foreground">
            {t("blockedBy")}
          </span>
          <div className="flex flex-col gap-1 mt-0.5">
            {blockedBy.map((dep) => (
              <div
                key={dep.id}
                className="group flex items-center gap-1.5 rounded px-1 py-0.5 hover:bg-muted/50"
              >
                <Badge
                  variant={
                    statusColor[dep.dependsOn.status] as
                      | "outline"
                      | "secondary"
                      | "default"
                  }
                  className="h-4 text-[10px]"
                >
                  {dep.type}
                </Badge>
                <button
                  type="button"
                  onClick={() => openPanel(dep.dependsOn.id)}
                  className="flex-1 truncate text-left text-xs hover:underline"
                >
                  {dep.dependsOn.title}
                </button>
                <button
                  type="button"
                  onClick={() => handleRemove(dep.id)}
                  disabled={isPending}
                  className="invisible text-muted-foreground hover:text-destructive group-hover:visible"
                >
                  <X className="size-3" />
                </button>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Blocks */}
      {blocks.length > 0 && (
        <div className="mb-2">
          <span className="text-[10px] uppercase text-muted-foreground">
            {t("blocks")}
          </span>
          <div className="flex flex-col gap-1 mt-0.5">
            {blocks.map((dep) => (
              <div
                key={dep.id}
                className="group flex items-center gap-1.5 rounded px-1 py-0.5 hover:bg-muted/50"
              >
                <Badge
                  variant={
                    statusColor[dep.task.status] as
                      | "outline"
                      | "secondary"
                      | "default"
                  }
                  className="h-4 text-[10px]"
                >
                  {dep.type}
                </Badge>
                <button
                  type="button"
                  onClick={() => openPanel(dep.task.id)}
                  className="flex-1 truncate text-left text-xs hover:underline"
                >
                  {dep.task.title}
                </button>
                <button
                  type="button"
                  onClick={() => handleRemove(dep.id)}
                  disabled={isPending}
                  className="invisible text-muted-foreground hover:text-destructive group-hover:visible"
                >
                  <X className="size-3" />
                </button>
              </div>
            ))}
          </div>
        </div>
      )}

      {blockedBy.length === 0 && blocks.length === 0 && (
        <p className="text-xs text-muted-foreground py-1">--</p>
      )}

      {/* Search to add */}
      {showSearch && (
        <div className="mt-2 rounded-md border p-2">
          <div className="flex gap-1.5 mb-2">
            <button
              type="button"
              onClick={() => setDepType("Blocks")}
            >
              <Badge variant={depType === "Blocks" ? "default" : "outline"}>
                {t("blocks")}
              </Badge>
            </button>
            <button
              type="button"
              onClick={() => setDepType("RelatedTo")}
            >
              <Badge variant={depType === "RelatedTo" ? "default" : "outline"}>
                {t("relatedTo")}
              </Badge>
            </button>
          </div>
          <div className="relative">
            <Search className="absolute left-2 top-1/2 size-3 -translate-y-1/2 text-muted-foreground" />
            <Input
              value={searchQuery}
              onChange={(e) => handleSearch(e.target.value)}
              placeholder={tCommon("search")}
              className="h-7 pl-7 text-xs"
              autoFocus
            />
          </div>
          {searchResults.length > 0 && (
            <div className="mt-1.5 flex flex-col gap-0.5">
              {searchResults.map((result) => (
                <button
                  key={result.id}
                  type="button"
                  onClick={() => handleAddDependency(result.id)}
                  disabled={isPending}
                  className="rounded px-2 py-1 text-left text-xs hover:bg-muted/50"
                >
                  {result.title}
                </button>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

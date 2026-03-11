"use client";

import { useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Plus, Trash2, X, Link2 } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import {
  addDecisionOption,
  removeDecisionOption,
  deleteDecision,
  linkDecisionToTask,
  unlinkDecisionFromTask,
} from "@/actions/decisions";
import type { DecisionItem } from "./decision-list";

interface DecisionDetailProps {
  decision: DecisionItem;
  dealId: string;
  onClose: () => void;
}

export function DecisionDetail({
  decision,
  dealId,
  onClose,
}: DecisionDetailProps) {
  const t = useTranslations("decision");
  const tCommon = useTranslations("common");
  const [isPending, startTransition] = useTransition();
  const [newOptDesc, setNewOptDesc] = useState("");
  const [newOptPros, setNewOptPros] = useState("");
  const [taskSearchQuery, setTaskSearchQuery] = useState("");
  const [taskResults, setTaskResults] = useState<
    { id: string; title: string }[]
  >([]);

  function handleAddOption() {
    if (!newOptDesc.trim()) return;
    startTransition(async () => {
      await addDecisionOption(decision.id, newOptDesc, newOptPros || undefined);
      setNewOptDesc("");
      setNewOptPros("");
    });
  }

  function handleRemoveOption(optionId: string) {
    startTransition(async () => {
      await removeDecisionOption(optionId);
    });
  }

  function handleDelete() {
    if (!confirm(t("deleteConfirm"))) return;
    startTransition(async () => {
      await deleteDecision(decision.id);
      onClose();
    });
  }

  function handleUnlinkTask(taskId: string) {
    startTransition(async () => {
      await unlinkDecisionFromTask(decision.id, taskId);
    });
  }

  async function searchTasks(query: string) {
    setTaskSearchQuery(query);
    if (query.length < 2) {
      setTaskResults([]);
      return;
    }
    const excludeIds = decision.linkedTasks.map((lt) => lt.taskId).join(",");
    const res = await fetch(
      `/api/tasks/search?dealId=${dealId}&q=${encodeURIComponent(query)}&exclude=${excludeIds}`
    );
    const data = await res.json();
    setTaskResults(data);
  }

  function handleLinkTask(taskId: string) {
    startTransition(async () => {
      await linkDecisionToTask(decision.id, taskId);
      setTaskSearchQuery("");
      setTaskResults([]);
    });
  }

  return (
    <Sheet open onOpenChange={(open) => !open && onClose()}>
      <SheetContent side="right" className="overflow-y-auto data-[side=right]:sm:max-w-lg">
        <SheetHeader>
          <SheetTitle>{decision.title}</SheetTitle>
        </SheetHeader>

        <div className="flex flex-col gap-6 px-4 pb-4">
          {/* Status */}
          <div className="flex items-center gap-2">
            <Badge variant="secondary">
              {t(
                decision.status === "PendingAnalysis"
                  ? "pendingAnalysis"
                  : decision.status === "Reported"
                    ? "reported"
                    : decision.status === "Decided"
                      ? "decided"
                      : "implemented"
              )}
            </Badge>
            {decision.workstream && (
              <span className="text-xs text-muted-foreground">
                {decision.workstream.name}
              </span>
            )}
          </div>

          {/* Background */}
          {decision.background && (
            <div>
              <h4 className="mb-1 text-xs font-medium uppercase text-muted-foreground">
                {t("background")}
              </h4>
              <p className="text-sm whitespace-pre-wrap">
                {decision.background}
              </p>
            </div>
          )}

          {/* Analysis */}
          {decision.analysis && (
            <div>
              <h4 className="mb-1 text-xs font-medium uppercase text-muted-foreground">
                {t("analysis")}
              </h4>
              <p className="text-sm whitespace-pre-wrap">
                {decision.analysis}
              </p>
            </div>
          )}

          {/* Options */}
          <div>
            <h4 className="mb-2 text-xs font-medium uppercase text-muted-foreground">
              {t("options")}
            </h4>
            <div className="flex flex-col gap-2">
              {decision.options
                .sort((a, b) => a.sortOrder - b.sortOrder)
                .map((opt, idx) => (
                  <div
                    key={opt.id}
                    className="rounded-md border p-2 text-sm"
                  >
                    <div className="flex items-start justify-between gap-2">
                      <span className="font-medium">
                        {t("option")} {idx + 1}: {opt.description}
                      </span>
                      <Button
                        variant="ghost"
                        size="icon-sm"
                        onClick={() => handleRemoveOption(opt.id)}
                        disabled={isPending}
                      >
                        <Trash2 className="size-3.5" />
                      </Button>
                    </div>
                    {opt.prosAndCons && (
                      <p className="mt-1 text-muted-foreground whitespace-pre-wrap">
                        {opt.prosAndCons}
                      </p>
                    )}
                  </div>
                ))}
            </div>

            {/* Add option */}
            <div className="mt-2 flex flex-col gap-1.5">
              <Input
                placeholder={t("optionDescription")}
                value={newOptDesc}
                onChange={(e) => setNewOptDesc(e.target.value)}
              />
              <Textarea
                placeholder={t("prosAndCons")}
                rows={2}
                value={newOptPros}
                onChange={(e) => setNewOptPros(e.target.value)}
              />
              <Button
                size="sm"
                variant="outline"
                onClick={handleAddOption}
                disabled={isPending || !newOptDesc.trim()}
              >
                <Plus className="mr-1 size-3.5" />
                {t("addOption")}
              </Button>
            </div>
          </div>

          {/* Client Decision */}
          {decision.clientDecision && (
            <div>
              <h4 className="mb-1 text-xs font-medium uppercase text-muted-foreground">
                {t("clientDecision")}
              </h4>
              <p className="text-sm whitespace-pre-wrap">
                {decision.clientDecision}
              </p>
            </div>
          )}

          {/* Linked Tasks */}
          <div>
            <h4 className="mb-2 text-xs font-medium uppercase text-muted-foreground">
              {t("linkedTasks")}
            </h4>
            <div className="flex flex-col gap-1">
              {decision.linkedTasks.map((lt) => (
                <div
                  key={lt.taskId}
                  className="flex items-center justify-between rounded-md border px-2 py-1 text-sm"
                >
                  <div className="flex items-center gap-1.5">
                    <Link2 className="size-3.5 text-muted-foreground" />
                    {lt.task.title}
                  </div>
                  <Button
                    variant="ghost"
                    size="icon-sm"
                    onClick={() => handleUnlinkTask(lt.taskId)}
                    disabled={isPending}
                  >
                    <X className="size-3.5" />
                  </Button>
                </div>
              ))}
            </div>

            {/* Search & link tasks */}
            <div className="mt-2">
              <Input
                placeholder={t("searchTask")}
                value={taskSearchQuery}
                onChange={(e) => searchTasks(e.target.value)}
              />
              {taskResults.length > 0 && (
                <div className="mt-1 rounded-md border divide-y">
                  {taskResults.map((task) => (
                    <button
                      key={task.id}
                      className="flex w-full items-center px-2 py-1.5 text-sm hover:bg-muted/50"
                      onClick={() => handleLinkTask(task.id)}
                    >
                      <Plus className="mr-1.5 size-3.5" />
                      {task.title}
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Delete decision */}
          <div className="border-t pt-4">
            <Button
              variant="destructive"
              size="sm"
              onClick={handleDelete}
              disabled={isPending}
            >
              <Trash2 className="mr-1 size-3.5" />
              {tCommon("delete")}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  );
}

"use client";

import { useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Plus, Trash2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
} from "@/components/ui/dialog";
import { createDecision, updateDecision } from "@/actions/decisions";
import type {
  DecisionSource,
  DecisionStatus,
} from "@/generated/prisma/client";

interface WorkstreamOption {
  id: string;
  name: string;
}

interface DecisionData {
  id: string;
  title: string;
  background: string | null;
  source: DecisionSource;
  analysis: string | null;
  clientDecision: string | null;
  status: DecisionStatus;
  workstreamId: string | null;
}

interface DecisionFormProps {
  dealId: string;
  workstreams: WorkstreamOption[];
  decision?: DecisionData;
  trigger: React.ReactNode;
}

const SOURCES: DecisionSource[] = [
  "DDFinding",
  "Negotiation",
  "Regulatory",
  "Other",
];
const STATUSES: DecisionStatus[] = [
  "PendingAnalysis",
  "Reported",
  "Decided",
  "Implemented",
];

export function DecisionForm({
  dealId,
  workstreams,
  decision,
  trigger,
}: DecisionFormProps) {
  const t = useTranslations("decision");
  const tCommon = useTranslations("common");
  const [isPending, startTransition] = useTransition();
  const [open, setOpen] = useState(false);

  const isEdit = !!decision;

  const sourceLabel = (s: DecisionSource): string => {
    const map: Record<DecisionSource, string> = {
      DDFinding: t("ddFinding"),
      Negotiation: t("negotiation"),
      Regulatory: t("regulatory"),
      Other: t("other"),
    };
    return map[s];
  };

  const statusLabel = (s: DecisionStatus): string => {
    const map: Record<DecisionStatus, string> = {
      PendingAnalysis: t("pendingAnalysis"),
      Reported: t("reported"),
      Decided: t("decided"),
      Implemented: t("implemented"),
    };
    return map[s];
  };

  function handleSubmit(formData: FormData) {
    startTransition(async () => {
      if (isEdit && decision) {
        await updateDecision(decision.id, {
          title: formData.get("title") as string,
          background: (formData.get("background") as string) || null,
          source: formData.get("source") as DecisionSource,
          analysis: (formData.get("analysis") as string) || null,
          clientDecision:
            (formData.get("clientDecision") as string) || null,
          status: formData.get("status") as DecisionStatus,
          workstreamId:
            (formData.get("workstreamId") as string) || null,
        });
      } else {
        formData.set("dealId", dealId);
        await createDecision(formData);
      }
      setOpen(false);
    });
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger render={<span />}>{trigger}</DialogTrigger>
      <DialogContent className="sm:max-w-lg">
        <DialogHeader>
          <DialogTitle>
            {isEdit ? tCommon("edit") : t("newDecision")}
          </DialogTitle>
        </DialogHeader>

        <form action={handleSubmit} className="flex flex-col gap-4">
          {/* Title */}
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="dec-title">{t("title")}</Label>
            <Input
              id="dec-title"
              name="title"
              required
              defaultValue={decision?.title ?? ""}
            />
          </div>

          {/* Source + Status side-by-side */}
          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-1.5">
              <Label>{t("source")}</Label>
              <Select
                name="source"
                defaultValue={decision?.source ?? "Other"}
              >
                <SelectTrigger className="w-full">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {SOURCES.map((s) => (
                    <SelectItem key={s} value={s}>
                      {sourceLabel(s)}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="flex flex-col gap-1.5">
              <Label>{t("status")}</Label>
              <Select
                name="status"
                defaultValue={decision?.status ?? "PendingAnalysis"}
              >
                <SelectTrigger className="w-full">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {STATUSES.map((s) => (
                    <SelectItem key={s} value={s}>
                      {statusLabel(s)}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>

          {/* Workstream */}
          {workstreams.length > 0 && (
            <div className="flex flex-col gap-1.5">
              <Label>{t("workstream")}</Label>
              <Select
                name="workstreamId"
                defaultValue={decision?.workstreamId ?? ""}
              >
                <SelectTrigger className="w-full">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="">{"\u2014"}</SelectItem>
                  {workstreams.map((ws) => (
                    <SelectItem key={ws.id} value={ws.id}>
                      {ws.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          )}

          {/* Background */}
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="dec-bg">{t("background")}</Label>
            <Textarea
              id="dec-bg"
              name="background"
              rows={3}
              defaultValue={decision?.background ?? ""}
            />
          </div>

          {/* Analysis */}
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="dec-analysis">{t("analysis")}</Label>
            <Textarea
              id="dec-analysis"
              name="analysis"
              rows={3}
              defaultValue={decision?.analysis ?? ""}
            />
          </div>

          {/* Client Decision */}
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="dec-cd">{t("clientDecision")}</Label>
            <Textarea
              id="dec-cd"
              name="clientDecision"
              rows={2}
              defaultValue={decision?.clientDecision ?? ""}
            />
          </div>

          <DialogFooter>
            <Button type="submit" disabled={isPending}>
              {isPending
                ? tCommon("loading")
                : isEdit
                  ? tCommon("save")
                  : tCommon("create")}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}

"use client";

import { useState, useTransition } from "react";
import Link from "next/link";
import { useLocale, useTranslations } from "next-intl";
import { ArrowLeft, ChevronDown, Copy, Pencil } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { DealStatusBadge } from "./deal-status-badge";
import { updateDeal } from "@/actions/deals";
import { saveDealAsTemplate } from "@/actions/templates";
import type { DealStatus } from "@/generated/prisma/client";

interface DealHeaderProps {
  deal: {
    id: string;
    name: string;
    codeName: string | null;
    status: DealStatus;
    clientName: string;
    targetCompany: string;
    jurisdictions: string[];
    summary: string | null;
    dealLead: { name: string };
  };
}

const ALL_STATUSES: DealStatus[] = ["Active", "OnHold", "Completed"];

export function DealHeader({ deal }: DealHeaderProps) {
  const locale = useLocale();
  const t = useTranslations("deal");
  const tTemplate = useTranslations("template");
  const tCommon = useTranslations("common");
  const [expanded, setExpanded] = useState(false);
  const [isPending, startTransition] = useTransition();
  const [templateOpen, setTemplateOpen] = useState(false);
  const [templateName, setTemplateName] = useState("");
  const [templateSaving, startTemplateSave] = useTransition();
  const [templateSaved, setTemplateSaved] = useState(false);
  const [editOpen, setEditOpen] = useState(false);
  const [editName, setEditName] = useState(deal.name);
  const [editCodeName, setEditCodeName] = useState(deal.codeName ?? "");
  const [editClient, setEditClient] = useState(deal.clientName);
  const [editTarget, setEditTarget] = useState(deal.targetCompany);
  const [editJurisdictions, setEditJurisdictions] = useState(deal.jurisdictions.join(", "));
  const [editSummary, setEditSummary] = useState(deal.summary ?? "");
  const [editSaving, startEditSave] = useTransition();

  function handleStatusChange(newStatus: DealStatus) {
    startTransition(async () => {
      await updateDeal(deal.id, { status: newStatus });
    });
  }

  function handleEditSave() {
    if (!editName.trim() || !editClient.trim() || !editTarget.trim()) return;
    startEditSave(async () => {
      await updateDeal(deal.id, {
        name: editName.trim(),
        codeName: editCodeName.trim() || null,
        clientName: editClient.trim(),
        targetCompany: editTarget.trim(),
        jurisdictions: editJurisdictions.split(",").map((s) => s.trim()).filter(Boolean),
        summary: editSummary.trim() || null,
      });
      setEditOpen(false);
    });
  }

  function handleSaveTemplate() {
    if (!templateName.trim()) return;
    startTemplateSave(async () => {
      await saveDealAsTemplate(deal.id, templateName.trim());
      setTemplateSaved(true);
      setTimeout(() => {
        setTemplateOpen(false);
        setTemplateSaved(false);
        setTemplateName("");
      }, 1200);
    });
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-2">
        <Link
          href={`/${locale}/deals`}
          className="flex items-center gap-1 text-sm text-muted-foreground hover:text-foreground"
        >
          <ArrowLeft className="size-4" />
          {t("backToDeals")}
        </Link>
      </div>

      <div className="flex items-center gap-3">
        <h1 className="text-2xl font-bold">{deal.name}</h1>
        {deal.codeName && (
          <span className="text-sm text-muted-foreground">({deal.codeName})</span>
        )}

        <Button
          variant="ghost"
          size="icon-xs"
          onClick={() => setEditOpen(true)}
          className="text-muted-foreground"
        >
          <Pencil className="size-3.5" />
        </Button>

        <DropdownMenu>
          <DropdownMenuTrigger
            disabled={isPending}
            className="inline-flex items-center gap-1"
          >
            <DealStatusBadge status={deal.status} locale={locale} />
            <ChevronDown className="size-3 text-muted-foreground" />
          </DropdownMenuTrigger>
          <DropdownMenuContent>
            {ALL_STATUSES.map((s) => (
              <DropdownMenuItem
                key={s}
                onClick={() => handleStatusChange(s)}
              >
                <DealStatusBadge status={s} locale={locale} />
              </DropdownMenuItem>
            ))}
          </DropdownMenuContent>
        </DropdownMenu>

        <div className="ml-auto">
          <Dialog open={templateOpen} onOpenChange={setTemplateOpen}>
            <DialogTrigger
              render={
                <Button variant="outline" size="sm">
                  <Copy className="mr-1.5 size-3.5" />
                  {tTemplate("saveAsTemplate")}
                </Button>
              }
            />
            <DialogContent>
              <DialogHeader>
                <DialogTitle>{tTemplate("saveAsTemplate")}</DialogTitle>
              </DialogHeader>
              <div className="space-y-4 pt-2">
                <div>
                  <label className="mb-1.5 block text-sm font-medium">
                    {tTemplate("templateName")}
                  </label>
                  <Input
                    value={templateName}
                    onChange={(e) => setTemplateName(e.target.value)}
                    placeholder={tTemplate("templateNamePlaceholder")}
                    disabled={templateSaving}
                  />
                </div>
                {templateSaved ? (
                  <p className="text-sm font-medium text-emerald-600">
                    {tTemplate("saved")}
                  </p>
                ) : (
                  <div className="flex justify-end gap-2">
                    <Button
                      variant="outline"
                      onClick={() => setTemplateOpen(false)}
                      disabled={templateSaving}
                    >
                      {tCommon("cancel")}
                    </Button>
                    <Button
                      onClick={handleSaveTemplate}
                      disabled={templateSaving || !templateName.trim()}
                    >
                      {tCommon("save")}
                    </Button>
                  </div>
                )}
              </div>
            </DialogContent>
          </Dialog>
        </div>
      </div>

      <div className="flex items-center gap-4 text-sm text-muted-foreground">
        <span>
          {t("clientName")}: <strong className="text-foreground">{deal.clientName}</strong>
        </span>
        <span>|</span>
        <span>
          {t("targetCompany")}: <strong className="text-foreground">{deal.targetCompany}</strong>
        </span>
        <span>|</span>
        <span>
          {t("dealLead")}: <strong className="text-foreground">{deal.dealLead.name}</strong>
        </span>
      </div>

      {deal.summary && (
        <div>
          <button
            onClick={() => setExpanded(!expanded)}
            className="text-sm text-muted-foreground hover:text-foreground"
          >
            {expanded ? "\u25B2" : "\u25BC"} {t("summary")}
          </button>
          {expanded && (
            <p className="mt-1 text-sm text-muted-foreground whitespace-pre-wrap">
              {deal.summary}
            </p>
          )}
        </div>
      )}

      {/* Edit Deal Dialog */}
      <Dialog open={editOpen} onOpenChange={setEditOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{tCommon("edit")} — {deal.name}</DialogTitle>
          </DialogHeader>
          <div className="space-y-3 pt-2">
            <div>
              <label className="mb-1 block text-sm font-medium">{t("name")}</label>
              <Input value={editName} onChange={(e) => setEditName(e.target.value)} disabled={editSaving} />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium">{t("codeName")}</label>
              <Input value={editCodeName} onChange={(e) => setEditCodeName(e.target.value)} disabled={editSaving} />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium">{t("clientName")}</label>
              <Input value={editClient} onChange={(e) => setEditClient(e.target.value)} disabled={editSaving} />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium">{t("targetCompany")}</label>
              <Input value={editTarget} onChange={(e) => setEditTarget(e.target.value)} disabled={editSaving} />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium">{t("jurisdictions")}</label>
              <Input
                value={editJurisdictions}
                onChange={(e) => setEditJurisdictions(e.target.value)}
                placeholder="PRC, Vietnam"
                disabled={editSaving}
              />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium">{t("summary")}</label>
              <textarea
                value={editSummary}
                onChange={(e) => setEditSummary(e.target.value)}
                className="flex min-h-[80px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                disabled={editSaving}
              />
            </div>
            <div className="flex justify-end gap-2">
              <Button variant="outline" onClick={() => setEditOpen(false)} disabled={editSaving}>
                {tCommon("cancel")}
              </Button>
              <Button onClick={handleEditSave} disabled={editSaving || !editName.trim()}>
                {tCommon("save")}
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}

"use client";

import { useState, useTransition } from "react";
import Link from "next/link";
import { useLocale, useTranslations } from "next-intl";
import { ArrowLeft, ChevronDown, Copy } from "lucide-react";
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
    status: DealStatus;
    clientName: string;
    targetCompany: string;
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

  function handleStatusChange(newStatus: DealStatus) {
    startTransition(async () => {
      await updateDeal(deal.id, { status: newStatus });
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
    </div>
  );
}

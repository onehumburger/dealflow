"use client";

import { useState, useTransition } from "react";
import Link from "next/link";
import { useLocale, useTranslations } from "next-intl";
import { ArrowLeft, Check, ChevronDown, Copy, Pencil, X } from "lucide-react";
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
import { DealPhaseBadge } from "./deal-phase-badge";
import { updateDeal } from "@/actions/deals";
import { saveDealAsTemplate } from "@/actions/templates";
import type { DealStatus, DealPhase, DealSource } from "@/generated/prisma/client";

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
    phase: DealPhase;
    dealValue: number | null;
    valueCurrency: string;
    keyTerms: string | null;
    source: DealSource | null;
    sourceNote: string | null;
  };
}

const ALL_STATUSES: DealStatus[] = ["Active", "OnHold", "Completed"];
const ALL_PHASES: DealPhase[] = ["Intake", "DueDiligence", "Negotiation", "Signing", "Closing", "PostClosing"];
const ALL_SOURCES: DealSource[] = ["FAReferral", "DirectClient", "PartnerReferral", "Repeat", "Other"];
const CURRENCIES = ["USD", "CNY", "EUR", "HKD", "SGD", "VND"] as const;

export function DealHeader({ deal }: DealHeaderProps) {
  const locale = useLocale();
  const t = useTranslations("deal");
  const tTemplate = useTranslations("template");
  const tCommon = useTranslations("common");
  const [expanded, setExpanded] = useState(false);
  const [keyTermsExpanded, setKeyTermsExpanded] = useState(false);
  const [isPending, startTransition] = useTransition();
  const [valueEditing, setValueEditing] = useState(false);
  const [inlineValue, setInlineValue] = useState(deal.dealValue?.toString() ?? "");
  const [inlineCurrency, setInlineCurrency] = useState(deal.valueCurrency);
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
  const [editPhase, setEditPhase] = useState(deal.phase);
  const [editDealValue, setEditDealValue] = useState(deal.dealValue?.toString() ?? "");
  const [editValueCurrency, setEditValueCurrency] = useState(deal.valueCurrency);
  const [editKeyTerms, setEditKeyTerms] = useState(deal.keyTerms ?? "");
  const [editSource, setEditSource] = useState<DealSource | "">(deal.source ?? "");
  const [editSourceNote, setEditSourceNote] = useState(deal.sourceNote ?? "");
  const [editSaving, startEditSave] = useTransition();
  const [summaryEditing, setSummaryEditing] = useState(false);
  const [inlineSummary, setInlineSummary] = useState(deal.summary ?? "");

  function handleStatusChange(newStatus: DealStatus) {
    startTransition(async () => {
      await updateDeal(deal.id, { status: newStatus });
    });
  }

  function handlePhaseChange(newPhase: DealPhase) {
    startTransition(async () => {
      await updateDeal(deal.id, { phase: newPhase });
    });
  }

  function handleValueSave() {
    const parsed = inlineValue.trim() ? parseFloat(inlineValue) : null;
    startTransition(async () => {
      await updateDeal(deal.id, {
        dealValue: parsed !== null && !isNaN(parsed) ? parsed : null,
        valueCurrency: inlineCurrency,
      });
      setValueEditing(false);
    });
  }

  function handleSummarySave() {
    startTransition(async () => {
      await updateDeal(deal.id, { summary: inlineSummary.trim() || null });
      setSummaryEditing(false);
    });
  }

  function handleEditSave() {
    if (!editName.trim() || !editClient.trim() || !editTarget.trim()) return;
    startEditSave(async () => {
      const parsedValue = editDealValue.trim() ? parseFloat(editDealValue) : null;
      await updateDeal(deal.id, {
        name: editName.trim(),
        codeName: editCodeName.trim() || null,
        clientName: editClient.trim(),
        targetCompany: editTarget.trim(),
        jurisdictions: editJurisdictions.split(",").map((s) => s.trim()).filter(Boolean),
        summary: editSummary.trim() || null,
        phase: editPhase as DealPhase,
        dealValue: parsedValue !== null && !isNaN(parsedValue) ? parsedValue : null,
        valueCurrency: editValueCurrency,
        keyTerms: editKeyTerms.trim() || null,
        source: editSource || null,
        sourceNote: editSourceNote.trim() || null,
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

        <DropdownMenu>
          <DropdownMenuTrigger
            disabled={isPending}
            className="inline-flex items-center gap-1"
          >
            <DealPhaseBadge phase={deal.phase} locale={locale} />
            <ChevronDown className="size-3 text-muted-foreground" />
          </DropdownMenuTrigger>
          <DropdownMenuContent>
            {ALL_PHASES.map((p) => (
              <DropdownMenuItem
                key={p}
                onClick={() => handlePhaseChange(p)}
              >
                <DealPhaseBadge phase={p} locale={locale} />
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

      <div className="flex flex-wrap items-center gap-2 text-sm text-muted-foreground">
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

      <div className="flex flex-wrap items-center gap-2 text-sm text-muted-foreground">
        {valueEditing ? (
          <div className="flex items-center gap-1.5">
            <select
              value={inlineCurrency}
              onChange={(e) => setInlineCurrency(e.target.value)}
              className="h-7 rounded border border-input bg-background px-1.5 text-xs"
              disabled={isPending}
            >
              {CURRENCIES.map((c) => (
                <option key={c} value={c}>{c}</option>
              ))}
            </select>
            <Input
              type="number"
              step="0.01"
              value={inlineValue}
              onChange={(e) => setInlineValue(e.target.value)}
              className="h-7 w-36 text-xs"
              disabled={isPending}
              autoFocus
              onKeyDown={(e) => {
                if (e.key === "Enter") handleValueSave();
                if (e.key === "Escape") setValueEditing(false);
              }}
            />
            <Button variant="ghost" size="icon-xs" onClick={handleValueSave} disabled={isPending}>
              <Check className="size-3.5 text-emerald-600" />
            </Button>
            <Button variant="ghost" size="icon-xs" onClick={() => setValueEditing(false)} disabled={isPending}>
              <X className="size-3.5 text-muted-foreground" />
            </Button>
          </div>
        ) : (
          <button
            onClick={() => setValueEditing(true)}
            className="hover:text-foreground hover:underline decoration-dashed underline-offset-2"
          >
            {deal.dealValue !== null ? (
              <strong className="text-foreground">
                {deal.valueCurrency} {deal.dealValue.toLocaleString(locale === "zh" ? "zh-CN" : "en-US", { minimumFractionDigits: 0, maximumFractionDigits: 2 })}
              </strong>
            ) : (
              <span className="italic">{t("dealValue")}: —</span>
            )}
          </button>
        )}
        {!valueEditing && deal.source && (
          <>
            {deal.dealValue !== null && <span>|</span>}
            <span>
              {t(deal.source === "FAReferral" ? "faReferral" : deal.source === "DirectClient" ? "directClient" : deal.source === "PartnerReferral" ? "partnerReferral" : deal.source === "Repeat" ? "repeat" : "otherSource")}
              {deal.sourceNote && ` — ${deal.sourceNote}`}
            </span>
          </>
        )}
      </div>

      <div>
        <button
          onClick={() => setExpanded(!expanded)}
          className="text-sm text-muted-foreground hover:text-foreground"
        >
          {expanded ? "\u25B2" : "\u25BC"} {t("summary")}
        </button>
        {expanded && (
          summaryEditing ? (
            <div className="mt-1">
              <textarea
                value={inlineSummary}
                onChange={(e) => setInlineSummary(e.target.value)}
                className="flex min-h-[80px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                autoFocus
                onKeyDown={(e) => {
                  if (e.key === "Escape") {
                    setSummaryEditing(false);
                    setInlineSummary(deal.summary ?? "");
                  }
                }}
              />
              <div className="mt-1.5 flex items-center gap-1.5">
                <Button size="xs" onClick={handleSummarySave} disabled={isPending}>
                  {tCommon("save")}
                </Button>
                <Button size="xs" variant="ghost" onClick={() => { setSummaryEditing(false); setInlineSummary(deal.summary ?? ""); }}>
                  {tCommon("cancel")}
                </Button>
              </div>
            </div>
          ) : (
            <p
              className="mt-1 text-sm text-muted-foreground whitespace-pre-wrap cursor-pointer rounded px-1 -mx-1 hover:bg-muted/50"
              onClick={() => setSummaryEditing(true)}
              title={tCommon("edit")}
            >
              {deal.summary || <span className="italic">{t("summaryPlaceholder")}</span>}
            </p>
          )
        )}
      </div>

      {deal.keyTerms && (
        <div>
          <button
            onClick={() => setKeyTermsExpanded(!keyTermsExpanded)}
            className="text-sm text-muted-foreground hover:text-foreground"
          >
            {keyTermsExpanded ? "\u25B2" : "\u25BC"} {t("keyTerms")}
          </button>
          {keyTermsExpanded && (
            <p className="mt-1 text-sm text-muted-foreground whitespace-pre-wrap">
              {deal.keyTerms}
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
            {/* Phase */}
            <div>
              <label className="mb-1 block text-sm font-medium">{t("phase")}</label>
              <select
                value={editPhase}
                onChange={(e) => setEditPhase(e.target.value as DealPhase)}
                disabled={editSaving}
                className="flex h-8 w-full rounded-md border border-input bg-background px-3 text-sm"
              >
                {ALL_PHASES.map((p) => (
                  <option key={p} value={p}>
                    {t(p === "DueDiligence" ? "dueDiligence" : p === "PostClosing" ? "postClosing" : p.toLowerCase())}
                  </option>
                ))}
              </select>
            </div>
            {/* Deal Value + Currency */}
            <div className="grid grid-cols-[1fr_100px] gap-2">
              <div>
                <label className="mb-1 block text-sm font-medium">{t("dealValue")}</label>
                <Input
                  type="number"
                  step="0.01"
                  value={editDealValue}
                  onChange={(e) => setEditDealValue(e.target.value)}
                  disabled={editSaving}
                />
              </div>
              <div>
                <label className="mb-1 block text-sm font-medium">{t("valueCurrency")}</label>
                <select
                  value={editValueCurrency}
                  onChange={(e) => setEditValueCurrency(e.target.value)}
                  disabled={editSaving}
                  className="flex h-8 w-full rounded-md border border-input bg-background px-3 text-sm"
                >
                  {CURRENCIES.map((c) => (
                    <option key={c} value={c}>{c}</option>
                  ))}
                </select>
              </div>
            </div>
            {/* Key Terms */}
            <div>
              <label className="mb-1 block text-sm font-medium">{t("keyTerms")}</label>
              <textarea
                value={editKeyTerms}
                onChange={(e) => setEditKeyTerms(e.target.value)}
                className="flex min-h-[60px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                disabled={editSaving}
              />
            </div>
            {/* Source + Source Note */}
            <div>
              <label className="mb-1 block text-sm font-medium">{t("source")}</label>
              <select
                value={editSource}
                onChange={(e) => setEditSource(e.target.value as DealSource | "")}
                disabled={editSaving}
                className="flex h-8 w-full rounded-md border border-input bg-background px-3 text-sm"
              >
                <option value="">—</option>
                {ALL_SOURCES.map((s) => (
                  <option key={s} value={s}>
                    {t(s === "FAReferral" ? "faReferral" : s === "DirectClient" ? "directClient" : s === "PartnerReferral" ? "partnerReferral" : s === "Repeat" ? "repeat" : "otherSource")}
                  </option>
                ))}
              </select>
            </div>
            {editSource && (
              <div>
                <label className="mb-1 block text-sm font-medium">{t("sourceNote")}</label>
                <Input
                  value={editSourceNote}
                  onChange={(e) => setEditSourceNote(e.target.value)}
                  disabled={editSaving}
                />
              </div>
            )}
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

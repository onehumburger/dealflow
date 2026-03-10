"use client";

import { useEffect, useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { createDeal } from "@/actions/deals";

interface User {
  id: string;
  name: string;
}

interface Template {
  id: string;
  name: string;
  dealType: string;
  ourRole: string;
}

interface DealFormProps {
  users: User[];
  templates: Template[];
  mode?: "create" | "edit";
  defaultValues?: {
    id?: string;
    name?: string;
    codeName?: string;
    dealType?: string;
    ourRole?: string;
    clientName?: string;
    targetCompany?: string;
    jurisdictions?: string[];
    dealLeadId?: string;
    memberIds?: string[];
    summary?: string;
  };
}

const DEAL_TYPES = ["Auction", "Negotiated", "JV"] as const;
const OUR_ROLES = ["BuySide", "SellSide", "LeadParty", "ParticipatingParty"] as const;

export function DealForm({
  users,
  templates,
  mode = "create",
  defaultValues,
}: DealFormProps) {
  const t = useTranslations("deal");
  const tCommon = useTranslations("common");
  const [isPending, startTransition] = useTransition();

  const [dealType, setDealType] = useState(defaultValues?.dealType || "");
  const [ourRole, setOurRole] = useState(defaultValues?.ourRole || "");
  const [templateId, setTemplateId] = useState("");
  const [selectedMembers, setSelectedMembers] = useState<string[]>(
    defaultValues?.memberIds || []
  );

  // Auto-match template when dealType + ourRole change
  useEffect(() => {
    if (dealType && ourRole) {
      const matched = templates.find(
        (tpl) => tpl.dealType === dealType && tpl.ourRole === ourRole
      );
      if (matched) {
        setTemplateId(matched.id);
      }
    }
  }, [dealType, ourRole, templates]);

  function toggleMember(userId: string) {
    setSelectedMembers((prev) =>
      prev.includes(userId)
        ? prev.filter((id) => id !== userId)
        : [...prev, userId]
    );
  }

  function handleSubmit(formData: FormData) {
    formData.set("memberIds", selectedMembers.join(","));
    formData.set("templateId", templateId);
    startTransition(() => {
      createDeal(formData);
    });
  }

  const dealTypeLabels: Record<string, string> = {
    Auction: t("auction"),
    Negotiated: t("negotiated"),
    JV: t("jv"),
  };

  const roleLabels: Record<string, string> = {
    BuySide: t("buySide"),
    SellSide: t("sellSide"),
    LeadParty: t("leadParty"),
    ParticipatingParty: t("participatingParty"),
  };

  return (
    <Card className="mx-auto max-w-2xl">
      <CardHeader>
        <CardTitle>{mode === "create" ? t("newDeal") : tCommon("edit")}</CardTitle>
      </CardHeader>
      <CardContent>
        <form action={handleSubmit} className="flex flex-col gap-5">
          {/* Name */}
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="name">{t("name")}</Label>
            <Input
              id="name"
              name="name"
              required
              defaultValue={defaultValues?.name}
            />
          </div>

          {/* Code Name */}
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="codeName">{t("codeName")}</Label>
            <Input
              id="codeName"
              name="codeName"
              defaultValue={defaultValues?.codeName}
            />
          </div>

          {/* Deal Type + Our Role (side by side) */}
          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="dealType">{t("dealType")}</Label>
              <select
                id="dealType"
                name="dealType"
                required
                value={dealType}
                onChange={(e) => setDealType(e.target.value)}
                className="h-8 w-full rounded-lg border border-input bg-transparent px-2.5 text-sm outline-none focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50"
              >
                <option value="">{"\u2014"}</option>
                {DEAL_TYPES.map((dt) => (
                  <option key={dt} value={dt}>
                    {dealTypeLabels[dt]}
                  </option>
                ))}
              </select>
            </div>

            <div className="flex flex-col gap-1.5">
              <Label htmlFor="ourRole">{t("ourRole")}</Label>
              <select
                id="ourRole"
                name="ourRole"
                required
                value={ourRole}
                onChange={(e) => setOurRole(e.target.value)}
                className="h-8 w-full rounded-lg border border-input bg-transparent px-2.5 text-sm outline-none focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50"
              >
                <option value="">{"\u2014"}</option>
                {OUR_ROLES.map((role) => (
                  <option key={role} value={role}>
                    {roleLabels[role]}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* Template selector */}
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="templateId">{t("template")}</Label>
            <select
              id="templateId"
              value={templateId}
              onChange={(e) => setTemplateId(e.target.value)}
              className="h-8 w-full rounded-lg border border-input bg-transparent px-2.5 text-sm outline-none focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50"
            >
              <option value="">{t("selectTemplate")}</option>
              {templates.map((tpl) => (
                <option key={tpl.id} value={tpl.id}>
                  {tpl.name}
                </option>
              ))}
            </select>
          </div>

          {/* Client + Target (side by side) */}
          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="clientName">{t("clientName")}</Label>
              <Input
                id="clientName"
                name="clientName"
                required
                defaultValue={defaultValues?.clientName}
              />
            </div>

            <div className="flex flex-col gap-1.5">
              <Label htmlFor="targetCompany">{t("targetCompany")}</Label>
              <Input
                id="targetCompany"
                name="targetCompany"
                required
                defaultValue={defaultValues?.targetCompany}
              />
            </div>
          </div>

          {/* Jurisdictions */}
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="jurisdictions">{t("jurisdictions")}</Label>
            <Input
              id="jurisdictions"
              name="jurisdictions"
              placeholder="PRC, HK, US"
              defaultValue={defaultValues?.jurisdictions?.join(", ")}
            />
          </div>

          {/* Deal Lead */}
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="dealLeadId">{t("dealLead")}</Label>
            <select
              id="dealLeadId"
              name="dealLeadId"
              required
              defaultValue={defaultValues?.dealLeadId}
              className="h-8 w-full rounded-lg border border-input bg-transparent px-2.5 text-sm outline-none focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50"
            >
              <option value="">{"\u2014"}</option>
              {users.map((u) => (
                <option key={u.id} value={u.id}>
                  {u.name}
                </option>
              ))}
            </select>
          </div>

          {/* Team Members (multi-select via checkboxes) */}
          <div className="flex flex-col gap-1.5">
            <Label>{t("teamMembers")}</Label>
            <div className="flex flex-wrap gap-2">
              {users.map((u) => (
                <label
                  key={u.id}
                  className={`inline-flex cursor-pointer items-center gap-1.5 rounded-md border px-2.5 py-1 text-sm transition-colors ${
                    selectedMembers.includes(u.id)
                      ? "border-primary bg-primary/10 text-primary"
                      : "border-input hover:bg-accent"
                  }`}
                >
                  <input
                    type="checkbox"
                    className="sr-only"
                    checked={selectedMembers.includes(u.id)}
                    onChange={() => toggleMember(u.id)}
                  />
                  {u.name}
                </label>
              ))}
            </div>
          </div>

          {/* Summary */}
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="summary">{t("summary")}</Label>
            <Textarea
              id="summary"
              name="summary"
              defaultValue={defaultValues?.summary}
            />
          </div>

          <div className="flex justify-end gap-2 pt-2">
            <Button type="submit" disabled={isPending}>
              {isPending
                ? tCommon("loading")
                : mode === "create"
                  ? tCommon("create")
                  : tCommon("save")}
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}

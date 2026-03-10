"use client";

import { useState, useTransition } from "react";
import Link from "next/link";
import { useLocale, useTranslations } from "next-intl";
import { ArrowLeft, ChevronDown, Settings } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { DealStatusBadge } from "./deal-status-badge";
import { updateDeal } from "@/actions/deals";
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
  const [expanded, setExpanded] = useState(false);
  const [isPending, startTransition] = useTransition();

  function handleStatusChange(newStatus: DealStatus) {
    startTransition(async () => {
      await updateDeal(deal.id, { status: newStatus });
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

        <Button variant="ghost" size="icon" className="ml-auto">
          <Settings className="size-4" />
        </Button>
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

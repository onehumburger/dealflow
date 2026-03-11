"use client";

import { useState, useTransition } from "react";
import Link from "next/link";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { ChevronDown, Check, X } from "lucide-react";
import { DealStatusBadge } from "./deal-status-badge";
import { DealPhaseBadge } from "./deal-phase-badge";
import { updateDeal } from "@/actions/deals";
import type { DealStatus, DealPhase } from "@/generated/prisma/client";

export interface DealListItem {
  id: string;
  name: string;
  codeName: string | null;
  clientName: string;
  targetCompany: string;
  status: DealStatus;
  dealLead: { name: string };
  phase: DealPhase;
  dealValue: number | null;
  valueCurrency: string;
  workstreams: {
    tasks: { status: string }[];
  }[];
}

interface DealListProps {
  deals: DealListItem[];
  locale: string;
  translations: {
    name: string;
    codeName: string;
    clientName: string;
    targetCompany: string;
    status: string;
    dealLead: string;
    tasks: string;
    phase: string;
    dealValue: string;
  };
}

const ALL_PHASES: DealPhase[] = ["Intake", "DueDiligence", "Negotiation", "Signing", "Closing", "PostClosing"];
const CURRENCIES = ["USD", "CNY", "EUR", "HKD", "SGD", "VND"] as const;

function InlineValueEdit({
  dealId,
  initialValue,
  initialCurrency,
  locale,
}: {
  dealId: string;
  initialValue: number | null;
  initialCurrency: string;
  locale: string;
}) {
  const [editing, setEditing] = useState(false);
  const [value, setValue] = useState(initialValue?.toString() ?? "");
  const [currency, setCurrency] = useState(initialCurrency);
  const [isPending, startTransition] = useTransition();

  function handleSave() {
    const parsed = value.trim() ? parseFloat(value) : null;
    startTransition(async () => {
      await updateDeal(dealId, {
        dealValue: parsed !== null && !isNaN(parsed) ? parsed : null,
        valueCurrency: currency,
      });
      setEditing(false);
    });
  }

  if (editing) {
    return (
      <div className="flex items-center gap-1">
        <select
          value={currency}
          onChange={(e) => setCurrency(e.target.value)}
          className="h-7 rounded border border-input bg-background px-1 text-xs"
          disabled={isPending}
        >
          {CURRENCIES.map((c) => (
            <option key={c} value={c}>{c}</option>
          ))}
        </select>
        <Input
          type="number"
          step="0.01"
          value={value}
          onChange={(e) => setValue(e.target.value)}
          className="h-7 w-28 text-xs"
          disabled={isPending}
          autoFocus
          onKeyDown={(e) => {
            if (e.key === "Enter") handleSave();
            if (e.key === "Escape") setEditing(false);
          }}
        />
        <Button variant="ghost" size="icon-xs" onClick={handleSave} disabled={isPending}>
          <Check className="size-3 text-emerald-600" />
        </Button>
        <Button variant="ghost" size="icon-xs" onClick={() => setEditing(false)} disabled={isPending}>
          <X className="size-3 text-muted-foreground" />
        </Button>
      </div>
    );
  }

  const display = initialValue !== null
    ? `${initialCurrency} ${initialValue.toLocaleString(locale === "zh" ? "zh-CN" : "en-US", { minimumFractionDigits: 0, maximumFractionDigits: 2 })}`
    : "\u2014";

  return (
    <button
      onClick={() => setEditing(true)}
      className="text-left text-muted-foreground hover:text-foreground hover:underline decoration-dashed underline-offset-2"
    >
      {display}
    </button>
  );
}

export function DealList({ deals, locale, translations }: DealListProps) {
  const [isPending, startTransition] = useTransition();

  function handlePhaseChange(dealId: string, newPhase: DealPhase) {
    startTransition(async () => {
      await updateDeal(dealId, { phase: newPhase });
    });
  }

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>{translations.name}</TableHead>
          <TableHead>{translations.codeName}</TableHead>
          <TableHead>{translations.clientName}</TableHead>
          <TableHead>{translations.targetCompany}</TableHead>
          <TableHead>{translations.status}</TableHead>
          <TableHead>{translations.phase}</TableHead>
          <TableHead>{translations.dealValue}</TableHead>
          <TableHead>{translations.dealLead}</TableHead>
          <TableHead>{translations.tasks}</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {deals.map((deal) => {
          const allTasks = deal.workstreams.flatMap((ws) => ws.tasks);
          const doneTasks = allTasks.filter((t) => t.status === "Done").length;
          const totalTasks = allTasks.length;

          return (
            <TableRow key={deal.id}>
              <TableCell>
                <Link
                  href={`/${locale}/deals/${deal.id}`}
                  className="font-medium text-foreground hover:underline"
                >
                  {deal.name}
                </Link>
              </TableCell>
              <TableCell className="text-muted-foreground">
                {deal.codeName || "\u2014"}
              </TableCell>
              <TableCell>{deal.clientName}</TableCell>
              <TableCell>{deal.targetCompany}</TableCell>
              <TableCell>
                <DealStatusBadge status={deal.status} locale={locale} />
              </TableCell>
              <TableCell>
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
                        onClick={() => handlePhaseChange(deal.id, p)}
                      >
                        <DealPhaseBadge phase={p} locale={locale} />
                      </DropdownMenuItem>
                    ))}
                  </DropdownMenuContent>
                </DropdownMenu>
              </TableCell>
              <TableCell>
                <InlineValueEdit
                  dealId={deal.id}
                  initialValue={deal.dealValue}
                  initialCurrency={deal.valueCurrency}
                  locale={locale}
                />
              </TableCell>
              <TableCell>{deal.dealLead.name}</TableCell>
              <TableCell className="text-muted-foreground">
                {totalTasks > 0 ? `${doneTasks}/${totalTasks}` : "\u2014"}
              </TableCell>
            </TableRow>
          );
        })}
      </TableBody>
    </Table>
  );
}

"use client";

import { useTranslations } from "next-intl";
import type { EntryData } from "./billing-table";
import type { RateData } from "./billing-rate-editor";

function formatHours(minutes: number, precision: number): string {
  return (minutes / 60).toFixed(precision) + "h";
}

interface BillingSummaryProps {
  entries: EntryData[];
  rates: RateData[];
  precision: number;
}

export function BillingSummary({ entries, rates, precision }: BillingSummaryProps) {
  const tBilling = useTranslations("billing");

  const rateMap = new Map<string, number>();
  for (const r of rates) {
    rateMap.set(`${r.deal.id}-${r.user.id}`, r.ratePerHour);
  }

  const totalMinutes = entries.reduce((s, e) => s + e.durationMinutes, 0);
  const billableMinutes = entries.filter((e) => e.isBillable).reduce((s, e) => s + e.durationMinutes, 0);
  const totalAmount = entries
    .filter((e) => e.isBillable)
    .reduce((s, e) => s + (e.durationMinutes / 60) * (rateMap.get(`${e.deal.id}-${e.user.id}`) ?? 0), 0);

  return (
    <div className="flex items-center gap-6 rounded-lg border bg-muted/30 px-4 py-3 text-sm">
      <span className="font-medium">{tBilling("summary")}:</span>
      <span>{tBilling("totalHours")} {formatHours(totalMinutes, precision)}</span>
      <span>{tBilling("billableHours")} {formatHours(billableMinutes, precision)}</span>
      <span>{tBilling("totalAmount")} ¥{totalAmount.toLocaleString(undefined, { minimumFractionDigits: 2 })}</span>
    </div>
  );
}

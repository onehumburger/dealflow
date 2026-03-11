"use client";

import { useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { BillingFilters } from "@/components/billing/billing-filters";
import { BillingRateEditor, type RateData } from "@/components/billing/billing-rate-editor";
import { BillingTable, type EntryData } from "@/components/billing/billing-table";
import { BillingSummary } from "@/components/billing/billing-summary";
import {
  getFilteredTimeEntries,
  exportBillingExcel,
} from "@/actions/billing";

interface BillingPageClientProps {
  deals: { id: string; name: string }[];
  users: { id: string; name: string }[];
  initialEntries: EntryData[];
  initialRates: RateData[];
}

export function BillingPageClient({
  deals,
  users,
  initialEntries,
  initialRates,
}: BillingPageClientProps) {
  const tBilling = useTranslations("billing");
  const [isPending, startTransition] = useTransition();

  const [dealId, setDealId] = useState("");
  const [userId, setUserId] = useState("");
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [billableOnly, setBillableOnly] = useState(false);

  const [entries, setEntries] = useState<EntryData[]>(initialEntries);
  const [rates, setRates] = useState<RateData[]>(initialRates);

  function handleFilter() {
    startTransition(async () => {
      const result = await getFilteredTimeEntries({
        dealId: dealId || undefined,
        userId: userId || undefined,
        startDate: startDate || undefined,
        endDate: endDate || undefined,
        billableOnly,
      });
      setEntries(result);
    });
  }

  function handleExport() {
    startTransition(async () => {
      const base64 = await exportBillingExcel({
        dealId: dealId || undefined,
        userId: userId || undefined,
        startDate: startDate || undefined,
        endDate: endDate || undefined,
        billableOnly,
      });
      const blob = new Blob(
        [Uint8Array.from(atob(base64), (c) => c.charCodeAt(0))],
        { type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" }
      );
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `billing-${new Date().toISOString().split("T")[0]}.xlsx`;
      a.click();
      URL.revokeObjectURL(url);
    });
  }

  return (
    <div className="flex flex-col gap-6">
      <h1 className="text-lg font-semibold">{tBilling("billing")}</h1>

      <BillingFilters
        deals={deals}
        users={users}
        dealId={dealId}
        userId={userId}
        startDate={startDate}
        endDate={endDate}
        billableOnly={billableOnly}
        isPending={isPending}
        onDealChange={(v) => setDealId(v ?? "")}
        onUserChange={(v) => setUserId(v ?? "")}
        onStartDateChange={setStartDate}
        onEndDateChange={setEndDate}
        onBillableOnlyChange={setBillableOnly}
        onFilter={handleFilter}
        onExport={handleExport}
      />

      <BillingRateEditor
        deals={deals}
        users={users}
        rates={rates}
        onRatesChange={setRates}
      />

      <BillingTable entries={entries} onRefresh={handleFilter} />

      <BillingSummary entries={entries} rates={rates} />
    </div>
  );
}

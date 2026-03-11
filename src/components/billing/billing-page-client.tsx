"use client";

import { useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { BillingFilters, type WorkstreamOption } from "@/components/billing/billing-filters";
import { BillingRateEditor, type RateData } from "@/components/billing/billing-rate-editor";
import { BillingTable, type EntryData } from "@/components/billing/billing-table";
import { BillingSummary } from "@/components/billing/billing-summary";
import {
  getFilteredTimeEntries,
  getWorkstreamsForDeal,
  exportBillingExcel,
} from "@/actions/billing";

interface BillingPageClientProps {
  deals: { id: string; name: string }[];
  users: { id: string; name: string }[];
  initialEntries: EntryData[];
  initialRates: RateData[];
  isAdmin: boolean;
  currentUserId: string;
}

export function BillingPageClient({
  deals,
  users,
  initialEntries,
  initialRates,
  isAdmin,
  currentUserId,
}: BillingPageClientProps) {
  const tBilling = useTranslations("billing");
  const [isPending, startTransition] = useTransition();

  const [dealId, setDealId] = useState("");
  const [userId, setUserId] = useState("");
  const [workstreamId, setWorkstreamId] = useState("");
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [billableOnly, setBillableOnly] = useState(false);
  const [precision, setPrecision] = useState(1);

  const [workstreams, setWorkstreams] = useState<WorkstreamOption[]>([]);
  const [entries, setEntries] = useState<EntryData[]>(initialEntries);
  const [rates, setRates] = useState<RateData[]>(initialRates);

  function handleDealChange(v: string | null) {
    const newDealId = v ?? "";
    setDealId(newDealId);
    setWorkstreamId("");
    if (newDealId) {
      startTransition(async () => {
        const ws = await getWorkstreamsForDeal(newDealId);
        setWorkstreams(ws);
      });
    } else {
      setWorkstreams([]);
    }
  }

  function getFilters() {
    return {
      dealId: dealId || undefined,
      userId: userId || undefined,
      workstreamId: workstreamId || undefined,
      startDate: startDate || undefined,
      endDate: endDate || undefined,
      billableOnly,
    };
  }

  function handleFilter() {
    startTransition(async () => {
      const result = await getFilteredTimeEntries(getFilters());
      setEntries(result);
    });
  }

  function handleExport() {
    startTransition(async () => {
      const base64 = await exportBillingExcel(getFilters());
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
        workstreams={workstreams}
        dealId={dealId}
        userId={userId}
        workstreamId={workstreamId}
        startDate={startDate}
        endDate={endDate}
        billableOnly={billableOnly}
        precision={precision}
        isPending={isPending}
        onDealChange={handleDealChange}
        onUserChange={(v) => setUserId(v ?? "")}
        onWorkstreamChange={(v) => setWorkstreamId(v ?? "")}
        onStartDateChange={setStartDate}
        onEndDateChange={setEndDate}
        onBillableOnlyChange={setBillableOnly}
        onPrecisionChange={setPrecision}
        onFilter={handleFilter}
        onExport={handleExport}
      />

      {isAdmin && (
        <BillingRateEditor
          deals={deals}
          users={users}
          rates={rates}
          onRatesChange={setRates}
        />
      )}

      <BillingTable
        entries={entries}
        precision={precision}
        onRefresh={handleFilter}
        isAdmin={isAdmin}
        currentUserId={currentUserId}
      />

      <BillingSummary entries={entries} rates={rates} precision={precision} />
    </div>
  );
}

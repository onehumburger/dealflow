"use client";

import { useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
} from "@/components/ui/select";
import { setBillingRate, getDealBillingRates } from "@/actions/billing";
import type { DealOption, UserOption } from "./billing-filters";

export interface RateData {
  id: string;
  ratePerHour: number;
  currency: string;
  deal: { id: string; name: string };
  user: { id: string; name: string };
}

interface BillingRateEditorProps {
  deals: DealOption[];
  users: UserOption[];
  rates: RateData[];
  onRatesChange: (rates: RateData[]) => void;
}

export function BillingRateEditor({ deals, users, rates, onRatesChange }: BillingRateEditorProps) {
  const tBilling = useTranslations("billing");
  const tCommon = useTranslations("common");
  const [isPending, startTransition] = useTransition();

  const [editingRate, setEditingRate] = useState<{ dealId: string; userId: string; value: string } | null>(null);
  const [newDealId, setNewDealId] = useState("");
  const [newUserId, setNewUserId] = useState("");
  const [newValue, setNewValue] = useState("3000");

  function handleSaveRate(dealId: string, userId: string, value: string) {
    const rate = parseFloat(value);
    if (isNaN(rate) || rate < 0) return;

    startTransition(async () => {
      await setBillingRate(dealId, userId, rate);
      const updated = await getDealBillingRates();
      onRatesChange(updated);
      setEditingRate(null);
    });
  }

  function handleAddRate() {
    if (!newDealId || !newUserId) return;
    handleSaveRate(newDealId, newUserId, newValue);
    setNewDealId("");
    setNewUserId("");
    setNewValue("3000");
  }

  return (
    <div className="rounded-lg border p-3">
      <span className="text-sm font-medium">{tBilling("rate")}</span>

      {rates.length === 0 ? (
        <p className="mt-1 text-sm text-muted-foreground">{tBilling("noRates")}</p>
      ) : (
        <div className="mt-2 flex flex-wrap gap-2">
          {rates.map((r) => (
            <div key={r.id} className="flex items-center gap-1.5 rounded border px-2 py-1 text-sm">
              <span className="font-medium">{r.deal.name}</span>
              <span className="text-muted-foreground">:</span>
              <span>{r.user.name}</span>

              {editingRate?.dealId === r.deal.id && editingRate?.userId === r.user.id ? (
                <div className="flex items-center gap-1">
                  <Input
                    type="number"
                    value={editingRate.value}
                    onChange={(e) => setEditingRate({ ...editingRate, value: e.target.value })}
                    className="h-6 w-20 text-sm"
                    autoFocus
                    onKeyDown={(e) => e.key === "Enter" && handleSaveRate(editingRate.dealId, editingRate.userId, editingRate.value)}
                  />
                  <Button size="xs" onClick={() => handleSaveRate(editingRate.dealId, editingRate.userId, editingRate.value)} disabled={isPending}>
                    {tCommon("save")}
                  </Button>
                </div>
              ) : (
                <button
                  onClick={() => setEditingRate({ dealId: r.deal.id, userId: r.user.id, value: String(r.ratePerHour) })}
                  className="text-muted-foreground hover:text-foreground"
                >
                  ¥{r.ratePerHour.toLocaleString()}{tBilling("perHour")}
                </button>
              )}
            </div>
          ))}
        </div>
      )}

      {/* Add new rate */}
      <div className="mt-2 flex items-center gap-2">
        <Select value={newDealId} onValueChange={(v) => setNewDealId(v ?? "")}>
          <SelectTrigger className="w-36 h-7 text-sm">
            <span className="truncate">{newDealId ? deals.find((d) => d.id === newDealId)?.name : tBilling("deal")}</span>
          </SelectTrigger>
          <SelectContent>
            {deals.map((d) => (
              <SelectItem key={d.id} value={d.id}>{d.name}</SelectItem>
            ))}
          </SelectContent>
        </Select>

        <Select value={newUserId} onValueChange={(v) => setNewUserId(v ?? "")}>
          <SelectTrigger className="w-28 h-7 text-sm">
            <span className="truncate">{newUserId ? users.find((u) => u.id === newUserId)?.name : tBilling("member")}</span>
          </SelectTrigger>
          <SelectContent>
            {users.map((u) => (
              <SelectItem key={u.id} value={u.id}>{u.name}</SelectItem>
            ))}
          </SelectContent>
        </Select>

        <Input type="number" value={newValue} onChange={(e) => setNewValue(e.target.value)} placeholder={tBilling("ratePerHour")} className="h-7 w-24 text-sm" />

        <Button size="xs" onClick={handleAddRate} disabled={isPending || !newDealId || !newUserId}>
          {tBilling("setRate")}
        </Button>
      </div>
    </div>
  );
}

"use client";

import { useTranslations } from "next-intl";
import { Download } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
} from "@/components/ui/select";

export interface DealOption {
  id: string;
  name: string;
}

export interface UserOption {
  id: string;
  name: string;
}

interface BillingFiltersProps {
  deals: DealOption[];
  users: UserOption[];
  dealId: string;
  userId: string;
  startDate: string;
  endDate: string;
  billableOnly: boolean;
  isPending: boolean;
  onDealChange: (v: string | null) => void;
  onUserChange: (v: string | null) => void;
  onStartDateChange: (v: string) => void;
  onEndDateChange: (v: string) => void;
  onBillableOnlyChange: (v: boolean) => void;
  onFilter: () => void;
  onExport: () => void;
}

export function BillingFilters({
  deals,
  users,
  dealId,
  userId,
  startDate,
  endDate,
  billableOnly,
  isPending,
  onDealChange,
  onUserChange,
  onStartDateChange,
  onEndDateChange,
  onBillableOnlyChange,
  onFilter,
  onExport,
}: BillingFiltersProps) {
  const tBilling = useTranslations("billing");
  const tCommon = useTranslations("common");

  return (
    <div className="flex flex-wrap items-end gap-3 rounded-lg border p-3">
      <div>
        <label className="text-xs text-muted-foreground">{tBilling("deal")}</label>
        <Select value={dealId} onValueChange={(v) => onDealChange(v ?? "")}>
          <SelectTrigger className="w-40 h-8 text-sm">
            <span className="truncate">
              {dealId ? deals.find((d) => d.id === dealId)?.name : tBilling("allDeals")}
            </span>
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="">{tBilling("allDeals")}</SelectItem>
            {deals.map((d) => (
              <SelectItem key={d.id} value={d.id}>{d.name}</SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <div>
        <label className="text-xs text-muted-foreground">{tBilling("member")}</label>
        <Select value={userId} onValueChange={(v) => onUserChange(v ?? "")}>
          <SelectTrigger className="w-36 h-8 text-sm">
            <span className="truncate">
              {userId ? users.find((u) => u.id === userId)?.name : tBilling("allMembers")}
            </span>
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="">{tBilling("allMembers")}</SelectItem>
            {users.map((u) => (
              <SelectItem key={u.id} value={u.id}>{u.name}</SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <div>
        <label className="text-xs text-muted-foreground">{tBilling("dateRange")}</label>
        <div className="flex gap-1">
          <Input type="date" value={startDate} onChange={(e) => onStartDateChange(e.target.value)} className="h-8 w-32 text-sm" />
          <Input type="date" value={endDate} onChange={(e) => onEndDateChange(e.target.value)} className="h-8 w-32 text-sm" />
        </div>
      </div>

      <label className="flex items-center gap-1.5 text-sm">
        <input type="checkbox" checked={billableOnly} onChange={(e) => onBillableOnlyChange(e.target.checked)} />
        {tBilling("billableOnly")}
      </label>

      <Button size="sm" onClick={onFilter} disabled={isPending}>{tCommon("filter")}</Button>

      <Button size="sm" variant="outline" onClick={onExport} disabled={isPending}>
        <Download className="size-3.5" />
        {tBilling("exportExcel")}
      </Button>
    </div>
  );
}

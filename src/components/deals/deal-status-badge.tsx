import { Badge } from "@/components/ui/badge";
import type { DealStatus } from "@/generated/prisma/client";

const statusConfig: Record<DealStatus, { variant: "default" | "secondary" | "outline" | "destructive"; className: string }> = {
  Active: { variant: "default", className: "bg-emerald-600 text-white" },
  OnHold: { variant: "secondary", className: "bg-amber-100 text-amber-800" },
  Completed: { variant: "outline", className: "" },
};

const statusLabels: Record<string, Record<DealStatus, string>> = {
  en: { Active: "Active", OnHold: "On Hold", Completed: "Completed" },
  zh: { Active: "\u8FDB\u884C\u4E2D", OnHold: "\u6682\u505C", Completed: "\u5DF2\u5B8C\u6210" },
};

export function DealStatusBadge({
  status,
  locale = "zh",
}: {
  status: DealStatus;
  locale?: string;
}) {
  const config = statusConfig[status];
  const labels = statusLabels[locale] || statusLabels.zh;
  return (
    <Badge variant={config.variant} className={config.className}>
      {labels[status]}
    </Badge>
  );
}

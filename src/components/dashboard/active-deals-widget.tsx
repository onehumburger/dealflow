import Link from "next/link";
import { DealStatusBadge } from "@/components/deals/deal-status-badge";
import type { DealStatus } from "@/generated/prisma/client";

interface DealItem {
  id: string;
  name: string;
  status: DealStatus;
  clientName: string;
  targetCompany: string;
  tasksDone: number;
  tasksTotal: number;
}

interface ActiveDealsWidgetProps {
  deals: DealItem[];
  locale: string;
  translations: {
    activeDeals: string;
    noResults: string;
    tasks: string;
  };
}

export function ActiveDealsWidget({
  deals,
  locale,
  translations,
}: ActiveDealsWidgetProps) {
  return (
    <div className="rounded-lg border bg-card">
      <div className="border-b px-4 py-3">
        <h3 className="text-sm font-semibold">{translations.activeDeals}</h3>
      </div>
      {deals.length === 0 ? (
        <p className="px-4 py-6 text-center text-sm text-muted-foreground">
          {translations.noResults}
        </p>
      ) : (
        <div className="grid gap-px sm:grid-cols-2 lg:grid-cols-3">
          {deals.map((deal) => {
            const pct =
              deal.tasksTotal > 0
                ? Math.round((deal.tasksDone / deal.tasksTotal) * 100)
                : 0;

            return (
              <Link
                key={deal.id}
                href={`/${locale}/deals/${deal.id}`}
                className="flex flex-col gap-2 px-4 py-3 hover:bg-muted/50 transition-colors"
              >
                <div className="flex items-center gap-2">
                  <span className="truncate text-sm font-medium">
                    {deal.name}
                  </span>
                  <DealStatusBadge status={deal.status} locale={locale} />
                </div>
                <p className="text-xs text-muted-foreground truncate">
                  {deal.clientName} / {deal.targetCompany}
                </p>
                <div className="flex items-center gap-2">
                  <div className="h-1.5 flex-1 rounded-full bg-muted">
                    <div
                      className="h-full rounded-full bg-emerald-500 transition-all"
                      style={{ width: `${pct}%` }}
                    />
                  </div>
                  <span className="text-[11px] tabular-nums text-muted-foreground">
                    {deal.tasksDone}/{deal.tasksTotal}
                  </span>
                </div>
              </Link>
            );
          })}
        </div>
      )}
    </div>
  );
}

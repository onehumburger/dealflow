"use client";

import { useState } from "react";
import Link from "next/link";
import { cn } from "@/lib/utils";

interface MilestoneItem {
  id: string;
  name: string;
  date: Date | null;
  dealId: string;
  dealName: string;
  daysRemaining: number | null;
}

interface MilestonesWidgetProps {
  milestones: MilestoneItem[];
  locale: string;
  translations: {
    upcomingMilestones: string;
    overdue: string;
    noResults: string;
    allDeals: string;
  };
}

function formatDate(date: Date, locale: string): string {
  return new Intl.DateTimeFormat(locale, {
    month: "short",
    day: "numeric",
  }).format(date);
}

export function MilestonesWidget({
  milestones,
  locale,
  translations,
}: MilestonesWidgetProps) {
  const [selectedDeal, setSelectedDeal] = useState<string | null>(null);

  const deals = Array.from(
    new Map(milestones.map((m) => [m.dealId, m.dealName]))
  );

  const filteredMilestones = selectedDeal
    ? milestones.filter((m) => m.dealId === selectedDeal)
    : milestones;

  return (
    <div className="rounded-lg border bg-card">
      <div className="border-b px-4 py-3">
        <h3 className="text-base font-semibold">{translations.upcomingMilestones}</h3>
        {deals.length > 1 && (
          <div className="mt-1.5 flex flex-wrap gap-1">
            <button
              type="button"
              onClick={() => setSelectedDeal(null)}
              className={cn(
                "rounded-full px-2 py-0.5 text-xs transition-colors",
                selectedDeal === null
                  ? "bg-primary text-primary-foreground"
                  : "bg-muted text-muted-foreground hover:bg-muted/80"
              )}
            >
              {translations.allDeals}
            </button>
            {deals.map(([id, name]) => (
              <button
                key={id}
                type="button"
                onClick={() => setSelectedDeal(id)}
                className={cn(
                  "rounded-full px-2 py-0.5 text-xs transition-colors",
                  selectedDeal === id
                    ? "bg-primary text-primary-foreground"
                    : "bg-muted text-muted-foreground hover:bg-muted/80"
                )}
              >
                {name}
              </button>
            ))}
          </div>
        )}
      </div>
      <div className="divide-y">
        {filteredMilestones.length === 0 ? (
          <p className="px-4 py-6 text-center text-sm text-muted-foreground">
            {translations.noResults}
          </p>
        ) : (
          filteredMilestones.map((m) => (
            <Link
              key={m.id}
              href={`/${locale}/deals/${m.dealId}`}
              className="flex items-center gap-3 px-4 py-2.5 text-sm hover:bg-muted/50 transition-colors"
            >
              <div className="min-w-0 flex-1">
                <p className="truncate font-medium">{m.name}</p>
                <p className="truncate text-xs text-muted-foreground">
                  {m.dealName}
                </p>
              </div>
              <div className="flex shrink-0 items-center gap-2">
                {m.date && (
                  <span className="text-xs text-muted-foreground">
                    {formatDate(m.date, locale)}
                  </span>
                )}
                {m.daysRemaining !== null && (
                  <span
                    className={cn(
                      "rounded-full px-2 py-0.5 text-xs font-medium tabular-nums",
                      m.daysRemaining < 0
                        ? "bg-red-100 text-red-700"
                        : m.daysRemaining <= 3
                          ? "bg-amber-100 text-amber-700"
                          : "bg-muted text-muted-foreground"
                    )}
                  >
                    {m.daysRemaining < 0
                      ? `${Math.abs(m.daysRemaining)}d ${translations.overdue}`
                      : m.daysRemaining === 0
                        ? locale === "zh"
                          ? "\u4eca\u5929"
                          : "Today"
                        : `${m.daysRemaining}d`}
                  </span>
                )}
              </div>
            </Link>
          ))
        )}
      </div>
    </div>
  );
}

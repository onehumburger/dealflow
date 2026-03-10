"use client";

import { useTranslations } from "next-intl";
import { cn } from "@/lib/utils";
import { Plus } from "lucide-react";
import { MilestoneForm } from "./milestone-form";
import type { MilestoneType } from "@/generated/prisma/client";

interface MilestoneItem {
  id: string;
  name: string;
  date: Date | null;
  type?: MilestoneType;
  isDone: boolean;
}

interface MilestoneTimelineProps {
  milestones: MilestoneItem[];
  locale: string;
  dealId: string;
}

function formatDate(date: Date | null, locale: string): string {
  if (!date) return "\u2014";
  return new Intl.DateTimeFormat(locale, {
    month: "short",
    day: "numeric",
  }).format(date);
}

function isOverdue(milestone: MilestoneItem): boolean {
  if (milestone.isDone) return false;
  if (!milestone.date) return false;
  return milestone.date < new Date();
}

export function MilestoneTimeline({ milestones, locale, dealId }: MilestoneTimelineProps) {
  const t = useTranslations("milestone");

  return (
    <div className="overflow-x-auto py-2">
      <div className="flex items-start gap-0 min-w-fit px-4">
        {milestones.map((ms, i) => {
          const done = ms.isDone;
          const overdue = isOverdue(ms);

          return (
            <div key={ms.id} className="flex items-start">
              {/* Dot + label column — clickable via MilestoneForm popover */}
              <MilestoneForm
                dealId={dealId}
                milestone={ms}
                trigger={
                  <button
                    type="button"
                    className="flex flex-col items-center cursor-pointer group"
                  >
                    <div
                      className={cn(
                        "size-3.5 rounded-full border-2 transition-transform group-hover:scale-125",
                        done
                          ? "border-emerald-600 bg-emerald-600"
                          : overdue
                            ? "border-red-500 bg-red-500"
                            : "border-muted-foreground bg-background"
                      )}
                    />
                    <span
                      className={cn(
                        "mt-1.5 max-w-[80px] text-center text-xs leading-tight",
                        done
                          ? "text-emerald-700"
                          : overdue
                            ? "text-red-500"
                            : "text-muted-foreground"
                      )}
                    >
                      {ms.name}
                    </span>
                    <span className="mt-0.5 text-[10px] text-muted-foreground">
                      {formatDate(ms.date, locale)}
                    </span>
                  </button>
                }
              />

              {/* Connector line */}
              {i < milestones.length - 1 && (
                <div className="mt-1.5 h-px w-10 bg-border" />
              )}
            </div>
          );
        })}

        {/* Add Milestone button */}
        {milestones.length > 0 && (
          <div className="mt-1.5 h-px w-10 bg-border" />
        )}
        <MilestoneForm
          dealId={dealId}
          trigger={
            <button
              type="button"
              className="flex flex-col items-center cursor-pointer group"
            >
              <div className="flex size-3.5 items-center justify-center rounded-full border-2 border-dashed border-muted-foreground transition-colors group-hover:border-foreground">
                <Plus className="size-2.5 text-muted-foreground group-hover:text-foreground" />
              </div>
              <span className="mt-1.5 text-xs text-muted-foreground group-hover:text-foreground">
                {t("addMilestone")}
              </span>
            </button>
          }
        />
      </div>
    </div>
  );
}

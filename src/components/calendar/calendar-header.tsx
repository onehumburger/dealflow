"use client";

import { useTranslations, useLocale } from "next-intl";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { useCalendar } from "@/hooks/use-calendar";

interface CalendarHeaderProps {
  deals?: { id: string; name: string; color: string }[];
}

export function CalendarHeader({ deals }: CalendarHeaderProps) {
  const locale = useLocale();
  const t = useTranslations("calendar");

  const year = useCalendar((s) => s.year);
  const month = useCalendar((s) => s.month);
  const showMilestones = useCalendar((s) => s.showMilestones);
  const showTasks = useCalendar((s) => s.showTasks);
  const showActivity = useCalendar((s) => s.showActivity);
  const prevMonth = useCalendar((s) => s.prevMonth);
  const nextMonth = useCalendar((s) => s.nextMonth);
  const goToToday = useCalendar((s) => s.goToToday);
  const toggleMilestones = useCalendar((s) => s.toggleMilestones);
  const toggleTasks = useCalendar((s) => s.toggleTasks);
  const toggleActivity = useCalendar((s) => s.toggleActivity);
  const selectedDealIds = useCalendar((s) => s.selectedDealIds);
  const setSelectedDealIds = useCalendar((s) => s.setSelectedDealIds);

  const monthLabel = new Intl.DateTimeFormat(locale, {
    year: "numeric",
    month: "long",
  }).format(new Date(year, month - 1));

  function handleDealToggle(dealId: string) {
    if (!deals) return;
    if (selectedDealIds === null) {
      setSelectedDealIds(deals.filter((d) => d.id !== dealId).map((d) => d.id));
    } else if (selectedDealIds.includes(dealId)) {
      const next = selectedDealIds.filter((id) => id !== dealId);
      setSelectedDealIds(next.length === 0 ? null : next);
    } else {
      const next = [...selectedDealIds, dealId];
      setSelectedDealIds(next.length === deals.length ? null : next);
    }
  }

  return (
    <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
      <div className="flex items-center gap-2">
        <Button variant="ghost" size="icon-sm" onClick={prevMonth}>
          <ChevronLeft className="size-4" />
        </Button>
        <h2 className="min-w-[10rem] text-center text-lg font-semibold">
          {monthLabel}
        </h2>
        <Button variant="ghost" size="icon-sm" onClick={nextMonth}>
          <ChevronRight className="size-4" />
        </Button>
        <Button variant="outline" size="sm" onClick={goToToday}>
          {t("today")}
        </Button>
      </div>

      <div className="flex flex-wrap items-center gap-1.5">
        <button type="button" onClick={toggleMilestones}>
          <Badge variant={showMilestones ? "default" : "outline"}>
            ◆ {t("showMilestones")}
          </Badge>
        </button>
        <button type="button" onClick={toggleTasks}>
          <Badge variant={showTasks ? "default" : "outline"}>
            ● {t("showTasks")}
          </Badge>
        </button>
        <button type="button" onClick={toggleActivity}>
          <Badge variant={showActivity ? "default" : "outline"}>
            ○ {t("showActivity")}
          </Badge>
        </button>

        {deals && deals.length > 1 && (
          <>
            <span className="mx-1 text-muted-foreground">|</span>
            {deals.map((d) => {
              const isSelected =
                selectedDealIds === null || selectedDealIds.includes(d.id);
              return (
                <button key={d.id} type="button" onClick={() => handleDealToggle(d.id)}>
                  <Badge
                    variant={isSelected ? "default" : "outline"}
                    style={isSelected ? { backgroundColor: d.color } : undefined}
                  >
                    {d.name}
                  </Badge>
                </button>
              );
            })}
          </>
        )}
      </div>
    </div>
  );
}

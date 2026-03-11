"use client";

import { useEffect, useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { CalendarHeader } from "./calendar-header";
import { CalendarGrid } from "./calendar-grid";
import { useCalendar } from "@/hooks/use-calendar";
import { getCalendarEvents } from "@/actions/calendar";
import type { CalendarEvent } from "@/actions/calendar";

interface CalendarViewProps {
  initialEvents: CalendarEvent[];
  deals?: { id: string; name: string; color: string }[];
  scopeDealId?: string;
}

export function CalendarView({
  initialEvents,
  deals,
  scopeDealId,
}: CalendarViewProps) {
  const t = useTranslations("calendar");
  const [events, setEvents] = useState(initialEvents);
  const [isPending, startTransition] = useTransition();

  const year = useCalendar((s) => s.year);
  const month = useCalendar((s) => s.month);
  const showMilestones = useCalendar((s) => s.showMilestones);
  const showTasks = useCalendar((s) => s.showTasks);
  const showActivity = useCalendar((s) => s.showActivity);
  const selectedDealIds = useCalendar((s) => s.selectedDealIds);

  useEffect(() => {
    startTransition(async () => {
      const scope = scopeDealId ? [scopeDealId] : undefined;
      const { events: newEvents } = await getCalendarEvents(year, month, scope);
      setEvents(newEvents);
    });
  }, [year, month, scopeDealId]);

  const filtered = events.filter((evt) => {
    if (evt.type === "milestone" && !showMilestones) return false;
    if (evt.type === "task" && !showTasks) return false;
    if (evt.type === "activity" && !showActivity) return false;
    if (selectedDealIds !== null && !selectedDealIds.includes(evt.dealId)) return false;
    return true;
  });

  return (
    <div>
      <CalendarHeader deals={deals} />
      <div className={isPending ? "opacity-50 pointer-events-none" : undefined}>
        <CalendarGrid events={filtered} />
      </div>
      {filtered.length === 0 && !isPending && (
        <p className="mt-8 text-center text-sm text-muted-foreground">
          {t("noEvents")}
        </p>
      )}
    </div>
  );
}

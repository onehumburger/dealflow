"use client";

import { useLocale } from "next-intl";
import { CalendarDayCell } from "./calendar-day-cell";
import { useCalendar } from "@/hooks/use-calendar";
import type { CalendarEvent } from "@/actions/calendar";

interface CalendarGridProps {
  events: CalendarEvent[];
}

function getMonthGrid(year: number, month: number) {
  const firstDay = new Date(year, month - 1, 1);
  const startDate = new Date(firstDay);
  const dayOfWeek = startDate.getDay();
  const offset = dayOfWeek === 0 ? 6 : dayOfWeek - 1;
  startDate.setDate(startDate.getDate() - offset);

  const days: Date[] = [];
  for (let i = 0; i < 42; i++) {
    days.push(new Date(startDate));
    startDate.setDate(startDate.getDate() + 1);
  }
  return days;
}

function dateKey(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}

export function CalendarGrid({ events }: CalendarGridProps) {
  const locale = useLocale();
  const year = useCalendar((s) => s.year);
  const month = useCalendar((s) => s.month);

  const days = getMonthGrid(year, month);
  const today = new Date();
  const todayKey = dateKey(today);

  const eventsByDay = new Map<string, CalendarEvent[]>();
  for (const evt of events) {
    const key = dateKey(new Date(evt.date));
    if (!eventsByDay.has(key)) eventsByDay.set(key, []);
    eventsByDay.get(key)!.push(evt);
  }

  // Monday = 2024-01-01
  const weekdays = Array.from({ length: 7 }, (_, i) => {
    const d = new Date(2024, 0, i + 1);
    return new Intl.DateTimeFormat(locale, { weekday: "short" }).format(d);
  });

  return (
    <div className="mt-3 overflow-x-auto">
      <div className="min-w-[700px]">
      <div className="grid grid-cols-7 text-center text-xs font-medium text-muted-foreground">
        {weekdays.map((wd, i) => (
          <div key={wd} className={i >= 5 ? "text-muted-foreground/60" : undefined}>
            {wd}
          </div>
        ))}
      </div>

      <div className="grid grid-cols-7 border-l border-b">
        {days.map((d, i) => {
          const key = dateKey(d);
          const dayOfWeek = d.getDay();
          return (
            <div key={i} className="border-r">
              <CalendarDayCell
                date={d}
                events={eventsByDay.get(key) ?? []}
                isCurrentMonth={d.getMonth() + 1 === month}
                isToday={key === todayKey}
                isWeekend={dayOfWeek === 0 || dayOfWeek === 6}
              />
            </div>
          );
        })}
      </div>
      </div>
    </div>
  );
}

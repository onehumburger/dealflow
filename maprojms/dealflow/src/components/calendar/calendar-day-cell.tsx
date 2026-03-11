"use client";

import { useTranslations } from "next-intl";
import { cn } from "@/lib/utils";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { CalendarEventPopover } from "./calendar-event-popover";
import type { CalendarEvent } from "@/actions/calendar";

interface CalendarDayCellProps {
  date: Date;
  events: CalendarEvent[];
  isCurrentMonth: boolean;
  isToday: boolean;
  isWeekend: boolean;
}

const MAX_VISIBLE = 3;

const typeIcons: Record<CalendarEvent["type"], string> = {
  milestone: "◆",
  task: "●",
  activity: "○",
};

export function CalendarDayCell({
  date,
  events,
  isCurrentMonth,
  isToday,
  isWeekend,
}: CalendarDayCellProps) {
  const t = useTranslations("calendar");
  const visible = events.slice(0, MAX_VISIBLE);
  const overflow = events.length - MAX_VISIBLE;

  return (
    <div
      className={cn(
        "min-h-[6rem] border-t p-1 text-xs",
        !isCurrentMonth && "bg-muted/20 text-muted-foreground/50",
        isWeekend && isCurrentMonth && "bg-muted/30",
        isToday && "ring-2 ring-primary/50 ring-inset bg-primary/5"
      )}
    >
      <div
        className={cn(
          "mb-0.5 text-right text-xs font-medium",
          isToday && "text-primary font-bold"
        )}
      >
        {date.getDate()}
      </div>

      <div className="flex flex-col gap-0.5">
        {visible.map((evt) => (
          <CalendarEventPopover key={`${evt.type}-${evt.id}`} event={evt}>
            <div
              className={cn(
                "flex items-center gap-1 truncate rounded px-1 py-0.5 text-[11px] leading-tight cursor-pointer transition-colors hover:bg-muted",
                evt.isOverdue && "text-red-600 font-medium"
              )}
              style={{ borderLeft: `3px solid ${evt.dealColor}` }}
            >
              <span className="shrink-0">{typeIcons[evt.type]}</span>
              <span className="truncate">{evt.title}</span>
            </div>
          </CalendarEventPopover>
        ))}

        {overflow > 0 && (
          <Popover>
            <PopoverTrigger nativeButton={false} render={<span />}>
              <button
                type="button"
                className="rounded px-1 py-0.5 text-[11px] text-muted-foreground hover:bg-muted"
              >
                {t("more", { count: overflow })}
              </button>
            </PopoverTrigger>
            <PopoverContent className="w-64 max-h-60 overflow-y-auto p-2" align="start">
              <div className="flex flex-col gap-1">
                {events.map((evt) => (
                  <CalendarEventPopover key={`${evt.type}-${evt.id}`} event={evt}>
                    <div
                      className="flex items-center gap-1 truncate rounded px-1 py-0.5 text-xs cursor-pointer hover:bg-muted"
                      style={{ borderLeft: `3px solid ${evt.dealColor}` }}
                    >
                      <span className="shrink-0">{typeIcons[evt.type]}</span>
                      <span className="truncate">{evt.title}</span>
                    </div>
                  </CalendarEventPopover>
                ))}
              </div>
            </PopoverContent>
          </Popover>
        )}
      </div>
    </div>
  );
}

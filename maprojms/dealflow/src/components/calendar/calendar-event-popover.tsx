"use client";

import { useTranslations, useLocale } from "next-intl";
import Link from "next/link";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { Badge } from "@/components/ui/badge";
import type { CalendarEvent } from "@/actions/calendar";

interface CalendarEventPopoverProps {
  event: CalendarEvent;
  children: React.ReactNode;
}

const typeIcons: Record<CalendarEvent["type"], string> = {
  milestone: "◆",
  task: "●",
  activity: "○",
};

export function CalendarEventPopover({
  event,
  children,
}: CalendarEventPopoverProps) {
  const locale = useLocale();
  const t = useTranslations("calendar");

  const dateStr = new Intl.DateTimeFormat(locale, {
    weekday: "short",
    year: "numeric",
    month: "short",
    day: "numeric",
  }).format(new Date(event.date));

  return (
    <Popover>
      <PopoverTrigger nativeButton={false} render={<span />}>
        {children}
      </PopoverTrigger>
      <PopoverContent className="w-64 p-3" align="start">
        <div className="flex flex-col gap-2">
          <div className="flex items-center gap-2">
            <Badge variant="outline" className="text-xs">
              {typeIcons[event.type]} {t(event.type)}
            </Badge>
            <span
              className="size-2 rounded-full shrink-0"
              style={{ backgroundColor: event.dealColor }}
            />
            <span className="truncate text-xs text-muted-foreground">
              {event.dealName}
            </span>
          </div>

          <p className="text-sm font-medium leading-tight">{event.title}</p>
          <p className="text-xs text-muted-foreground">{dateStr}</p>

          {event.isOverdue && (
            <Badge variant="destructive" className="w-fit text-xs">
              {t("overdue")}
            </Badge>
          )}
          {(event.status === "Done" || event.status === "done") && (
            <Badge variant="outline" className="w-fit text-xs text-emerald-600">
              {t("done")}
            </Badge>
          )}

          <Link
            href={event.href}
            className="mt-1 text-xs font-medium text-primary hover:underline"
          >
            {t("viewDetails")} →
          </Link>
        </div>
      </PopoverContent>
    </Popover>
  );
}

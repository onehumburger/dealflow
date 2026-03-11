# Calendar View & Contacts Grouping Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a monthly calendar view (global + per-deal) and group the contacts page by deal.

**Architecture:** Reusable `CalendarView` client component consumed by two server pages. Calendar events derived from existing Milestone, Task, and ActivityEntry models via a single server action. Contacts page modified to group by deal using `DealContact` join table.

**Tech Stack:** Next.js 16, Prisma 7, next-intl, Base UI Popover, Tailwind CSS, Zustand (for calendar client state)

**Spec:** `docs/superpowers/specs/2026-03-11-calendar-and-contacts-grouping-design.md`

---

## Codebase Context

**Key patterns to follow:**
- Server actions in `src/actions/*.ts` — always start with `auth()` check, use `assertDealMember` from `src/actions/_helpers.ts` for deal-scoped actions
- Pages in `src/app/[locale]/...` — server components, use `getLocale()` and `getTranslations()` from `next-intl/server`
- Client components use `"use client"` directive, `useTranslations()` and `useLocale()` from `next-intl`
- Prisma client at `@/lib/prisma`, generated types at `@/generated/prisma/client`
- UI components from `@/components/ui/*` — Base UI primitives (NOT Radix)
- Translations in `messages/en.json` and `messages/zh.json`
- Top nav in `src/components/layout/app-shell.tsx` — links array at line 20-28
- Deal detail bottom links in `src/app/[locale]/deals/[dealId]/page.tsx` lines 156-175

**Important Base UI notes:**
- `SelectValue` does not reliably show item labels — render display text manually in `SelectTrigger`
- `DialogTrigger` / `PopoverTrigger` with `render={<span />}` needs `nativeButton={false}`

---

## File Structure

```
Files to CREATE:
  src/actions/calendar.ts              — Server action: getCalendarEvents()
  src/hooks/use-calendar.ts            — Zustand store for month/filters state
  src/components/calendar/calendar-view.tsx       — Main reusable component
  src/components/calendar/calendar-header.tsx      — Month nav + today + filters
  src/components/calendar/calendar-grid.tsx         — 7-col grid with day cells
  src/components/calendar/calendar-day-cell.tsx     — Single day cell
  src/components/calendar/calendar-event-popover.tsx — Click popover
  src/app/[locale]/calendar/page.tsx               — Dashboard calendar page
  src/app/[locale]/deals/[dealId]/calendar/page.tsx — Deal calendar page

Files to MODIFY:
  messages/en.json                     — Add "calendar" translation keys
  messages/zh.json                     — Add "calendar" translation keys
  src/components/layout/app-shell.tsx  — Add "Calendar" nav link
  src/app/[locale]/deals/[dealId]/page.tsx — Add "Calendar" bottom link
  src/app/[locale]/contacts/page.tsx   — Grouped query by deal
  src/components/contacts/contact-list.tsx — Render grouped sections
```

---

## Chunk 1: Server Action + Translations + Zustand Store

### Task 1: Add calendar translations

**Files:**
- Modify: `messages/en.json`
- Modify: `messages/zh.json`

- [ ] **Step 1: Add English translations**

Add `"calendar"` key to `messages/en.json` (at same level as `"nav"`, `"dashboard"`, etc.):

```json
"calendar": {
  "calendar": "Calendar",
  "today": "Today",
  "showMilestones": "Milestones",
  "showTasks": "Tasks",
  "showActivity": "Activity",
  "more": "+{count} more",
  "viewDetails": "View Details",
  "noEvents": "No events this month",
  "allDeals": "All Deals",
  "milestone": "Milestone",
  "task": "Task",
  "activity": "Activity",
  "overdue": "Overdue",
  "done": "Done"
}
```

Also add to `"nav"`:

```json
"calendar": "Calendar"
```

- [ ] **Step 2: Add Chinese translations**

Add `"calendar"` key to `messages/zh.json`:

```json
"calendar": {
  "calendar": "日历",
  "today": "今天",
  "showMilestones": "节点",
  "showTasks": "任务",
  "showActivity": "动态",
  "more": "还有{count}项",
  "viewDetails": "查看详情",
  "noEvents": "本月无事件",
  "allDeals": "全部项目",
  "milestone": "节点",
  "task": "任务",
  "activity": "动态",
  "overdue": "已逾期",
  "done": "已完成"
}
```

Also add to `"nav"`:

```json
"calendar": "日历"
```

- [ ] **Step 3: Commit**

```bash
git add messages/en.json messages/zh.json
git commit -m "feat(calendar): add bilingual translation keys"
```

---

### Task 2: Create calendar server action

**Files:**
- Create: `src/actions/calendar.ts`

- [ ] **Step 1: Create the server action**

```ts
"use server";

import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { getLocale } from "next-intl/server";

export interface CalendarEvent {
  id: string;
  type: "milestone" | "task" | "activity";
  title: string;
  date: Date;
  dealId: string;
  dealName: string;
  dealColor: string;
  status?: string;
  isOverdue: boolean;
  href: string;
}

// 10-color palette for deal distinction
const DEAL_COLORS = [
  "#2563eb", // blue
  "#16a34a", // green
  "#d97706", // amber
  "#dc2626", // red
  "#7c3aed", // violet
  "#0891b2", // cyan
  "#be185d", // pink
  "#65a30d", // lime
  "#ea580c", // orange
  "#6366f1", // indigo
];

export async function getCalendarEvents(
  year: number,
  month: number, // 1-indexed (1=Jan)
  scopeDealIds?: string[]
): Promise<{ events: CalendarEvent[]; deals: { id: string; name: string; color: string }[] }> {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");
  const locale = await getLocale();

  // Get user's deal memberships
  const memberships = await prisma.dealMember.findMany({
    where: { userId: session.user.id },
    select: { dealId: true, deal: { select: { id: true, name: true } } },
  });

  let dealMap = new Map<string, { name: string; color: string }>();
  memberships.forEach((m, i) => {
    dealMap.set(m.dealId, {
      name: m.deal.name,
      color: DEAL_COLORS[i % DEAL_COLORS.length],
    });
  });

  // Scope to requested deals or all
  const dealIds = scopeDealIds
    ? scopeDealIds.filter((id) => dealMap.has(id))
    : [...dealMap.keys()];

  if (dealIds.length === 0) {
    return { events: [], deals: [] };
  }

  // Date range: first day of month -7 days to last day +7 days (for edge cells)
  const start = new Date(year, month - 1, 1);
  start.setDate(start.getDate() - 7);
  const end = new Date(year, month, 0); // last day of month
  end.setDate(end.getDate() + 7);

  const now = new Date();

  // Fetch all 3 data sources in parallel
  const [milestones, tasks, activities] = await Promise.all([
    prisma.milestone.findMany({
      where: {
        dealId: { in: dealIds },
        date: { not: null, gte: start, lte: end },
      },
      select: {
        id: true,
        name: true,
        date: true,
        isDone: true,
        deal: { select: { id: true } },
      },
    }),
    prisma.task.findMany({
      where: {
        workstream: { dealId: { in: dealIds } },
        dueDate: { not: null, gte: start, lte: end },
      },
      select: {
        id: true,
        title: true,
        dueDate: true,
        status: true,
        workstream: { select: { deal: { select: { id: true } } } },
      },
    }),
    prisma.activityEntry.findMany({
      where: {
        dealId: { in: dealIds },
        createdAt: { gte: start, lte: end },
      },
      select: {
        id: true,
        content: true,
        type: true,
        createdAt: true,
        dealId: true,
      },
    }),
  ]);

  const events: CalendarEvent[] = [];

  for (const m of milestones) {
    if (!m.date) continue;
    const deal = dealMap.get(m.deal.id);
    if (!deal) continue;
    events.push({
      id: m.id,
      type: "milestone",
      title: m.name,
      date: m.date,
      dealId: m.deal.id,
      dealName: deal.name,
      dealColor: deal.color,
      status: m.isDone ? "done" : undefined,
      isOverdue: !m.isDone && m.date < now,
      href: `/${locale}/deals/${m.deal.id}`,
    });
  }

  for (const t of tasks) {
    if (!t.dueDate) continue;
    const dId = t.workstream.deal.id;
    const deal = dealMap.get(dId);
    if (!deal) continue;
    events.push({
      id: t.id,
      type: "task",
      title: t.title,
      date: t.dueDate,
      dealId: dId,
      dealName: deal.name,
      dealColor: deal.color,
      status: t.status,
      isOverdue: t.status !== "Done" && t.dueDate < now,
      href: `/${locale}/deals/${dId}`,
    });
  }

  for (const a of activities) {
    const deal = dealMap.get(a.dealId);
    if (!deal) continue;
    events.push({
      id: a.id,
      type: "activity",
      title: a.content.length > 60 ? a.content.slice(0, 60) + "..." : a.content,
      date: a.createdAt,
      dealId: a.dealId,
      dealName: deal.name,
      dealColor: deal.color,
      isOverdue: false,
      href: `/${locale}/deals/${a.dealId}`,
    });
  }

  // Sort by date
  events.sort((a, b) => a.date.getTime() - b.date.getTime());

  const deals = dealIds
    .map((id) => {
      const d = dealMap.get(id);
      return d ? { id, name: d.name, color: d.color } : null;
    })
    .filter(Boolean) as { id: string; name: string; color: string }[];

  return { events, deals };
}
```

- [ ] **Step 2: Type-check**

Run: `cd /Users/BBB/ccproj/maprojms/dealflow && npx tsc --noEmit`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add src/actions/calendar.ts
git commit -m "feat(calendar): add getCalendarEvents server action"
```

---

### Task 3: Create Zustand calendar store

**Files:**
- Create: `src/hooks/use-calendar.ts`

- [ ] **Step 1: Create the store**

```ts
import { create } from "zustand";

interface CalendarState {
  year: number;
  month: number; // 1-indexed
  showMilestones: boolean;
  showTasks: boolean;
  showActivity: boolean;
  selectedDealIds: string[] | null; // null = all deals
  prevMonth: () => void;
  nextMonth: () => void;
  goToToday: () => void;
  toggleMilestones: () => void;
  toggleTasks: () => void;
  toggleActivity: () => void;
  setSelectedDealIds: (ids: string[] | null) => void;
}

const now = new Date();

export const useCalendar = create<CalendarState>((set) => ({
  year: now.getFullYear(),
  month: now.getMonth() + 1,
  showMilestones: true,
  showTasks: true,
  showActivity: false,
  selectedDealIds: null,
  prevMonth: () =>
    set((s) => {
      if (s.month === 1) return { year: s.year - 1, month: 12 };
      return { month: s.month - 1 };
    }),
  nextMonth: () =>
    set((s) => {
      if (s.month === 12) return { year: s.year + 1, month: 1 };
      return { month: s.month + 1 };
    }),
  goToToday: () =>
    set({
      year: new Date().getFullYear(),
      month: new Date().getMonth() + 1,
    }),
  toggleMilestones: () => set((s) => ({ showMilestones: !s.showMilestones })),
  toggleTasks: () => set((s) => ({ showTasks: !s.showTasks })),
  toggleActivity: () => set((s) => ({ showActivity: !s.showActivity })),
  setSelectedDealIds: (ids) => set({ selectedDealIds: ids }),
}));
```

- [ ] **Step 2: Commit**

```bash
git add src/hooks/use-calendar.ts
git commit -m "feat(calendar): add Zustand calendar state store"
```

---

## Chunk 2: Calendar UI Components

### Task 4: CalendarHeader component

**Files:**
- Create: `src/components/calendar/calendar-header.tsx`

- [ ] **Step 1: Create the header**

This renders: `← MonthName Year →` | `[Today]` | filter toggles (Milestones/Tasks/Activity) | deal selector (dashboard only).

```tsx
"use client";

import { useTranslations, useLocale } from "next-intl";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { useCalendar } from "@/hooks/use-calendar";

interface CalendarHeaderProps {
  /** Available deals for filtering (omit for single-deal calendar) */
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
      // Currently all selected → deselect this one
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
      {/* Left: month navigation */}
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

      {/* Right: filters */}
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

        {/* Deal filter (dashboard only) */}
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
```

- [ ] **Step 2: Commit**

```bash
git add src/components/calendar/calendar-header.tsx
git commit -m "feat(calendar): add CalendarHeader with nav and filters"
```

---

### Task 5: CalendarEventPopover component

**Files:**
- Create: `src/components/calendar/calendar-event-popover.tsx`

- [ ] **Step 1: Create the popover**

```tsx
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
          {/* Type badge + deal */}
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

          {/* Title */}
          <p className="text-sm font-medium leading-tight">{event.title}</p>

          {/* Date */}
          <p className="text-xs text-muted-foreground">{dateStr}</p>

          {/* Status */}
          {event.isOverdue && (
            <Badge variant="destructive" className="w-fit text-xs">
              {t("overdue")}
            </Badge>
          )}
          {event.status === "Done" || event.status === "done" ? (
            <Badge variant="outline" className="w-fit text-xs text-emerald-600">
              {t("done")}
            </Badge>
          ) : null}

          {/* Link */}
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
```

- [ ] **Step 2: Commit**

```bash
git add src/components/calendar/calendar-event-popover.tsx
git commit -m "feat(calendar): add CalendarEventPopover component"
```

---

### Task 6: CalendarDayCell component

**Files:**
- Create: `src/components/calendar/calendar-day-cell.tsx`

- [ ] **Step 1: Create the day cell**

```tsx
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
      {/* Day number */}
      <div
        className={cn(
          "mb-0.5 text-right text-xs font-medium",
          isToday && "text-primary font-bold"
        )}
      >
        {date.getDate()}
      </div>

      {/* Events */}
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
            <PopoverTrigger
              nativeButton={false}
              render={<span />}
            >
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
```

- [ ] **Step 2: Commit**

```bash
git add src/components/calendar/calendar-day-cell.tsx
git commit -m "feat(calendar): add CalendarDayCell with events and overflow"
```

---

### Task 7: CalendarGrid component

**Files:**
- Create: `src/components/calendar/calendar-grid.tsx`

- [ ] **Step 1: Create the grid**

Builds 6 weeks × 7 days grid starting from Monday. Groups events by day key.

```tsx
"use client";

import { useLocale } from "next-intl";
import { CalendarDayCell } from "./calendar-day-cell";
import { useCalendar } from "@/hooks/use-calendar";
import type { CalendarEvent } from "@/actions/calendar";

interface CalendarGridProps {
  events: CalendarEvent[];
}

function getMonthGrid(year: number, month: number) {
  // month is 1-indexed
  const firstDay = new Date(year, month - 1, 1);
  // Start grid on Monday (ISO week)
  let startDate = new Date(firstDay);
  const dayOfWeek = startDate.getDay(); // 0=Sun
  const offset = dayOfWeek === 0 ? 6 : dayOfWeek - 1; // days since Monday
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

  // Group events by day
  const eventsByDay = new Map<string, CalendarEvent[]>();
  for (const evt of events) {
    const key = dateKey(new Date(evt.date));
    if (!eventsByDay.has(key)) eventsByDay.set(key, []);
    eventsByDay.get(key)!.push(evt);
  }

  // Weekday headers (Mon–Sun)
  const weekdays = Array.from({ length: 7 }, (_, i) => {
    const d = new Date(2024, 0, i + 1); // 2024-01-01 is Monday
    return new Intl.DateTimeFormat(locale, { weekday: "short" }).format(d);
  });

  return (
    <div className="mt-3">
      {/* Weekday headers */}
      <div className="grid grid-cols-7 text-center text-xs font-medium text-muted-foreground">
        {weekdays.map((wd, i) => (
          <div
            key={wd}
            className={i >= 5 ? "text-muted-foreground/60" : undefined}
          >
            {wd}
          </div>
        ))}
      </div>

      {/* Day grid */}
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
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add src/components/calendar/calendar-grid.tsx
git commit -m "feat(calendar): add CalendarGrid with Monday-start week layout"
```

---

### Task 8: CalendarView main component

**Files:**
- Create: `src/components/calendar/calendar-view.tsx`

- [ ] **Step 1: Create the main component**

This is the reusable wrapper that combines header + grid + client-side filtering/data fetching.

```tsx
"use client";

import { useEffect, useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { CalendarHeader } from "./calendar-header";
import { CalendarGrid } from "./calendar-grid";
import { useCalendar } from "@/hooks/use-calendar";
import { getCalendarEvents } from "@/actions/calendar";
import type { CalendarEvent } from "@/actions/calendar";

interface CalendarViewProps {
  /** Initial events from server */
  initialEvents: CalendarEvent[];
  /** Available deals for dashboard filter; omit for single-deal */
  deals?: { id: string; name: string; color: string }[];
  /** If set, scope fetches to this deal only */
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

  // Re-fetch when month changes
  useEffect(() => {
    startTransition(async () => {
      const scope = scopeDealId ? [scopeDealId] : undefined;
      const { events: newEvents } = await getCalendarEvents(year, month, scope);
      setEvents(newEvents);
    });
  }, [year, month, scopeDealId]);

  // Client-side filter
  const filtered = events.filter((evt) => {
    if (evt.type === "milestone" && !showMilestones) return false;
    if (evt.type === "task" && !showTasks) return false;
    if (evt.type === "activity" && !showActivity) return false;
    if (selectedDealIds !== null && !selectedDealIds.includes(evt.dealId))
      return false;
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
```

- [ ] **Step 2: Type-check**

Run: `cd /Users/BBB/ccproj/maprojms/dealflow && npx tsc --noEmit`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add src/components/calendar/calendar-view.tsx
git commit -m "feat(calendar): add CalendarView reusable component"
```

---

## Chunk 3: Pages + Navigation + Contacts Grouping

### Task 9: Dashboard calendar page

**Files:**
- Create: `src/app/[locale]/calendar/page.tsx`

- [ ] **Step 1: Create the page**

```tsx
import { auth } from "@/lib/auth";
import { redirect } from "next/navigation";
import { getLocale, getTranslations } from "next-intl/server";
import { getCalendarEvents } from "@/actions/calendar";
import { CalendarView } from "@/components/calendar/calendar-view";

export const dynamic = "force-dynamic";

export default async function DashboardCalendarPage() {
  const session = await auth();
  const locale = await getLocale();

  if (!session?.user?.id) {
    redirect(`/${locale}/login`);
  }

  const t = await getTranslations("calendar");
  const now = new Date();
  const { events, deals } = await getCalendarEvents(
    now.getFullYear(),
    now.getMonth() + 1
  );

  return (
    <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6">
      <h1 className="mb-4 text-2xl font-bold">{t("calendar")}</h1>
      <CalendarView initialEvents={events} deals={deals} />
    </div>
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add src/app/\[locale\]/calendar/page.tsx
git commit -m "feat(calendar): add dashboard calendar page"
```

---

### Task 10: Deal calendar page

**Files:**
- Create: `src/app/[locale]/deals/[dealId]/calendar/page.tsx`

- [ ] **Step 1: Create the page**

```tsx
import { auth } from "@/lib/auth";
import { redirect, notFound } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { getLocale, getTranslations } from "next-intl/server";
import { getCalendarEvents } from "@/actions/calendar";
import { CalendarView } from "@/components/calendar/calendar-view";

export const dynamic = "force-dynamic";

export default async function DealCalendarPage({
  params,
}: {
  params: Promise<{ dealId: string; locale: string }>;
}) {
  const { dealId } = await params;
  const session = await auth();
  const locale = await getLocale();

  if (!session?.user?.id) {
    redirect(`/${locale}/login`);
  }

  // Verify membership
  const isMember = await prisma.dealMember.findUnique({
    where: { dealId_userId: { dealId, userId: session.user.id } },
  });
  if (!isMember) {
    notFound();
  }

  const deal = await prisma.deal.findUnique({
    where: { id: dealId },
    select: { name: true },
  });
  if (!deal) notFound();

  const t = await getTranslations("calendar");
  const now = new Date();
  const { events } = await getCalendarEvents(
    now.getFullYear(),
    now.getMonth() + 1,
    [dealId]
  );

  return (
    <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6">
      <h1 className="mb-4 text-2xl font-bold">
        {deal.name} — {t("calendar")}
      </h1>
      <CalendarView initialEvents={events} scopeDealId={dealId} />
    </div>
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add src/app/\[locale\]/deals/\[dealId\]/calendar/page.tsx
git commit -m "feat(calendar): add per-deal calendar page"
```

---

### Task 11: Add calendar link to top nav and deal detail

**Files:**
- Modify: `src/components/layout/app-shell.tsx` (line 20-28 navLinks array)
- Modify: `src/app/[locale]/deals/[dealId]/page.tsx` (line 156-175 bottom links)

- [ ] **Step 1: Add to top nav**

In `src/components/layout/app-shell.tsx`, add the calendar link to the `navLinks` array between "contacts" and the admin link:

```ts
// Existing:
  const navLinks = [
    { href: `/${locale}/dashboard`, label: t("dashboard") },
    { href: `/${locale}/deals`, label: t("deals") },
    { href: `/${locale}/tasks`, label: t("myTasks") },
    { href: `/${locale}/contacts`, label: t("contacts") },
// ADD THIS LINE:
    { href: `/${locale}/calendar`, label: t("calendar") },
    ...(role === "Admin"
      ? [{ href: `/${locale}/admin/users`, label: t("admin") }]
      : []),
  ];
```

- [ ] **Step 2: Add to deal detail bottom links**

In `src/app/[locale]/deals/[dealId]/page.tsx`, add a Calendar link after the Documents link. Add `tCalendar` translations:

After the existing `const tDocument = await getTranslations("document");` line, add:

```ts
const tCalendar = await getTranslations("calendar");
```

Then in the bottom links `<div>`, add after the Documents `<Link>`:

```tsx
<Link
  href={`/${locale}/deals/${dealId}/calendar`}
  className="rounded-md border px-4 py-2 text-sm font-medium transition-colors hover:bg-muted"
>
  {tCalendar("calendar")}
</Link>
```

- [ ] **Step 3: Type-check**

Run: `cd /Users/BBB/ccproj/maprojms/dealflow && npx tsc --noEmit`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add src/components/layout/app-shell.tsx src/app/\[locale\]/deals/\[dealId\]/page.tsx
git commit -m "feat(calendar): add calendar links to nav and deal detail"
```

---

### Task 12: Group contacts page by deal

**Files:**
- Modify: `src/app/[locale]/contacts/page.tsx`
- Modify: `src/components/contacts/contact-list.tsx`

- [ ] **Step 1: Add translation keys**

Add to `messages/en.json` `"contact"` section:

```json
"unlinkedContacts": "Not linked to any deal",
"linkedToDeals": "Linked to {count} deals"
```

Add to `messages/zh.json` `"contact"` section:

```json
"unlinkedContacts": "未关联项目",
"linkedToDeals": "关联{count}个项目"
```

- [ ] **Step 2: Update contacts page to fetch grouped data**

Replace the query in `src/app/[locale]/contacts/page.tsx` with:

```tsx
import { auth } from "@/lib/auth";
import { redirect } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { getLocale, getTranslations } from "next-intl/server";
import { GroupedContactList } from "@/components/contacts/contact-list";
import { ContactForm } from "@/components/contacts/contact-form";

export default async function GlobalContactsPage() {
  const session = await auth();
  const locale = await getLocale();

  if (!session?.user?.id) {
    redirect(`/${locale}/login`);
  }

  const t = await getTranslations("contact");

  // Get user's deals
  const memberships = await prisma.dealMember.findMany({
    where: { userId: session.user.id },
    select: { dealId: true, deal: { select: { id: true, name: true } } },
  });
  const dealIds = memberships.map((m) => m.dealId);

  // Get all contacts with their deal links
  const contacts = await prisma.contact.findMany({
    orderBy: { name: "asc" },
    include: {
      dealContacts: {
        where: { dealId: { in: dealIds } },
        select: {
          dealId: true,
          roleInDeal: true,
          deal: { select: { id: true, name: true } },
        },
      },
    },
  });

  // Build grouped structure
  const dealGroups: Record<string, {
    dealName: string;
    contacts: typeof contactsData;
  }> = {};

  const contactsData = contacts.map((c) => ({
    id: c.id,
    name: c.name,
    organization: c.organization,
    role: c.role,
    title: c.title,
    email: c.email,
    phone: c.phone,
    timezone: c.timezone,
    notes: c.notes,
    dealLinks: c.dealContacts.map((dc) => ({
      dealId: dc.deal.id,
      dealName: dc.deal.name,
      roleInDeal: dc.roleInDeal,
    })),
  }));

  type ContactData = (typeof contactsData)[number];

  // Group by deal
  for (const c of contactsData) {
    for (const link of c.dealLinks) {
      if (!dealGroups[link.dealId]) {
        dealGroups[link.dealId] = { dealName: link.dealName, contacts: [] };
      }
      dealGroups[link.dealId].contacts.push(c);
    }
  }

  // Unlinked contacts
  const unlinked = contactsData.filter((c) => c.dealLinks.length === 0);

  // Sort deal groups by deal name
  const sortedGroups = Object.entries(dealGroups).sort((a, b) =>
    a[1].dealName.localeCompare(b[1].dealName)
  );

  return (
    <div className="mx-auto max-w-5xl px-4 py-6 sm:px-6">
      <div className="mb-4 flex items-center justify-between">
        <h1 className="text-lg font-semibold">{t("contacts")}</h1>
        <ContactForm
          trigger={
            <button className="rounded-md bg-primary px-3 py-1.5 text-sm font-medium text-primary-foreground hover:bg-primary/90">
              + {t("addContact")}
            </button>
          }
        />
      </div>

      <GroupedContactList groups={sortedGroups} unlinked={unlinked} />
    </div>
  );
}
```

- [ ] **Step 3: Add GroupedContactList to contact-list.tsx**

Add the `GroupedContactList` export at the end of `src/components/contacts/contact-list.tsx`:

```tsx
// --- Grouped view for global contacts page ---

interface DealGroup {
  dealName: string;
  contacts: (ContactItem & {
    dealLinks: { dealId: string; dealName: string; roleInDeal: string | null }[];
  })[];
}

interface GroupedContactListProps {
  groups: [string, DealGroup][];
  unlinked: (ContactItem & {
    dealLinks: { dealId: string; dealName: string; roleInDeal: string | null }[];
  })[];
}

export function GroupedContactList({ groups, unlinked }: GroupedContactListProps) {
  const t = useTranslations("contact");
  const tCommon = useTranslations("common");
  const [collapsed, setCollapsed] = useState<Record<string, boolean>>({});

  function toggleCollapse(key: string) {
    setCollapsed((prev) => ({ ...prev, [key]: !prev[key] }));
  }

  if (groups.length === 0 && unlinked.length === 0) {
    return (
      <p className="py-8 text-center text-sm text-muted-foreground">
        {tCommon("noResults")}
      </p>
    );
  }

  return (
    <div className="flex flex-col gap-6">
      {groups.map(([dealId, group]) => (
        <div key={dealId} className="rounded-lg border bg-card">
          <button
            type="button"
            className="flex w-full items-center justify-between px-4 py-3 text-left hover:bg-muted/50"
            onClick={() => toggleCollapse(dealId)}
          >
            <span className="text-sm font-semibold">{group.dealName}</span>
            <span className="text-xs text-muted-foreground">
              {group.contacts.length}
            </span>
          </button>
          {!collapsed[dealId] && (
            <div className="border-t">
              <ContactList contacts={group.contacts} showDelete />
            </div>
          )}
        </div>
      ))}

      {unlinked.length > 0 && (
        <div className="rounded-lg border bg-card">
          <button
            type="button"
            className="flex w-full items-center justify-between px-4 py-3 text-left hover:bg-muted/50"
            onClick={() => toggleCollapse("__unlinked")}
          >
            <span className="text-sm font-semibold text-muted-foreground">
              {t("unlinkedContacts")}
            </span>
            <span className="text-xs text-muted-foreground">
              {unlinked.length}
            </span>
          </button>
          {!collapsed["__unlinked"] && (
            <div className="border-t">
              <ContactList contacts={unlinked} showDelete />
            </div>
          )}
        </div>
      )}
    </div>
  );
}
```

- [ ] **Step 4: Type-check**

Run: `cd /Users/BBB/ccproj/maprojms/dealflow && npx tsc --noEmit`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add messages/en.json messages/zh.json src/app/\[locale\]/contacts/page.tsx src/components/contacts/contact-list.tsx
git commit -m "feat(contacts): group contacts page by deal with collapsible sections"
```

---

### Task 13: Final type-check and manual verification

- [ ] **Step 1: Full type-check**

Run: `cd /Users/BBB/ccproj/maprojms/dealflow && npx tsc --noEmit`
Expected: No errors

- [ ] **Step 2: Visual verification checklist**

Open `http://localhost:3000` and verify:
1. Top nav shows "日历" / "Calendar" link
2. Click → Dashboard calendar page loads with month view
3. Events from Project Alpha and Beta appear on correct dates
4. Filter toggles (milestones/tasks/activity) work
5. Deal color badges work for filtering
6. Click event → popover shows details with "View Details" link
7. ← → month navigation works, "Today" button returns to current month
8. Weekend columns have gray background, today has highlight
9. Open Project Alpha → bottom links show "日历" link
10. Click → Deal calendar page loads with only Alpha events
11. Contacts page (`/contacts`) shows contacts grouped by deal
12. Deal group sections are collapsible
13. Unlinked contacts appear in separate section at bottom

- [ ] **Step 3: Commit any fixes, then final commit**

```bash
git add -A
git commit -m "feat: add calendar view and contacts grouping (Phase 2)"
```

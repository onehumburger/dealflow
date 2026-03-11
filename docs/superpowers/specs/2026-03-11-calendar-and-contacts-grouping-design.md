# Phase 2: Calendar View & Contacts Grouping Design

## Overview

Add a monthly calendar view to DealFlow at two levels (global dashboard and per-deal), plus group the contacts page by deal. These are the first Phase 2 features after the MVP.

---

## Feature 1: Calendar View

### Goal

Provide a monthly calendar so lawyers can see all milestones, task deadlines, and optionally activity entries across projects at a glance, with clear weekday visibility.

### Architecture

One reusable `CalendarView` client component consumed by two pages:

- **Dashboard Calendar** — `/[locale]/calendar` — shows events from all deals the user is a member of
- **Deal Calendar** — `/[locale]/deals/[dealId]/calendar` — shows events from that deal only

Data is fetched server-side and passed as a unified event array to the shared component.

### Data Model

No schema changes needed. Calendar events are derived from existing models:

```ts
interface CalendarEvent {
  id: string;
  type: "milestone" | "task" | "activity";
  title: string;
  date: Date;
  dealId: string;
  dealName: string;
  dealColor: string; // assigned per-deal for visual distinction
  status?: string;   // e.g. TaskStatus, milestone isDone
  isOverdue: boolean;
  href: string;      // link to detail page
}
```

### Data Sources

| Type | Source | Date field | Condition |
|------|--------|-----------|-----------|
| Milestone | `Milestone` | `date` | `date IS NOT NULL` |
| Task | `Task` | `dueDate` | `dueDate IS NOT NULL` |
| Activity | `ActivityEntry` | `createdAt` | Only when activity toggle is on |

### Pages

#### Dashboard Calendar (`/[locale]/calendar`)

- **Navigation**: Add "Calendar" / "日历" link to top nav bar
- **Server component** fetches events for the selected month (±1 week buffer for edge days) across all user's deals
- **Filters**:
  - Deal filter: multi-select to show/hide specific deals
  - Type toggles: Milestone (default on), Task (default on), Activity (default off)
- **Color coding**: Each deal assigned a color from a fixed palette (8-10 colors, cycling)

#### Deal Calendar (`/[locale]/deals/[dealId]/calendar`)

- **Navigation**: Add "Calendar" / "日历" link in deal detail bottom links area (next to Decisions, Contacts, Documents)
- **Server component** fetches events for that deal only
- **Filters**: Type toggles only (no deal filter needed)
- **Color coding**: Single-deal, so color distinguishes type (milestone vs task vs activity)

### CalendarView Component

#### Layout

```
┌──────────────────────────────────────────────┐
│  ← March 2026 →              [Today] [Filters]│
├──────┬──────┬──────┬──────┬──────┬──────┬──────┤
│ Mon  │ Tue  │ Wed  │ Thu  │ Fri  │ Sat  │ Sun  │
├──────┼──────┼──────┼──────┼──────┼──────┼──────┤
│      │      │  1   │  2   │  3   │  4   │  5   │
│      │      │      │      │ ◆NBO │      │      │
│      │      │      │      │ ●SPA │      │      │
├──────┼──────┼──────┼──────┼──────┼──────┼──────┤
│  6   │  7   │  8   │ ...  │      │      │      │
│      │      │ ●DD  │      │      │      │      │
│      │      │+2more│      │      │      │      │
└──────┴──────┴──────┴──────┴──────┴──────┴──────┘
```

#### Visual Rules

- **Today**: Bold border + light background highlight
- **Weekends (Sat/Sun)**: Light gray background
- **Overdue items**: Red text + red dot indicator
- **Event display per cell**: Max 3 items visible, then "+N more" link
- **Event icons**: ◆ for milestone, ● for task, ○ for activity
- **Deal colors**: Small colored left-border or dot per event in dashboard view

#### Interaction

1. **Click event** → Popover appears with:
   - Event title
   - Deal name (with color dot)
   - Date and type badge
   - Status (for tasks/milestones)
   - "View Details" link → navigates to deal page / opens task panel
2. **Click "+N more"** → Popover with full list for that day
3. **← → arrows** → Navigate months
4. **"Today" button** → Jump back to current month
5. **Filter toggles** → Show/hide event types, filter deals (dashboard only)

### File Structure

```
src/
  components/
    calendar/
      calendar-view.tsx        # Main reusable calendar component (client)
      calendar-header.tsx      # Month nav + today button + filters
      calendar-grid.tsx        # Month grid with day cells
      calendar-day-cell.tsx    # Single day cell with events
      calendar-event.tsx       # Event item (colored pill)
      calendar-event-popover.tsx # Click popover with details
  app/
    [locale]/
      calendar/
        page.tsx               # Dashboard calendar page (server)
      deals/
        [dealId]/
          calendar/
            page.tsx           # Deal calendar page (server)
  actions/
    calendar.ts                # Server action: getCalendarEvents(month, dealIds?)
```

### Server Action

```ts
// src/actions/calendar.ts
export async function getCalendarEvents(
  year: number,
  month: number,        // 0-indexed
  dealIds?: string[]    // if provided, scope to these deals; otherwise all user's deals
): Promise<CalendarEvent[]>
```

Fetches milestones, tasks, and activities for the given month (with ±7 day buffer), scoped to user's deal memberships. Returns unified `CalendarEvent[]`.

### Translations

Add to `messages/{zh,en}.json`:

```json
{
  "calendar": {
    "calendar": "日历 / Calendar",
    "today": "今天 / Today",
    "showMilestones": "显示节点 / Show Milestones",
    "showTasks": "显示任务 / Show Tasks",
    "showActivity": "显示动态 / Show Activity",
    "more": "还有{count}项 / +{count} more",
    "viewDetails": "查看详情 / View Details",
    "noEvents": "无事件 / No events"
  }
}
```

---

## Feature 2: Contacts Page Grouped by Deal

### Goal

The global contacts page (`/[locale]/contacts`) currently shows a flat list. Group contacts by deal for easier navigation, while keeping the global shared contact pool.

### Design

- **Default view**: Contacts grouped by deal, each deal as a collapsible section
- **Section header**: Deal name + contact count
- **Contacts not linked to any deal**: Shown in a separate "Unlinked" / "未关联项目" section at bottom
- **Contacts linked to multiple deals**: Appear in each deal's section (with a subtle badge indicating multi-deal)
- **Search/filter**: Existing search still works across all contacts
- **Data model**: No changes — uses existing `DealContact` join table

### File Changes

- Modify `src/app/[locale]/contacts/page.tsx` — group query by deal
- Modify `src/components/contacts/contact-list.tsx` — render grouped sections

---

## Out of Scope

- Week view / day view (can add later if needed)
- Drag-and-drop rescheduling on calendar
- Recurring events
- External calendar sync (Google Calendar, Outlook)
- Push notifications / email reminders

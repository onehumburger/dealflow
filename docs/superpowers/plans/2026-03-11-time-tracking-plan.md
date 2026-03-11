# Time Tracking System Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add time tracking to DealFlow so lawyers can log hours via live timer or manual entry, with an admin billing page for rate management and Excel export.

**Architecture:** Server actions handle all time entry CRUD. A Zustand store with localStorage persistence manages the live timer client-side. The floating timer bar is rendered in the app shell (visible on all pages). Time entries display in the task panel. Admin billing is a new page under `/admin/billing`. Excel export uses `exceljs` on the server.

**Tech Stack:** Next.js 16, Prisma 7 (`@/generated/prisma/client`), Zustand 5 (with `persist` middleware), next-intl, exceljs, lucide-react, shadcn/ui, Base UI

---

## Codebase Context

**Key patterns every task must follow:**

- **Server actions**: `"use server"` directive, auth check via `const session = await auth()`, membership check via `assertDealMember(dealId, userId)`, revalidation via `revalidateDeal(dealId, extraPath?)`, audit via `logAudit(userId, action, entityType, entityId, changes?)`
- **Prisma imports**: Use `import { prisma } from "@/lib/prisma"` and types from `@/generated/prisma/client` (NOT `@prisma/client`)
- **Client components**: `"use client"` directive, translations via `useTranslations("namespace")`, transitions via `useTransition()`
- **Server pages**: Auth check → membership check → data fetch with `select` → serialize dates → render with translated props
- **Admin pages**: Additional role check: `const role = (session.user as unknown as { role: string }).role; if (role !== "Admin") redirect(...)`
- **Zustand stores**: `create<State>((set) => ({ ... }))` pattern, see `src/hooks/use-task-panel.ts`
- **Deal detail bottom links**: Pattern in `src/app/[locale]/deals/[dealId]/page.tsx:166-191` — `<Link>` elements with `rounded-md border px-4 py-2 text-sm font-medium` classes

**Key files referenced frequently:**

| File | Purpose |
|------|---------|
| `prisma/schema.prisma` | Data models |
| `src/actions/_helpers.ts` | `assertDealMember`, `revalidateDeal` |
| `src/actions/tasks.ts` | Server action patterns (auth, membership, audit, revalidate) |
| `src/lib/audit.ts` | `logAudit(userId, action, entityType, entityId, changes?)` |
| `src/hooks/use-task-panel.ts` | Zustand store pattern |
| `src/components/tasks/task-panel.tsx` | Task panel (where time entries will display) |
| `src/components/tasks/task-row.tsx` | Task row (where timer button will appear) |
| `src/components/layout/app-shell.tsx` | App shell (where timer bar will render) |
| `src/app/[locale]/deals/[dealId]/page.tsx` | Deal detail (where time link will be added) |
| `src/app/[locale]/admin/users/page.tsx` | Admin page pattern |
| `messages/en.json`, `messages/zh.json` | Translation files |

---

## File Structure

**New files to create:**

| File | Purpose |
|------|---------|
| `src/actions/time-entries.ts` | Timer and time entry CRUD server actions |
| `src/actions/billing.ts` | Admin billing, rates, Excel export server actions |
| `src/hooks/use-timer.ts` | Zustand timer store with localStorage persistence |
| `src/components/timer/timer-button.tsx` | Play/stop button for task rows and task panel |
| `src/components/timer/timer-bar.tsx` | Floating bottom bar showing active timer |
| `src/components/time/time-entry-list.tsx` | Time entry list in task panel |
| `src/components/time/manual-time-form.tsx` | Manual time entry form |
| `src/components/time/deal-time-summary.tsx` | Deal time summary grouped views |
| `src/components/billing/billing-filters.tsx` | Filter controls for admin billing |
| `src/components/billing/billing-table.tsx` | Time entry table with inline edit |
| `src/components/billing/billing-rate-editor.tsx` | Rate management per person per deal |
| `src/components/billing/billing-summary.tsx` | Totals panel |
| `src/app/[locale]/deals/[dealId]/time/page.tsx` | Deal time summary page |
| `src/app/[locale]/admin/billing/page.tsx` | Admin billing page |

**Existing files to modify:**

| File | Change |
|------|--------|
| `prisma/schema.prisma` | Add TimeEntry, DealBillingRate models + relations |
| `messages/en.json` | Add `timer` and `billing` translation keys |
| `messages/zh.json` | Add `timer` and `billing` translation keys |
| `src/components/tasks/task-panel.tsx` | Add time section with entry list + timer/manual buttons |
| `src/components/tasks/task-row.tsx` | Add timer button on hover |
| `src/components/layout/app-shell.tsx` | Add TimerBar, add billing nav link for Admin |
| `src/app/[locale]/deals/[dealId]/page.tsx` | Add time link to bottom links |
| `src/actions/tasks.ts` | Add deal name to `getTaskDetail` select |
| `package.json` | Add `exceljs` dependency |

---

## Chunk 1: Data Foundation

### Task 1: Prisma Schema + Migration

**Files:**
- Modify: `prisma/schema.prisma`

- [ ] **Step 1: Add TimeEntry and DealBillingRate models to schema**

Add the following after the `Document` model (before `AuditLog`) in `prisma/schema.prisma`:

```prisma
model TimeEntry {
  id              String   @id @default(cuid())
  description     String?
  startedAt       DateTime?
  stoppedAt       DateTime?
  durationMinutes Int
  isManual        Boolean  @default(false)
  isBillable      Boolean  @default(true)
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt

  taskId String
  task   Task   @relation(fields: [taskId], references: [id], onDelete: Cascade)
  userId String
  user   User   @relation("TimeEntries", fields: [userId], references: [id])
  dealId String
  deal   Deal   @relation(fields: [dealId], references: [id], onDelete: Cascade)

  @@index([taskId])
  @@index([userId])
  @@index([dealId, userId])
}

model DealBillingRate {
  id          String  @id @default(cuid())
  ratePerHour Decimal @db.Decimal(10, 2)
  currency    String  @default("CNY")

  dealId String
  deal   Deal   @relation(fields: [dealId], references: [id], onDelete: Cascade)
  userId String
  user   User   @relation("BillingRates", fields: [userId], references: [id])

  @@unique([dealId, userId])
}
```

- [ ] **Step 2: Add relation fields to existing models**

In the `User` model, after the `auditLogs` field (line ~111), add:

```prisma
  timeEntries  TimeEntry[]       @relation("TimeEntries")
  billingRates DealBillingRate[] @relation("BillingRates")
```

In the `Deal` model, after the `documents` field (line ~136), add:

```prisma
  timeEntries  TimeEntry[]
  billingRates DealBillingRate[]
```

In the `Task` model, after the `linkedMilestones` field (line ~218), add:

```prisma
  timeEntries TimeEntry[]
```

- [ ] **Step 3: Generate migration and Prisma client**

Run:
```bash
npx prisma migrate dev --name add-time-tracking
```

Expected: Migration created successfully, Prisma client regenerated in `src/generated/prisma/`.

- [ ] **Step 4: Verify schema compiles**

Run:
```bash
npx prisma validate
```

Expected: "The schema at `prisma/schema.prisma` is valid."

- [ ] **Step 5: Commit**

```bash
git add prisma/schema.prisma prisma/migrations/ src/generated/
git commit -m "feat: add TimeEntry and DealBillingRate models for time tracking"
```

---

### Task 2: Translations

**Files:**
- Modify: `messages/en.json`
- Modify: `messages/zh.json`

- [ ] **Step 1: Add timer and billing keys to en.json**

Add the following two sections to `messages/en.json`, after the `"calendar"` section and before the `"error"` section:

```json
  "timer": {
    "startTimer": "Start Timer",
    "stopTimer": "Stop",
    "switchTimer": "Stop current timer and start new one?",
    "logTime": "Log Time",
    "duration": "Duration",
    "hours": "hours",
    "date": "Date",
    "description": "Description",
    "totalTime": "Total",
    "timeEntries": "Time",
    "running": "Running",
    "noEntries": "No time entries",
    "billable": "Billable",
    "manual": "Manual",
    "deleteConfirm": "Delete this time entry?"
  },
  "billing": {
    "billing": "Time Management",
    "rate": "Rate",
    "ratePerHour": "Rate/Hour",
    "billable": "Billable",
    "nonBillable": "Non-billable",
    "totalHours": "Total Hours",
    "billableHours": "Billable Hours",
    "totalAmount": "Total Amount",
    "exportExcel": "Export Excel",
    "editRate": "Edit Rates",
    "setRate": "Set Rate",
    "byWorkstream": "By Workstream",
    "byMember": "By Member",
    "dateRange": "Date Range",
    "allDeals": "All Deals",
    "allMembers": "All Members",
    "billableOnly": "Billable Only",
    "summary": "Summary",
    "deal": "Deal",
    "member": "Member",
    "task": "Task",
    "workstream": "Workstream",
    "amount": "Amount",
    "currency": "CNY",
    "noRates": "No rates configured",
    "rateUpdated": "Rate updated",
    "perHour": "/hr"
  },
```

- [ ] **Step 2: Add timer and billing keys to zh.json**

Add the following two sections to `messages/zh.json`, after the `"calendar"` section and before the `"error"` section:

```json
  "timer": {
    "startTimer": "开始计时",
    "stopTimer": "停止",
    "switchTimer": "停止当前计时并开始新的?",
    "logTime": "手动录入",
    "duration": "时长",
    "hours": "小时",
    "date": "日期",
    "description": "描述",
    "totalTime": "总计",
    "timeEntries": "计时",
    "running": "计时中",
    "noEntries": "暂无计时记录",
    "billable": "可计费",
    "manual": "手动",
    "deleteConfirm": "确认删除此计时记录？"
  },
  "billing": {
    "billing": "计时管理",
    "rate": "费率",
    "ratePerHour": "时薪",
    "billable": "可计费",
    "nonBillable": "不可计费",
    "totalHours": "总时长",
    "billableHours": "可计费时长",
    "totalAmount": "总金额",
    "exportExcel": "导出Excel",
    "editRate": "编辑费率",
    "setRate": "设置费率",
    "byWorkstream": "按工作流",
    "byMember": "按成员",
    "dateRange": "日期范围",
    "allDeals": "全部项目",
    "allMembers": "全部成员",
    "billableOnly": "仅可计费",
    "summary": "汇总",
    "deal": "项目",
    "member": "成员",
    "task": "任务",
    "workstream": "工作流",
    "amount": "金额",
    "currency": "CNY",
    "noRates": "未设置费率",
    "rateUpdated": "费率已更新",
    "perHour": "/时"
  },
```

- [ ] **Step 3: Verify translations load**

Run:
```bash
npm run build
```

Expected: Build succeeds with no missing translation key errors.

- [ ] **Step 4: Commit**

```bash
git add messages/en.json messages/zh.json
git commit -m "feat: add timer and billing translation keys (en + zh)"
```

---

### Task 3: Time Entry Server Actions

**Files:**
- Create: `src/actions/time-entries.ts`
- Modify: `src/actions/tasks.ts` (add deal name to `getTaskDetail`)

- [ ] **Step 1: Create time entry server actions**

Create `src/actions/time-entries.ts`:

```ts
"use server";

import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { assertDealMember, revalidateDeal } from "@/actions/_helpers";
import { logAudit } from "@/lib/audit";
import { revalidatePath } from "next/cache";
import { getLocale } from "next-intl/server";

// ---------- helpers ----------

async function getTaskWithDeal(taskId: string) {
  const task = await prisma.task.findUnique({
    where: { id: taskId },
    select: {
      id: true,
      title: true,
      workstream: {
        select: {
          dealId: true,
          deal: { select: { name: true } },
        },
      },
    },
  });
  if (!task) throw new Error("Task not found");
  return task;
}

// ---------- startTimer ----------

export async function startTimer(taskId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const task = await getTaskWithDeal(taskId);
  const dealId = task.workstream.dealId;

  await assertDealMember(dealId, session.user.id);

  // Stop any running timer for this user
  const running = await prisma.timeEntry.findFirst({
    where: { userId: session.user.id, stoppedAt: null, isManual: false },
  });
  if (running) {
    const now = new Date();
    const durationMs = now.getTime() - (running.startedAt?.getTime() ?? now.getTime());
    await prisma.timeEntry.update({
      where: { id: running.id },
      data: {
        stoppedAt: now,
        durationMinutes: Math.max(1, Math.round(durationMs / 60000)),
      },
    });
  }

  const entry = await prisma.timeEntry.create({
    data: {
      startedAt: new Date(),
      durationMinutes: 0,
      isManual: false,
      taskId,
      userId: session.user.id,
      dealId,
    },
  });

  await revalidateDeal(dealId);

  return {
    entryId: entry.id,
    taskId: task.id,
    taskTitle: task.title,
    dealName: task.workstream.deal.name,
  };
}

// ---------- stopTimer ----------

export async function stopTimer(entryId: string, description?: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const entry = await prisma.timeEntry.findUnique({
    where: { id: entryId },
    select: { userId: true, startedAt: true, dealId: true },
  });
  if (!entry) throw new Error("Entry not found");
  if (entry.userId !== session.user.id) throw new Error("Forbidden");

  const now = new Date();
  const durationMs = now.getTime() - (entry.startedAt?.getTime() ?? now.getTime());

  await prisma.timeEntry.update({
    where: { id: entryId },
    data: {
      stoppedAt: now,
      durationMinutes: Math.max(1, Math.round(durationMs / 60000)),
      description: description?.trim() || null,
    },
  });

  await revalidateDeal(entry.dealId);
}

// ---------- logManualTime ----------

export async function logManualTime(
  taskId: string,
  data: { durationHours: number; date: string; description?: string }
) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const task = await getTaskWithDeal(taskId);
  const dealId = task.workstream.dealId;

  await assertDealMember(dealId, session.user.id);

  const durationMinutes = Math.round(data.durationHours * 60);
  if (durationMinutes <= 0) throw new Error("Duration must be positive");

  await prisma.timeEntry.create({
    data: {
      durationMinutes,
      isManual: true,
      startedAt: new Date(data.date),
      description: data.description?.trim() || null,
      taskId,
      userId: session.user.id,
      dealId,
    },
  });

  await revalidateDeal(dealId);
}

// ---------- updateTimeEntry ----------

export async function updateTimeEntry(
  entryId: string,
  data: {
    durationMinutes?: number;
    description?: string;
    isBillable?: boolean;
  }
) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const entry = await prisma.timeEntry.findUnique({
    where: { id: entryId },
    select: { userId: true, dealId: true, durationMinutes: true },
  });
  if (!entry) throw new Error("Entry not found");

  // Only owner or admin can edit
  const role = (session.user as unknown as { role: string }).role;
  if (entry.userId !== session.user.id && role !== "Admin") {
    throw new Error("Forbidden");
  }

  await prisma.timeEntry.update({
    where: { id: entryId },
    data: {
      ...(data.durationMinutes !== undefined && { durationMinutes: data.durationMinutes }),
      ...(data.description !== undefined && { description: data.description.trim() || null }),
      ...(data.isBillable !== undefined && { isBillable: data.isBillable }),
    },
  });

  await logAudit(session.user.id, "update_time_entry", "TimeEntry", entryId, {
    ...(data.durationMinutes !== undefined && {
      durationMinutes: { from: entry.durationMinutes, to: data.durationMinutes },
    }),
  });

  await revalidateDeal(entry.dealId);
}

// ---------- deleteTimeEntry ----------

export async function deleteTimeEntry(entryId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const entry = await prisma.timeEntry.findUnique({
    where: { id: entryId },
    select: { userId: true, dealId: true },
  });
  if (!entry) throw new Error("Entry not found");

  const role = (session.user as unknown as { role: string }).role;
  if (entry.userId !== session.user.id && role !== "Admin") {
    throw new Error("Forbidden");
  }

  await prisma.timeEntry.delete({ where: { id: entryId } });

  await logAudit(session.user.id, "delete_time_entry", "TimeEntry", entryId, {});

  await revalidateDeal(entry.dealId);
}

// ---------- getTaskTimeEntries ----------

export async function getTaskTimeEntries(taskId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const entries = await prisma.timeEntry.findMany({
    where: { taskId },
    orderBy: { createdAt: "desc" },
    select: {
      id: true,
      description: true,
      startedAt: true,
      stoppedAt: true,
      durationMinutes: true,
      isManual: true,
      isBillable: true,
      createdAt: true,
      user: { select: { id: true, name: true } },
    },
  });

  return entries;
}

// ---------- getDealTimeSummary ----------

export async function getDealTimeSummary(dealId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  await assertDealMember(dealId, session.user.id);

  const entries = await prisma.timeEntry.findMany({
    where: { dealId },
    select: {
      durationMinutes: true,
      isBillable: true,
      task: {
        select: {
          id: true,
          title: true,
          workstream: { select: { id: true, name: true } },
        },
      },
      user: { select: { id: true, name: true } },
    },
  });

  // Group by workstream → task
  const wsMap = new Map<string, {
    id: string;
    name: string;
    totalMinutes: number;
    billableMinutes: number;
    tasks: Map<string, { id: string; title: string; totalMinutes: number; billableMinutes: number }>;
  }>();

  for (const e of entries) {
    const ws = e.task.workstream;
    if (!wsMap.has(ws.id)) {
      wsMap.set(ws.id, {
        id: ws.id,
        name: ws.name,
        totalMinutes: 0,
        billableMinutes: 0,
        tasks: new Map(),
      });
    }
    const wsData = wsMap.get(ws.id)!;
    wsData.totalMinutes += e.durationMinutes;
    if (e.isBillable) wsData.billableMinutes += e.durationMinutes;

    if (!wsData.tasks.has(e.task.id)) {
      wsData.tasks.set(e.task.id, {
        id: e.task.id,
        title: e.task.title,
        totalMinutes: 0,
        billableMinutes: 0,
      });
    }
    const taskData = wsData.tasks.get(e.task.id)!;
    taskData.totalMinutes += e.durationMinutes;
    if (e.isBillable) taskData.billableMinutes += e.durationMinutes;
  }

  // Group by member
  const memberMap = new Map<string, {
    userId: string;
    userName: string;
    totalMinutes: number;
    billableMinutes: number;
  }>();

  for (const e of entries) {
    if (!memberMap.has(e.user.id)) {
      memberMap.set(e.user.id, {
        userId: e.user.id,
        userName: e.user.name,
        totalMinutes: 0,
        billableMinutes: 0,
      });
    }
    const m = memberMap.get(e.user.id)!;
    m.totalMinutes += e.durationMinutes;
    if (e.isBillable) m.billableMinutes += e.durationMinutes;
  }

  const totalMinutes = entries.reduce((sum, e) => sum + e.durationMinutes, 0);
  const billableMinutes = entries.filter((e) => e.isBillable).reduce((sum, e) => sum + e.durationMinutes, 0);

  return {
    byWorkstream: Array.from(wsMap.values()).map((ws) => ({
      ...ws,
      tasks: Array.from(ws.tasks.values()),
    })),
    byMember: Array.from(memberMap.values()),
    totalMinutes,
    billableMinutes,
  };
}
```

- [ ] **Step 2: Add deal name to getTaskDetail**

In `src/actions/tasks.ts`, in the `getTaskDetail` function, add `name: true` to the deal select. Find this block (around line 210-220):

```ts
      workstream: {
        select: {
          dealId: true,
          deal: {
            select: {
              members: {
                include: { user: { select: { id: true, name: true } } },
              },
            },
          },
        },
      },
```

Change it to:

```ts
      workstream: {
        select: {
          dealId: true,
          deal: {
            select: {
              name: true,
              members: {
                include: { user: { select: { id: true, name: true } } },
              },
            },
          },
        },
      },
```

- [ ] **Step 3: Verify build**

Run:
```bash
npx tsc --noEmit
```

Expected: No type errors.

- [ ] **Step 4: Commit**

```bash
git add src/actions/time-entries.ts src/actions/tasks.ts
git commit -m "feat: add time entry server actions (start/stop timer, manual entry, CRUD, deal summary)"
```

---

### Task 4: Zustand Timer Store

**Files:**
- Create: `src/hooks/use-timer.ts`

- [ ] **Step 1: Create timer store with localStorage persistence**

Create `src/hooks/use-timer.ts`:

```ts
"use client";

import { create } from "zustand";
import { persist } from "zustand/middleware";

interface TimerState {
  activeEntryId: string | null;
  taskId: string | null;
  taskTitle: string;
  dealName: string;
  startedAt: number | null; // timestamp ms
  start: (entryId: string, taskId: string, taskTitle: string, dealName: string) => void;
  stop: () => void;
}

export const useTimer = create<TimerState>()(
  persist(
    (set) => ({
      activeEntryId: null,
      taskId: null,
      taskTitle: "",
      dealName: "",
      startedAt: null,
      start: (entryId, taskId, taskTitle, dealName) =>
        set({
          activeEntryId: entryId,
          taskId,
          taskTitle,
          dealName,
          startedAt: Date.now(),
        }),
      stop: () =>
        set({
          activeEntryId: null,
          taskId: null,
          taskTitle: "",
          dealName: "",
          startedAt: null,
        }),
    }),
    {
      name: "dealflow-timer",
    }
  )
);
```

- [ ] **Step 2: Verify build**

Run:
```bash
npx tsc --noEmit
```

Expected: No type errors.

- [ ] **Step 3: Commit**

```bash
git add src/hooks/use-timer.ts
git commit -m "feat: add Zustand timer store with localStorage persistence"
```

---

## Chunk 2: Timer & Time Entry UI

### Task 5: Timer Button + Timer Bar + Integration

**Files:**
- Create: `src/components/timer/timer-button.tsx`
- Create: `src/components/timer/timer-bar.tsx`
- Modify: `src/components/layout/app-shell.tsx`
- Modify: `src/components/tasks/task-row.tsx`

- [ ] **Step 1: Create timer button component**

Create `src/components/timer/timer-button.tsx`:

```tsx
"use client";

import { useTransition } from "react";
import { useTranslations } from "next-intl";
import { Play, Square } from "lucide-react";
import { cn } from "@/lib/utils";
import { useTimer } from "@/hooks/use-timer";
import { startTimer, stopTimer } from "@/actions/time-entries";

interface TimerButtonProps {
  taskId: string;
  size?: "sm" | "md";
  className?: string;
}

export function TimerButton({ taskId, size = "sm", className }: TimerButtonProps) {
  const t = useTranslations("timer");
  const [isPending, startTransition] = useTransition();
  const activeEntryId = useTimer((s) => s.activeEntryId);
  const activeTaskId = useTimer((s) => s.taskId);
  const start = useTimer((s) => s.start);
  const stop = useTimer((s) => s.stop);

  const isRunningOnThisTask = activeTaskId === taskId;
  const isRunningOnOther = activeEntryId !== null && !isRunningOnThisTask;

  function handleClick(e: React.MouseEvent) {
    e.stopPropagation();

    if (isRunningOnThisTask) {
      // Stop timer
      startTransition(async () => {
        await stopTimer(activeEntryId!);
        stop();
      });
      return;
    }

    if (isRunningOnOther) {
      if (!confirm(t("switchTimer"))) return;
      // Stop current, then start new
      startTransition(async () => {
        await stopTimer(activeEntryId!);
        stop();
        const result = await startTimer(taskId);
        start(result.entryId, result.taskId, result.taskTitle, result.dealName);
      });
      return;
    }

    // Start new timer
    startTransition(async () => {
      const result = await startTimer(taskId);
      start(result.entryId, result.taskId, result.taskTitle, result.dealName);
    });
  }

  const iconSize = size === "sm" ? "size-3" : "size-3.5";

  return (
    <button
      type="button"
      onClick={handleClick}
      disabled={isPending}
      title={isRunningOnThisTask ? t("stopTimer") : t("startTimer")}
      className={cn(
        "flex items-center justify-center rounded transition-colors disabled:opacity-50",
        size === "sm" ? "size-5" : "size-7",
        isRunningOnThisTask
          ? "text-red-500 hover:bg-red-50"
          : "text-muted-foreground hover:text-emerald-600 hover:bg-emerald-50",
        className
      )}
    >
      {isRunningOnThisTask ? (
        <Square className={cn(iconSize, "fill-current")} />
      ) : (
        <Play className={cn(iconSize, "fill-current")} />
      )}
    </button>
  );
}
```

- [ ] **Step 2: Create timer floating bar component**

Create `src/components/timer/timer-bar.tsx`:

```tsx
"use client";

import { useEffect, useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Square, Clock } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useTimer } from "@/hooks/use-timer";
import { stopTimer } from "@/actions/time-entries";

function formatElapsed(ms: number): string {
  const totalSeconds = Math.floor(ms / 1000);
  const h = Math.floor(totalSeconds / 3600);
  const m = Math.floor((totalSeconds % 3600) / 60);
  const s = totalSeconds % 60;
  return `${String(h).padStart(2, "0")}:${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`;
}

export function TimerBar() {
  const t = useTranslations("timer");
  const activeEntryId = useTimer((s) => s.activeEntryId);
  const taskTitle = useTimer((s) => s.taskTitle);
  const dealName = useTimer((s) => s.dealName);
  const startedAt = useTimer((s) => s.startedAt);
  const stop = useTimer((s) => s.stop);

  const [elapsed, setElapsed] = useState(0);
  const [showDescription, setShowDescription] = useState(false);
  const [description, setDescription] = useState("");
  const [isPending, startTransition] = useTransition();

  useEffect(() => {
    if (!startedAt) {
      setElapsed(0);
      return;
    }
    setElapsed(Date.now() - startedAt);
    const interval = setInterval(() => {
      setElapsed(Date.now() - startedAt);
    }, 1000);
    return () => clearInterval(interval);
  }, [startedAt]);

  if (!activeEntryId) return null;

  function handleStop() {
    setShowDescription(true);
  }

  function handleSave() {
    startTransition(async () => {
      await stopTimer(activeEntryId!, description.trim() || undefined);
      stop();
      setShowDescription(false);
      setDescription("");
    });
  }

  function handleSaveWithoutDescription() {
    startTransition(async () => {
      await stopTimer(activeEntryId!);
      stop();
      setShowDescription(false);
      setDescription("");
    });
  }

  return (
    <div className="fixed bottom-0 left-0 right-0 z-50 border-t bg-background shadow-lg">
      <div className="mx-auto flex max-w-7xl items-center gap-3 px-4 py-2 sm:px-6">
        <Clock className="size-4 text-emerald-600 animate-pulse" />

        <div className="flex items-center gap-2 text-sm">
          <span className="font-medium truncate max-w-[200px]">{taskTitle}</span>
          <span className="text-muted-foreground">—</span>
          <span className="text-muted-foreground truncate max-w-[150px]">{dealName}</span>
        </div>

        <div className="ml-auto flex items-center gap-3">
          <span className="font-mono text-sm font-medium tabular-nums">
            {formatElapsed(elapsed)}
          </span>

          {showDescription ? (
            <div className="flex items-center gap-2">
              <Input
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder={t("description")}
                className="h-7 w-48 text-sm"
                autoFocus
                onKeyDown={(e) => {
                  if (e.key === "Enter") handleSave();
                  if (e.key === "Escape") handleSaveWithoutDescription();
                }}
              />
              <Button size="xs" onClick={handleSave} disabled={isPending}>
                {t("stopTimer")}
              </Button>
            </div>
          ) : (
            <Button
              size="sm"
              variant="destructive"
              onClick={handleStop}
              disabled={isPending}
            >
              <Square className="size-3 fill-current" />
              {t("stopTimer")}
            </Button>
          )}
        </div>
      </div>
    </div>
  );
}
```

- [ ] **Step 3: Add TimerBar to app shell**

In `src/components/layout/app-shell.tsx`, add the timer bar import and render it. This is a server component, so we need a client wrapper.

First, add the import at the top:

```ts
import { TimerBar } from "@/components/timer/timer-bar";
```

Then, add `<TimerBar />` right before the closing `</div>` of the root div (after `<main>{children}</main>`):

Change:
```tsx
      <main>{children}</main>
    </div>
```

To:
```tsx
      <main>{children}</main>
      <TimerBar />
    </div>
```

- [ ] **Step 4: Add timer button to task row**

In `src/components/tasks/task-row.tsx`, add the timer button that appears on hover.

Add import at the top:
```ts
import { TimerButton } from "@/components/timer/timer-button";
```

Add the timer button between the checkbox and the title. Find the `{/* Title — clickable to open panel */}` comment and add the timer button before it:

Change:
```tsx
      {/* Title — clickable to open panel */}
      <button
```

To:
```tsx
      {/* Timer button - appears on hover */}
      <span className="hidden group-hover/row:inline-flex shrink-0">
        <TimerButton taskId={task.id} size="sm" />
      </span>

      {/* Title — clickable to open panel */}
      <button
```

Also add `group/row` to the outer div's className. Change:
```tsx
    <div
      className={cn(
        "flex items-center gap-3 rounded-md px-2 py-1.5 hover:bg-muted/50",
        isPending && "opacity-50"
      )}
    >
```

To:
```tsx
    <div
      className={cn(
        "group/row flex items-center gap-3 rounded-md px-2 py-1.5 hover:bg-muted/50",
        isPending && "opacity-50"
      )}
    >
```

- [ ] **Step 5: Verify build and test visually**

Run:
```bash
npx tsc --noEmit && npm run dev
```

Expected: No type errors. Visit a deal page, hover over a task row to see the timer button. Click it to start a timer — the floating bar should appear at the bottom. Click stop to stop it.

- [ ] **Step 6: Commit**

```bash
git add src/components/timer/ src/components/layout/app-shell.tsx src/components/tasks/task-row.tsx
git commit -m "feat: add live timer with floating bar and task row timer button"
```

---

### Task 6: Time Entry List + Manual Form + Task Panel Integration

**Files:**
- Create: `src/components/time/time-entry-list.tsx`
- Create: `src/components/time/manual-time-form.tsx`
- Modify: `src/components/tasks/task-panel.tsx`

- [ ] **Step 1: Create time entry list component**

Create `src/components/time/time-entry-list.tsx`:

```tsx
"use client";

import { useTransition } from "react";
import { useLocale, useTranslations } from "next-intl";
import { Trash2, Clock } from "lucide-react";
import { cn } from "@/lib/utils";
import { deleteTimeEntry } from "@/actions/time-entries";

interface TimeEntryData {
  id: string;
  description: string | null;
  startedAt: Date | null;
  durationMinutes: number;
  isManual: boolean;
  isBillable: boolean;
  user: { id: string; name: string };
}

interface TimeEntryListProps {
  entries: TimeEntryData[];
  onRefresh: () => void;
}

function formatDuration(minutes: number): string {
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  if (h === 0) return `${m}m`;
  if (m === 0) return `${h}h`;
  return `${h}h ${m}m`;
}

export function TimeEntryList({ entries, onRefresh }: TimeEntryListProps) {
  const locale = useLocale();
  const t = useTranslations("timer");
  const [isPending, startTransition] = useTransition();

  const totalMinutes = entries.reduce((sum, e) => sum + e.durationMinutes, 0);

  if (entries.length === 0) {
    return (
      <p className="text-xs text-muted-foreground">{t("noEntries")}</p>
    );
  }

  function handleDelete(entryId: string) {
    if (!confirm(t("deleteConfirm"))) return;
    startTransition(async () => {
      await deleteTimeEntry(entryId);
      onRefresh();
    });
  }

  return (
    <div className="flex flex-col gap-1">
      <div className="flex items-center justify-between text-xs text-muted-foreground mb-1">
        <span>{t("timeEntries")}</span>
        <span>{t("totalTime")}: {formatDuration(totalMinutes)}</span>
      </div>

      {entries.map((entry) => (
        <div
          key={entry.id}
          className={cn(
            "flex items-center gap-2 rounded px-2 py-1 text-xs group/entry hover:bg-muted/50",
            isPending && "opacity-50"
          )}
        >
          <span className="text-muted-foreground w-16 shrink-0">
            {entry.startedAt
              ? new Intl.DateTimeFormat(locale, {
                  month: "short",
                  day: "numeric",
                }).format(new Date(entry.startedAt))
              : "—"}
          </span>

          <span className="shrink-0 text-muted-foreground truncate max-w-[80px]">
            {entry.user.name}
          </span>

          <span className="shrink-0 font-medium w-12 text-right">
            {formatDuration(entry.durationMinutes)}
          </span>

          <span className="flex-1 truncate text-muted-foreground">
            {entry.description || ""}
          </span>

          {entry.isManual && (
            <Clock className="size-3 text-muted-foreground shrink-0" title={t("manual")} />
          )}

          <button
            type="button"
            onClick={() => handleDelete(entry.id)}
            disabled={isPending}
            className="hidden group-hover/entry:inline-flex shrink-0 text-muted-foreground hover:text-red-500"
          >
            <Trash2 className="size-3" />
          </button>
        </div>
      ))}
    </div>
  );
}
```

- [ ] **Step 2: Create manual time form component**

Create `src/components/time/manual-time-form.tsx`:

```tsx
"use client";

import { useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Plus } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { logManualTime } from "@/actions/time-entries";

interface ManualTimeFormProps {
  taskId: string;
  onDone: () => void;
}

export function ManualTimeForm({ taskId, onDone }: ManualTimeFormProps) {
  const t = useTranslations("timer");
  const tCommon = useTranslations("common");
  const [open, setOpen] = useState(false);
  const [hours, setHours] = useState("");
  const [date, setDate] = useState(new Date().toISOString().split("T")[0]);
  const [description, setDescription] = useState("");
  const [isPending, startTransition] = useTransition();

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const h = parseFloat(hours);
    if (isNaN(h) || h <= 0) return;

    startTransition(async () => {
      await logManualTime(taskId, {
        durationHours: h,
        date,
        description: description.trim() || undefined,
      });
      setHours("");
      setDescription("");
      setOpen(false);
      onDone();
    });
  }

  if (!open) {
    return (
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="flex items-center gap-1.5 text-xs text-muted-foreground hover:text-foreground"
      >
        <Plus className="size-3" />
        {t("logTime")}
      </button>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-2 rounded border p-2">
      <div className="flex items-center gap-2">
        <Input
          type="number"
          step="0.25"
          min="0.25"
          value={hours}
          onChange={(e) => setHours(e.target.value)}
          placeholder={t("hours")}
          className="h-7 w-20 text-sm"
          autoFocus
          required
        />
        <Input
          type="date"
          value={date}
          onChange={(e) => setDate(e.target.value)}
          className="h-7 text-sm"
        />
      </div>
      <Input
        value={description}
        onChange={(e) => setDescription(e.target.value)}
        placeholder={t("description")}
        className="h-7 text-sm"
      />
      <div className="flex items-center gap-2">
        <Button type="submit" size="xs" disabled={isPending}>
          {t("logTime")}
        </Button>
        <Button
          type="button"
          variant="ghost"
          size="xs"
          onClick={() => setOpen(false)}
        >
          {tCommon("cancel")}
        </Button>
      </div>
    </form>
  );
}
```

- [ ] **Step 3: Add time section to task panel**

In `src/components/tasks/task-panel.tsx`, add imports at the top:

```ts
import { TimerButton } from "@/components/timer/timer-button";
import { TimeEntryList } from "@/components/time/time-entry-list";
import { ManualTimeForm } from "@/components/time/manual-time-form";
import { getTaskTimeEntries } from "@/actions/time-entries";
```

Add a `timeEntries` state variable after the existing state declarations (around line 57):

```ts
  const [timeEntries, setTimeEntries] = useState<Awaited<ReturnType<typeof getTaskTimeEntries>>>([]);
```

Add a `loadTimeEntries` function and call it in `loadTask`. Inside the existing `loadTask` callback, after `setDueDate(...)` (around line 72), add:

```ts
      // Load time entries
      const entries = await getTaskTimeEntries(id);
      setTimeEntries(entries);
```

Add the time section in the JSX, between the `{/* Dependencies */}` section and `{/* Comments */}` section. Find:

```tsx
            {/* Comments */}
            <TaskComments
```

And add before it:

```tsx
            {/* Time Entries */}
            <div>
              <Label className="mb-1.5 text-xs text-muted-foreground">
                {useTranslations("timer")("timeEntries")}
              </Label>
              <TimeEntryList
                entries={timeEntries}
                onRefresh={() => taskId && loadTask(taskId)}
              />
              <div className="mt-2 flex items-center gap-2">
                <ManualTimeForm
                  taskId={task.id}
                  onDone={() => taskId && loadTask(taskId)}
                />
                <TimerButton taskId={task.id} size="md" />
              </div>
            </div>

```

Note: Since `useTranslations` cannot be called inside event handlers or conditionally, get the timer translations at the top of the component. Add after the existing `const tCommon = useTranslations("common");`:

```ts
  const tTimer = useTranslations("timer");
```

Then replace the inline `useTranslations("timer")("timeEntries")` with `tTimer("timeEntries")`.

- [ ] **Step 4: Verify build and test visually**

Run:
```bash
npx tsc --noEmit && npm run dev
```

Expected: No type errors. Open a task panel — the "Time" section appears with empty state, manual form button, and timer button.

- [ ] **Step 5: Commit**

```bash
git add src/components/time/ src/components/tasks/task-panel.tsx
git commit -m "feat: add time entry list and manual time form in task panel"
```

---

## Chunk 3: Summary, Billing & Navigation

### Task 7: Deal Time Summary Page

**Files:**
- Create: `src/components/time/deal-time-summary.tsx`
- Create: `src/app/[locale]/deals/[dealId]/time/page.tsx`
- Modify: `src/app/[locale]/deals/[dealId]/page.tsx` (add time link)

- [ ] **Step 1: Create deal time summary component**

Create `src/components/time/deal-time-summary.tsx`:

```tsx
"use client";

import { useTranslations } from "next-intl";

function formatHours(minutes: number): string {
  return (minutes / 60).toFixed(1) + "h";
}

interface WorkstreamSummary {
  id: string;
  name: string;
  totalMinutes: number;
  billableMinutes: number;
  tasks: {
    id: string;
    title: string;
    totalMinutes: number;
    billableMinutes: number;
  }[];
}

interface MemberSummary {
  userId: string;
  userName: string;
  totalMinutes: number;
  billableMinutes: number;
}

interface DealTimeSummaryProps {
  dealName: string;
  summary: {
    byWorkstream: WorkstreamSummary[];
    byMember: MemberSummary[];
    totalMinutes: number;
    billableMinutes: number;
  };
}

export function DealTimeSummary({ dealName, summary }: DealTimeSummaryProps) {
  const tBilling = useTranslations("billing");
  const tTimer = useTranslations("timer");

  return (
    <div className="flex flex-col gap-6">
      <h1 className="text-lg font-semibold">
        {dealName} — {tTimer("timeEntries")}
      </h1>

      {/* By Workstream */}
      <div className="rounded-lg border">
        <div className="flex items-center justify-between border-b px-4 py-2.5 text-sm font-medium">
          <span>{tBilling("byWorkstream")}</span>
          <div className="flex gap-6 text-muted-foreground">
            <span>{tBilling("totalHours")}</span>
            <span>{tBilling("billable")}</span>
          </div>
        </div>

        {summary.byWorkstream.map((ws) => (
          <div key={ws.id} className="border-b last:border-b-0">
            <div className="flex items-center justify-between px-4 py-2 bg-muted/30">
              <span className="text-sm font-medium">{ws.name}</span>
              <div className="flex gap-6 text-sm">
                <span className="w-16 text-right">{formatHours(ws.totalMinutes)}</span>
                <span className="w-16 text-right">{formatHours(ws.billableMinutes)}</span>
              </div>
            </div>

            {ws.tasks.map((task) => (
              <div key={task.id} className="flex items-center justify-between px-4 py-1.5 pl-8">
                <span className="text-sm text-muted-foreground">{task.title}</span>
                <div className="flex gap-6 text-sm text-muted-foreground">
                  <span className="w-16 text-right">{formatHours(task.totalMinutes)}</span>
                  <span className="w-16 text-right">{formatHours(task.billableMinutes)}</span>
                </div>
              </div>
            ))}
          </div>
        ))}

        {summary.byWorkstream.length === 0 && (
          <div className="px-4 py-3 text-sm text-muted-foreground">
            {tTimer("noEntries")}
          </div>
        )}
      </div>

      {/* By Member */}
      <div className="rounded-lg border">
        <div className="flex items-center justify-between border-b px-4 py-2.5 text-sm font-medium">
          <span>{tBilling("byMember")}</span>
          <div className="flex gap-6 text-muted-foreground">
            <span>{tBilling("totalHours")}</span>
            <span>{tBilling("billable")}</span>
          </div>
        </div>

        {summary.byMember.map((m) => (
          <div key={m.userId} className="flex items-center justify-between border-b last:border-b-0 px-4 py-2">
            <span className="text-sm">{m.userName}</span>
            <div className="flex gap-6 text-sm">
              <span className="w-16 text-right">{formatHours(m.totalMinutes)}</span>
              <span className="w-16 text-right">{formatHours(m.billableMinutes)}</span>
            </div>
          </div>
        ))}
      </div>

      {/* Total */}
      <div className="flex items-center justify-between rounded-lg border bg-muted/30 px-4 py-3 text-sm font-medium">
        <span>{tTimer("totalTime")}</span>
        <div className="flex gap-6">
          <span className="w-16 text-right">{formatHours(summary.totalMinutes)}</span>
          <span className="w-16 text-right">{formatHours(summary.billableMinutes)}</span>
        </div>
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Create deal time summary page**

Create `src/app/[locale]/deals/[dealId]/time/page.tsx`:

```tsx
import { auth } from "@/lib/auth";
import { redirect, notFound } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { getLocale } from "next-intl/server";
import { getDealTimeSummary } from "@/actions/time-entries";
import { DealTimeSummary } from "@/components/time/deal-time-summary";
import Link from "next/link";

export default async function DealTimePage({
  params,
}: {
  params: Promise<{ dealId: string }>;
}) {
  const { dealId } = await params;
  const session = await auth();
  const locale = await getLocale();

  if (!session?.user?.id) {
    redirect(`/${locale}/login`);
  }

  const isMember = await prisma.dealMember.findUnique({
    where: { dealId_userId: { dealId, userId: session.user.id } },
  });
  if (!isMember) notFound();

  const deal = await prisma.deal.findUnique({
    where: { id: dealId },
    select: { name: true },
  });
  if (!deal) notFound();

  const summary = await getDealTimeSummary(dealId);

  return (
    <div className="mx-auto max-w-5xl px-4 py-6 sm:px-6">
      <div className="mb-4">
        <Link
          href={`/${locale}/deals/${dealId}`}
          className="text-sm text-muted-foreground hover:text-foreground"
        >
          &larr; {deal.name}
        </Link>
      </div>

      <DealTimeSummary dealName={deal.name} summary={summary} />
    </div>
  );
}
```

- [ ] **Step 3: Add time link to deal detail page**

In `src/app/[locale]/deals/[dealId]/page.tsx`, add a time link to the bottom links area.

First, add the translations import. After the existing `const tCalendar = await getTranslations("calendar");` line, add:

```ts
  const tTimer = await getTranslations("timer");
```

Then add the time link after the calendar link. Find:

```tsx
        <Link
          href={`/${locale}/deals/${dealId}/calendar`}
          className="rounded-md border px-4 py-2 text-sm font-medium transition-colors hover:bg-muted"
        >
          {tCalendar("calendar")}
        </Link>
```

And add after it:

```tsx
        <Link
          href={`/${locale}/deals/${dealId}/time`}
          className="rounded-md border px-4 py-2 text-sm font-medium transition-colors hover:bg-muted"
        >
          {tTimer("timeEntries")}
        </Link>
```

- [ ] **Step 4: Verify build and test**

Run:
```bash
npx tsc --noEmit && npm run dev
```

Expected: No errors. Visit a deal page, see the "Time" link at the bottom. Click it to see the time summary page.

- [ ] **Step 5: Commit**

```bash
git add src/components/time/deal-time-summary.tsx src/app/[locale]/deals/[dealId]/time/ src/app/[locale]/deals/[dealId]/page.tsx
git commit -m "feat: add deal time summary page with workstream and member breakdowns"
```

---

### Task 8: Billing Server Actions + Excel Export

**Files:**
- Create: `src/actions/billing.ts`
- Modify: `package.json` (add exceljs)

- [ ] **Step 1: Install exceljs**

Run:
```bash
npm install exceljs
```

- [ ] **Step 2: Create billing server actions**

Create `src/actions/billing.ts`:

```ts
"use server";

import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { logAudit } from "@/lib/audit";
import { revalidatePath } from "next/cache";
import { getLocale } from "next-intl/server";
import ExcelJS from "exceljs";

// ---------- helpers ----------

function assertAdmin(session: { user?: { role?: string } | null } | null) {
  const role = (session?.user as unknown as { role: string } | undefined)?.role;
  if (role !== "Admin") throw new Error("Forbidden: Admin only");
}

// ---------- getFilteredTimeEntries ----------

export async function getFilteredTimeEntries(filters: {
  dealId?: string;
  userId?: string;
  startDate?: string;
  endDate?: string;
  billableOnly?: boolean;
}) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");
  assertAdmin(session);

  const where: Record<string, unknown> = {};

  if (filters.dealId) where.dealId = filters.dealId;
  if (filters.userId) where.userId = filters.userId;
  if (filters.billableOnly) where.isBillable = true;

  if (filters.startDate || filters.endDate) {
    const dateFilter: Record<string, Date> = {};
    if (filters.startDate) dateFilter.gte = new Date(filters.startDate);
    if (filters.endDate) {
      const end = new Date(filters.endDate);
      end.setHours(23, 59, 59, 999);
      dateFilter.lte = end;
    }
    where.createdAt = dateFilter;
  }

  const entries = await prisma.timeEntry.findMany({
    where,
    orderBy: { createdAt: "desc" },
    select: {
      id: true,
      description: true,
      startedAt: true,
      stoppedAt: true,
      durationMinutes: true,
      isManual: true,
      isBillable: true,
      createdAt: true,
      task: {
        select: {
          id: true,
          title: true,
          workstream: { select: { name: true } },
        },
      },
      user: { select: { id: true, name: true } },
      deal: { select: { id: true, name: true } },
    },
  });

  return entries;
}

// ---------- setBillingRate ----------

export async function setBillingRate(
  dealId: string,
  userId: string,
  ratePerHour: number
) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");
  assertAdmin(session);

  await prisma.dealBillingRate.upsert({
    where: { dealId_userId: { dealId, userId } },
    update: { ratePerHour },
    create: { dealId, userId, ratePerHour },
  });

  await logAudit(session.user.id, "set_billing_rate", "DealBillingRate", `${dealId}-${userId}`, {
    ratePerHour: { from: null, to: ratePerHour },
  });

  const locale = await getLocale();
  revalidatePath(`/${locale}/admin/billing`);
}

// ---------- getDealBillingRates ----------

export async function getDealBillingRates(dealId?: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");
  assertAdmin(session);

  const where = dealId ? { dealId } : {};

  const rates = await prisma.dealBillingRate.findMany({
    where,
    select: {
      id: true,
      ratePerHour: true,
      currency: true,
      deal: { select: { id: true, name: true } },
      user: { select: { id: true, name: true } },
    },
  });

  return rates.map((r) => ({
    ...r,
    ratePerHour: Number(r.ratePerHour),
  }));
}

// ---------- getAdminFilterOptions ----------

export async function getAdminFilterOptions() {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");
  assertAdmin(session);

  const deals = await prisma.deal.findMany({
    orderBy: { name: "asc" },
    select: { id: true, name: true },
  });

  const users = await prisma.user.findMany({
    orderBy: { name: "asc" },
    select: { id: true, name: true },
  });

  return { deals, users };
}

// ---------- exportBillingExcel ----------

export async function exportBillingExcel(filters: {
  dealId?: string;
  userId?: string;
  startDate?: string;
  endDate?: string;
  billableOnly?: boolean;
}): Promise<string> {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");
  assertAdmin(session);

  const entries = await getFilteredTimeEntries(filters);
  const rates = await getDealBillingRates(filters.dealId);

  // Build rate lookup: dealId-userId → ratePerHour
  const rateMap = new Map<string, number>();
  for (const r of rates) {
    rateMap.set(`${r.deal.id}-${r.user.id}`, r.ratePerHour);
  }

  const workbook = new ExcelJS.Workbook();

  // Sheet 1: Time Entries
  const ws1 = workbook.addWorksheet("Time Entries");
  ws1.columns = [
    { header: "Date", key: "date", width: 12 },
    { header: "Person", key: "person", width: 15 },
    { header: "Deal", key: "deal", width: 20 },
    { header: "Workstream", key: "workstream", width: 20 },
    { header: "Task", key: "task", width: 25 },
    { header: "Description", key: "description", width: 30 },
    { header: "Hours", key: "hours", width: 10 },
    { header: "Billable", key: "billable", width: 10 },
    { header: "Rate", key: "rate", width: 12 },
    { header: "Amount", key: "amount", width: 12 },
  ];

  for (const e of entries) {
    const hours = e.durationMinutes / 60;
    const rate = rateMap.get(`${e.deal.id}-${e.user.id}`) ?? 0;
    const amount = e.isBillable ? hours * rate : 0;

    ws1.addRow({
      date: e.startedAt ? new Date(e.startedAt).toLocaleDateString() : "",
      person: e.user.name,
      deal: e.deal.name,
      workstream: e.task.workstream.name,
      task: e.task.title,
      description: e.description || "",
      hours: parseFloat(hours.toFixed(2)),
      billable: e.isBillable ? "Yes" : "No",
      rate,
      amount: parseFloat(amount.toFixed(2)),
    });
  }

  // Sheet 2: Summary by Deal
  const ws2 = workbook.addWorksheet("By Deal");
  ws2.columns = [
    { header: "Deal", key: "deal", width: 20 },
    { header: "Person", key: "person", width: 15 },
    { header: "Total Hours", key: "totalHours", width: 12 },
    { header: "Billable Hours", key: "billableHours", width: 14 },
    { header: "Rate", key: "rate", width: 12 },
    { header: "Amount", key: "amount", width: 12 },
  ];

  // Group entries by deal+person
  const dealPersonMap = new Map<string, {
    deal: string;
    person: string;
    totalMinutes: number;
    billableMinutes: number;
    rate: number;
  }>();

  for (const e of entries) {
    const key = `${e.deal.id}-${e.user.id}`;
    if (!dealPersonMap.has(key)) {
      dealPersonMap.set(key, {
        deal: e.deal.name,
        person: e.user.name,
        totalMinutes: 0,
        billableMinutes: 0,
        rate: rateMap.get(key) ?? 0,
      });
    }
    const dp = dealPersonMap.get(key)!;
    dp.totalMinutes += e.durationMinutes;
    if (e.isBillable) dp.billableMinutes += e.durationMinutes;
  }

  for (const dp of dealPersonMap.values()) {
    const totalHours = dp.totalMinutes / 60;
    const billableHours = dp.billableMinutes / 60;
    ws2.addRow({
      deal: dp.deal,
      person: dp.person,
      totalHours: parseFloat(totalHours.toFixed(2)),
      billableHours: parseFloat(billableHours.toFixed(2)),
      rate: dp.rate,
      amount: parseFloat((billableHours * dp.rate).toFixed(2)),
    });
  }

  // Sheet 3: Summary by Person
  const ws3 = workbook.addWorksheet("By Person");
  ws3.columns = [
    { header: "Person", key: "person", width: 15 },
    { header: "Total Hours", key: "totalHours", width: 12 },
    { header: "Billable Hours", key: "billableHours", width: 14 },
    { header: "Amount", key: "amount", width: 12 },
  ];

  const personMap = new Map<string, {
    person: string;
    totalMinutes: number;
    billableMinutes: number;
    totalAmount: number;
  }>();

  for (const e of entries) {
    if (!personMap.has(e.user.id)) {
      personMap.set(e.user.id, {
        person: e.user.name,
        totalMinutes: 0,
        billableMinutes: 0,
        totalAmount: 0,
      });
    }
    const p = personMap.get(e.user.id)!;
    p.totalMinutes += e.durationMinutes;
    if (e.isBillable) {
      p.billableMinutes += e.durationMinutes;
      const rate = rateMap.get(`${e.deal.id}-${e.user.id}`) ?? 0;
      p.totalAmount += (e.durationMinutes / 60) * rate;
    }
  }

  for (const p of personMap.values()) {
    ws3.addRow({
      person: p.person,
      totalHours: parseFloat((p.totalMinutes / 60).toFixed(2)),
      billableHours: parseFloat((p.billableMinutes / 60).toFixed(2)),
      amount: parseFloat(p.totalAmount.toFixed(2)),
    });
  }

  // Style header rows
  for (const ws of [ws1, ws2, ws3]) {
    ws.getRow(1).font = { bold: true };
  }

  // Generate buffer and return as base64
  const buffer = await workbook.xlsx.writeBuffer();
  return Buffer.from(buffer).toString("base64");
}
```

- [ ] **Step 3: Verify build**

Run:
```bash
npx tsc --noEmit
```

Expected: No type errors.

- [ ] **Step 4: Commit**

```bash
git add src/actions/billing.ts package.json package-lock.json
git commit -m "feat: add billing server actions with rate management and Excel export"
```

---

### Task 9: Admin Billing Components

**Files:**
- Create: `src/components/billing/billing-filters.tsx`
- Create: `src/components/billing/billing-rate-editor.tsx`
- Create: `src/components/billing/billing-table.tsx`
- Create: `src/components/billing/billing-summary.tsx`

- [ ] **Step 1: Create shared types file**

These four components share types. Define them in `billing-filters.tsx` and re-export. All components use the same `EntryData` and option types.

Create `src/components/billing/billing-filters.tsx`:

```tsx
"use client";

import { useTranslations } from "next-intl";
import { Download } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
} from "@/components/ui/select";

export interface DealOption {
  id: string;
  name: string;
}

export interface UserOption {
  id: string;
  name: string;
}

interface BillingFiltersProps {
  deals: DealOption[];
  users: UserOption[];
  dealId: string;
  userId: string;
  startDate: string;
  endDate: string;
  billableOnly: boolean;
  isPending: boolean;
  onDealChange: (v: string) => void;
  onUserChange: (v: string) => void;
  onStartDateChange: (v: string) => void;
  onEndDateChange: (v: string) => void;
  onBillableOnlyChange: (v: boolean) => void;
  onFilter: () => void;
  onExport: () => void;
}

export function BillingFilters({
  deals,
  users,
  dealId,
  userId,
  startDate,
  endDate,
  billableOnly,
  isPending,
  onDealChange,
  onUserChange,
  onStartDateChange,
  onEndDateChange,
  onBillableOnlyChange,
  onFilter,
  onExport,
}: BillingFiltersProps) {
  const tBilling = useTranslations("billing");
  const tCommon = useTranslations("common");

  return (
    <div className="flex flex-wrap items-end gap-3 rounded-lg border p-3">
      <div>
        <label className="text-xs text-muted-foreground">{tBilling("deal")}</label>
        <Select value={dealId} onValueChange={onDealChange}>
          <SelectTrigger className="w-40 h-8 text-sm">
            <span className="truncate">
              {dealId ? deals.find((d) => d.id === dealId)?.name : tBilling("allDeals")}
            </span>
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="">{tBilling("allDeals")}</SelectItem>
            {deals.map((d) => (
              <SelectItem key={d.id} value={d.id}>{d.name}</SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <div>
        <label className="text-xs text-muted-foreground">{tBilling("member")}</label>
        <Select value={userId} onValueChange={onUserChange}>
          <SelectTrigger className="w-36 h-8 text-sm">
            <span className="truncate">
              {userId ? users.find((u) => u.id === userId)?.name : tBilling("allMembers")}
            </span>
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="">{tBilling("allMembers")}</SelectItem>
            {users.map((u) => (
              <SelectItem key={u.id} value={u.id}>{u.name}</SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <div>
        <label className="text-xs text-muted-foreground">{tBilling("dateRange")}</label>
        <div className="flex gap-1">
          <Input type="date" value={startDate} onChange={(e) => onStartDateChange(e.target.value)} className="h-8 w-32 text-sm" />
          <Input type="date" value={endDate} onChange={(e) => onEndDateChange(e.target.value)} className="h-8 w-32 text-sm" />
        </div>
      </div>

      <label className="flex items-center gap-1.5 text-sm">
        <input type="checkbox" checked={billableOnly} onChange={(e) => onBillableOnlyChange(e.target.checked)} />
        {tBilling("billableOnly")}
      </label>

      <Button size="sm" onClick={onFilter} disabled={isPending}>{tCommon("filter")}</Button>

      <Button size="sm" variant="outline" onClick={onExport} disabled={isPending}>
        <Download className="size-3.5" />
        {tBilling("exportExcel")}
      </Button>
    </div>
  );
}
```

- [ ] **Step 2: Create rate editor component**

Create `src/components/billing/billing-rate-editor.tsx`:

```tsx
"use client";

import { useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
} from "@/components/ui/select";
import { setBillingRate, getDealBillingRates } from "@/actions/billing";
import type { DealOption, UserOption } from "./billing-filters";

export interface RateData {
  id: string;
  ratePerHour: number;
  currency: string;
  deal: { id: string; name: string };
  user: { id: string; name: string };
}

interface BillingRateEditorProps {
  deals: DealOption[];
  users: UserOption[];
  rates: RateData[];
  onRatesChange: (rates: RateData[]) => void;
}

export function BillingRateEditor({ deals, users, rates, onRatesChange }: BillingRateEditorProps) {
  const tBilling = useTranslations("billing");
  const tCommon = useTranslations("common");
  const [isPending, startTransition] = useTransition();

  const [editingRate, setEditingRate] = useState<{ dealId: string; userId: string; value: string } | null>(null);
  const [newDealId, setNewDealId] = useState("");
  const [newUserId, setNewUserId] = useState("");
  const [newValue, setNewValue] = useState("3000");

  function handleSaveRate(dealId: string, userId: string, value: string) {
    const rate = parseFloat(value);
    if (isNaN(rate) || rate < 0) return;

    startTransition(async () => {
      await setBillingRate(dealId, userId, rate);
      const updated = await getDealBillingRates();
      onRatesChange(updated);
      setEditingRate(null);
    });
  }

  function handleAddRate() {
    if (!newDealId || !newUserId) return;
    handleSaveRate(newDealId, newUserId, newValue);
    setNewDealId("");
    setNewUserId("");
    setNewValue("3000");
  }

  return (
    <div className="rounded-lg border p-3">
      <span className="text-sm font-medium">{tBilling("rate")}</span>

      {rates.length === 0 ? (
        <p className="mt-1 text-sm text-muted-foreground">{tBilling("noRates")}</p>
      ) : (
        <div className="mt-2 flex flex-wrap gap-2">
          {rates.map((r) => (
            <div key={r.id} className="flex items-center gap-1.5 rounded border px-2 py-1 text-sm">
              <span className="font-medium">{r.deal.name}</span>
              <span className="text-muted-foreground">:</span>
              <span>{r.user.name}</span>

              {editingRate?.dealId === r.deal.id && editingRate?.userId === r.user.id ? (
                <div className="flex items-center gap-1">
                  <Input
                    type="number"
                    value={editingRate.value}
                    onChange={(e) => setEditingRate({ ...editingRate, value: e.target.value })}
                    className="h-6 w-20 text-sm"
                    autoFocus
                    onKeyDown={(e) => e.key === "Enter" && handleSaveRate(editingRate.dealId, editingRate.userId, editingRate.value)}
                  />
                  <Button size="xs" onClick={() => handleSaveRate(editingRate.dealId, editingRate.userId, editingRate.value)} disabled={isPending}>
                    {tCommon("save")}
                  </Button>
                </div>
              ) : (
                <button
                  onClick={() => setEditingRate({ dealId: r.deal.id, userId: r.user.id, value: String(r.ratePerHour) })}
                  className="text-muted-foreground hover:text-foreground"
                >
                  ¥{r.ratePerHour.toLocaleString()}{tBilling("perHour")}
                </button>
              )}
            </div>
          ))}
        </div>
      )}

      {/* Add new rate */}
      <div className="mt-2 flex items-center gap-2">
        <Select value={newDealId} onValueChange={setNewDealId}>
          <SelectTrigger className="w-36 h-7 text-sm">
            <span className="truncate">{newDealId ? deals.find((d) => d.id === newDealId)?.name : tBilling("deal")}</span>
          </SelectTrigger>
          <SelectContent>
            {deals.map((d) => (
              <SelectItem key={d.id} value={d.id}>{d.name}</SelectItem>
            ))}
          </SelectContent>
        </Select>

        <Select value={newUserId} onValueChange={setNewUserId}>
          <SelectTrigger className="w-28 h-7 text-sm">
            <span className="truncate">{newUserId ? users.find((u) => u.id === newUserId)?.name : tBilling("member")}</span>
          </SelectTrigger>
          <SelectContent>
            {users.map((u) => (
              <SelectItem key={u.id} value={u.id}>{u.name}</SelectItem>
            ))}
          </SelectContent>
        </Select>

        <Input type="number" value={newValue} onChange={(e) => setNewValue(e.target.value)} placeholder={tBilling("ratePerHour")} className="h-7 w-24 text-sm" />

        <Button size="xs" onClick={handleAddRate} disabled={isPending || !newDealId || !newUserId}>
          {tBilling("setRate")}
        </Button>
      </div>
    </div>
  );
}
```

- [ ] **Step 3: Create billing table component**

Create `src/components/billing/billing-table.tsx`:

```tsx
"use client";

import { useState, useTransition } from "react";
import { useLocale, useTranslations } from "next-intl";
import { Pencil, Trash2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { updateTimeEntry, deleteTimeEntry } from "@/actions/time-entries";
import type { getFilteredTimeEntries } from "@/actions/billing";

export type EntryData = Awaited<ReturnType<typeof getFilteredTimeEntries>>[number];

function formatHours(minutes: number): string {
  return (minutes / 60).toFixed(1) + "h";
}

interface BillingTableProps {
  entries: EntryData[];
  onRefresh: () => void;
}

export function BillingTable({ entries, onRefresh }: BillingTableProps) {
  const locale = useLocale();
  const tBilling = useTranslations("billing");
  const tTimer = useTranslations("timer");
  const tCommon = useTranslations("common");
  const [isPending, startTransition] = useTransition();

  const [editingEntry, setEditingEntry] = useState<string | null>(null);
  const [editDuration, setEditDuration] = useState("");
  const [editDescription, setEditDescription] = useState("");

  function handleToggleBillable(entryId: string, current: boolean) {
    startTransition(async () => {
      await updateTimeEntry(entryId, { isBillable: !current });
      onRefresh();
    });
  }

  function handleDelete(entryId: string) {
    if (!confirm(tTimer("deleteConfirm"))) return;
    startTransition(async () => {
      await deleteTimeEntry(entryId);
      onRefresh();
    });
  }

  function handleStartEdit(entry: EntryData) {
    setEditingEntry(entry.id);
    setEditDuration((entry.durationMinutes / 60).toFixed(2));
    setEditDescription(entry.description || "");
  }

  function handleSaveEdit() {
    if (!editingEntry) return;
    const hours = parseFloat(editDuration);
    if (isNaN(hours) || hours <= 0) return;

    startTransition(async () => {
      await updateTimeEntry(editingEntry, {
        durationMinutes: Math.round(hours * 60),
        description: editDescription,
      });
      setEditingEntry(null);
      onRefresh();
    });
  }

  return (
    <div className="rounded-lg border overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr className="border-b bg-muted/30">
            <th className="px-3 py-2 text-left font-medium">{tTimer("date")}</th>
            <th className="px-3 py-2 text-left font-medium">{tBilling("member")}</th>
            <th className="px-3 py-2 text-left font-medium">{tBilling("deal")}</th>
            <th className="px-3 py-2 text-left font-medium">{tBilling("task")}</th>
            <th className="px-3 py-2 text-right font-medium">{tTimer("duration")}</th>
            <th className="px-3 py-2 text-center font-medium">{tBilling("billable")}</th>
            <th className="px-3 py-2 text-right font-medium"></th>
          </tr>
        </thead>
        <tbody>
          {entries.map((entry) => (
            <tr key={entry.id} className="border-b last:border-b-0 hover:bg-muted/30">
              <td className="px-3 py-1.5 text-muted-foreground">
                {entry.startedAt
                  ? new Intl.DateTimeFormat(locale, { month: "numeric", day: "numeric" }).format(new Date(entry.startedAt))
                  : "—"}
              </td>
              <td className="px-3 py-1.5">{entry.user.name}</td>
              <td className="px-3 py-1.5">{entry.deal.name}</td>
              <td className="px-3 py-1.5">
                <div className="flex flex-col">
                  <span className="truncate max-w-[200px]">{entry.task.title}</span>
                  {editingEntry === entry.id ? (
                    <Input value={editDescription} onChange={(e) => setEditDescription(e.target.value)} className="h-6 text-xs mt-0.5" placeholder={tTimer("description")} />
                  ) : entry.description ? (
                    <span className="text-xs text-muted-foreground truncate max-w-[200px]">{entry.description}</span>
                  ) : null}
                </div>
              </td>
              <td className="px-3 py-1.5 text-right">
                {editingEntry === entry.id ? (
                  <Input type="number" step="0.25" value={editDuration} onChange={(e) => setEditDuration(e.target.value)} className="h-6 w-16 text-sm ml-auto" onKeyDown={(e) => e.key === "Enter" && handleSaveEdit()} />
                ) : (
                  formatHours(entry.durationMinutes)
                )}
              </td>
              <td className="px-3 py-1.5 text-center">
                <button onClick={() => handleToggleBillable(entry.id, entry.isBillable)} disabled={isPending} className="text-sm">
                  {entry.isBillable ? "✓" : "✗"}
                </button>
              </td>
              <td className="px-3 py-1.5 text-right">
                <div className="flex items-center justify-end gap-1">
                  {editingEntry === entry.id ? (
                    <Button size="xs" onClick={handleSaveEdit} disabled={isPending}>{tCommon("save")}</Button>
                  ) : (
                    <button onClick={() => handleStartEdit(entry)} className="text-muted-foreground hover:text-foreground">
                      <Pencil className="size-3.5" />
                    </button>
                  )}
                  <button onClick={() => handleDelete(entry.id)} disabled={isPending} className="text-muted-foreground hover:text-red-500">
                    <Trash2 className="size-3.5" />
                  </button>
                </div>
              </td>
            </tr>
          ))}

          {entries.length === 0 && (
            <tr>
              <td colSpan={7} className="px-3 py-6 text-center text-muted-foreground">{tTimer("noEntries")}</td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
```

- [ ] **Step 4: Create billing summary component**

Create `src/components/billing/billing-summary.tsx`:

```tsx
"use client";

import { useTranslations } from "next-intl";
import type { EntryData } from "./billing-table";
import type { RateData } from "./billing-rate-editor";

function formatHours(minutes: number): string {
  return (minutes / 60).toFixed(1) + "h";
}

interface BillingSummaryProps {
  entries: EntryData[];
  rates: RateData[];
}

export function BillingSummary({ entries, rates }: BillingSummaryProps) {
  const tBilling = useTranslations("billing");

  const rateMap = new Map<string, number>();
  for (const r of rates) {
    rateMap.set(`${r.deal.id}-${r.user.id}`, r.ratePerHour);
  }

  const totalMinutes = entries.reduce((s, e) => s + e.durationMinutes, 0);
  const billableMinutes = entries.filter((e) => e.isBillable).reduce((s, e) => s + e.durationMinutes, 0);
  const totalAmount = entries
    .filter((e) => e.isBillable)
    .reduce((s, e) => s + (e.durationMinutes / 60) * (rateMap.get(`${e.deal.id}-${e.user.id}`) ?? 0), 0);

  return (
    <div className="flex items-center gap-6 rounded-lg border bg-muted/30 px-4 py-3 text-sm">
      <span className="font-medium">{tBilling("summary")}:</span>
      <span>{tBilling("totalHours")} {formatHours(totalMinutes)}</span>
      <span>{tBilling("billableHours")} {formatHours(billableMinutes)}</span>
      <span>{tBilling("totalAmount")} ¥{totalAmount.toLocaleString(undefined, { minimumFractionDigits: 2 })}</span>
    </div>
  );
}
```

- [ ] **Step 5: Verify build**

Run:
```bash
npx tsc --noEmit
```

Expected: No type errors.

- [ ] **Step 6: Commit**

```bash
git add src/components/billing/
git commit -m "feat: add billing UI components (filters, rate editor, table, summary)"
```

---

### Task 10: Admin Billing Page + Navigation

**Files:**
- Create: `src/app/[locale]/admin/billing/page.tsx`
- Modify: `src/components/layout/app-shell.tsx` (add admin billing nav)

- [ ] **Step 1: Create admin billing page**

Create `src/app/[locale]/admin/billing/page.tsx`:

```tsx
"use client";

import { useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { BillingFilters } from "@/components/billing/billing-filters";
import { BillingRateEditor, type RateData } from "@/components/billing/billing-rate-editor";
import { BillingTable, type EntryData } from "@/components/billing/billing-table";
import { BillingSummary } from "@/components/billing/billing-summary";
import {
  getFilteredTimeEntries,
  exportBillingExcel,
} from "@/actions/billing";

interface BillingPageClientProps {
  deals: { id: string; name: string }[];
  users: { id: string; name: string }[];
  initialEntries: EntryData[];
  initialRates: RateData[];
}

export function BillingPageClient({
  deals,
  users,
  initialEntries,
  initialRates,
}: BillingPageClientProps) {
  const tBilling = useTranslations("billing");
  const [isPending, startTransition] = useTransition();

  const [dealId, setDealId] = useState("");
  const [userId, setUserId] = useState("");
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [billableOnly, setBillableOnly] = useState(false);

  const [entries, setEntries] = useState<EntryData[]>(initialEntries);
  const [rates, setRates] = useState<RateData[]>(initialRates);

  function handleFilter() {
    startTransition(async () => {
      const result = await getFilteredTimeEntries({
        dealId: dealId || undefined,
        userId: userId || undefined,
        startDate: startDate || undefined,
        endDate: endDate || undefined,
        billableOnly,
      });
      setEntries(result);
    });
  }

  function handleExport() {
    startTransition(async () => {
      const base64 = await exportBillingExcel({
        dealId: dealId || undefined,
        userId: userId || undefined,
        startDate: startDate || undefined,
        endDate: endDate || undefined,
        billableOnly,
      });
      const blob = new Blob(
        [Uint8Array.from(atob(base64), (c) => c.charCodeAt(0))],
        { type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" }
      );
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `billing-${new Date().toISOString().split("T")[0]}.xlsx`;
      a.click();
      URL.revokeObjectURL(url);
    });
  }

  return (
    <div className="flex flex-col gap-6">
      <h1 className="text-lg font-semibold">{tBilling("billing")}</h1>

      <BillingFilters
        deals={deals}
        users={users}
        dealId={dealId}
        userId={userId}
        startDate={startDate}
        endDate={endDate}
        billableOnly={billableOnly}
        isPending={isPending}
        onDealChange={setDealId}
        onUserChange={setUserId}
        onStartDateChange={setStartDate}
        onEndDateChange={setEndDate}
        onBillableOnlyChange={setBillableOnly}
        onFilter={handleFilter}
        onExport={handleExport}
      />

      <BillingRateEditor
        deals={deals}
        users={users}
        rates={rates}
        onRatesChange={setRates}
      />

      <BillingTable entries={entries} onRefresh={handleFilter} />

      <BillingSummary entries={entries} rates={rates} />
    </div>
  );
}
```

Now create the server page wrapper. Since the billing page needs server-side auth and data fetching, create the actual server page that renders this client component.

Replace the file at `src/app/[locale]/admin/billing/page.tsx` — it should be a **server component** that fetches data and renders the client component. Rename the client component above and place it as part of this file or import it.

**Correction:** The `BillingPageClient` should be in `src/components/billing/billing-page-client.tsx`, and the server page should import it.

Create `src/components/billing/billing-page-client.tsx` with the `BillingPageClient` code above.

Then create `src/app/[locale]/admin/billing/page.tsx`:

```tsx
import { auth } from "@/lib/auth";
import { redirect } from "next/navigation";
import { getLocale } from "next-intl/server";
import {
  getFilteredTimeEntries,
  getDealBillingRates,
  getAdminFilterOptions,
} from "@/actions/billing";
import { BillingPageClient } from "@/components/billing/billing-page-client";

export default async function AdminBillingPage() {
  const session = await auth();
  const locale = await getLocale();

  if (!session?.user?.id) {
    redirect(`/${locale}/login`);
  }

  const role = (session.user as unknown as { role: string }).role;
  if (role !== "Admin") {
    redirect(`/${locale}/dashboard`);
  }

  const [entries, rates, options] = await Promise.all([
    getFilteredTimeEntries({}),
    getDealBillingRates(),
    getAdminFilterOptions(),
  ]);

  return (
    <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6">
      <BillingPageClient
        deals={options.deals}
        users={options.users}
        initialEntries={entries}
        initialRates={rates}
      />
    </div>
  );
}
```

- [ ] **Step 2: Add billing link to admin nav**

In `src/components/layout/app-shell.tsx`, add the billing translation and nav link for Admin users.

After the existing `const tCommon = await getTranslations("common");` line, add:

```ts
  const tBilling = await getTranslations("billing");
```

Then update the navLinks array. Change the admin entry from:

```tsx
    ...(role === "Admin"
      ? [{ href: `/${locale}/admin/users`, label: t("admin") }]
      : []),
```

To:

```tsx
    ...(role === "Admin"
      ? [
          { href: `/${locale}/admin/users`, label: t("admin") },
          { href: `/${locale}/admin/billing`, label: tBilling("billing") },
        ]
      : []),
```

- [ ] **Step 3: Verify build and test**

Run:
```bash
npx tsc --noEmit && npm run dev
```

Expected: No errors. Log in as Admin, see "Time Management" in nav. Visit the billing page — see filters, rate editor, entry table, summary, and export button.

- [ ] **Step 4: Commit**

```bash
git add src/components/billing/billing-page-client.tsx src/app/[locale]/admin/billing/ src/components/layout/app-shell.tsx
git commit -m "feat: add admin billing page with filters, rate management, and Excel export"
```

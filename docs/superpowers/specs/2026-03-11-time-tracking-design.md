# Time Tracking System Design

## Overview

Add a time tracking system to DealFlow so lawyers can track hours spent on tasks — via live timer or manual entry. An admin billing page allows reviewing, editing, setting per-person-per-deal rates, and exporting to Excel.

---

## Data Model

### New Models

```prisma
model TimeEntry {
  id              String   @id @default(cuid())
  description     String?
  startedAt       DateTime?          // null for manual entries
  stoppedAt       DateTime?          // null if timer still running
  durationMinutes Int                // computed from start/stop, or manually entered
  isManual        Boolean  @default(false)
  isBillable      Boolean  @default(true)
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt

  taskId    String
  task      Task    @relation(fields: [taskId], references: [id], onDelete: Cascade)
  userId    String
  user      User    @relation("TimeEntries", fields: [userId], references: [id])
  dealId    String
  deal      Deal    @relation(fields: [dealId], references: [id], onDelete: Cascade)

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

### Existing Model Changes

- `Task`: add `timeEntries TimeEntry[]`
- `User`: add `timeEntries TimeEntry[] @relation("TimeEntries")` and `billingRates DealBillingRate[] @relation("BillingRates")`
- `Deal`: add `timeEntries TimeEntry[]` and `billingRates DealBillingRate[]`

---

## Feature 1: Live Timer

### Timer Floating Bar

A fixed bar at the bottom of the screen, visible on all pages when a timer is running.

```
┌──────────────────────────────────────────────────────────────────┐
│  ⏱  公司尽调 — 审阅公司章程  │  Project Alpha  │  01:23:45  [■ 停止]  │
└──────────────────────────────────────────────────────────────────┘
```

- Shows: task title, optional description, deal name, elapsed time (ticking), Stop button
- Clicking task title opens the task panel
- When stopped: prompts for an optional description, then saves the entry

### Timer State (Client)

Zustand store (`use-timer.ts`) with localStorage persistence:

```ts
interface TimerState {
  activeEntryId: string | null;
  taskId: string | null;
  taskTitle: string;
  dealName: string;
  startedAt: number | null;     // timestamp ms
  start: (entryId: string, taskId: string, taskTitle: string, dealName: string) => void;
  stop: () => void;
}
```

Elapsed time computed client-side: `Date.now() - startedAt`.

### Timer Flow

1. **Start**: User clicks ▶ on a task row or task panel
   - If another timer is running → confirm dialog: "停止当前计时并开始新的?"
   - Server action creates `TimeEntry` with `startedAt = now()`, `stoppedAt = null`, `durationMinutes = 0`
   - Client store updated with entry ID and start time
2. **Stop**: User clicks Stop on floating bar
   - Optional description input (small inline field or popover)
   - Server action updates `stoppedAt = now()`, computes `durationMinutes`
   - Client store cleared
3. **Page refresh**: Store persisted in localStorage; on mount, if `activeEntryId` exists, resume display with elapsed time from `startedAt`

### Start Timer Button

- **Task row**: Small ▶ icon button, appears on hover (to the left of the checkbox)
- **Task detail panel**: "开始计时 / Start Timer" button in a new "Time" section

---

## Feature 2: Manual Time Entry

In the task detail panel, a "Time" section below dependencies:

```
计时 / Time                                    总计: 7.0h
──────────────────────────────────────────────────
3月10日  张律师  2.5h  审阅公司章程
3月11日  张律师  1.0h  核查股东决议
3月12日  何欣    3.0h  审阅劳动合同
──────────────────────────────────────────────────
[+ 手动录入]   [▶ 开始计时]
```

### Manual Entry Form

Inline form that appears when clicking "+ 手动录入":
- **Duration** (hours, decimal input, e.g. "1.5")
- **Date** (defaults to today)
- **Description** (optional text)

Creates `TimeEntry` with `isManual = true`, `durationMinutes` computed from hours input.

---

## Feature 3: Deal Time Summary

New link in deal detail bottom links area: "计时 / Time"

Page: `/[locale]/deals/[dealId]/time`

```
Project Alpha — 计时汇总
──────────────────────────────────────────────
按工作流                          小时    可计费
  Phase 1 尽职调查                25.0h   22.5h
    公司尽调                       7.0h    7.0h
    财务尽调                      10.0h    8.5h
    ...
  Phase 2 交易结构                12.0h   12.0h
    ...
──────────────────────────────────────────────
按成员
  张律师                          20.0h   18.0h
  何欣                            17.0h   16.5h
──────────────────────────────────────────────
总计                              37.0h   34.5h
```

Server action fetches all time entries for the deal, groups by workstream → task and by user.

---

## Feature 4: Admin Billing Page

Page: `/[locale]/admin/billing`

Accessible only to Admin role users. Link added to admin nav.

### Layout

```
计时管理 / Time Management
──────────────────────────────────────────────────────────
筛选: [项目 ▼] [成员 ▼] [日期范围] [仅可计费 ☐]  [导出Excel]
──────────────────────────────────────────────────────────

费率设置                                    [编辑费率]
  Project Alpha: 张律师 ¥3,000/h | 何欣 ¥2,500/h
  Project Beta:  张律师 ¥2,800/h | 杨律师 ¥2,200/h

──────────────────────────────────────────────────────────
日期     成员    项目            任务           时长   可计费  操作
3/10   张律师  Project Alpha  公司尽调        2.5h    ✓     [编辑][删除]
3/10   何欣    Project Alpha  劳动合同审阅    3.0h    ✓     [编辑][删除]
3/11   张律师  Project Beta   NDA审阅         1.0h    ✗     [编辑][删除]
...
──────────────────────────────────────────────────────────
汇总: 总时长 42.0h | 可计费 38.5h | 总金额 ¥112,500
```

### Features

- **Filter**: by deal, person, date range, billable only
- **Inline edit**: click edit to modify duration, description, billable flag
- **Delete**: remove erroneous entries
- **Rate management**: set/edit hourly rate per person per deal
- **Summary**: total hours, billable hours, total amount (computed from rates)
- **Export to Excel**: downloads .xlsx with all filtered entries + summary sheet

### Excel Export Format

**Sheet 1: Time Entries**
| Date | Person | Deal | Workstream | Task | Description | Hours | Billable | Rate | Amount |

**Sheet 2: Summary by Deal**
| Deal | Person | Total Hours | Billable Hours | Rate | Total Amount |

**Sheet 3: Summary by Person**
| Person | Deal | Total Hours | Billable Hours | Rate | Total Amount |

---

## Server Actions

```ts
// src/actions/time-entries.ts
startTimer(taskId: string): Promise<{ entryId: string }>
stopTimer(entryId: string, description?: string): Promise<void>
logManualTime(taskId: string, data: { durationMinutes: number; date: Date; description?: string }): Promise<void>
updateTimeEntry(entryId: string, data: Partial<{ durationMinutes: number; description: string; isBillable: boolean }>): Promise<void>
deleteTimeEntry(entryId: string): Promise<void>
getTaskTimeEntries(taskId: string): Promise<TimeEntry[]>
getDealTimeSummary(dealId: string): Promise<DealTimeSummary>

// src/actions/billing.ts
getFilteredTimeEntries(filters: { dealId?: string; userId?: string; startDate?: Date; endDate?: Date; billableOnly?: boolean }): Promise<TimeEntry[]>
setBillingRate(dealId: string, userId: string, ratePerHour: number): Promise<void>
getDealBillingRates(dealId?: string): Promise<DealBillingRate[]>
exportBillingExcel(filters: same as above): Promise<Buffer>
```

---

## File Structure

```
src/
  actions/
    time-entries.ts          # Timer and time entry CRUD
    billing.ts               # Admin billing, rates, export
  components/
    timer/
      timer-bar.tsx          # Floating bottom bar
      timer-button.tsx       # Play button for task rows
    time/
      time-entry-list.tsx    # Time entries in task panel
      manual-time-form.tsx   # Manual time input
      deal-time-summary.tsx  # Deal time summary view
    billing/
      billing-filters.tsx    # Filter controls
      billing-table.tsx      # Time entry table with inline edit
      billing-rate-editor.tsx # Rate management
      billing-summary.tsx    # Totals panel
  app/[locale]/
    admin/
      billing/
        page.tsx             # Admin billing page
    deals/[dealId]/
      time/
        page.tsx             # Deal time summary page
  hooks/
    use-timer.ts             # Zustand timer store with localStorage
```

---

## Translations

Add `"timer"` and `"billing"` keys to both `messages/en.json` and `messages/zh.json`:

```json
{
  "timer": {
    "startTimer": "Start Timer / 开始计时",
    "stopTimer": "Stop / 停止",
    "switchTimer": "Stop current timer and start new one? / 停止当前计时并开始新的?",
    "logTime": "Log Time / 手动录入",
    "duration": "Duration / 时长",
    "hours": "hours / 小时",
    "description": "Description / 描述",
    "totalTime": "Total / 总计",
    "timeEntries": "Time / 计时",
    "running": "Running / 计时中",
    "noEntries": "No time entries / 暂无计时记录"
  },
  "billing": {
    "billing": "Time Management / 计时管理",
    "rate": "Rate / 费率",
    "ratePerHour": "Rate per hour / 时薪",
    "billable": "Billable / 可计费",
    "nonBillable": "Non-billable / 不可计费",
    "totalHours": "Total Hours / 总时长",
    "billableHours": "Billable Hours / 可计费时长",
    "totalAmount": "Total Amount / 总金额",
    "exportExcel": "Export Excel / 导出Excel",
    "editRate": "Edit Rates / 编辑费率",
    "byWorkstream": "By Workstream / 按工作流",
    "byMember": "By Member / 按成员",
    "dateRange": "Date Range / 日期范围",
    "allDeals": "All Deals / 全部项目",
    "allMembers": "All Members / 全部成员",
    "billableOnly": "Billable Only / 仅可计费",
    "summary": "Summary / 汇总"
  }
}
```

---

## Out of Scope

- Approval workflow (internal team, no need)
- Invoice generation (export Excel is sufficient)
- Automatic time tracking (only manual + timer)
- Overtime / holiday rate multipliers
- Budget / estimate vs actual comparison

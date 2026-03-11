# Deal Metadata Enhancements Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add deal phase, transaction value, and deal source fields to the Deal model, with corresponding UI updates across deal header, deal form, and deal list.

**Architecture:** Prisma schema gets two new enums (`DealPhase`, `DealSource`) and six new fields on `Deal`. Server actions accept the new fields. Three UI components are updated: DealHeader (display + edit), DealForm (create), DealList (table columns). A new `DealPhaseBadge` component mirrors the existing `DealStatusBadge` pattern.

**Tech Stack:** Prisma 7, Next.js 16 App Router, Server Actions, next-intl, Tailwind CSS, shadcn/ui

---

## File Structure

| Action | File | Responsibility |
|--------|------|----------------|
| Modify | `prisma/schema.prisma` | Add `DealPhase`, `DealSource` enums and six new `Deal` fields |
| Modify | `messages/en.json` | English translations for new fields and enum values |
| Modify | `messages/zh.json` | Chinese translations for new fields and enum values |
| Modify | `src/actions/deals.ts` | Extend `updateDeal` type signature and `createDeal` FormData handling |
| Create | `src/components/deals/deal-phase-badge.tsx` | Phase badge component (mirrors `deal-status-badge.tsx` pattern) |
| Modify | `src/components/deals/deal-header.tsx` | Display phase/value/source, expand edit dialog with new fields |
| Modify | `src/components/deals/deal-form.tsx` | Add phase, value, currency, keyTerms, source, sourceNote fields |
| Modify | `src/components/deals/deal-list.tsx` | Add Phase and Value columns to table |
| Modify | `src/app/[locale]/deals/[dealId]/page.tsx` | Pass new fields to DealHeader |
| Modify | `src/app/[locale]/deals/page.tsx` | Include new fields in Prisma query for deal list |

---

## Chunk 1: Schema, Migration, i18n, Server Actions

### Task 1: Prisma Schema — Add Enums and Fields

**Files:**
- Modify: `prisma/schema.prisma:10-142`

- [ ] **Step 1: Add DealPhase and DealSource enums**

Add after the existing `DealStatus` enum (line 28):

```prisma
enum DealPhase {
  Intake
  DueDiligence
  Negotiation
  Signing
  Closing
  PostClosing
}

enum DealSource {
  FAReferral
  DirectClient
  PartnerReferral
  Repeat
  Other
}
```

- [ ] **Step 2: Add new fields to Deal model**

Add after the `summary` field (line 125) inside the `Deal` model:

```prisma
  phase         DealPhase   @default(Intake)
  dealValue     Decimal?    @db.Decimal(18, 2)
  valueCurrency String      @default("USD")
  keyTerms      String?
  source        DealSource?
  sourceNote    String?
```

- [ ] **Step 3: Run Prisma migration**

Run:
```bash
cd /Users/BBB/ccproj/maprojms/dealflow
npx prisma migrate dev --name add-deal-metadata
```

Expected: Migration succeeds. Existing deals get `phase=Intake`, `valueCurrency="USD"`, others nullable.

- [ ] **Step 4: Generate Prisma client and verify**

Run:
```bash
npx prisma generate
```

Expected: Prisma client regenerated with `DealPhase` and `DealSource` types available at `@/generated/prisma/client`.

- [ ] **Step 5: Commit**

```bash
git add prisma/schema.prisma prisma/migrations/
git commit -m "feat: add DealPhase, DealSource enums and metadata fields to Deal model"
```

---

### Task 2: i18n Translations

**Files:**
- Modify: `messages/en.json:30-56` (deal section)
- Modify: `messages/zh.json:30-56` (deal section)

- [ ] **Step 1: Add English translations**

In `messages/en.json`, add these keys inside the `"deal"` object, after the `"backToDeals"` key:

```json
"phase": "Phase",
"intake": "Intake",
"dueDiligence": "Due Diligence",
"negotiation": "Negotiation",
"signing": "Signing",
"closing": "Closing",
"postClosing": "Post-Closing",
"dealValue": "Deal Value",
"valueCurrency": "Currency",
"keyTerms": "Key Terms",
"source": "Source",
"sourceNote": "Source Note",
"faReferral": "FA Referral",
"directClient": "Direct Client",
"partnerReferral": "Partner Referral",
"repeat": "Repeat Client",
"otherSource": "Other"
```

Note: Use `"otherSource"` instead of `"other"` to avoid collision with `decision.other`.

- [ ] **Step 2: Add Chinese translations**

In `messages/zh.json`, add these keys inside the `"deal"` object, after the `"backToDeals"` key:

```json
"phase": "阶段",
"intake": "立项",
"dueDiligence": "尽调",
"negotiation": "谈判",
"signing": "签约",
"closing": "交割",
"postClosing": "结项",
"dealValue": "交易金额",
"valueCurrency": "币种",
"keyTerms": "核心条款",
"source": "项目来源",
"sourceNote": "来源备注",
"faReferral": "FA引荐",
"directClient": "客户直接委托",
"partnerReferral": "合伙人转介",
"repeat": "老客户新项目",
"otherSource": "其他"
```

- [ ] **Step 3: Verify type check**

Run:
```bash
npx tsc --noEmit
```

Expected: No errors (JSON files aren't type-checked, but this ensures nothing else broke).

- [ ] **Step 4: Commit**

```bash
git add messages/en.json messages/zh.json
git commit -m "feat: add i18n translations for deal metadata fields"
```

---

### Task 3: Server Actions — Update Type Signatures

**Files:**
- Modify: `src/actions/deals.ts:10,131-143,17-129`

- [ ] **Step 1: Add new types to import**

In `src/actions/deals.ts`, update the type import on line 10:

```typescript
import type { DealType, DealRole, DealStatus, DealPhase, DealSource, MilestoneType } from "@/generated/prisma/client";
```

- [ ] **Step 2: Extend updateDeal type signature**

Change the `data` parameter type in `updateDeal` (lines 133-142) to include the new fields:

```typescript
export async function updateDeal(
  dealId: string,
  data: {
    name?: string;
    codeName?: string | null;
    clientName?: string;
    targetCompany?: string;
    jurisdictions?: string[];
    summary?: string | null;
    status?: DealStatus;
    dealLeadId?: string;
    phase?: DealPhase;
    dealValue?: number | null;
    valueCurrency?: string;
    keyTerms?: string | null;
    source?: DealSource | null;
    sourceNote?: string | null;
  }
)
```

- [ ] **Step 3: Add new fields to createDeal FormData handling**

In `createDeal`, after the `summary` FormData extraction (around line 40), add:

```typescript
  const phase = (formData.get("phase") as string) || "Intake";
  const dealValueRaw = formData.get("dealValue") as string;
  const dealValue = dealValueRaw ? parseFloat(dealValueRaw) : null;
  const valueCurrency = (formData.get("valueCurrency") as string) || "USD";
  const keyTerms = (formData.get("keyTerms") as string) || null;
  const sourceRaw = (formData.get("source") as string) || null;
  const source = sourceRaw as DealSource | null;
  const sourceNote = (formData.get("sourceNote") as string) || null;
```

Then add these fields to the `prisma.deal.create` data object (inside the `data:` block starting at line 69):

```typescript
      phase: phase as DealPhase,
      dealValue: dealValue !== null && !isNaN(dealValue) ? dealValue : null,
      valueCurrency,
      keyTerms,
      source,
      sourceNote,
```

Add after `summary,` and before `dealLeadId,`.

- [ ] **Step 4: Add enum validation in createDeal**

After the existing validation block (lines 46-54 in `deals.ts`), add validation for the new enum fields:

```typescript
  const validPhases = ["Intake", "DueDiligence", "Negotiation", "Signing", "Closing", "PostClosing"];
  const validSources = ["FAReferral", "DirectClient", "PartnerReferral", "Repeat", "Other"];

  if (!validPhases.includes(phase)) {
    throw new Error("Invalid deal phase");
  }
  if (sourceRaw && !validSources.includes(sourceRaw)) {
    throw new Error("Invalid deal source");
  }
```

- [ ] **Step 5: Verify type check**

Run:
```bash
npx tsc --noEmit
```

Expected: No type errors.

- [ ] **Step 6: Commit**

```bash
git add src/actions/deals.ts
git commit -m "feat: extend createDeal and updateDeal with deal metadata fields"
```

---

## Chunk 2: UI Components

### Task 4: Create DealPhaseBadge Component

**Files:**
- Create: `src/components/deals/deal-phase-badge.tsx`

Reference: `src/components/deals/deal-status-badge.tsx` — follow same pattern.

- [ ] **Step 1: Create the component**

Create `src/components/deals/deal-phase-badge.tsx`:

```tsx
import { Badge } from "@/components/ui/badge";
import type { DealPhase } from "@/generated/prisma/client";

const phaseConfig: Record<DealPhase, { className: string }> = {
  Intake: { className: "bg-blue-100 text-blue-800" },
  DueDiligence: { className: "bg-indigo-100 text-indigo-800" },
  Negotiation: { className: "bg-purple-100 text-purple-800" },
  Signing: { className: "bg-pink-100 text-pink-800" },
  Closing: { className: "bg-amber-100 text-amber-800" },
  PostClosing: { className: "bg-gray-100 text-gray-800" },
};

const phaseLabels: Record<string, Record<DealPhase, string>> = {
  en: {
    Intake: "Intake",
    DueDiligence: "Due Diligence",
    Negotiation: "Negotiation",
    Signing: "Signing",
    Closing: "Closing",
    PostClosing: "Post-Closing",
  },
  zh: {
    Intake: "立项",
    DueDiligence: "尽调",
    Negotiation: "谈判",
    Signing: "签约",
    Closing: "交割",
    PostClosing: "结项",
  },
};

export function DealPhaseBadge({
  phase,
  locale = "zh",
}: {
  phase: DealPhase;
  locale?: string;
}) {
  const config = phaseConfig[phase];
  const labels = phaseLabels[locale] || phaseLabels.zh;
  return (
    <Badge variant="secondary" className={config.className}>
      {labels[phase]}
    </Badge>
  );
}
```

- [ ] **Step 2: Verify type check**

Run:
```bash
npx tsc --noEmit
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add src/components/deals/deal-phase-badge.tsx
git commit -m "feat: add DealPhaseBadge component"
```

---

### Task 5: Deal Header — Display New Fields and Extend Edit Dialog

**Files:**
- Modify: `src/components/deals/deal-header.tsx`

This is the largest task. The deal header needs:
1. Phase badge next to status badge
2. Deal value + currency below deal name
3. Source as small text
4. keyTerms collapsible section (same pattern as summary toggle)
5. Edit dialog extended with new fields

- [ ] **Step 1: Update imports**

Add to the existing imports in `deal-header.tsx`:

```typescript
import { DealPhaseBadge } from "./deal-phase-badge";
import type { DealStatus, DealPhase, DealSource } from "@/generated/prisma/client";
```

Remove the existing `DealStatus` import from line 25 (it's now in the combined import above).

- [ ] **Step 2: Extend DealHeaderProps interface**

Update the `deal` type inside `DealHeaderProps` (lines 28-39) to include new fields:

```typescript
interface DealHeaderProps {
  deal: {
    id: string;
    name: string;
    codeName: string | null;
    status: DealStatus;
    clientName: string;
    targetCompany: string;
    jurisdictions: string[];
    summary: string | null;
    dealLead: { name: string };
    phase: DealPhase;
    dealValue: number | null;
    valueCurrency: string;
    keyTerms: string | null;
    source: DealSource | null;
    sourceNote: string | null;
  };
}
```

- [ ] **Step 3: Add state for new edit fields**

After the existing `editSummary` state (line 60), add:

```typescript
  const [editPhase, setEditPhase] = useState(deal.phase);
  const [editDealValue, setEditDealValue] = useState(deal.dealValue?.toString() ?? "");
  const [editValueCurrency, setEditValueCurrency] = useState(deal.valueCurrency);
  const [editKeyTerms, setEditKeyTerms] = useState(deal.keyTerms ?? "");
  const [editSource, setEditSource] = useState<DealSource | "">(deal.source ?? "");
  const [editSourceNote, setEditSourceNote] = useState(deal.sourceNote ?? "");
```

- [ ] **Step 4: Add constants for dropdowns**

After the `ALL_STATUSES` constant (line 41), add:

```typescript
const ALL_PHASES: DealPhase[] = ["Intake", "DueDiligence", "Negotiation", "Signing", "Closing", "PostClosing"];
const ALL_SOURCES: DealSource[] = ["FAReferral", "DirectClient", "PartnerReferral", "Repeat", "Other"];
const CURRENCIES = ["USD", "CNY", "EUR", "HKD", "SGD", "VND"] as const;
```

- [ ] **Step 5: Update handleEditSave to include new fields**

Replace the `handleEditSave` function body to include new fields in the `updateDeal` call:

```typescript
  function handleEditSave() {
    if (!editName.trim() || !editClient.trim() || !editTarget.trim()) return;
    startEditSave(async () => {
      const parsedValue = editDealValue.trim() ? parseFloat(editDealValue) : null;
      await updateDeal(deal.id, {
        name: editName.trim(),
        codeName: editCodeName.trim() || null,
        clientName: editClient.trim(),
        targetCompany: editTarget.trim(),
        jurisdictions: editJurisdictions.split(",").map((s) => s.trim()).filter(Boolean),
        summary: editSummary.trim() || null,
        phase: editPhase as DealPhase,
        dealValue: parsedValue !== null && !isNaN(parsedValue) ? parsedValue : null,
        valueCurrency: editValueCurrency,
        keyTerms: editKeyTerms.trim() || null,
        source: editSource || null,
        sourceNote: editSourceNote.trim() || null,
      });
      setEditOpen(false);
    });
  }
```

- [ ] **Step 6: Add phase badge next to status badge in JSX**

In the header row (line 109, the `<div className="flex items-center gap-3">` block), after the status dropdown (after line 142's closing `</DropdownMenu>`), add:

```tsx
        <DealPhaseBadge phase={deal.phase} locale={locale} />
```

- [ ] **Step 7: Add deal value and source display**

After the existing info row (the `<div className="flex items-center gap-4 text-sm text-muted-foreground">` block ending around line 209), add a new row:

```tsx
      {(deal.dealValue !== null || deal.source) && (
        <div className="flex items-center gap-4 text-sm text-muted-foreground">
          {deal.dealValue !== null && (
            <span>
              <strong className="text-foreground">
                {deal.valueCurrency} {deal.dealValue.toLocaleString(locale === "zh" ? "zh-CN" : "en-US", { minimumFractionDigits: 0, maximumFractionDigits: 2 })}
              </strong>
            </span>
          )}
          {deal.dealValue !== null && deal.source && <span>|</span>}
          {deal.source && (
            <span>
              {t(deal.source === "FAReferral" ? "faReferral" : deal.source === "DirectClient" ? "directClient" : deal.source === "PartnerReferral" ? "partnerReferral" : deal.source === "Repeat" ? "repeat" : "otherSource")}
              {deal.sourceNote && ` — ${deal.sourceNote}`}
            </span>
          )}
        </div>
      )}
```

- [ ] **Step 8: Add keyTerms collapsible section**

After the summary collapsible section (after line 225's closing `</div>`), add a keyTerms section using the same toggle pattern:

```tsx
      {deal.keyTerms && (
        <div>
          <button
            onClick={() => setKeyTermsExpanded(!keyTermsExpanded)}
            className="text-sm text-muted-foreground hover:text-foreground"
          >
            {keyTermsExpanded ? "\u25B2" : "\u25BC"} {t("keyTerms")}
          </button>
          {keyTermsExpanded && (
            <p className="mt-1 text-sm text-muted-foreground whitespace-pre-wrap">
              {deal.keyTerms}
            </p>
          )}
        </div>
      )}
```

Also add the state for this toggle after the `expanded` state (line 48):

```typescript
  const [keyTermsExpanded, setKeyTermsExpanded] = useState(false);
```

- [ ] **Step 9: Extend edit dialog with new fields**

In the edit dialog's `<div className="space-y-3 pt-2">` block, after the summary textarea field and before the button row, add:

```tsx
            {/* Phase */}
            <div>
              <label className="mb-1 block text-sm font-medium">{t("phase")}</label>
              <select
                value={editPhase}
                onChange={(e) => setEditPhase(e.target.value as DealPhase)}
                disabled={editSaving}
                className="flex h-8 w-full rounded-md border border-input bg-background px-3 text-sm"
              >
                {ALL_PHASES.map((p) => (
                  <option key={p} value={p}>
                    {t(p === "DueDiligence" ? "dueDiligence" : p === "PostClosing" ? "postClosing" : p.toLowerCase())}
                  </option>
                ))}
              </select>
            </div>
            {/* Deal Value + Currency */}
            <div className="grid grid-cols-[1fr_100px] gap-2">
              <div>
                <label className="mb-1 block text-sm font-medium">{t("dealValue")}</label>
                <Input
                  type="number"
                  step="0.01"
                  value={editDealValue}
                  onChange={(e) => setEditDealValue(e.target.value)}
                  disabled={editSaving}
                />
              </div>
              <div>
                <label className="mb-1 block text-sm font-medium">{t("valueCurrency")}</label>
                <select
                  value={editValueCurrency}
                  onChange={(e) => setEditValueCurrency(e.target.value)}
                  disabled={editSaving}
                  className="flex h-8 w-full rounded-md border border-input bg-background px-3 text-sm"
                >
                  {CURRENCIES.map((c) => (
                    <option key={c} value={c}>{c}</option>
                  ))}
                </select>
              </div>
            </div>
            {/* Key Terms */}
            <div>
              <label className="mb-1 block text-sm font-medium">{t("keyTerms")}</label>
              <textarea
                value={editKeyTerms}
                onChange={(e) => setEditKeyTerms(e.target.value)}
                className="flex min-h-[60px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                disabled={editSaving}
              />
            </div>
            {/* Source + Source Note */}
            <div>
              <label className="mb-1 block text-sm font-medium">{t("source")}</label>
              <select
                value={editSource}
                onChange={(e) => setEditSource(e.target.value as DealSource | "")}
                disabled={editSaving}
                className="flex h-8 w-full rounded-md border border-input bg-background px-3 text-sm"
              >
                <option value="">—</option>
                {ALL_SOURCES.map((s) => (
                  <option key={s} value={s}>
                    {t(s === "FAReferral" ? "faReferral" : s === "DirectClient" ? "directClient" : s === "PartnerReferral" ? "partnerReferral" : s === "Repeat" ? "repeat" : "otherSource")}
                  </option>
                ))}
              </select>
            </div>
            {editSource && (
              <div>
                <label className="mb-1 block text-sm font-medium">{t("sourceNote")}</label>
                <Input
                  value={editSourceNote}
                  onChange={(e) => setEditSourceNote(e.target.value)}
                  disabled={editSaving}
                />
              </div>
            )}
```

- [ ] **Step 10: Verify type check**

Run:
```bash
npx tsc --noEmit
```

Expected: No errors.

- [ ] **Step 11: Commit**

```bash
git add src/components/deals/deal-header.tsx
git commit -m "feat: display deal metadata in header and extend edit dialog"
```

---

### Task 6: Deal Form — Add New Fields for Create/Edit

**Files:**
- Modify: `src/components/deals/deal-form.tsx`

- [ ] **Step 1: Update imports and add types**

Add to the existing imports:

```typescript
import type { DealPhase, DealSource } from "@/generated/prisma/client";
```

- [ ] **Step 2: Extend DealFormProps defaultValues**

In the `DealFormProps` interface, extend the `defaultValues` type (lines 29-41):

```typescript
  defaultValues?: {
    id?: string;
    name?: string;
    codeName?: string;
    dealType?: string;
    ourRole?: string;
    clientName?: string;
    targetCompany?: string;
    jurisdictions?: string[];
    dealLeadId?: string;
    memberIds?: string[];
    summary?: string;
    phase?: string;
    dealValue?: number | null;
    valueCurrency?: string;
    keyTerms?: string;
    source?: string;
    sourceNote?: string;
  };
```

- [ ] **Step 3: Add constants for new dropdowns**

After the existing `OUR_ROLES` constant (line 46), add:

```typescript
const DEAL_PHASES: DealPhase[] = ["Intake", "DueDiligence", "Negotiation", "Signing", "Closing", "PostClosing"];
const DEAL_SOURCES: DealSource[] = ["FAReferral", "DirectClient", "PartnerReferral", "Repeat", "Other"];
const CURRENCIES = ["USD", "CNY", "EUR", "HKD", "SGD", "VND"] as const;
```

- [ ] **Step 4: Add state for new controlled fields**

After the existing `selectedMembers` state (line 61), add:

```typescript
  const [phase, setPhase] = useState(defaultValues?.phase || "Intake");
  const [valueCurrency, setValueCurrency] = useState(defaultValues?.valueCurrency || "USD");
  const [source, setSource] = useState(defaultValues?.source || "");
```

- [ ] **Step 5: Add i18n label maps for new enums**

After the existing `roleLabels` map (line 122), add:

```typescript
  const phaseLabels: Record<string, string> = {
    Intake: t("intake"),
    DueDiligence: t("dueDiligence"),
    Negotiation: t("negotiation"),
    Signing: t("signing"),
    Closing: t("closing"),
    PostClosing: t("postClosing"),
  };

  const sourceLabels: Record<string, string> = {
    FAReferral: t("faReferral"),
    DirectClient: t("directClient"),
    PartnerReferral: t("partnerReferral"),
    Repeat: t("repeat"),
    Other: t("otherSource"),
  };
```

- [ ] **Step 6: Update edit mode in handleSubmit**

In the `handleSubmit` function's edit branch (lines 88-103), add the new fields to the `updateDeal` call:

```typescript
      startTransition(() => {
        updateDeal(dealId, {
          name: formData.get("name") as string,
          codeName: (formData.get("codeName") as string) || null,
          clientName: formData.get("clientName") as string,
          targetCompany: formData.get("targetCompany") as string,
          jurisdictions,
          summary: (formData.get("summary") as string) || null,
          dealLeadId: formData.get("dealLeadId") as string,
          phase: phase as DealPhase,
          dealValue: formData.get("dealValue") ? parseFloat(formData.get("dealValue") as string) : null,
          valueCurrency,
          keyTerms: (formData.get("keyTerms") as string) || null,
          source: (source as DealSource) || null,
          sourceNote: (formData.get("sourceNote") as string) || null,
        });
      });
```

- [ ] **Step 7: Add form fields in JSX**

After the Jurisdictions field and before the Deal Lead field, add:

```tsx
          {/* Phase + Currency (side by side) */}
          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="phase">{t("phase")}</Label>
              <select
                id="phase"
                name="phase"
                value={phase}
                onChange={(e) => setPhase(e.target.value)}
                className="h-8 w-full rounded-lg border border-input bg-transparent px-2.5 text-sm outline-none focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50"
              >
                {DEAL_PHASES.map((p) => (
                  <option key={p} value={p}>
                    {phaseLabels[p]}
                  </option>
                ))}
              </select>
            </div>

            <div className="flex flex-col gap-1.5">
              <Label htmlFor="valueCurrency">{t("valueCurrency")}</Label>
              <select
                id="valueCurrency"
                name="valueCurrency"
                value={valueCurrency}
                onChange={(e) => setValueCurrency(e.target.value)}
                className="h-8 w-full rounded-lg border border-input bg-transparent px-2.5 text-sm outline-none focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50"
              >
                {CURRENCIES.map((c) => (
                  <option key={c} value={c}>{c}</option>
                ))}
              </select>
            </div>
          </div>

          {/* Deal Value */}
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="dealValue">{t("dealValue")}</Label>
            <Input
              id="dealValue"
              name="dealValue"
              type="number"
              step="0.01"
              defaultValue={defaultValues?.dealValue ?? undefined}
            />
          </div>

          {/* Key Terms */}
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="keyTerms">{t("keyTerms")}</Label>
            <Textarea
              id="keyTerms"
              name="keyTerms"
              defaultValue={defaultValues?.keyTerms}
            />
          </div>

          {/* Source + Source Note */}
          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="source">{t("source")}</Label>
              <select
                id="source"
                name="source"
                value={source}
                onChange={(e) => setSource(e.target.value)}
                className="h-8 w-full rounded-lg border border-input bg-transparent px-2.5 text-sm outline-none focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50"
              >
                <option value="">{"\u2014"}</option>
                {DEAL_SOURCES.map((s) => (
                  <option key={s} value={s}>
                    {sourceLabels[s]}
                  </option>
                ))}
              </select>
            </div>

            {source && (
              <div className="flex flex-col gap-1.5">
                <Label htmlFor="sourceNote">{t("sourceNote")}</Label>
                <Input
                  id="sourceNote"
                  name="sourceNote"
                  defaultValue={defaultValues?.sourceNote}
                />
              </div>
            )}
          </div>
```

- [ ] **Step 8: Verify type check**

Run:
```bash
npx tsc --noEmit
```

Expected: No errors.

- [ ] **Step 9: Commit**

```bash
git add src/components/deals/deal-form.tsx
git commit -m "feat: add deal metadata fields to DealForm"
```

---

### Task 7: Deal List — Add Phase and Value Columns

**Files:**
- Modify: `src/components/deals/deal-list.tsx`

- [ ] **Step 1: Update imports**

Add import at the top:

```typescript
import { DealPhaseBadge } from "./deal-phase-badge";
import type { DealPhase } from "@/generated/prisma/client";
```

- [ ] **Step 2: Extend DealListItem interface**

Add new fields to the `DealListItem` interface (after `dealLead` on line 20):

```typescript
  phase: DealPhase;
  dealValue: number | null;
  valueCurrency: string;
```

- [ ] **Step 3: Extend translations prop**

Add to the `translations` type in `DealListProps` (after `tasks` on line 37):

```typescript
    phase: string;
    dealValue: string;
```

- [ ] **Step 4: Add table headers**

In the `<TableHeader>`, after the status `<TableHead>` (line 49), add:

```tsx
          <TableHead>{translations.phase}</TableHead>
          <TableHead>{translations.dealValue}</TableHead>
```

- [ ] **Step 5: Add table cells**

In the `<TableRow>` mapping, after the status `<TableCell>` (line 76), add:

```tsx
              <TableCell>
                <DealPhaseBadge phase={deal.phase} locale={locale} />
              </TableCell>
              <TableCell className="text-muted-foreground">
                {deal.dealValue !== null
                  ? `${deal.valueCurrency} ${deal.dealValue.toLocaleString(locale === "zh" ? "zh-CN" : "en-US", { minimumFractionDigits: 0, maximumFractionDigits: 2 })}`
                  : "\u2014"}
              </TableCell>
```

- [ ] **Step 6: Verify type check**

Run:
```bash
npx tsc --noEmit
```

Expected: Will show errors in pages that don't pass the new required props yet — that's expected, fixed in Task 8.

- [ ] **Step 7: Commit**

```bash
git add src/components/deals/deal-list.tsx
git commit -m "feat: add Phase and Value columns to deal list table"
```

---

### Task 8: Update Pages — Pass New Fields Through

**Files:**
- Modify: `src/app/[locale]/deals/[dealId]/page.tsx:126-137`
- Modify: `src/app/[locale]/deals/page.tsx:29-40,55-66`

- [ ] **Step 1: Update deal detail page — pass new fields to DealHeader**

In `src/app/[locale]/deals/[dealId]/page.tsx`, update the `<DealHeader>` props (lines 126-137) to include the new fields:

```tsx
      <DealHeader
        deal={{
          id: deal.id,
          name: deal.name,
          codeName: deal.codeName,
          status: deal.status,
          clientName: deal.clientName,
          targetCompany: deal.targetCompany,
          jurisdictions: deal.jurisdictions,
          summary: deal.summary,
          dealLead: deal.dealLead,
          phase: deal.phase,
          dealValue: deal.dealValue ? Number(deal.dealValue) : null,
          valueCurrency: deal.valueCurrency,
          keyTerms: deal.keyTerms,
          source: deal.source,
          sourceNote: deal.sourceNote,
        }}
      />
```

Note: `deal.dealValue` is a Prisma `Decimal`, so we convert with `Number()` — same pattern used in `billing.ts:134`.

- [ ] **Step 2: Update deals list page — include new fields in query**

In `src/app/[locale]/deals/page.tsx`, the Prisma query (lines 29-40) already uses `include` which returns all Deal fields. But the `DealList` translations prop needs updating.

Update the `<DealList>` component call (lines 55-67) to pass new translation props:

```tsx
        <DealList
          deals={deals.map((d) => ({
            ...d,
            dealValue: d.dealValue ? Number(d.dealValue) : null,
          }))}
          locale={locale}
          translations={{
            name: t("name"),
            codeName: t("codeName"),
            clientName: t("clientName"),
            targetCompany: t("targetCompany"),
            status: t("status"),
            dealLead: t("dealLead"),
            tasks: tTask("tasks"),
            phase: t("phase"),
            dealValue: t("dealValue"),
          }}
        />
```

Note: We map deals to convert `Decimal` to `number` for `dealValue`.

- [ ] **Step 3: Verify type check passes**

Run:
```bash
npx tsc --noEmit
```

Expected: No errors — all type contracts are now satisfied.

- [ ] **Step 4: Verify dev server builds**

Run:
```bash
npm run dev
```

Navigate to the deals list and a deal detail page. Verify:
- Deal list shows Phase and Value columns
- Deal detail header shows phase badge, value, and source
- Edit dialog has all new fields
- Creating a new deal includes the new fields

- [ ] **Step 5: Commit**

```bash
git add src/app/[locale]/deals/[dealId]/page.tsx src/app/[locale]/deals/page.tsx
git commit -m "feat: pass deal metadata fields through to DealHeader and DealList"
```

---

## Summary

After completing all 8 tasks:

1. **Schema**: `DealPhase` and `DealSource` enums exist, `Deal` has 6 new fields
2. **i18n**: EN and ZH translations for all new fields and enum values
3. **Server actions**: `createDeal` and `updateDeal` handle all new fields
4. **UI**: Phase badge (distinct from status), value display, source display, keyTerms collapsible, edit dialog with all fields, create form with all fields, list table with phase + value columns

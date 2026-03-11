# Deal Metadata Enhancements — Design Spec

## Goal

Add deal phase, transaction value, and deal source fields to the Deal model, with corresponding UI updates across deal header, deal form, and deal list.

## Context

Project Epsilon simulation revealed that key project information — stage, financial terms, sourcing — has no structured place in the system. Teams rely on activity logs and summary text to find this information, which is fragile and hard to reference.

## Schema Changes

### New Enums

```prisma
enum DealPhase {
  Intake        // 立项
  DueDiligence  // 尽调
  Negotiation   // 谈判
  Signing       // 签约
  Closing       // 交割
  PostClosing   // 结项
}

enum DealSource {
  FAReferral      // FA引荐
  DirectClient    // 客户直接委托
  PartnerReferral // 合伙人转介
  Repeat          // 老客户新项目
  Other           // 其他
}
```

### Deal Model Additions

```prisma
model Deal {
  // ... existing fields ...

  phase         DealPhase   @default(Intake)
  dealValue     Decimal?    @db.Decimal(18, 2)
  valueCurrency String      @default("USD")
  keyTerms      String?     // Free-text core commercial terms (escrow, indemnity cap, lock-box, etc.)
  source        DealSource?
  sourceNote    String?     // e.g. "Golden Bridge Capital / Michael Chen"
}
```

## UI Changes

### Deal Header (`deal-header.tsx`)

- Show phase badge next to status badge (distinct color from status)
- Show deal value + currency below deal name (e.g. "USD 48,000,000")
- Show source as small text if present (e.g. "FA引荐 — Golden Bridge Capital")
- keyTerms: collapsible section below summary (same pattern as existing summary toggle)
- Edit dialog: add phase, dealValue, valueCurrency, keyTerms, source, sourceNote fields

### Deal Form (`deal-form.tsx`)

New fields in create/edit form:
- Phase: dropdown select (default: Intake)
- Deal Value: number input + currency select (USD/CNY/EUR/HKD/SGD/VND)
- Key Terms: textarea
- Source: dropdown select
- Source Note: text input (shown when source is selected)

### Deal List (`deal-list.tsx`)

- Add "阶段/Phase" column after status
- Add "金额/Value" column showing formatted value + currency
- Both columns visible in the table

### Deal Detail Page (`deals/[dealId]/page.tsx`)

- Pass new fields to DealHeader

### Server Action (`updateDeal`)

- Already accepts arbitrary fields — just needs the new field names added to the type signature

## i18n

### en.json additions (under "deal")

```json
{
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
  "other": "Other"
}
```

### zh.json additions (under "deal")

```json
{
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
  "other": "其他"
}
```

## Migration

- Prisma migration adds new columns with defaults (phase=Intake, valueCurrency="USD", others nullable)
- Existing deals get phase=Intake by default — correct since we can't infer phase from existing data
- No data migration needed

## Non-Goals

- Phase auto-advancement based on milestone completion (future enhancement)
- Financial reporting/analytics across deals (future enhancement)
- Currency conversion (display as-is)

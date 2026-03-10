# DealFlow — Design Specification

> **Version**: v1.0
> **Date**: 2026-03-10
> **Status**: Approved
> **Based on**: prd.md v0.1 (2026-03-09)

---

## 1. Product Summary

DealFlow is a project management system for a ~10-person cross-border M&A legal team at a Chinese law firm. It replaces the current workflow of email + WeChat + memory-based tracking with a single system where every team member — including newcomers — can see where a deal stands, what happened, and what's next.

### Core Problem

Team knowledge lives in people's heads, email threads, and WeChat messages. There is no single source of truth for deal status, task ownership, or decision history.

### Design Principles

1. **Practical over flashy** — every feature must pass: "Would a junior associate use this at 11pm while drafting a BO?"
2. **Clean, polished UI** — professional aesthetic, but zero unnecessary complexity
3. **Parallel workstreams are the reality** — deals have 5-10 things happening simultaneously, not neat sequential phases
4. **Cross-dependencies matter** — a DD finding affects SPA terms, which affects regulatory strategy
5. **Newcomer-friendly** — a new team member should understand a deal's full context by reading one page

---

## 2. Tech Stack

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Framework | Next.js 14+ (App Router) | Single codebase (frontend + API), fast iteration |
| Language | TypeScript | End-to-end type safety |
| UI | shadcn/ui + Tailwind CSS | Modern components, highly customizable |
| Database | PostgreSQL 16 | Free, open source, same for local and cloud |
| ORM | Prisma | Type-safe queries, migrations, works with PostgreSQL |
| Auth | NextAuth.js | Simple session management |
| Deployment (local) | Docker Compose (PostgreSQL + Next.js) | Zero-config local setup |
| Deployment (cloud) | Vercel + managed PostgreSQL, or Docker on VPS | Flexible migration path |

**Architecture**: Monolithic Next.js — one codebase, one deploy target. API routes co-located with frontend. Refactor to separate services only if/when needed.

---

## 3. Core Architecture: Milestones + Workstreams

### Key Shift from PRD

The PRD organized deals around sequential "Phases." The real workflow has 5-10 parallel workstreams running simultaneously with cross-dependencies. The new architecture:

- **Milestones** — key events on a horizontal timeline (NDA Signed, BO Due, Signing, Closing). These are dates/checkpoints, not containers.
- **Workstreams** — parallel tracks of actual work (DD, SPA Negotiation, Regulatory, etc.). Each contains tasks. Multiple workstreams are active simultaneously.
- **Activity Feed** — chronological log of everything that happens on a deal. The single source of truth.

```
Deal
├── Milestones (horizontal timeline at top)
│   ● NDA Signed ── ● NBO Due ── ◉ BO Due (Apr 15) ── ○ Signing ── ○ Closing
│
├── Workstreams (parallel tracks, the daily work)
│   ├── Due Diligence [4/7 tasks done]
│   ├── SPA Negotiation [2/5 tasks done]
│   ├── Regulatory [0/4 tasks done]
│   ├── Deal Structure & Tax [3/3 tasks done]
│   └── CP Tracker [0/12 CPs satisfied]  ← post-signing
│
├── Activity Feed (what happened, in chronological order)
│
├── Decisions (problem → analysis → options → client decision)
├── Contacts (people involved in this deal)
└── Documents (files)
```

---

## 4. Data Model

### Entities

**Deal**

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| name | Text | Yes | e.g., "Acquisition of Schmidt GmbH" |
| codeName | Text | No | e.g., "Project Eagle" |
| dealType | Enum | Yes | Auction / Negotiated / JV |
| ourRole | Enum | Yes | BuySide / SellSide / LeadParty / ParticipatingParty |
| clientName | Text | Yes | |
| targetCompany | Text | Yes | |
| jurisdictions | Text[] | Yes | Multi-select |
| dealLead | Relation → User | Yes | |
| status | Enum | Yes | Active / OnHold / Completed |
| summary | Text | No | Brief deal context for newcomers |
| createdAt | Timestamp | Auto | |
| updatedAt | Timestamp | Auto | |

**Milestone**

| Field | Type | Notes |
|-------|------|-------|
| name | Text | e.g., "BO Due", "Signing" |
| date | Date | Target date |
| type | Enum | External / Contractual / Regulatory / Internal / Custom |
| status | Computed | Upcoming / Done / Overdue (auto from date + done flag) |
| isDone | Boolean | Manually marked done |
| reminders | JSON | Array of reminder offsets (e.g., 7d, 3d, 1d) |
| dealId | Relation → Deal | |
| sortOrder | Int | Position on timeline |

**Workstream**

| Field | Type | Notes |
|-------|------|-------|
| name | Text | e.g., "Due Diligence", "SPA Negotiation" |
| description | Text | Optional context |
| dealId | Relation → Deal | |
| sortOrder | Int | Display order |
| createdAt | Timestamp | |

**Task**

| Field | Type | Notes |
|-------|------|-------|
| title | Text | |
| description | Text | Plain text / markdown |
| workstreamId | Relation → Workstream | |
| assigneeId | Relation → User | Optional |
| priority | Enum | High / Normal |
| dueDate | Date | Optional |
| status | Enum | ToDo / InProgress / Done |
| sortOrder | Int | Within workstream |
| createdAt | Timestamp | |
| updatedAt | Timestamp | |

**Subtask**

| Field | Type | Notes |
|-------|------|-------|
| title | Text | |
| isDone | Boolean | |
| taskId | Relation → Task | Parent task |
| sortOrder | Int | |

**TaskDependency**

| Field | Type | Notes |
|-------|------|-------|
| taskId | Relation → Task | |
| dependsOnTaskId | Relation → Task | |
| type | Enum | blocks / relatedTo |

**TaskComment**

| Field | Type | Notes |
|-------|------|-------|
| taskId | Relation → Task | |
| authorId | Relation → User | |
| content | Text | |
| createdAt | Timestamp | |

**ActivityEntry**

| Field | Type | Notes |
|-------|------|-------|
| dealId | Relation → Deal | |
| workstreamId | Relation → Workstream | Optional — links to a workstream |
| type | Enum | Note / Call / Meeting / ClientInstruction / TaskUpdate / MilestoneChange / DecisionCreated / DocumentUpload |
| content | Text | |
| authorId | Relation → User | |
| createdAt | Timestamp | |

**Decision**

| Field | Type | Notes |
|-------|------|-------|
| dealId | Relation → Deal | |
| workstreamId | Relation → Workstream | Optional |
| title | Text | e.g., "Target has undisclosed material litigation" |
| background | Text | Problem description and context |
| source | Enum | DDFinding / Negotiation / Regulatory / Other |
| analysis | Text | Legal analysis, risk assessment |
| clientDecision | Text | What the client decided |
| status | Enum | PendingAnalysis / Reported / Decided / Implemented |
| createdAt | Timestamp | |
| updatedAt | Timestamp | |

**DecisionOption**

| Field | Type | Notes |
|-------|------|-------|
| decisionId | Relation → Decision | |
| description | Text | Option description |
| prosAndCons | Text | |
| sortOrder | Int | |

**Contact**

| Field | Type | Notes |
|-------|------|-------|
| name | Text | |
| organization | Text | Firm, company, bank, etc. |
| role | Enum | Client / CounterpartyCounsel / ExternalCounsel / FA / Accountant / Regulator / Other |
| title | Text | Optional |
| email | Text | Optional |
| phone | Text | Optional |
| timezone | Text | Optional — for cross-timezone awareness |
| notes | Text | Optional |

**DealContact** (join table)

| Field | Type | Notes |
|-------|------|-------|
| dealId | Relation → Deal | |
| contactId | Relation → Contact | |
| roleInDeal | Text | e.g., "US Corporate DD Lead" |

**Document**

| Field | Type | Notes |
|-------|------|-------|
| name | Text | File name |
| filePath | Text | Storage path |
| dealId | Relation → Deal | |
| workstreamId | Relation → Workstream | Optional |
| taskId | Relation → Task | Optional |
| uploadedById | Relation → User | |
| createdAt | Timestamp | |

**AuditLog**

| Field | Type | Notes |
|-------|------|-------|
| userId | Relation → User | |
| action | Text | e.g., "task.status.changed" |
| entityType | Text | e.g., "Task", "Deal", "Decision" |
| entityId | Text | |
| changes | JSON | { field: { from, to } } |
| createdAt | Timestamp | |

**User**

| Field | Type | Notes |
|-------|------|-------|
| name | Text | |
| email | Text | Unique |
| passwordHash | Text | |
| role | Enum | Admin / Member |
| locale | Enum | zh / en |

**Template**

| Field | Type | Notes |
|-------|------|-------|
| name | Text | e.g., "Auction — Buy-Side" |
| dealType | Enum | Auction / Negotiated / JV |
| ourRole | Enum | BuySide / SellSide / LeadParty / ParticipatingParty |
| definition | JSON | { milestones: [...], workstreams: [{ name, tasks: [...] }] } |
| isSystem | Boolean | Pre-built vs. user-created |

### Key Relationships

```
Deal 1──n Milestone
Deal 1──n Workstream
Deal 1──n ActivityEntry
Deal 1──n Decision
Deal n──m Contact (via DealContact, with roleInDeal)
Deal n──m User (team members, via join table)
Workstream 1──n Task
Task 1──n Subtask
Task 1──n TaskComment
Task 1──n Document (attachments)
Task n──m Task (via TaskDependency)
Decision 1──n DecisionOption
Decision n──m Task (via link table, cross-references)
```

---

## 5. UI Layout

### App Shell

```
┌─────────────────────────────────────────────────────────┐
│  DealFlow    [Dashboard] [Deals] [My Tasks] [Contacts]  │
│              [Search]                    [avatar ▼]      │
└─────────────────────────────────────────────────────────┘
```

### Dashboard (Home Page)

Fixed layout, no customization:

```
┌──────────────────────┬──────────────────────┐
│  My Tasks            │  Upcoming Milestones │
│  (overdue first,     │  (next 14 days,      │
│   then by due date)  │   across all deals)  │
├──────────────────────┴──────────────────────┤
│  Active Deals                                │
│  (cards showing name, client, target,        │
│   task completion counts)                    │
├──────────────────────────────────────────────┤
│  Recent Activity (across all deals)          │
└──────────────────────────────────────────────┘
```

### Deal List Page

Simple table: name, code name, client, target, status, deal lead, task progress. Sortable columns. Filter by status.

### Deal Detail Page (core page)

```
┌──────────────────────────────────────────────────────────────┐
│  ← Deals    Deal Name                [Active ▼]  [⚙]       │
│  Client: X | Target: Y | Lead: Z                            │
│  Summary: Brief deal context for newcomers (collapsible)     │
├──────────────────────────────────────────────────────────────┤
│  MILESTONES                                                  │
│  ● NDA ── ● NBO ── ◉ BO (Apr 15) ── ○ Signing ── ○ Closing │
├──────────────────────────────────────────────────────────────┤
│  [Filter: All ▼] [Assignee ▼] [Status ▼]   [Activity ◀▶]  │
├────────────────────────────────┬─────────────────────────────┤
│  WORKSTREAMS                   │  ACTIVITY FEED (collapsible)│
│                                │                             │
│  ▼ Due Diligence [4/7]        │  [10:30] DD report uploaded │
│    □ Corporate DD              │  [09:00] Client call re:   │
│    □ IP DD                     │    pricing strategy         │
│    ...                         │  [+ Add note]              │
│  ▼ SPA Negotiation [2/5]     │                             │
│    □ Draft SPA                 │                             │
│  [+ Add Workstream]           │                             │
├────────────────────────────────┴─────────────────────────────┤
│  [Decisions (3)] [Contacts (12)] [Documents (47)]           │
└──────────────────────────────────────────────────────────────┘
```

- Click task → slide-over panel from right (title, description, assignee, status, due date, priority, dependencies, comments, attachments, links)
- Activity Feed collapsible to give more space to workstreams
- Deal Summary collapsible after first read

### My Tasks Page

All tasks assigned to current user, across all deals. Grouped by deal, sorted by urgency (overdue → due soon → no date). Filter by deal, status.

### Contacts Page

Global directory. Search by name, organization, role. Click → see all linked deals.

---

## 6. Core Workflows

### Creating a Deal

1. Click [+ New Deal]
2. Fill form: name, code name, type, role, client, target, jurisdictions, lead, team members, summary
3. Select template (auto-matched from type + role, or manual)
4. System generates milestones, workstreams, and checklist tasks from template
5. User lands on Deal Detail page, customizes as needed

### Daily Task Work

1. Open Dashboard → see My Tasks sorted by urgency
2. Click task → slide-over panel
3. Update status, add comment, attach file
4. System auto-posts to Activity Feed

### Logging a Communication

1. On Deal Detail page, click [+ Add note] in Activity Feed
2. Select type: Note / Call / Meeting / Client Instruction
3. Optionally link to a workstream
4. Write content
5. Optionally create action items → converted into Tasks in relevant workstream

### Recording a Decision

1. Click Decisions tab → [+ New Decision]
2. Fill: title, background, source workstream, analysis, options (with pros/cons)
3. Status starts at PendingAnalysis
4. Update to Reported → Decided (fill client decision) → Implemented
5. Link to related tasks across workstreams

### Cross-Linking Items

1. From any task or decision, click [+ Link]
2. Search/select target item (task, decision)
3. Choose relationship: blocks / blocked by / related to
4. Both items show the link in their detail panels

### New Team Member Onboarding

1. Added to deal as team member
2. Opens Deal Detail page
3. Reads Summary (deal context)
4. Sees Milestones (lifecycle position)
5. Scans Workstreams (what's happening)
6. Reads Activity Feed (what happened)
7. Checks Decisions (key choices made)
8. Full context acquired without asking anyone

---

## 7. Deal Templates

6 pre-built templates. All milestones, workstreams, and tasks are fully editable after deal creation. Users can save a completed deal as a new template.

### Template 1: Auction — Buy-Side

**Milestones**: NDA Signed → NBO Due → BO Due → Signing → Closing

**Workstreams**:

```
├── Due Diligence
│   □ Sign NDA and access VDR
│   □ Phase 1 DD — coordinate external counsel across jurisdictions
│   □ Phase 2 DD — deep dive, management presentations
│   □ Compile Key Issue List
│   □ Confirm all DD reports received
│
├── SPA & Documentation
│   □ Review seller's draft SPA
│   □ Internal review and mark-up
│   □ Negotiate reps & warranties, indemnities, CPs
│   □ Final SPA agreed
│
├── Regulatory
│   □ Identify required filings (antitrust, FDI, industry-specific)
│   □ Pre-consultation with regulators
│   □ Prepare and submit filings
│   □ Track review periods and respond to queries
│
├── Deal Structure & Tax
│   □ Confirm acquisition vehicle (direct / SPV / JV)
│   □ Obtain tax structuring advice
│   □ Finalize funding and financing arrangements
│
├── Client Communication & Strategy
│   □ Initial client briefing and engagement letter
│   □ Pricing strategy discussion
│   □ Prepare NBO / BO cover letters
│   □ Client decision on key DD findings
│   □ Pre-signing client approval
│
├── Conditions Precedent Tracker (post-signing)
│   □ Regulatory approvals (per jurisdiction)
│   □ Third-party consents (change-of-control)
│   □ Board / shareholder approvals
│   □ No material adverse change confirmation
│   □ Officer certificates
│   □ Legal opinions (each jurisdiction)
│   □ SAFE registration and fund remittance
│
└── Closing Checklist (near closing)
    □ Signature pages collected
    □ Board resolutions executed
    □ Legal opinions delivered
    □ Funds transfer instructions confirmed
    □ Closing funds wired and confirmed
    □ Share transfer / business registration filings
    □ Post-closing notices
    □ File closing binder
```

### Template 2: Auction — Sell-Side

**Milestones**: VDR Ready → Phase 1 Bids Due → Phase 2 Bids Due → Signing → Closing

**Workstreams**:

```
├── VDR & DD Management
│   □ Prepare VDR structure and populate documents
│   □ Prepare IM, Teaser, Process Letter
│   □ Manage buyer Q&A during Phase 1
│   □ Arrange management presentations for Phase 2
│   □ Respond to supplemental DD requests
│
├── Bid Management
│   □ Distribute materials to potential buyers
│   □ Collect Phase 1 NBOs
│   □ Shortlist bidders with client
│   □ Collect Phase 2 BOs and SPA mark-ups
│   □ Evaluate bids — prepare comparison memo
│
├── SPA & Documentation
│   □ Draft SPA and disclosure schedules
│   □ Review buyer mark-ups
│   □ Negotiate to final form
│
├── Regulatory
│   □ Identify buyer-side filing requirements
│   □ Support buyer regulatory filings
│   □ Track approval timelines
│
├── Client Communication & Strategy
│   □ Engagement letter and team setup
│   □ Bid evaluation and recommendation
│   □ Advise on preferred bidder selection
│   □ Pre-signing client approval
│
├── Conditions Precedent Tracker (post-signing)
│   □ Buyer regulatory approvals
│   □ Third-party consents
│   □ Buyer financing confirmation
│   □ No MAC confirmation
│   □ Legal opinions
│
└── Closing Checklist
    □ Signature pages collected
    □ Board resolutions executed
    □ Legal opinions delivered
    □ Funds receipt confirmed
    □ Share transfer / registration filings
    □ Post-closing notices
    □ File closing binder
```

### Template 3: Negotiated Deal — Buy-Side

**Milestones**: NDA Signed → LOI Signed → DD Complete → Signing → Closing

**Workstreams**:

```
├── Due Diligence
│   □ Sign NDA and request initial materials
│   □ Coordinate external counsel DD
│   □ Compile Key Issue List
│   □ Confirm all DD reports received
│
├── SPA & Documentation
│   □ Negotiate LOI / Term Sheet
│   □ Draft or review SPA
│   □ Negotiate to final form
│
├── Regulatory
│   □ Identify required filings
│   □ Pre-consultation and filings
│   □ Track review periods
│
├── Deal Structure & Tax
│   □ Confirm acquisition vehicle
│   □ Obtain tax structuring advice
│   □ Finalize financing
│
├── Client Communication & Strategy
│   □ Engagement letter and team setup
│   □ LOI strategy discussion
│   □ Client decisions on key DD findings
│   □ Pre-signing approval
│
├── Conditions Precedent Tracker (post-signing)
│   □ Regulatory approvals
│   □ Third-party consents
│   □ Board / shareholder approvals
│   □ No MAC confirmation
│   □ Legal opinions
│   □ SAFE registration and fund remittance
│
└── Closing Checklist
    □ Signature pages collected
    □ Board resolutions executed
    □ Legal opinions delivered
    □ Funds transfer confirmed
    □ Share transfer / registration filings
    □ Post-closing notices
    □ File closing binder
```

### Template 4: Negotiated Deal — Sell-Side

**Milestones**: NDA Signed → LOI Signed → DD Complete → Signing → Closing

**Workstreams**:

```
├── DD Preparation & Support
│   □ Prepare VDR / information packages
│   □ Respond to buyer DD requests
│   □ Coordinate management access
│
├── SPA & Documentation
│   □ Negotiate LOI / Term Sheet
│   □ Review buyer's draft SPA (or draft our own)
│   □ Negotiate to final form
│
├── Regulatory
│   □ Support buyer regulatory filings
│   □ Track approval timelines
│
├── Client Communication & Strategy
│   □ Engagement letter and team setup
│   □ LOI strategy discussion
│   □ Pre-signing approval
│
├── Conditions Precedent Tracker (post-signing)
│   □ Buyer regulatory approvals
│   □ Third-party consents
│   □ Buyer financing confirmation
│   □ No MAC confirmation
│
└── Closing Checklist
    □ Signature pages collected
    □ Board resolutions executed
    □ Legal opinions delivered
    □ Funds receipt confirmed
    □ Share transfer / registration filings
    □ File closing binder
```

### Template 5: Joint Venture — Lead Party

**Milestones**: MOU Signed → DD Complete → JV Agreement Signed → Incorporation → Operational Launch

**Workstreams**:

```
├── Due Diligence
│   □ Bilateral DD (if applicable)
│   □ Partner background and financial check
│   □ Key Issue List
│
├── JV Agreement & Governance
│   □ Draft MOU / Framework Agreement
│   □ Negotiate JV agreement and articles of association
│   □ Design governance structure (board, voting, deadlock)
│   □ Shareholder agreement
│
├── Regulatory
│   □ Foreign investment review
│   □ Antitrust filing (if thresholds met)
│   □ Industry-specific approvals
│
├── Commercial & Structure
│   □ Contribution ratios and valuation
│   □ IP licensing arrangements
│   □ Operational planning
│
├── Client Communication & Strategy
│   □ Engagement letter and team setup
│   □ Partner negotiation strategy
│   □ Client decisions on governance and economics
│
├── Conditions Precedent Tracker (post-signing)
│   □ Regulatory approvals
│   □ Partner capital contribution confirmation
│   □ Third-party consents
│   □ IP transfer / licensing execution
│
└── Incorporation & Launch Checklist
    □ JV company registration
    □ Business licenses obtained
    □ Bank accounts opened
    □ Initial capital contributed
    □ First board meeting held
    □ Key personnel appointed
```

### Template 6: Joint Venture — Participating Party

**Milestones**: MOU Signed → DD Complete → JV Agreement Signed → Incorporation → Operational Launch

**Workstreams**:

```
├── Due Diligence
│   □ Review lead party's DD materials
│   □ Independent verification where needed
│
├── JV Agreement & Governance
│   □ Review lead party's draft JV agreement
│   □ Negotiate protective provisions (veto rights, exit mechanisms)
│   □ Shareholder agreement review
│
├── Regulatory
│   □ Own regulatory filings
│   □ Track lead party's filing progress
│
├── Commercial & Structure
│   □ Review contribution terms and valuation
│   □ Negotiate IP and operational arrangements
│
├── Client Communication & Strategy
│   □ Engagement letter and team setup
│   □ Protective rights strategy
│   □ Client decisions on key terms
│
├── Conditions Precedent Tracker (post-signing)
│   □ Regulatory approvals
│   □ Lead party capital contribution confirmation
│   □ Third-party consents
│
└── Incorporation & Launch Checklist
    □ JV company registration
    □ Bank accounts opened
    □ Initial capital contributed
    □ Board seat confirmed
    □ Key personnel appointed
```

---

## 8. Simplification Rules

| Aspect | Rule |
|--------|------|
| Task status | ToDo / InProgress / Done (3 states only) |
| Task priority | High / Normal (2 levels only) |
| Deal status | Active / OnHold / Completed (3 states only) |
| Milestone status | Upcoming / Done / Overdue (auto-calculated from date + isDone flag) |
| Workstream progress | "4/7 tasks done" (auto-counted, no percentages) |
| Tags | No free-form tagging in MVP. Fixed categories per entity type. |
| Permissions | Admin / Member only. No complex RBAC. |
| Dashboard | Fixed layout, no customizable widgets. |
| Rich text | Markdown in text fields. No heavyweight WYSIWYG editor. |

---

## 9. MVP Scope

### Included

- Deal CRUD with template-based creation
- Milestone timeline (horizontal, with reminders)
- Workstreams with tasks (parallel tracks, task dependencies, cross-linking)
- Task detail panel (slide-over: description, assignee, status, priority, due date, dependencies, comments, attachments)
- Activity Feed (manual notes + auto-generated from task/milestone changes)
- Decision Archive (problem → analysis → options → client decision)
- CP Tracker (post-signing conditions tracking)
- Closing Checklist
- Contacts (global directory, linked to deals with roles)
- Documents (file attachments on tasks, workstreams, deals)
- 6 pre-built deal templates
- Save deal as new template
- Dashboard (My Tasks, Upcoming Milestones, Active Deals, Recent Activity)
- My Tasks page (cross-deal view)
- Global search (across deals, tasks, activity entries, contacts)
- Audit trail (who changed what, when)
- User system (login, team members, admin/member roles)
- Bilingual UI (Chinese / English)

### Deferred to Phase 2+

- Email integration (forwarding + AI summary)
- Speech-to-text / meeting minutes
- DD Monitoring dashboard (workstream-level progress tracking with external firms)
- Negotiation Points Tracker
- AI features (email summary, meeting minutes, action item extraction)
- Time tracking
- Gantt charts
- Workflow automation (rule-based triggers)
- Mobile app
- Report export (Word / PDF)
- Playbook notes on templates
- Document AI analysis (upload DD report → extract key issues)
- OAuth email ingestion (Gmail / Outlook)
- WeChat Work / WeChat push notifications
- Calendar subscription (iCal export)

---

## 10. Non-Functional Requirements

| Requirement | Target |
|-------------|--------|
| Page load time | < 2 seconds |
| Concurrent users | 10 (current team size) |
| Data security | HTTPS, encrypted passwords, encrypted file storage |
| Database backups | Daily automated backups |
| Browser support | Chrome, Safari, Edge (latest) |
| Responsive | Desktop-first, usable on tablet |
| i18n | Chinese and English, switchable per user |
| Deployment | Docker Compose for local; flexible cloud deployment |

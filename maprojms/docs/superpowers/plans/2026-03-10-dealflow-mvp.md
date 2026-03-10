# DealFlow MVP Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a working M&A legal project management system with deal templates, milestone timelines, parallel workstreams with tasks, activity feed, decisions, contacts, and documents.

**Architecture:** Monolithic Next.js 16 App Router with Server Actions for mutations, Prisma 7 ORM on PostgreSQL, Auth.js v5 for authentication, next-intl for bilingual support (zh/en), shadcn/ui + Tailwind for UI.

**Tech Stack:** Next.js 16, TypeScript, PostgreSQL 16, Prisma 7, Auth.js v5, next-intl, shadcn/ui, Tailwind CSS, Vitest, Docker Compose

**Design Spec:** `docs/plans/2026-03-10-dealflow-design.md`

---

## File Structure

```
dealflow/
├── prisma/
│   ├── schema.prisma                    # Full data model
│   ├── seed.ts                          # Seed templates + demo data
│   └── migrations/
├── src/
│   ├── app/
│   │   ├── [locale]/
│   │   │   ├── layout.tsx               # Root layout with providers
│   │   │   ├── page.tsx                 # Redirect to /dashboard
│   │   │   ├── login/
│   │   │   │   └── page.tsx             # Login page
│   │   │   ├── dashboard/
│   │   │   │   └── page.tsx             # Dashboard (home)
│   │   │   ├── deals/
│   │   │   │   ├── page.tsx             # Deal list
│   │   │   │   ├── new/
│   │   │   │   │   └── page.tsx         # Create deal form
│   │   │   │   └── [dealId]/
│   │   │   │       ├── page.tsx         # Deal detail (core page)
│   │   │   │       ├── decisions/
│   │   │   │       │   └── page.tsx     # Decisions tab
│   │   │   │       ├── contacts/
│   │   │   │       │   └── page.tsx     # Deal contacts tab
│   │   │   │       └── documents/
│   │   │   │           └── page.tsx     # Deal documents tab
│   │   │   ├── tasks/
│   │   │   │   └── page.tsx             # My Tasks (cross-deal)
│   │   │   ├── contacts/
│   │   │   │   └── page.tsx             # Global contacts
│   │   │   └── search/
│   │   │       └── page.tsx             # Global search
│   │   │   ├── admin/
│   │   │   │   └── users/
│   │   │   │       └── page.tsx         # User management (admin only)
│   │   └── api/
│   │       ├── auth/[...nextauth]/
│   │       │   └── route.ts             # Auth.js route handler
│   │       └── documents/[id]/
│   │           └── download/
│   │               └── route.ts         # Authenticated document download
│   ├── actions/
│   │   ├── deals.ts                     # Deal CRUD server actions
│   │   ├── users.ts                     # User management actions
│   │   ├── workstreams.ts               # Workstream CRUD
│   │   ├── tasks.ts                     # Task CRUD, dependencies, comments
│   │   ├── milestones.ts                # Milestone CRUD
│   │   ├── activity.ts                  # Activity feed entries
│   │   ├── decisions.ts                 # Decision CRUD
│   │   ├── contacts.ts                  # Contact CRUD
│   │   ├── documents.ts                 # Document upload/management
│   │   └── templates.ts                 # Template operations
│   ├── components/
│   │   ├── ui/                          # shadcn/ui components
│   │   ├── layout/
│   │   │   ├── app-shell.tsx            # Top nav + page container
│   │   │   └── locale-switcher.tsx      # zh/en toggle
│   │   ├── deals/
│   │   │   ├── deal-list.tsx            # Deal table
│   │   │   ├── deal-form.tsx            # Create/edit deal form
│   │   │   ├── deal-header.tsx          # Deal info card + summary
│   │   │   └── deal-status-badge.tsx    # Status pill
│   │   ├── milestones/
│   │   │   ├── milestone-timeline.tsx   # Horizontal timeline
│   │   │   ├── milestone-form.tsx       # Add/edit milestone
│   │   │   └── milestone-item.tsx       # Single milestone node
│   │   ├── workstreams/
│   │   │   ├── workstream-list.tsx      # All workstreams for a deal
│   │   │   ├── workstream-section.tsx   # Collapsible workstream with tasks
│   │   │   └── workstream-form.tsx      # Add/edit workstream
│   │   ├── tasks/
│   │   │   ├── task-row.tsx             # Task in workstream list
│   │   │   ├── task-panel.tsx           # Slide-over detail panel
│   │   │   ├── task-form.tsx            # Create/edit task
│   │   │   ├── task-comments.tsx        # Comment thread
│   │   │   ├── task-dependencies.tsx    # Dependency links
│   │   │   └── task-filters.tsx         # Filter bar
│   │   ├── activity/
│   │   │   ├── activity-feed.tsx        # Feed list
│   │   │   ├── activity-entry.tsx       # Single entry
│   │   │   └── activity-form.tsx        # Add manual note
│   │   ├── decisions/
│   │   │   ├── decision-list.tsx        # Decisions for a deal
│   │   │   ├── decision-detail.tsx      # Full decision view
│   │   │   └── decision-form.tsx        # Create/edit decision
│   │   ├── contacts/
│   │   │   ├── contact-list.tsx         # Contact table
│   │   │   └── contact-form.tsx         # Create/edit contact
│   │   ├── documents/
│   │   │   ├── document-list.tsx        # Document table
│   │   │   └── document-upload.tsx      # Upload component
│   │   └── dashboard/
│   │       ├── my-tasks-widget.tsx      # My tasks section
│   │       ├── milestones-widget.tsx    # Upcoming milestones
│   │       ├── active-deals-widget.tsx  # Deal cards
│   │       └── recent-activity-widget.tsx # Cross-deal activity
│   ├── lib/
│   │   ├── prisma.ts                    # Prisma client singleton
│   │   ├── auth.ts                      # Auth.js config
│   │   ├── utils.ts                     # cn() helper + general utils
│   │   ├── audit.ts                     # Audit log helper
│   │   └── templates/
│   │       ├── index.ts                 # Template loader
│   │       ├── auction-buy-side.ts      # Template definition
│   │       ├── auction-sell-side.ts
│   │       ├── negotiated-buy-side.ts
│   │       ├── negotiated-sell-side.ts
│   │       ├── jv-lead-party.ts
│   │       └── jv-participating-party.ts
│   ├── hooks/
│   │   └── use-task-panel.ts            # Slide-over panel state
│   ├── types/
│   │   └── index.ts                     # Shared TypeScript types
│   └── i18n/
│       ├── routing.ts                   # next-intl routing config
│       └── request.ts                   # next-intl request config
├── messages/
│   ├── en.json                          # English translations
│   └── zh.json                          # Chinese translations
├── tests/
│   ├── setup.ts                         # Vitest setup
│   ├── actions/                         # Server action tests
│   ├── components/                      # Component tests
│   └── lib/                             # Utility tests
├── storage/
│   └── uploads/                         # Document storage (non-public, served via authenticated API)
├── public/
├── docker-compose.yml                   # PostgreSQL for dev
├── Dockerfile                           # Production build
├── .env.example                         # Environment template
├── next.config.ts
├── tailwind.config.ts
├── tsconfig.json
├── vitest.config.ts
├── components.json                      # shadcn config
└── package.json
```

---

## Chunk 1: Project Scaffolding & Database

### Task 1: Initialize Next.js project

**Files:**
- Create: `dealflow/package.json` (via CLI)
- Create: `dealflow/next.config.ts` (via CLI)
- Create: `dealflow/tsconfig.json` (via CLI)

- [ ] **Step 1: Create Next.js project**

```bash
cd /Users/BBB/ccproj/maprojms
npx create-next-app@latest dealflow --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"
```

- [ ] **Step 2: Verify it runs**

```bash
cd dealflow
npm run dev
```

Expected: App running at http://localhost:3000

- [ ] **Step 3: Stop dev server, commit**

```bash
git add dealflow/
git commit -m "feat: scaffold Next.js project"
```

### Task 2: Add Docker Compose for PostgreSQL

**Files:**
- Create: `dealflow/docker-compose.yml`
- Create: `dealflow/.env.example`
- Create: `dealflow/.env`

- [ ] **Step 1: Create docker-compose.yml**

```yaml
services:
  db:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_USER: dealflow
      POSTGRES_PASSWORD: dealflow_dev
      POSTGRES_DB: dealflow
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

- [ ] **Step 2: Create .env.example and .env**

`.env.example`:
```
DATABASE_URL="postgresql://dealflow:dealflow_dev@localhost:5432/dealflow?schema=public"
NEXTAUTH_SECRET="generate-a-secret-here"
NEXTAUTH_URL="http://localhost:3000"
```

Copy to `.env` with real values. Add `.env` to `.gitignore` (should already be there from create-next-app).

- [ ] **Step 3: Start PostgreSQL**

```bash
cd dealflow
docker compose up -d
```

Expected: PostgreSQL running on port 5432.

- [ ] **Step 4: Verify connection**

```bash
docker compose exec db psql -U dealflow -c "SELECT 1;"
```

Expected: Returns `1`.

- [ ] **Step 5: Commit**

```bash
git add docker-compose.yml .env.example
git commit -m "infra: add Docker Compose for PostgreSQL"
```

### Task 3: Set up Prisma with full schema

**Files:**
- Create: `dealflow/prisma/schema.prisma`
- Modify: `dealflow/package.json` (add prisma deps)
- Create: `dealflow/src/lib/prisma.ts`

- [ ] **Step 1: Install Prisma**

```bash
cd dealflow
npm install prisma --save-dev
npm install @prisma/client
npx prisma init
```

- [ ] **Step 2: Write the full schema**

Replace `prisma/schema.prisma` with:

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

enum DealType {
  Auction
  Negotiated
  JV
}

enum DealRole {
  BuySide
  SellSide
  LeadParty
  ParticipatingParty
}

enum DealStatus {
  Active
  OnHold
  Completed
}

enum TaskStatus {
  ToDo
  InProgress
  Done
}

enum TaskPriority {
  High
  Normal
}

enum DependencyType {
  Blocks
  RelatedTo
}

enum ActivityType {
  Note
  Call
  Meeting
  ClientInstruction
  TaskUpdate
  MilestoneChange
  DecisionCreated
  DocumentUpload
}

enum MilestoneType {
  External
  Contractual
  Regulatory
  Internal
  Custom
}

enum DecisionStatus {
  PendingAnalysis
  Reported
  Decided
  Implemented
}

enum DecisionSource {
  DDFinding
  Negotiation
  Regulatory
  Other
}

enum ContactRole {
  Client
  CounterpartyCounsel
  ExternalCounsel
  FA
  Accountant
  Regulator
  Other
}

enum UserRole {
  Admin
  Member
}

model User {
  id           String   @id @default(cuid())
  name         String
  email        String   @unique
  passwordHash String
  role         UserRole @default(Member)
  locale       String   @default("zh")
  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt

  // Relations
  assignedTasks  Task[]          @relation("TaskAssignee")
  leadDeals      Deal[]          @relation("DealLead")
  teamDeals      DealMember[]
  comments       TaskComment[]
  activityEntries ActivityEntry[]
  documents      Document[]
  auditLogs      AuditLog[]
}

model Deal {
  id            String     @id @default(cuid())
  name          String
  codeName      String?
  dealType      DealType
  ourRole       DealRole
  clientName    String
  targetCompany String
  jurisdictions String[]
  status        DealStatus @default(Active)
  summary       String?
  createdAt     DateTime   @default(now())
  updatedAt     DateTime   @updatedAt

  // Relations
  dealLeadId    String
  dealLead      User         @relation("DealLead", fields: [dealLeadId], references: [id])
  members       DealMember[]
  milestones    Milestone[]
  workstreams   Workstream[]
  activityEntries ActivityEntry[]
  decisions     Decision[]
  dealContacts  DealContact[]
  documents     Document[]

  @@index([status])
}

model DealMember {
  dealId String
  userId String
  deal   Deal   @relation(fields: [dealId], references: [id], onDelete: Cascade)
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@id([dealId, userId])
}

model Milestone {
  id        String        @id @default(cuid())
  name      String
  date      DateTime?
  type      MilestoneType @default(Custom)
  isDone    Boolean       @default(false)
  reminders Json?         // e.g. [7, 3, 1] days before
  sortOrder Int           @default(0)
  dealId    String
  deal      Deal          @relation(fields: [dealId], references: [id], onDelete: Cascade)
  createdAt DateTime      @default(now())
  updatedAt DateTime      @updatedAt

  linkedTasks MilestoneTask[]

  @@index([dealId])
}

model MilestoneTask {
  milestoneId String
  taskId      String
  milestone   Milestone @relation(fields: [milestoneId], references: [id], onDelete: Cascade)
  task        Task      @relation(fields: [taskId], references: [id], onDelete: Cascade)

  @@id([milestoneId, taskId])
}

model Workstream {
  id          String   @id @default(cuid())
  name        String
  description String?
  sortOrder   Int      @default(0)
  dealId      String
  deal        Deal     @relation(fields: [dealId], references: [id], onDelete: Cascade)
  createdAt   DateTime @default(now())

  // Relations
  tasks           Task[]
  activityEntries ActivityEntry[]
  decisions       Decision[]

  @@index([dealId])
}

model Task {
  id          String       @id @default(cuid())
  title       String
  description String?
  status      TaskStatus   @default(ToDo)
  priority    TaskPriority @default(Normal)
  dueDate     DateTime?
  sortOrder   Int          @default(0)
  createdAt   DateTime     @default(now())
  updatedAt   DateTime     @updatedAt

  // Relations
  workstreamId String
  workstream   Workstream    @relation(fields: [workstreamId], references: [id], onDelete: Cascade)
  assigneeId   String?
  assignee     User?         @relation("TaskAssignee", fields: [assigneeId], references: [id], onDelete: SetNull)
  subtasks     Subtask[]
  comments     TaskComment[]
  documents    Document[]

  // Dependencies
  blockedBy    TaskDependency[] @relation("DependentTask")
  blocks       TaskDependency[] @relation("DependencyTask")

  // Cross-links to decisions
  linkedDecisions DecisionTaskLink[]
  linkedMilestones MilestoneTask[]

  @@index([workstreamId])
  @@index([assigneeId])
  @@index([status])
}

model Subtask {
  id        String  @id @default(cuid())
  title     String
  isDone    Boolean @default(false)
  sortOrder Int     @default(0)
  taskId    String
  task      Task    @relation(fields: [taskId], references: [id], onDelete: Cascade)

  @@index([taskId])
}

model TaskDependency {
  id              String         @id @default(cuid())
  type            DependencyType
  taskId          String
  dependsOnTaskId String
  task            Task           @relation("DependentTask", fields: [taskId], references: [id], onDelete: Cascade)
  dependsOn       Task           @relation("DependencyTask", fields: [dependsOnTaskId], references: [id], onDelete: Cascade)

  @@unique([taskId, dependsOnTaskId])
}

model TaskComment {
  id        String   @id @default(cuid())
  content   String
  createdAt DateTime @default(now())
  taskId    String
  task      Task     @relation(fields: [taskId], references: [id], onDelete: Cascade)
  authorId  String
  author    User     @relation(fields: [authorId], references: [id])

  @@index([taskId])
}

model ActivityEntry {
  id        String       @id @default(cuid())
  type      ActivityType
  content   String
  createdAt DateTime     @default(now())

  dealId       String
  deal         Deal       @relation(fields: [dealId], references: [id], onDelete: Cascade)
  workstreamId String?
  workstream   Workstream? @relation(fields: [workstreamId], references: [id], onDelete: SetNull)
  authorId     String
  author       User       @relation(fields: [authorId], references: [id])

  @@index([dealId, createdAt])
}

model Decision {
  id             String         @id @default(cuid())
  title          String
  background     String?
  source         DecisionSource @default(Other)
  analysis       String?
  clientDecision String?
  status         DecisionStatus @default(PendingAnalysis)
  createdAt      DateTime       @default(now())
  updatedAt      DateTime       @updatedAt

  dealId       String
  deal         Deal        @relation(fields: [dealId], references: [id], onDelete: Cascade)
  workstreamId String?
  workstream   Workstream? @relation(fields: [workstreamId], references: [id], onDelete: SetNull)

  options     DecisionOption[]
  linkedTasks DecisionTaskLink[]

  @@index([dealId])
}

model DecisionOption {
  id          String   @id @default(cuid())
  description String
  prosAndCons String?
  sortOrder   Int      @default(0)
  decisionId  String
  decision    Decision @relation(fields: [decisionId], references: [id], onDelete: Cascade)

  @@index([decisionId])
}

model DecisionTaskLink {
  decisionId String
  taskId     String
  decision   Decision @relation(fields: [decisionId], references: [id], onDelete: Cascade)
  task       Task     @relation(fields: [taskId], references: [id], onDelete: Cascade)

  @@id([decisionId, taskId])
}

model Contact {
  id           String      @id @default(cuid())
  name         String
  organization String?
  role         ContactRole @default(Other)
  title        String?
  email        String?
  phone        String?
  timezone     String?
  notes        String?
  createdAt    DateTime    @default(now())
  updatedAt    DateTime    @updatedAt

  dealContacts DealContact[]
}

model DealContact {
  dealId     String
  contactId  String
  roleInDeal String?
  deal       Deal    @relation(fields: [dealId], references: [id], onDelete: Cascade)
  contact    Contact @relation(fields: [contactId], references: [id], onDelete: Cascade)

  @@id([dealId, contactId])
}

model Document {
  id        String   @id @default(cuid())
  name      String
  filePath  String
  createdAt DateTime @default(now())

  dealId       String
  deal         Deal       @relation(fields: [dealId], references: [id], onDelete: Cascade)
  workstreamId String?
  taskId       String?
  task         Task?      @relation(fields: [taskId], references: [id], onDelete: SetNull)
  uploadedById String
  uploadedBy   User       @relation(fields: [uploadedById], references: [id])

  @@index([dealId])
}

model AuditLog {
  id         String   @id @default(cuid())
  action     String
  entityType String
  entityId   String
  changes    Json?
  createdAt  DateTime @default(now())

  userId String
  user   User   @relation(fields: [userId], references: [id])

  @@index([entityType, entityId])
  @@index([createdAt])
}

model Template {
  id         String   @id @default(cuid())
  name       String
  dealType   DealType
  ourRole    DealRole
  definition Json     // { milestones: [...], workstreams: [{ name, tasks: [...] }] }
  isSystem   Boolean  @default(false)
  createdAt  DateTime @default(now())
  updatedAt  DateTime @updatedAt
}
```

- [ ] **Step 3: Create Prisma client singleton**

Create `src/lib/prisma.ts`:

```typescript
import { PrismaClient } from "@prisma/client";

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma = globalForPrisma.prisma ?? new PrismaClient();

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;
```

- [ ] **Step 4: Run migration**

```bash
npx prisma migrate dev --name init
```

Expected: Migration created, database tables generated.

- [ ] **Step 5: Verify with Prisma Studio**

```bash
npx prisma studio
```

Expected: Opens browser showing all tables.

- [ ] **Step 6: Commit**

```bash
git add prisma/ src/lib/prisma.ts
git commit -m "feat: add Prisma schema with full data model"
```

### Task 4: Set up Auth.js

**Files:**
- Create: `dealflow/src/lib/auth.ts`
- Create: `dealflow/src/app/api/auth/[...nextauth]/route.ts`
- Modify: `dealflow/package.json` (add deps)

- [ ] **Step 1: Install Auth.js**

```bash
npm install next-auth@beta @auth/prisma-adapter bcryptjs
npm install --save-dev @types/bcryptjs
```

- [ ] **Step 2: Create auth config**

Create `src/lib/auth.ts`:

```typescript
import NextAuth from "next-auth";
import Credentials from "next-auth/providers/credentials";
import { PrismaAdapter } from "@auth/prisma-adapter";
import { prisma } from "./prisma";
import bcrypt from "bcryptjs";

export const { handlers, auth, signIn, signOut } = NextAuth({
  adapter: PrismaAdapter(prisma),
  session: { strategy: "jwt" },
  providers: [
    Credentials({
      credentials: {
        email: { label: "Email", type: "email" },
        password: { label: "Password", type: "password" },
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) return null;

        const user = await prisma.user.findUnique({
          where: { email: credentials.email as string },
        });

        if (!user) return null;

        const passwordMatch = await bcrypt.compare(
          credentials.password as string,
          user.passwordHash
        );

        if (!passwordMatch) return null;

        return { id: user.id, name: user.name, email: user.email, role: user.role };
      },
    }),
  ],
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.id = user.id;
        token.role = (user as { role: string }).role;
      }
      return token;
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.id = token.id as string;
        (session.user as { role: string }).role = token.role as string;
      }
      return session;
    },
  },
  pages: {
    signIn: "/login",
  },
});
```

- [ ] **Step 3: Create route handler**

Create `src/app/api/auth/[...nextauth]/route.ts`:

```typescript
import { handlers } from "@/lib/auth";

export const { GET, POST } = handlers;
```

- [ ] **Step 4: Generate NEXTAUTH_SECRET**

```bash
openssl rand -base64 32
```

Add the output to `.env` as `NEXTAUTH_SECRET`.

- [ ] **Step 5: Commit**

```bash
git add src/lib/auth.ts src/app/api/auth/
git commit -m "feat: add Auth.js with credentials provider"
```

### Task 5: Set up shadcn/ui

**Files:**
- Create: `dealflow/components.json`
- Create: `dealflow/src/lib/utils.ts`
- Create: `dealflow/src/components/ui/` (multiple files)

- [ ] **Step 1: Initialize shadcn**

```bash
npx shadcn@latest init
```

Choose: New York style, Zinc base color, CSS variables.

- [ ] **Step 2: Add essential components**

```bash
npx shadcn@latest add button card input label select textarea table badge dialog sheet dropdown-menu separator avatar tabs form toast
```

- [ ] **Step 3: Verify**

Check that `src/components/ui/` contains the added components.

- [ ] **Step 4: Commit**

```bash
git add components.json src/components/ui/ src/lib/utils.ts
git commit -m "feat: add shadcn/ui with essential components"
```

### Task 6: Set up next-intl for bilingual support

**Files:**
- Create: `dealflow/messages/en.json`
- Create: `dealflow/messages/zh.json`
- Create: `dealflow/src/i18n/routing.ts`
- Create: `dealflow/src/i18n/request.ts`
- Create: `dealflow/src/middleware.ts`
- Modify: `dealflow/next.config.ts`

- [ ] **Step 1: Install next-intl**

```bash
npm install next-intl
```

- [ ] **Step 2: Create routing config**

Create `src/i18n/routing.ts`:

```typescript
import { defineRouting } from "next-intl/routing";

export const routing = defineRouting({
  locales: ["zh", "en"],
  defaultLocale: "zh",
});
```

- [ ] **Step 3: Create request config**

Create `src/i18n/request.ts`:

```typescript
import { getRequestConfig } from "next-intl/server";
import { routing } from "./routing";

export default getRequestConfig(async ({ requestLocale }) => {
  let locale = await requestLocale;
  if (!locale || !routing.locales.includes(locale as "zh" | "en")) {
    locale = routing.defaultLocale;
  }
  return {
    locale,
    messages: (await import(`../../messages/${locale}.json`)).default,
  };
});
```

- [ ] **Step 4: Create middleware**

Create `src/middleware.ts`:

```typescript
import createMiddleware from "next-intl/middleware";
import { routing } from "./i18n/routing";

export default createMiddleware(routing);

export const config = {
  matcher: ["/((?!api|_next|.*\\..*).*)"],
};
```

- [ ] **Step 5: Create initial message files**

Create `messages/en.json`:

```json
{
  "common": {
    "appName": "DealFlow",
    "save": "Save",
    "cancel": "Cancel",
    "delete": "Delete",
    "edit": "Edit",
    "create": "Create",
    "search": "Search",
    "filter": "Filter",
    "loading": "Loading...",
    "noResults": "No results"
  },
  "nav": {
    "dashboard": "Dashboard",
    "deals": "Deals",
    "myTasks": "My Tasks",
    "contacts": "Contacts"
  },
  "auth": {
    "login": "Log In",
    "logout": "Log Out",
    "email": "Email",
    "password": "Password"
  },
  "deal": {
    "newDeal": "New Deal",
    "name": "Deal Name",
    "codeName": "Code Name",
    "dealType": "Deal Type",
    "ourRole": "Our Role",
    "clientName": "Client",
    "targetCompany": "Target",
    "jurisdictions": "Jurisdictions",
    "dealLead": "Deal Lead",
    "teamMembers": "Team Members",
    "summary": "Summary",
    "status": "Status",
    "active": "Active",
    "onHold": "On Hold",
    "completed": "Completed",
    "auction": "Auction",
    "negotiated": "Negotiated",
    "jv": "Joint Venture",
    "buySide": "Buy-Side",
    "sellSide": "Sell-Side",
    "leadParty": "Lead Party",
    "participatingParty": "Participating Party"
  },
  "task": {
    "toDo": "To Do",
    "inProgress": "In Progress",
    "done": "Done",
    "high": "High",
    "normal": "Normal",
    "assignee": "Assignee",
    "dueDate": "Due Date",
    "addTask": "Add Task",
    "addComment": "Add Comment"
  },
  "milestone": {
    "addMilestone": "Add Milestone",
    "upcoming": "Upcoming",
    "done": "Done",
    "overdue": "Overdue"
  },
  "workstream": {
    "addWorkstream": "Add Workstream"
  },
  "activity": {
    "addNote": "Add Note",
    "note": "Note",
    "call": "Call",
    "meeting": "Meeting",
    "clientInstruction": "Client Instruction"
  },
  "decision": {
    "decisions": "Decisions",
    "newDecision": "New Decision",
    "background": "Background",
    "analysis": "Analysis",
    "options": "Options",
    "clientDecision": "Client Decision",
    "pendingAnalysis": "Pending Analysis",
    "reported": "Reported",
    "decided": "Decided",
    "implemented": "Implemented"
  },
  "contact": {
    "name": "Name",
    "organization": "Organization",
    "role": "Role",
    "email": "Email",
    "phone": "Phone",
    "timezone": "Timezone"
  },
  "dashboard": {
    "myTasks": "My Tasks",
    "upcomingMilestones": "Upcoming Milestones",
    "activeDeals": "Active Deals",
    "recentActivity": "Recent Activity"
  }
}
```

Create `messages/zh.json`:

```json
{
  "common": {
    "appName": "DealFlow",
    "save": "保存",
    "cancel": "取消",
    "delete": "删除",
    "edit": "编辑",
    "create": "创建",
    "search": "搜索",
    "filter": "筛选",
    "loading": "加载中...",
    "noResults": "暂无数据"
  },
  "nav": {
    "dashboard": "工作台",
    "deals": "项目",
    "myTasks": "我的任务",
    "contacts": "通讯录"
  },
  "auth": {
    "login": "登录",
    "logout": "退出",
    "email": "邮箱",
    "password": "密码"
  },
  "deal": {
    "newDeal": "新建项目",
    "name": "项目名称",
    "codeName": "代号",
    "dealType": "交易类型",
    "ourRole": "我方角色",
    "clientName": "客户",
    "targetCompany": "标的公司",
    "jurisdictions": "涉及法域",
    "dealLead": "项目负责人",
    "teamMembers": "团队成员",
    "summary": "项目概述",
    "status": "状态",
    "active": "进行中",
    "onHold": "暂停",
    "completed": "已完成",
    "auction": "竞标交易",
    "negotiated": "协议交易",
    "jv": "合资项目",
    "buySide": "买方",
    "sellSide": "卖方",
    "leadParty": "主导方",
    "participatingParty": "参与方"
  },
  "task": {
    "toDo": "待办",
    "inProgress": "进行中",
    "done": "已完成",
    "high": "高",
    "normal": "普通",
    "assignee": "负责人",
    "dueDate": "截止日期",
    "addTask": "添加任务",
    "addComment": "添加评论"
  },
  "milestone": {
    "addMilestone": "添加里程碑",
    "upcoming": "即将到来",
    "done": "已完成",
    "overdue": "已逾期"
  },
  "workstream": {
    "addWorkstream": "添加工作流"
  },
  "activity": {
    "addNote": "添加记录",
    "note": "笔记",
    "call": "电话",
    "meeting": "会议",
    "clientInstruction": "客户指示"
  },
  "decision": {
    "decisions": "决策记录",
    "newDecision": "新建决策",
    "background": "背景",
    "analysis": "分析",
    "options": "选项",
    "clientDecision": "客户决定",
    "pendingAnalysis": "待分析",
    "reported": "已汇报",
    "decided": "已决定",
    "implemented": "已执行"
  },
  "contact": {
    "name": "姓名",
    "organization": "单位",
    "role": "角色",
    "email": "邮箱",
    "phone": "电话",
    "timezone": "时区"
  },
  "dashboard": {
    "myTasks": "我的任务",
    "upcomingMilestones": "即将到来的里程碑",
    "activeDeals": "进行中的项目",
    "recentActivity": "最近动态"
  }
}
```

- [ ] **Step 6: Update next.config.ts for next-intl**

```typescript
import createNextIntlPlugin from "next-intl/plugin";

const withNextIntl = createNextIntlPlugin("./src/i18n/request.ts");

const nextConfig = {};

export default withNextIntl(nextConfig);
```

- [ ] **Step 7: Restructure app directory for locale routing**

Move `src/app/layout.tsx` and `src/app/page.tsx` under `src/app/[locale]/`:

```bash
mkdir -p src/app/\[locale\]
mv src/app/layout.tsx src/app/\[locale\]/layout.tsx
mv src/app/page.tsx src/app/\[locale\]/page.tsx
```

Update `src/app/[locale]/layout.tsx` to use next-intl:

```typescript
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import { NextIntlClientProvider } from "next-intl";
import { getMessages } from "next-intl/server";
import { notFound } from "next/navigation";
import { routing } from "@/i18n/routing";
import "../globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "DealFlow",
  description: "Cross-Border M&A Legal Project Management",
};

export default async function LocaleLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;

  if (!routing.locales.includes(locale as "zh" | "en")) {
    notFound();
  }

  const messages = await getMessages();

  return (
    <html lang={locale}>
      <body className={inter.className}>
        <NextIntlClientProvider messages={messages}>
          {children}
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
```

- [ ] **Step 8: Verify dev server starts**

```bash
npm run dev
```

Expected: App running, visiting `/zh` or `/en` both work.

- [ ] **Step 9: Commit**

```bash
git add messages/ src/i18n/ src/middleware.ts next.config.ts src/app/
git commit -m "feat: add next-intl bilingual support (zh/en)"
```

### Task 7: Set up Vitest

**Files:**
- Create: `dealflow/vitest.config.ts`
- Create: `dealflow/tests/setup.ts`
- Modify: `dealflow/package.json` (add deps + scripts)

- [ ] **Step 1: Install Vitest and testing libraries**

```bash
npm install --save-dev vitest @vitejs/plugin-react @testing-library/react @testing-library/jest-dom jsdom
```

- [ ] **Step 2: Create vitest.config.ts**

```typescript
import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
import path from "path";

export default defineConfig({
  plugins: [react()],
  test: {
    environment: "jsdom",
    setupFiles: ["./tests/setup.ts"],
    include: ["tests/**/*.test.{ts,tsx}"],
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
});
```

- [ ] **Step 3: Create test setup**

Create `tests/setup.ts`:

```typescript
import "@testing-library/jest-dom/vitest";
```

- [ ] **Step 4: Add test script to package.json**

Add to `scripts` in `package.json`:

```json
"test": "vitest run",
"test:watch": "vitest"
```

- [ ] **Step 5: Write a smoke test**

Create `tests/lib/utils.test.ts`:

```typescript
import { describe, it, expect } from "vitest";

describe("smoke test", () => {
  it("works", () => {
    expect(1 + 1).toBe(2);
  });
});
```

- [ ] **Step 6: Run test**

```bash
npm test
```

Expected: 1 test passes.

- [ ] **Step 7: Commit**

```bash
git add vitest.config.ts tests/ package.json
git commit -m "feat: add Vitest testing setup"
```

### Task 8: Seed templates and demo user

**Files:**
- Create: `dealflow/src/lib/templates/auction-buy-side.ts`
- Create: `dealflow/src/lib/templates/auction-sell-side.ts`
- Create: `dealflow/src/lib/templates/negotiated-buy-side.ts`
- Create: `dealflow/src/lib/templates/negotiated-sell-side.ts`
- Create: `dealflow/src/lib/templates/jv-lead-party.ts`
- Create: `dealflow/src/lib/templates/jv-participating-party.ts`
- Create: `dealflow/src/lib/templates/index.ts`
- Create: `dealflow/prisma/seed.ts`
- Modify: `dealflow/package.json` (add seed script)

- [ ] **Step 1: Create template definitions**

Create `src/lib/templates/auction-buy-side.ts`:

```typescript
import { DealType, DealRole } from "@prisma/client";

export const auctionBuySide = {
  name: "Auction — Buy-Side",
  dealType: DealType.Auction,
  ourRole: DealRole.BuySide,
  definition: {
    milestones: [
      { name: "NDA Signed", type: "External" },
      { name: "NBO Due", type: "External" },
      { name: "BO Due", type: "External" },
      { name: "Signing", type: "Contractual" },
      { name: "Closing", type: "Contractual" },
    ],
    workstreams: [
      {
        name: "Due Diligence",
        tasks: [
          "Sign NDA and access VDR",
          "Phase 1 DD — coordinate external counsel across jurisdictions",
          "Phase 2 DD — deep dive, management presentations",
          "Compile Key Issue List",
          "Confirm all DD reports received",
        ],
      },
      {
        name: "SPA & Documentation",
        tasks: [
          "Review seller's draft SPA",
          "Internal review and mark-up",
          "Negotiate reps & warranties, indemnities, CPs",
          "Final SPA agreed",
        ],
      },
      {
        name: "Regulatory",
        tasks: [
          "Identify required filings (antitrust, FDI, industry-specific)",
          "Pre-consultation with regulators",
          "Prepare and submit filings",
          "Track review periods and respond to queries",
        ],
      },
      {
        name: "Deal Structure & Tax",
        tasks: [
          "Confirm acquisition vehicle (direct / SPV / JV)",
          "Obtain tax structuring advice",
          "Finalize funding and financing arrangements",
        ],
      },
      {
        name: "Client Communication & Strategy",
        tasks: [
          "Initial client briefing and engagement letter",
          "Pricing strategy discussion",
          "Prepare NBO / BO cover letters",
          "Client decision on key DD findings",
          "Pre-signing client approval",
        ],
      },
      {
        name: "Conditions Precedent Tracker",
        tasks: [
          "Regulatory approvals (per jurisdiction)",
          "Third-party consents (change-of-control)",
          "Board / shareholder approvals",
          "No material adverse change confirmation",
          "Officer certificates",
          "Legal opinions (each jurisdiction)",
          "SAFE registration and fund remittance",
        ],
      },
      {
        name: "Closing Checklist",
        tasks: [
          "Signature pages collected",
          "Board resolutions executed",
          "Legal opinions delivered",
          "Funds transfer instructions confirmed",
          "Closing funds wired and confirmed",
          "Share transfer / business registration filings",
          "Post-closing notices",
          "File closing binder",
        ],
      },
    ],
  },
};
```

Create remaining 5 template files following the same pattern per the design spec. (Full content for each is in the design doc `docs/plans/2026-03-10-dealflow-design.md` section 7.)

Create `src/lib/templates/auction-sell-side.ts`:

```typescript
import { DealType, DealRole } from "@prisma/client";

export const auctionSellSide = {
  name: "Auction — Sell-Side",
  dealType: DealType.Auction,
  ourRole: DealRole.SellSide,
  definition: {
    milestones: [
      { name: "VDR Ready", type: "Internal" },
      { name: "Phase 1 Bids Due", type: "External" },
      { name: "Phase 2 Bids Due", type: "External" },
      { name: "Signing", type: "Contractual" },
      { name: "Closing", type: "Contractual" },
    ],
    workstreams: [
      {
        name: "VDR & DD Management",
        tasks: [
          "Prepare VDR structure and populate documents",
          "Prepare IM, Teaser, Process Letter",
          "Manage buyer Q&A during Phase 1",
          "Arrange management presentations for Phase 2",
          "Respond to supplemental DD requests",
        ],
      },
      {
        name: "Bid Management",
        tasks: [
          "Distribute materials to potential buyers",
          "Collect Phase 1 NBOs",
          "Shortlist bidders with client",
          "Collect Phase 2 BOs and SPA mark-ups",
          "Evaluate bids — prepare comparison memo",
        ],
      },
      {
        name: "SPA & Documentation",
        tasks: [
          "Draft SPA and disclosure schedules",
          "Review buyer mark-ups",
          "Negotiate to final form",
        ],
      },
      {
        name: "Regulatory",
        tasks: [
          "Identify buyer-side filing requirements",
          "Support buyer regulatory filings",
          "Track approval timelines",
        ],
      },
      {
        name: "Client Communication & Strategy",
        tasks: [
          "Engagement letter and team setup",
          "Bid evaluation and recommendation",
          "Advise on preferred bidder selection",
          "Pre-signing client approval",
        ],
      },
      {
        name: "Conditions Precedent Tracker",
        tasks: [
          "Buyer regulatory approvals",
          "Third-party consents",
          "Buyer financing confirmation",
          "No MAC confirmation",
          "Legal opinions",
        ],
      },
      {
        name: "Closing Checklist",
        tasks: [
          "Signature pages collected",
          "Board resolutions executed",
          "Legal opinions delivered",
          "Funds receipt confirmed",
          "Share transfer / registration filings",
          "Post-closing notices",
          "File closing binder",
        ],
      },
    ],
  },
};
```

Create `src/lib/templates/negotiated-buy-side.ts`:

```typescript
import { DealType, DealRole } from "@prisma/client";

export const negotiatedBuySide = {
  name: "Negotiated Deal — Buy-Side",
  dealType: DealType.Negotiated,
  ourRole: DealRole.BuySide,
  definition: {
    milestones: [
      { name: "NDA Signed", type: "External" },
      { name: "LOI Signed", type: "Contractual" },
      { name: "DD Complete", type: "Internal" },
      { name: "Signing", type: "Contractual" },
      { name: "Closing", type: "Contractual" },
    ],
    workstreams: [
      {
        name: "Due Diligence",
        tasks: [
          "Sign NDA and request initial materials",
          "Coordinate external counsel DD",
          "Compile Key Issue List",
          "Confirm all DD reports received",
        ],
      },
      {
        name: "SPA & Documentation",
        tasks: [
          "Negotiate LOI / Term Sheet",
          "Draft or review SPA",
          "Negotiate to final form",
        ],
      },
      {
        name: "Regulatory",
        tasks: [
          "Identify required filings",
          "Pre-consultation and filings",
          "Track review periods",
        ],
      },
      {
        name: "Deal Structure & Tax",
        tasks: [
          "Confirm acquisition vehicle",
          "Obtain tax structuring advice",
          "Finalize financing",
        ],
      },
      {
        name: "Client Communication & Strategy",
        tasks: [
          "Engagement letter and team setup",
          "LOI strategy discussion",
          "Client decisions on key DD findings",
          "Pre-signing approval",
        ],
      },
      {
        name: "Conditions Precedent Tracker",
        tasks: [
          "Regulatory approvals",
          "Third-party consents",
          "Board / shareholder approvals",
          "No MAC confirmation",
          "Legal opinions",
          "SAFE registration and fund remittance",
        ],
      },
      {
        name: "Closing Checklist",
        tasks: [
          "Signature pages collected",
          "Board resolutions executed",
          "Legal opinions delivered",
          "Funds transfer confirmed",
          "Share transfer / registration filings",
          "Post-closing notices",
          "File closing binder",
        ],
      },
    ],
  },
};
```

Create `src/lib/templates/negotiated-sell-side.ts`:

```typescript
import { DealType, DealRole } from "@prisma/client";

export const negotiatedSellSide = {
  name: "Negotiated Deal — Sell-Side",
  dealType: DealType.Negotiated,
  ourRole: DealRole.SellSide,
  definition: {
    milestones: [
      { name: "NDA Signed", type: "External" },
      { name: "LOI Signed", type: "Contractual" },
      { name: "DD Complete", type: "Internal" },
      { name: "Signing", type: "Contractual" },
      { name: "Closing", type: "Contractual" },
    ],
    workstreams: [
      {
        name: "DD Preparation & Support",
        tasks: [
          "Prepare VDR / information packages",
          "Respond to buyer DD requests",
          "Coordinate management access",
        ],
      },
      {
        name: "SPA & Documentation",
        tasks: [
          "Negotiate LOI / Term Sheet",
          "Review buyer's draft SPA (or draft our own)",
          "Negotiate to final form",
        ],
      },
      {
        name: "Regulatory",
        tasks: [
          "Support buyer regulatory filings",
          "Track approval timelines",
        ],
      },
      {
        name: "Client Communication & Strategy",
        tasks: [
          "Engagement letter and team setup",
          "LOI strategy discussion",
          "Pre-signing approval",
        ],
      },
      {
        name: "Conditions Precedent Tracker",
        tasks: [
          "Buyer regulatory approvals",
          "Third-party consents",
          "Buyer financing confirmation",
          "No MAC confirmation",
        ],
      },
      {
        name: "Closing Checklist",
        tasks: [
          "Signature pages collected",
          "Board resolutions executed",
          "Legal opinions delivered",
          "Funds receipt confirmed",
          "Share transfer / registration filings",
          "File closing binder",
        ],
      },
    ],
  },
};
```

Create `src/lib/templates/jv-lead-party.ts`:

```typescript
import { DealType, DealRole } from "@prisma/client";

export const jvLeadParty = {
  name: "Joint Venture — Lead Party",
  dealType: DealType.JV,
  ourRole: DealRole.LeadParty,
  definition: {
    milestones: [
      { name: "MOU Signed", type: "Contractual" },
      { name: "DD Complete", type: "Internal" },
      { name: "JV Agreement Signed", type: "Contractual" },
      { name: "Incorporation", type: "Regulatory" },
      { name: "Operational Launch", type: "Internal" },
    ],
    workstreams: [
      {
        name: "Due Diligence",
        tasks: [
          "Bilateral DD (if applicable)",
          "Partner background and financial check",
          "Key Issue List",
        ],
      },
      {
        name: "JV Agreement & Governance",
        tasks: [
          "Draft MOU / Framework Agreement",
          "Negotiate JV agreement and articles of association",
          "Design governance structure (board, voting, deadlock)",
          "Shareholder agreement",
        ],
      },
      {
        name: "Regulatory",
        tasks: [
          "Foreign investment review",
          "Antitrust filing (if thresholds met)",
          "Industry-specific approvals",
        ],
      },
      {
        name: "Commercial & Structure",
        tasks: [
          "Contribution ratios and valuation",
          "IP licensing arrangements",
          "Operational planning",
        ],
      },
      {
        name: "Client Communication & Strategy",
        tasks: [
          "Engagement letter and team setup",
          "Partner negotiation strategy",
          "Client decisions on governance and economics",
        ],
      },
      {
        name: "Conditions Precedent Tracker",
        tasks: [
          "Regulatory approvals",
          "Partner capital contribution confirmation",
          "Third-party consents",
          "IP transfer / licensing execution",
        ],
      },
      {
        name: "Incorporation & Launch Checklist",
        tasks: [
          "JV company registration",
          "Business licenses obtained",
          "Bank accounts opened",
          "Initial capital contributed",
          "First board meeting held",
          "Key personnel appointed",
        ],
      },
    ],
  },
};
```

Create `src/lib/templates/jv-participating-party.ts`:

```typescript
import { DealType, DealRole } from "@prisma/client";

export const jvParticipatingParty = {
  name: "Joint Venture — Participating Party",
  dealType: DealType.JV,
  ourRole: DealRole.ParticipatingParty,
  definition: {
    milestones: [
      { name: "MOU Signed", type: "Contractual" },
      { name: "DD Complete", type: "Internal" },
      { name: "JV Agreement Signed", type: "Contractual" },
      { name: "Incorporation", type: "Regulatory" },
      { name: "Operational Launch", type: "Internal" },
    ],
    workstreams: [
      {
        name: "Due Diligence",
        tasks: [
          "Review lead party's DD materials",
          "Independent verification where needed",
        ],
      },
      {
        name: "JV Agreement & Governance",
        tasks: [
          "Review lead party's draft JV agreement",
          "Negotiate protective provisions (veto rights, exit mechanisms)",
          "Shareholder agreement review",
        ],
      },
      {
        name: "Regulatory",
        tasks: [
          "Own regulatory filings",
          "Track lead party's filing progress",
        ],
      },
      {
        name: "Commercial & Structure",
        tasks: [
          "Review contribution terms and valuation",
          "Negotiate IP and operational arrangements",
        ],
      },
      {
        name: "Client Communication & Strategy",
        tasks: [
          "Engagement letter and team setup",
          "Protective rights strategy",
          "Client decisions on key terms",
        ],
      },
      {
        name: "Conditions Precedent Tracker",
        tasks: [
          "Regulatory approvals",
          "Lead party capital contribution confirmation",
          "Third-party consents",
        ],
      },
      {
        name: "Incorporation & Launch Checklist",
        tasks: [
          "JV company registration",
          "Bank accounts opened",
          "Initial capital contributed",
          "Board seat confirmed",
          "Key personnel appointed",
        ],
      },
    ],
  },
};
```

Create `src/lib/templates/index.ts`:

```typescript
export { auctionBuySide } from "./auction-buy-side";
export { auctionSellSide } from "./auction-sell-side";
export { negotiatedBuySide } from "./negotiated-buy-side";
export { negotiatedSellSide } from "./negotiated-sell-side";
export { jvLeadParty } from "./jv-lead-party";
export { jvParticipatingParty } from "./jv-participating-party";

import { auctionBuySide } from "./auction-buy-side";
import { auctionSellSide } from "./auction-sell-side";
import { negotiatedBuySide } from "./negotiated-buy-side";
import { negotiatedSellSide } from "./negotiated-sell-side";
import { jvLeadParty } from "./jv-lead-party";
import { jvParticipatingParty } from "./jv-participating-party";

export const allTemplates = [
  auctionBuySide,
  auctionSellSide,
  negotiatedBuySide,
  negotiatedSellSide,
  jvLeadParty,
  jvParticipatingParty,
];
```

- [ ] **Step 2: Create seed script**

Create `prisma/seed.ts`:

```typescript
import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";
import { allTemplates } from "../src/lib/templates";

const prisma = new PrismaClient();

async function main() {
  // Seed templates
  for (const template of allTemplates) {
    await prisma.template.upsert({
      where: { id: `system-${template.dealType}-${template.ourRole}` },
      update: { definition: template.definition },
      create: {
        id: `system-${template.dealType}-${template.ourRole}`,
        name: template.name,
        dealType: template.dealType,
        ourRole: template.ourRole,
        definition: template.definition,
        isSystem: true,
      },
    });
  }

  // Seed demo admin user
  const passwordHash = await bcrypt.hash("admin123", 10);
  await prisma.user.upsert({
    where: { email: "admin@dealflow.local" },
    update: {},
    create: {
      name: "Admin",
      email: "admin@dealflow.local",
      passwordHash,
      role: "Admin",
      locale: "zh",
    },
  });

  console.log("Seed complete: 6 templates + 1 admin user");
}

main()
  .then(() => prisma.$disconnect())
  .catch((e) => {
    console.error(e);
    prisma.$disconnect();
    process.exit(1);
  });
```

- [ ] **Step 3: Add seed config to package.json**

Add to `package.json`:

```json
"prisma": {
  "seed": "npx tsx prisma/seed.ts"
}
```

Install tsx:

```bash
npm install --save-dev tsx
```

- [ ] **Step 4: Run seed**

```bash
npx prisma db seed
```

Expected: "Seed complete: 6 templates + 1 admin user"

- [ ] **Step 5: Verify in Prisma Studio**

```bash
npx prisma studio
```

Expected: Template table has 6 rows, User table has 1 row.

- [ ] **Step 6: Commit**

```bash
git add src/lib/templates/ prisma/seed.ts package.json
git commit -m "feat: add 6 deal templates and seed script"
```

---

## Chunk 2: Login + App Shell + Deal CRUD

### Task 9: Build login page

**Files:**
- Create: `dealflow/src/app/[locale]/login/page.tsx`

- [ ] **Step 1: Create login page**

```tsx
"use client";

import { signIn } from "next-auth/react";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { useTranslations } from "next-intl";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export default function LoginPage() {
  const t = useTranslations("auth");
  const router = useRouter();
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setLoading(true);
    setError("");

    const formData = new FormData(e.currentTarget);
    const result = await signIn("credentials", {
      email: formData.get("email"),
      password: formData.get("password"),
      redirect: false,
    });

    if (result?.error) {
      setError("Invalid email or password");
      setLoading(false);
    } else {
      router.push("/dashboard");
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center">
      <Card className="w-full max-w-sm">
        <CardHeader>
          <CardTitle className="text-2xl">DealFlow</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="email">{t("email")}</Label>
              <Input id="email" name="email" type="email" required />
            </div>
            <div className="space-y-2">
              <Label htmlFor="password">{t("password")}</Label>
              <Input id="password" name="password" type="password" required />
            </div>
            {error && <p className="text-sm text-red-500">{error}</p>}
            <Button type="submit" className="w-full" disabled={loading}>
              {loading ? "..." : t("login")}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
```

- [ ] **Step 2: Verify login works**

Start dev server, go to `/zh/login`, log in with `admin@dealflow.local` / `admin123`.

- [ ] **Step 3: Commit**

```bash
git add src/app/\[locale\]/login/
git commit -m "feat: add login page"
```

### Task 10: Build app shell (top nav)

**Files:**
- Create: `dealflow/src/components/layout/app-shell.tsx`
- Create: `dealflow/src/components/layout/locale-switcher.tsx`

- [ ] **Step 1: Create app shell**

```tsx
import Link from "next/link";
import { useTranslations } from "next-intl";
import { auth } from "@/lib/auth";
import { LocaleSwitcher } from "./locale-switcher";

export async function AppShell({ children }: { children: React.ReactNode }) {
  const session = await auth();
  const t = useTranslations("nav");

  if (!session?.user) return <>{children}</>;

  return (
    <div className="min-h-screen bg-background">
      <header className="border-b">
        <div className="flex h-14 items-center px-6 gap-6">
          <Link href="/dashboard" className="font-bold text-lg">
            DealFlow
          </Link>
          <nav className="flex items-center gap-4 text-sm">
            <Link href="/dashboard" className="text-muted-foreground hover:text-foreground">
              {t("dashboard")}
            </Link>
            <Link href="/deals" className="text-muted-foreground hover:text-foreground">
              {t("deals")}
            </Link>
            <Link href="/tasks" className="text-muted-foreground hover:text-foreground">
              {t("myTasks")}
            </Link>
            <Link href="/contacts" className="text-muted-foreground hover:text-foreground">
              {t("contacts")}
            </Link>
          </nav>
          <div className="ml-auto flex items-center gap-4">
            <LocaleSwitcher />
            <span className="text-sm text-muted-foreground">{session.user.name}</span>
          </div>
        </div>
      </header>
      <main className="p-6">{children}</main>
    </div>
  );
}
```

- [ ] **Step 2: Create locale switcher**

```tsx
"use client";

import { useLocale } from "next-intl";
import { useRouter, usePathname } from "next/navigation";
import { Button } from "@/components/ui/button";

export function LocaleSwitcher() {
  const locale = useLocale();
  const router = useRouter();
  const pathname = usePathname();

  function switchLocale() {
    const newLocale = locale === "zh" ? "en" : "zh";
    const newPath = pathname.replace(`/${locale}`, `/${newLocale}`);
    router.push(newPath);
  }

  return (
    <Button variant="ghost" size="sm" onClick={switchLocale}>
      {locale === "zh" ? "EN" : "中文"}
    </Button>
  );
}
```

- [ ] **Step 3: Wire app shell into layout**

Update `src/app/[locale]/layout.tsx` to wrap children with `<AppShell>`.

- [ ] **Step 4: Verify nav renders after login**

- [ ] **Step 5: Commit**

```bash
git add src/components/layout/
git commit -m "feat: add app shell with nav and locale switcher"
```

### Task 11: Deal list page

**Files:**
- Create: `dealflow/src/app/[locale]/deals/page.tsx`
- Create: `dealflow/src/components/deals/deal-list.tsx`
- Create: `dealflow/src/components/deals/deal-status-badge.tsx`

- [ ] **Step 1: Create deal status badge**

```tsx
import { Badge } from "@/components/ui/badge";
import { DealStatus } from "@prisma/client";
import { useTranslations } from "next-intl";

const variants: Record<DealStatus, "default" | "secondary" | "outline"> = {
  Active: "default",
  OnHold: "secondary",
  Completed: "outline",
};

export function DealStatusBadge({ status }: { status: DealStatus }) {
  const t = useTranslations("deal");
  const labels: Record<DealStatus, string> = {
    Active: t("active"),
    OnHold: t("onHold"),
    Completed: t("completed"),
  };

  return <Badge variant={variants[status]}>{labels[status]}</Badge>;
}
```

- [ ] **Step 2: Create deal list component**

A server component that queries deals from DB and renders a table with: name, code name, client, target, status, deal lead, task progress (X/Y done). Link each row to `/deals/[dealId]`.

- [ ] **Step 3: Create deal list page**

```tsx
import { prisma } from "@/lib/prisma";
import { auth } from "@/lib/auth";
import { redirect } from "next/navigation";
import { DealList } from "@/components/deals/deal-list";
import { Button } from "@/components/ui/button";
import Link from "next/link";
import { getTranslations } from "next-intl/server";

export default async function DealsPage() {
  const session = await auth();
  if (!session) redirect("/login");

  const t = await getTranslations("deal");

  const deals = await prisma.deal.findMany({
    include: {
      dealLead: true,
      workstreams: {
        include: {
          tasks: { select: { status: true } },
        },
      },
    },
    orderBy: { updatedAt: "desc" },
  });

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">{t("deals")}</h1>
        <Link href="/deals/new">
          <Button>{t("newDeal")}</Button>
        </Link>
      </div>
      <DealList deals={deals} />
    </div>
  );
}
```

- [ ] **Step 4: Verify empty deals page renders**

- [ ] **Step 5: Commit**

```bash
git add src/app/\[locale\]/deals/ src/components/deals/
git commit -m "feat: add deal list page"
```

### Task 12: Create deal form + server action

**Files:**
- Create: `dealflow/src/app/[locale]/deals/new/page.tsx`
- Create: `dealflow/src/components/deals/deal-form.tsx`
- Create: `dealflow/src/actions/deals.ts`

- [ ] **Step 1: Create deal server action**

Create `src/actions/deals.ts`:

```typescript
"use server";

import { prisma } from "@/lib/prisma";
import { auth } from "@/lib/auth";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { DealType, DealRole, MilestoneType } from "@prisma/client";

export async function createDeal(formData: FormData) {
  const session = await auth();
  if (!session?.user) throw new Error("Unauthorized");

  const templateId = formData.get("templateId") as string;
  const name = formData.get("name") as string;
  const codeName = (formData.get("codeName") as string) || null;
  const dealType = formData.get("dealType") as DealType;
  const ourRole = formData.get("ourRole") as DealRole;
  const clientName = formData.get("clientName") as string;
  const targetCompany = formData.get("targetCompany") as string;
  const jurisdictions = (formData.get("jurisdictions") as string).split(",").map((j) => j.trim()).filter(Boolean);
  const dealLeadId = formData.get("dealLeadId") as string;
  const memberIds = formData.getAll("memberIds") as string[];
  const summary = (formData.get("summary") as string) || null;

  // Fetch template
  const template = templateId
    ? await prisma.template.findUnique({ where: { id: templateId } })
    : null;

  const def = template?.definition as {
    milestones: { name: string; type: string }[];
    workstreams: { name: string; tasks: string[] }[];
  } | null;

  const deal = await prisma.deal.create({
    data: {
      name,
      codeName,
      dealType,
      ourRole,
      clientName,
      targetCompany,
      jurisdictions,
      summary,
      dealLeadId,
      members: {
        create: [dealLeadId, ...memberIds]
          .filter((id, i, arr) => arr.indexOf(id) === i)
          .map((userId) => ({ userId })),
      },
      milestones: def
        ? {
            create: def.milestones.map((m, i) => ({
              name: m.name,
              type: m.type as MilestoneType,
              sortOrder: i,
            })),
          }
        : undefined,
      workstreams: def
        ? {
            create: def.workstreams.map((ws, i) => ({
              name: ws.name,
              sortOrder: i,
              tasks: {
                create: ws.tasks.map((title, j) => ({
                  title,
                  sortOrder: j,
                })),
              },
            })),
          }
        : undefined,
    },
  });

  // Auto-create activity entry
  await prisma.activityEntry.create({
    data: {
      type: "Note",
      content: `Deal created: ${name}`,
      dealId: deal.id,
      authorId: session.user.id,
    },
  });

  revalidatePath("/deals");
  redirect(`/deals/${deal.id}`);
}
```

- [ ] **Step 2: Add updateDeal server action**

Add `updateDeal` to `src/actions/deals.ts`. Accepts dealId + partial data (name, codeName, clientName, targetCompany, jurisdictions, summary, status, dealLeadId). On status change, auto-creates activity entry: "Deal status changed from X to Y". Revalidates `/deals` and `/deals/${dealId}`.

- [ ] **Step 3: Create deal form component**

A client component form with fields matching the design spec (name, codeName, dealType, ourRole, clientName, targetCompany, jurisdictions, dealLead, teamMembers, summary). DealType and OurRole selections auto-match a template. Form submits via the `createDeal` server action. The same form component should support edit mode (pre-filled with existing deal data, submits via `updateDeal`).

- [ ] **Step 3: Create the new deal page**

Fetches users and templates from DB, passes to DealForm.

- [ ] **Step 4: Test creating a deal**

Fill form, submit, verify redirected to deal detail page (which will be a placeholder for now).

- [ ] **Step 5: Verify deal appears in deal list**

- [ ] **Step 6: Commit**

```bash
git add src/actions/deals.ts src/components/deals/deal-form.tsx src/app/\[locale\]/deals/new/
git commit -m "feat: add create deal form with template-based generation"
```

### Task 13: Deal detail page (core page)

**Files:**
- Create: `dealflow/src/app/[locale]/deals/[dealId]/page.tsx`
- Create: `dealflow/src/components/deals/deal-header.tsx`
- Create: `dealflow/src/components/milestones/milestone-timeline.tsx`
- Create: `dealflow/src/components/workstreams/workstream-list.tsx`
- Create: `dealflow/src/components/workstreams/workstream-section.tsx`
- Create: `dealflow/src/components/tasks/task-row.tsx`
- Create: `dealflow/src/components/activity/activity-feed.tsx`
- Create: `dealflow/src/components/activity/activity-entry.tsx`

- [ ] **Step 1: Create deal header component**

Shows deal name, status badge, client, target, lead, and collapsible summary.

- [ ] **Step 2: Create milestone timeline component**

Horizontal row of milestone nodes. Each node: dot (filled if done, hollow if upcoming, red if overdue) + name + date. Clicking a milestone opens an edit popover.

- [ ] **Step 3: Create workstream section component**

Collapsible section: workstream name + "X/Y done" counter. Expanded shows task rows. Each task row: checkbox (toggles status), title, assignee avatar, due date, priority flag.

- [ ] **Step 4: Create workstream list component**

Renders all workstreams for the deal. Includes [+ Add Workstream] button.

- [ ] **Step 5: Create activity feed component**

Right sidebar (collapsible). Chronological list of activity entries. Each entry: timestamp, type icon, content, author. Includes [+ Add note] button at top.

- [ ] **Step 6: Create activity entry component**

Single entry rendering with type-appropriate icon and formatting.

- [ ] **Step 7: Create deal detail page**

Server component that fetches the full deal with all relations and composes the layout:

```
DealHeader (top)
MilestoneTimeline (below header)
FilterBar (above content area)
WorkstreamList (left) | ActivityFeed (right, collapsible)
Tabs: Decisions | Contacts | Documents (bottom)
```

- [ ] **Step 8: Verify deal detail page renders with template data**

Create a deal from template, navigate to detail page, confirm milestones, workstreams, and tasks all appear.

- [ ] **Step 9: Commit**

```bash
git add src/app/\[locale\]/deals/\[dealId\]/ src/components/deals/ src/components/milestones/ src/components/workstreams/ src/components/tasks/ src/components/activity/
git commit -m "feat: add deal detail page with milestones, workstreams, and activity feed"
```

---

## Chunk 3: Task Management

### Task 14: Task status toggle + server action

**Files:**
- Create: `dealflow/src/actions/tasks.ts`

- [ ] **Step 1: Create task server actions**

```typescript
"use server";

import { prisma } from "@/lib/prisma";
import { auth } from "@/lib/auth";
import { revalidatePath } from "next/cache";
import { TaskStatus, TaskPriority } from "@prisma/client";

export async function updateTaskStatus(taskId: string, status: TaskStatus) {
  const session = await auth();
  if (!session?.user) throw new Error("Unauthorized");

  const task = await prisma.task.update({
    where: { id: taskId },
    data: { status },
    include: { workstream: { select: { dealId: true } } },
  });

  // Auto-create activity entry
  await prisma.activityEntry.create({
    data: {
      type: "TaskUpdate",
      content: `Task "${task.title}" → ${status}`,
      dealId: task.workstream.dealId,
      workstreamId: task.workstreamId,
      authorId: session.user.id,
    },
  });

  revalidatePath(`/deals/${task.workstream.dealId}`);
}

export async function createTask(formData: FormData) {
  const session = await auth();
  if (!session?.user) throw new Error("Unauthorized");

  const workstreamId = formData.get("workstreamId") as string;
  const title = formData.get("title") as string;
  const description = (formData.get("description") as string) || null;
  const assigneeId = (formData.get("assigneeId") as string) || null;
  const priority = (formData.get("priority") as TaskPriority) || "Normal";
  const dueDate = formData.get("dueDate") ? new Date(formData.get("dueDate") as string) : null;

  const maxOrder = await prisma.task.aggregate({
    where: { workstreamId },
    _max: { sortOrder: true },
  });

  const task = await prisma.task.create({
    data: {
      title,
      description,
      workstreamId,
      assigneeId,
      priority,
      dueDate,
      sortOrder: (maxOrder._max.sortOrder ?? -1) + 1,
    },
    include: { workstream: { select: { dealId: true } } },
  });

  await prisma.activityEntry.create({
    data: {
      type: "TaskUpdate",
      content: `Task created: "${title}"`,
      dealId: task.workstream.dealId,
      workstreamId,
      authorId: session.user.id,
    },
  });

  revalidatePath(`/deals/${task.workstream.dealId}`);
}

export async function updateTask(taskId: string, data: {
  title?: string;
  description?: string | null;
  assigneeId?: string | null;
  priority?: TaskPriority;
  dueDate?: Date | null;
}) {
  const session = await auth();
  if (!session?.user) throw new Error("Unauthorized");

  const task = await prisma.task.update({
    where: { id: taskId },
    data,
    include: { workstream: { select: { dealId: true } } },
  });

  revalidatePath(`/deals/${task.workstream.dealId}`);
}

export async function deleteTask(taskId: string) {
  const session = await auth();
  if (!session?.user) throw new Error("Unauthorized");

  const task = await prisma.task.findUnique({
    where: { id: taskId },
    include: { workstream: { select: { dealId: true } } },
  });
  if (!task) throw new Error("Task not found");

  await prisma.task.delete({ where: { id: taskId } });
  revalidatePath(`/deals/${task.workstream.dealId}`);
}
```

- [ ] **Step 2: Wire task status toggle into task-row component**

Clicking the checkbox calls `updateTaskStatus` — toggles between ToDo and Done. Clicking the title opens the task panel.

- [ ] **Step 3: Test toggling task status**

Toggle a task, verify status changes, verify activity feed entry appears.

- [ ] **Step 4: Commit**

```bash
git add src/actions/tasks.ts src/components/tasks/
git commit -m "feat: add task CRUD server actions and status toggle"
```

### Task 15: Task slide-over panel

**Files:**
- Create: `dealflow/src/components/tasks/task-panel.tsx`
- Create: `dealflow/src/components/tasks/task-comments.tsx`
- Create: `dealflow/src/components/tasks/task-dependencies.tsx`
- Create: `dealflow/src/hooks/use-task-panel.ts`
- Create: `dealflow/src/actions/tasks.ts` (add comment + dependency actions)

- [ ] **Step 1: Create panel state hook**

```typescript
"use client";

import { create } from "zustand";

interface TaskPanelState {
  taskId: string | null;
  open: (taskId: string) => void;
  close: () => void;
}

export const useTaskPanel = create<TaskPanelState>((set) => ({
  taskId: null,
  open: (taskId) => set({ taskId }),
  close: () => set({ taskId: null }),
}));
```

Install zustand: `npm install zustand`

- [ ] **Step 2: Create task panel component**

Uses shadcn Sheet (slide-over from right). Shows:
- Title (editable inline)
- Status dropdown
- Priority toggle
- Assignee select
- Due date picker
- Description (textarea)
- Subtasks (checklist)
- Dependencies section
- Comments thread
- Attachments list

- [ ] **Step 3: Add comment server action**

Add to `src/actions/tasks.ts`:

```typescript
export async function addTaskComment(taskId: string, content: string) {
  const session = await auth();
  if (!session?.user) throw new Error("Unauthorized");

  const task = await prisma.task.findUnique({
    where: { id: taskId },
    include: { workstream: { select: { dealId: true } } },
  });
  if (!task) throw new Error("Task not found");

  await prisma.taskComment.create({
    data: { taskId, content, authorId: session.user.id },
  });

  revalidatePath(`/deals/${task.workstream.dealId}`);
}
```

- [ ] **Step 4: Add dependency server action**

```typescript
export async function addTaskDependency(
  taskId: string,
  dependsOnTaskId: string,
  type: "Blocks" | "RelatedTo"
) {
  const session = await auth();
  if (!session?.user) throw new Error("Unauthorized");

  await prisma.taskDependency.create({
    data: { taskId, dependsOnTaskId, type },
  });

  const task = await prisma.task.findUnique({
    where: { id: taskId },
    include: { workstream: { select: { dealId: true } } },
  });

  revalidatePath(`/deals/${task!.workstream.dealId}`);
}
```

- [ ] **Step 5: Create comments component**

Displays comment thread + input form at bottom.

- [ ] **Step 6: Create dependencies component**

Shows linked tasks with relationship type. [+ Link] button opens a search dialog to find tasks across all workstreams in the deal.

- [ ] **Step 7: Verify panel opens, comments work, dependencies work**

- [ ] **Step 8: Commit**

```bash
git add src/components/tasks/ src/hooks/ src/actions/tasks.ts
git commit -m "feat: add task slide-over panel with comments and dependencies"
```

### Task 16: Task filters + My Tasks page

**Files:**
- Create: `dealflow/src/components/tasks/task-filters.tsx`
- Create: `dealflow/src/app/[locale]/tasks/page.tsx`

- [ ] **Step 1: Create task filter bar**

Client component with dropdowns: Assignee, Status, (applied to workstream task list on deal detail page).

- [ ] **Step 2: Create My Tasks page**

Server component. Queries all tasks where `assigneeId = currentUser.id` across all deals. Groups by deal, sorted by: overdue first, then by due date. Shows deal name as section header, tasks as rows.

- [ ] **Step 3: Verify filtering works on deal detail page**

- [ ] **Step 4: Verify My Tasks page shows cross-deal tasks**

- [ ] **Step 5: Commit**

```bash
git add src/components/tasks/task-filters.tsx src/app/\[locale\]/tasks/
git commit -m "feat: add task filters and My Tasks page"
```

---

## Chunk 4: Milestones, Activity Feed, Workstream CRUD

### Task 17: Milestone CRUD + timeline interactions

**Files:**
- Create: `dealflow/src/actions/milestones.ts`
- Create: `dealflow/src/components/milestones/milestone-form.tsx`

- [ ] **Step 1: Create milestone server actions**

CRUD actions: `createMilestone`, `updateMilestone`, `deleteMilestone`, `toggleMilestoneDone`. Each writes an activity entry on changes.

- [ ] **Step 2: Create milestone form (popover)**

Popover form for adding/editing: name, date, type. Appears when clicking [+ Add Milestone] or clicking an existing milestone.

- [ ] **Step 3: Wire toggle into timeline**

Clicking a milestone dot toggles isDone. Auto-creates activity entry: "Milestone X marked as done".

- [ ] **Step 4: Verify milestone interactions**

- [ ] **Step 5: Commit**

```bash
git add src/actions/milestones.ts src/components/milestones/
git commit -m "feat: add milestone CRUD and timeline interactions"
```

### Task 18: Activity feed — manual notes

**Files:**
- Create: `dealflow/src/actions/activity.ts`
- Create: `dealflow/src/components/activity/activity-form.tsx`

- [ ] **Step 1: Create activity server actions**

```typescript
"use server";

import { prisma } from "@/lib/prisma";
import { auth } from "@/lib/auth";
import { revalidatePath } from "next/cache";
import { ActivityType } from "@prisma/client";

export async function createActivityEntry(formData: FormData) {
  const session = await auth();
  if (!session?.user) throw new Error("Unauthorized");

  const dealId = formData.get("dealId") as string;
  const type = formData.get("type") as ActivityType;
  const content = formData.get("content") as string;
  const workstreamId = (formData.get("workstreamId") as string) || null;

  await prisma.activityEntry.create({
    data: {
      type,
      content,
      dealId,
      workstreamId,
      authorId: session.user.id,
    },
  });

  revalidatePath(`/deals/${dealId}`);
}
```

- [ ] **Step 2: Create activity form**

Inline form at top of activity feed: type dropdown (Note/Call/Meeting/ClientInstruction), optional workstream link, content textarea, submit button. Option to create action items (which become tasks in selected workstream).

- [ ] **Step 3: Verify adding a manual note**

- [ ] **Step 4: Commit**

```bash
git add src/actions/activity.ts src/components/activity/activity-form.tsx
git commit -m "feat: add manual activity feed entries"
```

### Task 19: Workstream CRUD

**Files:**
- Create: `dealflow/src/actions/workstreams.ts`
- Create: `dealflow/src/components/workstreams/workstream-form.tsx`

- [ ] **Step 1: Create workstream server actions**

`createWorkstream`, `updateWorkstream`, `deleteWorkstream`, `reorderWorkstreams`.

- [ ] **Step 2: Create workstream form (dialog)**

Simple dialog: name field. For add and rename.

- [ ] **Step 3: Wire [+ Add Workstream] and rename/delete into UI**

- [ ] **Step 4: Verify adding and removing workstreams**

- [ ] **Step 5: Commit**

```bash
git add src/actions/workstreams.ts src/components/workstreams/workstream-form.tsx
git commit -m "feat: add workstream CRUD"
```

---

## Chunk 5: Decisions, Contacts, Documents

### Task 20: Decision CRUD

**Files:**
- Create: `dealflow/src/actions/decisions.ts`
- Create: `dealflow/src/app/[locale]/deals/[dealId]/decisions/page.tsx`
- Create: `dealflow/src/components/decisions/decision-list.tsx`
- Create: `dealflow/src/components/decisions/decision-form.tsx`
- Create: `dealflow/src/components/decisions/decision-detail.tsx`

- [ ] **Step 1: Create decision server actions**

`createDecision`, `updateDecision`, `addDecisionOption`, `linkDecisionToTask`. Auto-creates activity entry on creation.

- [ ] **Step 2: Create decision list component**

Table: title, source, status, date. Click to expand detail.

- [ ] **Step 3: Create decision form**

Form: title, background, source (dropdown), analysis, options (dynamic add/remove), client decision, status. Workstream link dropdown. Task link search.

- [ ] **Step 4: Create decision detail component**

Full view showing background → analysis → options (with pros/cons) → client decision → linked tasks.

- [ ] **Step 5: Create decisions page (deal tab)**

- [ ] **Step 6: Verify full decision workflow**

Create decision → add options → link to task → update status.

- [ ] **Step 7: Commit**

```bash
git add src/actions/decisions.ts src/app/\[locale\]/deals/\[dealId\]/decisions/ src/components/decisions/
git commit -m "feat: add decision CRUD with options and task linking"
```

### Task 21: Contact CRUD

**Files:**
- Create: `dealflow/src/actions/contacts.ts`
- Create: `dealflow/src/app/[locale]/contacts/page.tsx`
- Create: `dealflow/src/app/[locale]/deals/[dealId]/contacts/page.tsx`
- Create: `dealflow/src/components/contacts/contact-list.tsx`
- Create: `dealflow/src/components/contacts/contact-form.tsx`

- [ ] **Step 1: Create contact server actions**

`createContact`, `updateContact`, `deleteContact`, `linkContactToDeal`, `unlinkContactFromDeal`.

- [ ] **Step 2: Create contact list component**

Table: name, organization, role, email, phone. Reusable for both global and deal-scoped views.

- [ ] **Step 3: Create contact form (dialog)**

- [ ] **Step 4: Create global contacts page**

- [ ] **Step 5: Create deal contacts page (tab)**

Shows contacts linked to this deal with their roleInDeal. [+ Link Contact] button to search existing or create new.

- [ ] **Step 6: Verify contact workflows**

- [ ] **Step 7: Commit**

```bash
git add src/actions/contacts.ts src/app/\[locale\]/contacts/ src/app/\[locale\]/deals/\[dealId\]/contacts/ src/components/contacts/
git commit -m "feat: add contact management (global + per-deal)"
```

### Task 22: Document management

**Files:**
- Create: `dealflow/src/actions/documents.ts`
- Create: `dealflow/src/app/[locale]/deals/[dealId]/documents/page.tsx`
- Create: `dealflow/src/components/documents/document-list.tsx`
- Create: `dealflow/src/components/documents/document-upload.tsx`

- [ ] **Step 1: Create document server actions**

`uploadDocument` (handles file upload to `storage/uploads/`, creates DB record), `deleteDocument`. Auto-creates activity entry on upload. IMPORTANT: Files must be stored in `storage/uploads/` (NOT `public/`), and served through an authenticated API route at `/api/documents/[id]/download` that checks the user's session before streaming the file. Legal documents contain privileged material.

- [ ] **Step 2: Create document upload component**

File input + workstream/task link dropdowns. Uploads via form action.

- [ ] **Step 3: Create document list component**

Table: name, workstream, uploaded by, date. Download link.

- [ ] **Step 4: Create documents page (deal tab)**

- [ ] **Step 5: Verify upload and download**

- [ ] **Step 6: Commit**

```bash
git add src/actions/documents.ts src/app/\[locale\]/deals/\[dealId\]/documents/ src/components/documents/
git commit -m "feat: add document upload and management"
```

---

## Chunk 6: Dashboard, Search, Audit Trail

### Task 23: Dashboard

**Files:**
- Create: `dealflow/src/app/[locale]/dashboard/page.tsx`
- Create: `dealflow/src/components/dashboard/my-tasks-widget.tsx`
- Create: `dealflow/src/components/dashboard/milestones-widget.tsx`
- Create: `dealflow/src/components/dashboard/active-deals-widget.tsx`
- Create: `dealflow/src/components/dashboard/recent-activity-widget.tsx`

- [ ] **Step 1: Create My Tasks widget**

Query tasks where assigneeId = current user, status != Done, ordered by overdue first then due date. Show title, deal name, due date, priority.

- [ ] **Step 2: Create Milestones widget**

Query milestones where isDone = false, date within next 14 days, ordered by date. Show name, deal name, date, days remaining.

- [ ] **Step 3: Create Active Deals widget**

Query deals where status = Active. Show cards with name, client, target, task completion counts.

- [ ] **Step 4: Create Recent Activity widget**

Query latest 20 activity entries across all deals. Show timestamp, deal name, type icon, content.

- [ ] **Step 5: Compose dashboard page**

Fixed layout grid: tasks (top-left), milestones (top-right), active deals (middle), recent activity (bottom).

- [ ] **Step 6: Verify dashboard renders with real data**

- [ ] **Step 7: Commit**

```bash
git add src/app/\[locale\]/dashboard/ src/components/dashboard/
git commit -m "feat: add dashboard with tasks, milestones, deals, and activity widgets"
```

### Task 24: Global search

**Files:**
- Create: `dealflow/src/app/[locale]/search/page.tsx`
- Create: `dealflow/src/actions/search.ts`

- [ ] **Step 1: Create search server action**

Searches across: deals (name, codeName, clientName, targetCompany), tasks (title), activity entries (content), contacts (name, organization), decisions (title, background). Returns grouped results.

- [ ] **Step 2: Create search page**

Search input at top. Results grouped by type (Deals, Tasks, Activity, Contacts, Decisions). Each result links to the relevant page.

- [ ] **Step 3: Add search input to app shell nav**

Clicking the search input navigates to /search with the query.

- [ ] **Step 4: Verify search finds results across entities**

- [ ] **Step 5: Commit**

```bash
git add src/app/\[locale\]/search/ src/actions/search.ts src/components/layout/app-shell.tsx
git commit -m "feat: add global search across deals, tasks, contacts, activity, decisions"
```

### Task 25: Audit trail

**Files:**
- Create: `dealflow/src/lib/audit.ts`
- Modify: all server actions in `src/actions/` to call audit logger

- [ ] **Step 1: Create audit helper**

```typescript
import { prisma } from "./prisma";

export async function logAudit(
  userId: string,
  action: string,
  entityType: string,
  entityId: string,
  changes?: Record<string, { from: unknown; to: unknown }>
) {
  await prisma.auditLog.create({
    data: { userId, action, entityType, entityId, changes: changes ?? null },
  });
}
```

- [ ] **Step 2: Add audit logging to key server actions**

Add `logAudit` calls to: `createDeal`, `updateTaskStatus`, `createDecision`, `updateDecision`, `createMilestone`, `toggleMilestoneDone`. Focus on the most important state changes.

- [ ] **Step 3: Verify audit logs are created**

Check via Prisma Studio.

- [ ] **Step 4: Commit**

```bash
git add src/lib/audit.ts src/actions/
git commit -m "feat: add audit trail logging to key actions"
```

### Task 26: Save deal as template

**Files:**
- Create: `dealflow/src/actions/templates.ts`

- [ ] **Step 1: Create template server action**

```typescript
"use server";

import { prisma } from "@/lib/prisma";
import { auth } from "@/lib/auth";

export async function saveDealAsTemplate(dealId: string, templateName: string) {
  const session = await auth();
  if (!session?.user) throw new Error("Unauthorized");

  const deal = await prisma.deal.findUnique({
    where: { id: dealId },
    include: {
      milestones: { orderBy: { sortOrder: "asc" } },
      workstreams: {
        orderBy: { sortOrder: "asc" },
        include: { tasks: { orderBy: { sortOrder: "asc" } } },
      },
    },
  });

  if (!deal) throw new Error("Deal not found");

  await prisma.template.create({
    data: {
      name: templateName,
      dealType: deal.dealType,
      ourRole: deal.ourRole,
      isSystem: false,
      definition: {
        milestones: deal.milestones.map((m) => ({ name: m.name, type: m.type })),
        workstreams: deal.workstreams.map((ws) => ({
          name: ws.name,
          tasks: ws.tasks.map((t) => t.title),
        })),
      },
    },
  });
}
```

- [ ] **Step 2: Add "Save as Template" button to deal settings**

- [ ] **Step 3: Verify template creation from deal**

- [ ] **Step 4: Commit**

```bash
git add src/actions/templates.ts
git commit -m "feat: add save deal as template"
```

---

## Chunk 7: Polish & Production Readiness

### Task 27: User management (admin only)

**Files:**
- Create: `dealflow/src/actions/users.ts`
- Create: `dealflow/src/app/[locale]/admin/users/page.tsx`
- Create: `dealflow/src/components/users/user-list.tsx`
- Create: `dealflow/src/components/users/user-form.tsx`

- [ ] **Step 1: Create user server actions**

`createUser` (admin only — creates user with hashed password), `updateUser` (name, email, role, locale), `resetPassword` (admin sets new password). All check that the current user has Admin role.

- [ ] **Step 2: Create user list component**

Table: name, email, role, locale. Edit and reset password actions.

- [ ] **Step 3: Create user form (dialog)**

Name, email, password (for create), role (Admin/Member), locale (zh/en).

- [ ] **Step 4: Create user management page**

Admin-only page at `/admin/users`. Shows user list + [+ Add User] button. If non-admin accesses, redirect to dashboard.

- [ ] **Step 5: Verify create user, edit user, reset password**

- [ ] **Step 6: Commit**

```bash
git add src/actions/users.ts src/app/\[locale\]/admin/ src/components/users/
git commit -m "feat: add user management (admin only)"
```

### Task 28: Authenticated document download API route

**Files:**
- Create: `dealflow/src/app/api/documents/[id]/download/route.ts`

- [ ] **Step 1: Create download route**

```typescript
import { NextRequest, NextResponse } from "next/server";
import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { readFile } from "fs/promises";
import path from "path";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const session = await auth();
  if (!session?.user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const { id } = await params;
  const doc = await prisma.document.findUnique({ where: { id } });
  if (!doc) {
    return NextResponse.json({ error: "Not found" }, { status: 404 });
  }

  const filePath = path.join(process.cwd(), doc.filePath);
  const fileBuffer = await readFile(filePath);

  return new NextResponse(fileBuffer, {
    headers: {
      "Content-Disposition": `attachment; filename="${doc.name}"`,
      "Content-Type": "application/octet-stream",
    },
  });
}
```

- [ ] **Step 2: Update document list to use authenticated download URL**

Download links should point to `/api/documents/[id]/download` instead of direct file paths.

- [ ] **Step 3: Verify download works only when authenticated**

- [ ] **Step 4: Commit**

```bash
git add src/app/api/documents/
git commit -m "feat: add authenticated document download route"
```

### Task 29: Protect routes with auth middleware

- [ ] **Step 1: Update middleware to check auth**

Redirect unauthenticated users to /login for all routes except /login and /api/auth.

- [ ] **Step 2: Verify unauthenticated access is blocked**

- [ ] **Step 3: Commit**

### Task 30: Error handling and loading states

- [ ] **Step 1: Add loading.tsx files**

Add `loading.tsx` to key route segments (dashboard, deals, deals/[dealId]) with skeleton UI.

- [ ] **Step 2: Add error.tsx files**

Add `error.tsx` to key route segments with user-friendly error messages.

- [ ] **Step 3: Commit**

### Task 31: Dockerfile for production

**Files:**
- Create: `dealflow/Dockerfile`

- [ ] **Step 1: Create multi-stage Dockerfile**

```dockerfile
FROM node:20-alpine AS base

FROM base AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npx prisma generate
RUN npm run build

FROM base AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/prisma ./prisma

EXPOSE 3000
CMD ["node", "server.js"]
```

- [ ] **Step 2: Update next.config.ts for standalone output**

Add `output: "standalone"` to next config.

- [ ] **Step 3: Update docker-compose.yml to include app service**

- [ ] **Step 4: Test full Docker build and run**

```bash
docker compose up --build
```

- [ ] **Step 5: Commit**

```bash
git add Dockerfile docker-compose.yml next.config.ts
git commit -m "infra: add Dockerfile and production Docker Compose"
```

### Task 32: Final smoke test

- [ ] **Step 1: Start fresh database**

```bash
docker compose down -v
docker compose up -d db
npx prisma migrate deploy
npx prisma db seed
```

- [ ] **Step 2: Run full workflow test**

1. Login as admin
2. Create a deal from Auction Buy-Side template
3. Verify milestones, workstreams, tasks generated
4. Toggle task status, verify activity entry
5. Add a manual note to activity feed
6. Create a decision with options
7. Link a task to the decision
8. Add a contact, link to deal
9. Upload a document
10. Check dashboard shows data
11. Search for the deal name
12. Switch locale zh → en
13. Create a new user via admin panel
14. Verify document download requires authentication

- [ ] **Step 3: Run test suite**

```bash
npm test
```

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "feat: DealFlow MVP complete"
```

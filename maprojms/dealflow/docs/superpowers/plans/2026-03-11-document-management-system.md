# Document Management System (DMS) v1 Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an integrated DMS with version control, Document Hub, and task/deal document binding.

**Architecture:** Extends existing DealFlow app. New `DocumentVersion` model for version history. Three access points: global Document Hub (`/documents`), deal documents page (upgraded), and task panel documents tab. Server actions handle all mutations; local filesystem for storage.

**Tech Stack:** Next.js 16 App Router, Prisma 7 + PostgreSQL, next-intl, shadcn/ui, Zustand, lucide-react

**Spec:** `docs/superpowers/specs/2026-03-11-document-management-system-design.md`

---

## File Structure

### New Files
| File | Responsibility |
|---|---|
| `src/lib/format.ts` | Shared utility: `formatFileSize()` helper |
| `src/app/[locale]/documents/page.tsx` | Document Hub route (server component) |
| `src/components/documents/document-hub.tsx` | Hub client component (filters + card list + panel) |
| `src/components/documents/document-filters.tsx` | Left sidebar filter controls |
| `src/components/documents/document-card.tsx` | Single document card in list |
| `src/components/documents/document-detail-panel.tsx` | Slide-in detail panel (preview, metadata, versions) |
| `src/components/documents/document-preview.tsx` | PDF/image inline preview |
| `src/components/documents/version-history.tsx` | Version history list with download/restore |
| `src/components/documents/upload-version-dialog.tsx` | Dialog for same-name version detection |
| `src/components/documents/task-documents-tab.tsx` | Documents tab content for task panel |
| `src/hooks/use-document-panel.ts` | Zustand store for document detail panel open/close |

### Modified Files
| File | Changes |
|---|---|
| `prisma/schema.prisma` | Document model updates, new DocumentVersion model, new ActivityType values |
| `src/actions/documents.ts` | Rewrite upload (new storage path, version detection), update delete (cascade versions) |
| `src/app/api/documents/[id]/download/route.ts` | Add version query param support, use `storagePath` |
| `src/components/layout/app-shell.tsx` | Add "文档管理" nav link |
| `src/components/tasks/task-panel.tsx` | Refactor to tabs (详情 \| 文档 \| 活动) |
| `src/components/documents/document-upload.tsx` | Add version detection, new storage path |
| `src/components/documents/document-list.tsx` | Add version badge, preview action |
| `src/app/[locale]/deals/[dealId]/documents/page.tsx` | Upgrade with workstream/task grouping, deal-level docs |
| `src/components/activity/activity-entry.tsx` | Add new ActivityType entries to typeStyles and typeToTranslationKey |
| `messages/zh.json` | New document + activity namespace keys |
| `messages/en.json` | New document + activity namespace keys |

---

## Chunk 1: Foundation

### Task 1: Prisma Schema Update

**Files:**
- Modify: `prisma/schema.prisma:63-72` (ActivityType enum)
- Modify: `prisma/schema.prisma:111-130` (User model — add relation)
- Modify: `prisma/schema.prisma:370-386` (Document model)
- Create: DocumentVersion model (after Document)

- [ ] **Step 1: Add new ActivityType enum values**

In `prisma/schema.prisma`, add three new values to the `ActivityType` enum:

```prisma
enum ActivityType {
  Note
  Call
  Meeting
  ClientInstruction
  TaskUpdate
  MilestoneChange
  DecisionCreated
  DocumentUpload
  DocumentVersionUpload
  DocumentRestore
  DocumentDelete
}
```

- [ ] **Step 2: Update the Document model**

Replace the existing Document model (lines 370-386) with:

```prisma
model Document {
  id             String   @id @default(cuid())
  name           String
  fileType       String   @default("")
  fileSize       Int      @default(0)
  storagePath    String   @map("filePath")
  currentVersion Int      @default(1)
  createdAt      DateTime @default(now())
  updatedAt      DateTime @default(now()) @updatedAt

  dealId       String
  deal         Deal        @relation(fields: [dealId], references: [id], onDelete: Cascade)
  workstreamId String?
  workstream   Workstream? @relation(fields: [workstreamId], references: [id], onDelete: SetNull)
  taskId       String?
  task         Task?       @relation(fields: [taskId], references: [id], onDelete: SetNull)
  uploadedById String
  uploadedBy   User        @relation(fields: [uploadedById], references: [id])

  versions DocumentVersion[]

  @@index([dealId])
}
```

Key changes:
- `filePath` renamed to `storagePath` with `@map("filePath")` — no DB column rename needed
- Added: `fileType`, `fileSize`, `currentVersion`, `updatedAt`
- Added: `versions` relation to DocumentVersion

- [ ] **Step 3: Create the DocumentVersion model**

Add after the Document model:

```prisma
model DocumentVersion {
  id            String   @id @default(cuid())
  versionNumber Int
  name          String
  fileType      String
  fileSize      Int
  storagePath   String
  note          String?
  createdAt     DateTime @default(now())

  documentId   String
  document     Document @relation(fields: [documentId], references: [id], onDelete: Cascade)
  uploadedById String
  uploadedBy   User     @relation("DocumentVersions", fields: [uploadedById], references: [id])

  @@index([documentId])
}
```

- [ ] **Step 4: Add DocumentVersion relation to User model**

In the User model (around line 121-130), add:

```prisma
  documentVersions DocumentVersion[] @relation("DocumentVersions")
```

Add this after the existing `documents Document[]` line.

- [ ] **Step 5: Generate migration and Prisma client**

Run:
```bash
cd /Users/BBB/ccproj/maprojms/dealflow
npx prisma migrate dev --name add-document-versioning
```

Expected: Migration creates successfully, adds `fileType`, `fileSize`, `currentVersion`, `updatedAt` columns to Document table, creates DocumentVersion table, adds new ActivityType enum values. The `@map("filePath")` means the DB column stays as `filePath` — no rename needed.

Then generate the client:
```bash
npx prisma generate
```

- [ ] **Step 6: Verify the migration**

Run:
```bash
npx prisma migrate status
```

Expected: All migrations applied, no pending.

- [ ] **Step 7: Commit**

```bash
git add prisma/schema.prisma prisma/migrations/
git commit -m "feat(dms): add DocumentVersion model and update Document schema"
```

---

### Task 2: i18n Messages

**Files:**
- Modify: `messages/zh.json:195-207` (document section)
- Modify: `messages/en.json` (document section)

- [ ] **Step 1: Update Chinese messages**

Replace the `"document"` section in `messages/zh.json` with:

```json
  "document": {
    "documents": "文档管理",
    "fileName": "文件名",
    "workstream": "工作流",
    "task": "任务",
    "uploadedBy": "上传人",
    "date": "日期",
    "upload": "上传",
    "selectFile": "选择文件",
    "deleteConfirm": "确认删除此文件？所有版本将被永久删除。",
    "noDocuments": "暂无文件",
    "download": "下载",
    "preview": "预览",
    "versionHistory": "版本历史",
    "uploadNewVersion": "上传新版本",
    "currentVersion": "当前版本",
    "restoreVersion": "恢复此版本",
    "restoreConfirm": "确认恢复到版本 {version}？这将创建一个新版本。",
    "versionNote": "版本说明（可选）",
    "generalDocuments": "通用文档",
    "allDeals": "全部项目",
    "allWorkstreams": "全部工作流",
    "allTypes": "全部类型",
    "dateRange": "日期范围",
    "uploader": "上传人",
    "sortByDate": "按日期",
    "sortByName": "按名称",
    "sortBySize": "按大小",
    "fileExists": "文件 \"{name}\" 已存在",
    "uploadAsNewVersion": "上传为新版本 (v{version})",
    "uploadAsSeparate": "上传为独立文档",
    "details": "详情",
    "activity": "活动"
  }
```

- [ ] **Step 2: Update English messages**

Replace the `"document"` section in `messages/en.json` with the English equivalents:

```json
  "document": {
    "documents": "Documents",
    "fileName": "File Name",
    "workstream": "Workstream",
    "task": "Task",
    "uploadedBy": "Uploaded By",
    "date": "Date",
    "upload": "Upload",
    "selectFile": "Select File",
    "deleteConfirm": "Delete this document? All versions will be permanently deleted.",
    "noDocuments": "No documents yet",
    "download": "Download",
    "preview": "Preview",
    "versionHistory": "Version History",
    "uploadNewVersion": "Upload New Version",
    "currentVersion": "Current Version",
    "restoreVersion": "Restore This Version",
    "restoreConfirm": "Restore to version {version}? This will create a new version.",
    "versionNote": "Version note (optional)",
    "generalDocuments": "General Documents",
    "allDeals": "All Deals",
    "allWorkstreams": "All Workstreams",
    "allTypes": "All Types",
    "dateRange": "Date Range",
    "uploader": "Uploader",
    "sortByDate": "By Date",
    "sortByName": "By Name",
    "sortBySize": "By Size",
    "fileExists": "File \"{name}\" already exists",
    "uploadAsNewVersion": "Upload as new version (v{version})",
    "uploadAsSeparate": "Upload as separate document",
    "details": "Details",
    "activity": "Activity"
  }
```

- [ ] **Step 3: Add nav key for Documents**

In `messages/zh.json`, add to the `"nav"` section:
```json
    "documents": "文档管理"
```

In `messages/en.json`, add to the `"nav"` section:
```json
    "documents": "Documents"
```

- [ ] **Step 4: Add activity type translations**

The `ActivityType` enum now has 3 new values. The `activity-entry.tsx` component uses `Record<ActivityType, string>` which requires ALL enum values. Without these entries, TypeScript will fail to compile.

In `messages/zh.json`, add to the `"activity"` section:
```json
    "documentVersionUpload": "新版本",
    "documentRestore": "版本恢复",
    "documentDelete": "文件删除"
```

In `messages/en.json`, add to the `"activity"` section:
```json
    "documentVersionUpload": "New Version",
    "documentRestore": "Restore",
    "documentDelete": "Deleted"
```

- [ ] **Step 5: Update activity-entry.tsx**

In `src/components/activity/activity-entry.tsx`, add the new entries to both `typeStyles` and `typeToTranslationKey` records:

Add to `typeStyles` (after `DocumentUpload` line):
```typescript
  DocumentVersionUpload: "bg-sky-100 text-sky-700",
  DocumentRestore: "bg-teal-100 text-teal-700",
  DocumentDelete: "bg-red-100 text-red-700",
```

Add to `typeToTranslationKey` (after `DocumentUpload` line):
```typescript
  DocumentVersionUpload: "documentVersionUpload",
  DocumentRestore: "documentRestore",
  DocumentDelete: "documentDelete",
```

- [ ] **Step 6: Create formatFileSize utility**

Create `src/lib/format.ts`:

```typescript
export function formatFileSize(bytes: number): string {
  if (bytes === 0) return "0 B";
  const units = ["B", "KB", "MB", "GB"];
  const i = Math.floor(Math.log(bytes) / Math.log(1024));
  return `${(bytes / Math.pow(1024, i)).toFixed(i === 0 ? 0 : 1)} ${units[i]}`;
}
```

- [ ] **Step 7: Commit**

```bash
git add messages/zh.json messages/en.json src/components/activity/activity-entry.tsx src/lib/format.ts
git commit -m "feat(dms): add i18n messages, activity type entries, and formatFileSize utility"
```

---

### Task 3: Navigation Link

**Files:**
- Modify: `src/components/layout/app-shell.tsx:22-31`

- [ ] **Step 1: Add Documents nav link**

In `app-shell.tsx`, add the `tDocument` translation and the nav link. The Documents link goes between billing and contacts in the `navLinks` array.

Add a new translation getter after line 14:
```typescript
  const tDocument = await getTranslations("nav");
```

Wait — `t` already uses `getTranslations("nav")`, so just use the existing `t`. Insert the new link in the `navLinks` array between billing and contacts:

```typescript
  const navLinks = [
    { href: `/${locale}/dashboard`, label: t("dashboard") },
    { href: `/${locale}/deals`, label: t("deals") },
    { href: `/${locale}/tasks`, label: t("myTasks") },
    { href: `/${locale}/calendar`, label: t("calendar") },
    { href: `/${locale}/billing`, label: tBilling("billing") },
    { href: `/${locale}/documents`, label: t("documents") },
    { href: `/${locale}/contacts`, label: t("contacts") },
    ...(role === "Admin"
      ? [{ href: `/${locale}/admin/users`, label: t("admin") }]
      : []),
  ];
```

The only change is adding `{ href: \`/${locale}/documents\`, label: t("documents") }` after the billing link.

- [ ] **Step 2: Verify the nav renders**

Run:
```bash
npm run dev
```

Open browser, verify "文档管理" appears in the nav between "计时管理" and "通讯录". Clicking it should 404 (page not created yet).

- [ ] **Step 3: Commit**

```bash
git add src/components/layout/app-shell.tsx
git commit -m "feat(dms): add documents nav link"
```

---

## Chunk 2: Server Actions & API

### Task 4: Rewrite Document Upload Action

**Files:**
- Modify: `src/actions/documents.ts`

- [ ] **Step 1: Rewrite uploadDocument with new storage path and version detection**

Replace the entire `src/actions/documents.ts` with:

```typescript
"use server";

import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { assertDealMember, revalidateDeal } from "@/actions/_helpers";
import { writeFile, unlink, mkdir, rm } from "fs/promises";
import { join } from "path";

const UPLOAD_DIR = join(process.cwd(), "storage", "uploads");

async function ensureDir(dir: string) {
  await mkdir(dir, { recursive: true });
}

function getFileExtension(filename: string): string {
  return filename.includes(".") ? "." + filename.split(".").pop() : "";
}

function getFileType(filename: string): string {
  const ext = filename.split(".").pop()?.toLowerCase() || "";
  const mimeTypes: Record<string, string> = {
    pdf: "application/pdf",
    doc: "application/msword",
    docx: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    xls: "application/vnd.ms-excel",
    xlsx: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    ppt: "application/vnd.ms-powerpoint",
    pptx: "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    png: "image/png",
    jpg: "image/jpeg",
    jpeg: "image/jpeg",
    gif: "image/gif",
    txt: "text/plain",
    csv: "text/csv",
    zip: "application/zip",
    rar: "application/x-rar-compressed",
    rtf: "application/rtf",
  };
  return mimeTypes[ext] || "application/octet-stream";
}

// ---------- checkDuplicateName ----------

export async function checkDuplicateName(
  name: string,
  dealId: string,
  taskId: string | null
) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  await assertDealMember(dealId, session.user.id);

  const existing = await prisma.document.findFirst({
    where: {
      name,
      dealId,
      taskId: taskId ?? null,
    },
    select: { id: true, currentVersion: true },
  });
  return existing;
}

// ---------- uploadDocument ----------

export async function uploadDocument(formData: FormData) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const dealId = formData.get("dealId") as string;
  const file = formData.get("file") as File;
  const workstreamId = (formData.get("workstreamId") as string) || null;
  const taskId = (formData.get("taskId") as string) || null;

  if (!dealId || !file || !(file instanceof File)) {
    throw new Error("Missing required fields");
  }

  const MAX_FILE_SIZE = 50 * 1024 * 1024; // 50 MB
  if (file.size > MAX_FILE_SIZE) throw new Error("File too large (max 50 MB)");

  await assertDealMember(dealId, session.user.id);

  const ext = getFileExtension(file.name);
  const fileType = getFileType(file.name);
  const bytes = await file.arrayBuffer();
  const buffer = Buffer.from(bytes);

  // Create document record first to get the ID
  const document = await prisma.document.create({
    data: {
      name: file.name,
      fileType,
      fileSize: file.size,
      storagePath: "", // placeholder, updated below
      currentVersion: 1,
      dealId,
      workstreamId: workstreamId || null,
      taskId: taskId || null,
      uploadedById: session.user.id,
    },
  });

  // Write file with new path convention
  const docDir = join(UPLOAD_DIR, dealId, document.id);
  await ensureDir(docDir);
  const storagePath = `${dealId}/${document.id}/v1${ext}`;
  await writeFile(join(UPLOAD_DIR, storagePath), buffer);

  // Update storagePath
  await prisma.document.update({
    where: { id: document.id },
    data: { storagePath },
  });

  // Activity log
  await prisma.activityEntry.create({
    data: {
      type: "DocumentUpload",
      content: `Document uploaded: ${file.name}`,
      dealId,
      authorId: session.user.id,
    },
  });

  await revalidateDeal(dealId, `/deals/${dealId}/documents`);
  return { ...document, storagePath };
}

// ---------- uploadNewVersion ----------

export async function uploadNewVersion(formData: FormData) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const documentId = formData.get("documentId") as string;
  const file = formData.get("file") as File;
  const note = (formData.get("note") as string) || null;

  if (!documentId || !file || !(file instanceof File)) {
    throw new Error("Missing required fields");
  }

  const MAX_FILE_SIZE = 50 * 1024 * 1024;
  if (file.size > MAX_FILE_SIZE) throw new Error("File too large (max 50 MB)");

  const existing = await prisma.document.findUnique({
    where: { id: documentId },
    select: {
      id: true, name: true, fileType: true, fileSize: true,
      storagePath: true, currentVersion: true, dealId: true,
      uploadedById: true,
    },
  });
  if (!existing) throw new Error("Document not found");

  await assertDealMember(existing.dealId, session.user.id);

  const newVersion = existing.currentVersion + 1;
  const ext = getFileExtension(file.name);
  const fileType = getFileType(file.name);

  // Save current version to DocumentVersion
  await prisma.documentVersion.create({
    data: {
      documentId: existing.id,
      versionNumber: existing.currentVersion,
      name: existing.name,
      fileType: existing.fileType,
      fileSize: existing.fileSize,
      storagePath: existing.storagePath,
      uploadedById: existing.uploadedById,
    },
  });

  // Write new file
  const storagePath = `${existing.dealId}/${existing.id}/v${newVersion}${ext}`;
  const docDir = join(UPLOAD_DIR, existing.dealId, existing.id);
  await ensureDir(docDir);
  const bytes = await file.arrayBuffer();
  await writeFile(join(UPLOAD_DIR, storagePath), Buffer.from(bytes));

  // Update document to new version
  await prisma.document.update({
    where: { id: documentId },
    data: {
      name: file.name,
      fileType,
      fileSize: file.size,
      storagePath,
      currentVersion: newVersion,
      uploadedById: session.user.id,
    },
  });

  // Activity log
  await prisma.activityEntry.create({
    data: {
      type: "DocumentVersionUpload",
      content: `New version uploaded: ${file.name} v${newVersion}${note ? ` — ${note}` : ""}`,
      dealId: existing.dealId,
      authorId: session.user.id,
    },
  });

  await revalidateDeal(existing.dealId, `/deals/${existing.dealId}/documents`);
}

// ---------- restoreVersion ----------

export async function restoreVersion(documentId: string, versionNumber: number) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const document = await prisma.document.findUnique({
    where: { id: documentId },
    select: {
      id: true, name: true, fileType: true, fileSize: true,
      storagePath: true, currentVersion: true, dealId: true,
      uploadedById: true,
    },
  });
  if (!document) throw new Error("Document not found");

  await assertDealMember(document.dealId, session.user.id);

  const targetVersion = await prisma.documentVersion.findFirst({
    where: { documentId, versionNumber },
  });
  if (!targetVersion) throw new Error("Version not found");

  const newVersionNum = document.currentVersion + 1;

  // Save current as a version
  await prisma.documentVersion.create({
    data: {
      documentId: document.id,
      versionNumber: document.currentVersion,
      name: document.name,
      fileType: document.fileType,
      fileSize: document.fileSize,
      storagePath: document.storagePath,
      uploadedById: document.uploadedById,
    },
  });

  // Restore: update document with the target version's data
  await prisma.document.update({
    where: { id: documentId },
    data: {
      name: targetVersion.name,
      fileType: targetVersion.fileType,
      fileSize: targetVersion.fileSize,
      storagePath: targetVersion.storagePath,
      currentVersion: newVersionNum,
      uploadedById: session.user.id,
    },
  });

  // Activity log
  await prisma.activityEntry.create({
    data: {
      type: "DocumentRestore",
      content: `Restored ${targetVersion.name} from v${versionNumber} (now v${newVersionNum})`,
      dealId: document.dealId,
      authorId: session.user.id,
    },
  });

  await revalidateDeal(document.dealId, `/deals/${document.dealId}/documents`);
}

// ---------- getVersionHistory ----------

export async function getVersionHistory(documentId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const document = await prisma.document.findUnique({
    where: { id: documentId },
    select: { dealId: true },
  });
  if (!document) throw new Error("Document not found");

  await assertDealMember(document.dealId, session.user.id);

  return prisma.documentVersion.findMany({
    where: { documentId },
    orderBy: { versionNumber: "desc" },
    include: { uploadedBy: { select: { name: true } } },
  });
}

// ---------- deleteDocument ----------

export async function deleteDocument(documentId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const document = await prisma.document.findUnique({
    where: { id: documentId },
    select: { name: true, storagePath: true, dealId: true, uploadedById: true },
  });
  if (!document) throw new Error("Document not found");

  await assertDealMember(document.dealId, session.user.id);

  // Check permission: only uploader or admin
  const user = await prisma.user.findUnique({
    where: { id: session.user.id },
    select: { role: true },
  });
  if (document.uploadedById !== session.user.id && user?.role !== "Admin") {
    throw new Error("Only the uploader or an admin can delete documents");
  }

  // Delete all version files and directory
  const docDir = join(UPLOAD_DIR, document.dealId, documentId);
  try {
    await rm(docDir, { recursive: true, force: true });
  } catch {
    // Directory may not exist (legacy flat-path files)
  }

  // Also try deleting legacy flat file
  if (!document.storagePath.includes("/")) {
    try {
      await unlink(join(UPLOAD_DIR, document.storagePath));
    } catch {
      // File may already be removed
    }
  }

  // Cascade: DocumentVersion rows deleted automatically via onDelete: Cascade
  await prisma.document.delete({ where: { id: documentId } });

  await prisma.activityEntry.create({
    data: {
      type: "DocumentDelete",
      content: `Document deleted: ${document.name}`,
      dealId: document.dealId,
      authorId: session.user.id,
    },
  });

  await revalidateDeal(document.dealId, `/deals/${document.dealId}/documents`);
}
```

- [ ] **Step 2: Verify TypeScript compiles**

Run:
```bash
npx tsc --noEmit 2>&1 | grep -E "documents\.(ts|tsx)" || echo "No errors"
```

- [ ] **Step 3: Commit**

```bash
git add src/actions/documents.ts
git commit -m "feat(dms): rewrite document actions with versioning support"
```

---

### Task 5: Rewrite Download Route

**Files:**
- Modify: `src/app/api/documents/[id]/download/route.ts`

- [ ] **Step 1: Add version query parameter support**

Replace the entire download route with:

```typescript
import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { NextRequest, NextResponse } from "next/server";
import { readFile } from "fs/promises";
import { join } from "path";

const UPLOAD_DIR = join(process.cwd(), "storage", "uploads");

const contentTypes: Record<string, string> = {
  pdf: "application/pdf",
  doc: "application/msword",
  docx: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  xls: "application/vnd.ms-excel",
  xlsx: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  ppt: "application/vnd.ms-powerpoint",
  pptx: "application/vnd.openxmlformats-officedocument.presentationml.presentation",
  png: "image/png",
  jpg: "image/jpeg",
  jpeg: "image/jpeg",
  gif: "image/gif",
  txt: "text/plain",
  csv: "text/csv",
  zip: "application/zip",
  rar: "application/x-rar-compressed",
  rtf: "application/rtf",
};

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const session = await auth();
  if (!session?.user?.id) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const { id } = await params;
  const versionParam = request.nextUrl.searchParams.get("version");

  const document = await prisma.document.findUnique({
    where: { id },
    select: {
      name: true,
      storagePath: true,
      dealId: true,
      fileType: true,
    },
  });

  if (!document) {
    return NextResponse.json({ error: "Not found" }, { status: 404 });
  }

  // Check membership
  const membership = await prisma.dealMember.findUnique({
    where: {
      dealId_userId: { dealId: document.dealId, userId: session.user.id },
    },
  });

  if (!membership) {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }

  // Determine which file to serve
  let filePath: string;
  let fileName: string;

  if (versionParam) {
    const version = await prisma.documentVersion.findFirst({
      where: { documentId: id, versionNumber: parseInt(versionParam, 10) },
      select: { storagePath: true, name: true },
    });
    if (!version) {
      return NextResponse.json({ error: "Version not found" }, { status: 404 });
    }
    filePath = version.storagePath;
    fileName = version.name;
  } else {
    filePath = document.storagePath;
    fileName = document.name;
  }

  try {
    const fullPath = join(UPLOAD_DIR, filePath);
    if (!fullPath.startsWith(UPLOAD_DIR)) {
      return NextResponse.json({ error: "Invalid file path" }, { status: 400 });
    }
    const fileBuffer = await readFile(fullPath);

    const ext = fileName.split(".").pop()?.toLowerCase() || "";
    const contentType = contentTypes[ext] || "application/octet-stream";

    // For preview mode (PDF/images), use inline disposition
    const previewParam = request.nextUrl.searchParams.get("preview");
    const isPreviewable = ["pdf", "png", "jpg", "jpeg", "gif"].includes(ext);
    const disposition = previewParam && isPreviewable ? "inline" : "attachment";

    return new NextResponse(fileBuffer, {
      headers: {
        "Content-Type": contentType,
        "Content-Disposition": `${disposition}; filename="${encodeURIComponent(fileName)}"`,
      },
    });
  } catch {
    return NextResponse.json(
      { error: "File not found on disk" },
      { status: 404 }
    );
  }
}
```

Key changes:
- Added `?version=N` query param to serve specific versions
- Added `?preview=true` query param for inline display (PDF/images)
- Uses `storagePath` instead of `filePath`
- Supports both legacy flat paths and new nested paths

- [ ] **Step 2: Verify TypeScript compiles**

Run:
```bash
npx tsc --noEmit 2>&1 | grep "download" || echo "No errors"
```

- [ ] **Step 3: Commit**

```bash
git add src/app/api/documents/[id]/download/route.ts
git commit -m "feat(dms): add version and preview support to download route"
```

---

## Chunk 3: Document Hub UI

### Task 6: Document Panel Zustand Store

**Files:**
- Create: `src/hooks/use-document-panel.ts`

- [ ] **Step 1: Create the Zustand store**

```typescript
"use client";

import { create } from "zustand";

interface DocumentPanelState {
  documentId: string | null;
  open: (id: string) => void;
  close: () => void;
}

export const useDocumentPanel = create<DocumentPanelState>((set) => ({
  documentId: null,
  open: (id) => set({ documentId: id }),
  close: () => set({ documentId: null }),
}));
```

This follows the same pattern as `src/hooks/use-task-panel.ts`.

- [ ] **Step 2: Commit**

```bash
git add src/hooks/use-document-panel.ts
git commit -m "feat(dms): add document panel zustand store"
```

---

### Task 7: Document Hub Page

**Files:**
- Create: `src/app/[locale]/documents/page.tsx`
- Create: `src/components/documents/document-hub.tsx`
- Create: `src/components/documents/document-filters.tsx`
- Create: `src/components/documents/document-card.tsx`

- [ ] **Step 1: Create the Document Hub server component page**

Create `src/app/[locale]/documents/page.tsx`:

```typescript
import { auth } from "@/lib/auth";
import { redirect } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { getLocale, getTranslations } from "next-intl/server";
import { DocumentHub } from "@/components/documents/document-hub";

export default async function DocumentsHubPage() {
  const session = await auth();
  const locale = await getLocale();

  if (!session?.user?.id) {
    redirect(`/${locale}/login`);
  }

  // Get all deals the user is a member of
  const userDeals = await prisma.dealMember.findMany({
    where: { userId: session.user.id },
    select: { dealId: true },
  });
  const dealIds = userDeals.map((d) => d.dealId);

  // Fetch all documents across user's deals
  const documents = await prisma.document.findMany({
    where: { dealId: { in: dealIds } },
    orderBy: { updatedAt: "desc" },
    include: {
      deal: { select: { id: true, name: true } },
      workstream: { select: { id: true, name: true } },
      task: { select: { id: true, title: true } },
      uploadedBy: { select: { id: true, name: true } },
    },
  });

  // Get deals with workstreams for filters
  const deals = await prisma.deal.findMany({
    where: { id: { in: dealIds } },
    select: {
      id: true,
      name: true,
      workstreams: {
        orderBy: { sortOrder: "asc" },
        select: { id: true, name: true },
      },
      members: {
        include: { user: { select: { id: true, name: true } } },
      },
    },
  });

  const t = await getTranslations("document");

  const documentsData = documents.map((d) => ({
    id: d.id,
    name: d.name,
    fileType: d.fileType,
    fileSize: d.fileSize,
    currentVersion: d.currentVersion,
    createdAt: d.createdAt.toISOString(),
    updatedAt: d.updatedAt.toISOString(),
    deal: d.deal,
    workstream: d.workstream,
    task: d.task,
    uploadedBy: d.uploadedBy,
  }));

  const dealsData = deals.map((d) => ({
    id: d.id,
    name: d.name,
    workstreams: d.workstreams,
    members: d.members.map((m) => m.user),
  }));

  return (
    <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6">
      <h1 className="mb-4 text-lg font-semibold">{t("documents")}</h1>
      <DocumentHub documents={documentsData} deals={dealsData} />
    </div>
  );
}
```

- [ ] **Step 2: Create DocumentHub client component**

Create `src/components/documents/document-hub.tsx`:

This is the main client component that manages filter state and renders the sidebar + card list layout. It should:
- Accept `documents` and `deals` as props (serialized from server)
- Maintain filter state: `selectedDealId`, `selectedWorkstreamId`, `selectedFileType`, `selectedUploaderId`, `searchQuery`, `sortBy`
- Filter documents client-side based on current filter state
- Render `<DocumentFilters>` on the left and document cards on the right
- Render `<DocumentDetailPanel>` for the selected document
- Paginate at 50 documents per page

Key types:
```typescript
export type DocumentItem = {
  id: string;
  name: string;
  fileType: string;
  fileSize: number;
  currentVersion: number;
  createdAt: string;
  updatedAt: string;
  deal: { id: string; name: string };
  workstream: { id: string; name: string } | null;
  task: { id: string; title: string } | null;
  uploadedBy: { id: string; name: string };
};

export type DealOption = {
  id: string;
  name: string;
  workstreams: { id: string; name: string }[];
  members: { id: string; name: string }[];
};
```

Layout structure:
```tsx
<div className="flex gap-6">
  <div className="w-[240px] shrink-0">
    <DocumentFilters ... />
  </div>
  <div className="flex-1 min-w-0">
    {/* Search bar */}
    <Input placeholder={t("search")} ... />
    {/* Sort controls */}
    {/* Document card list */}
    {filteredDocs.map(doc => <DocumentCard key={doc.id} document={doc} />)}
    {/* Pagination */}
  </div>
</div>
<DocumentDetailPanel />
```

- [ ] **Step 3: Create DocumentFilters component**

Create `src/components/documents/document-filters.tsx`:

A sidebar with Select dropdowns for: Deal, Workstream (populated from selected deal), File Type (Word/PDF/Excel/PPT/Image/Other), Uploader (populated from selected deal's members). Each filter calls an `onChange` callback to the parent hub.

- [ ] **Step 4: Create DocumentCard component**

Create `src/components/documents/document-card.tsx`:

Each card displays:
- File type icon (use lucide-react: `FileText` for Word/PDF, `FileSpreadsheet` for Excel, `FileImage` for images, `File` as fallback)
- Document name
- Context path: `Deal → Workstream → Task` (or `Deal → 通用文档`)
- Uploader name and date
- Version badge (e.g. `v3`) if currentVersion > 1
- Click handler calls `useDocumentPanel().open(doc.id)`

```tsx
<div
  className="flex items-center gap-3 rounded-lg border p-3 cursor-pointer transition-colors hover:bg-accent"
  onClick={() => openPanel(document.id)}
>
  <FileTypeIcon fileType={document.fileType} />
  <div className="flex-1 min-w-0">
    <p className="text-sm font-medium truncate">{document.name}</p>
    <p className="text-xs text-muted-foreground truncate">
      {document.deal.name} → {document.workstream?.name ?? t("generalDocuments")}
      {document.task && ` → ${document.task.title}`}
    </p>
  </div>
  <div className="text-right shrink-0">
    <p className="text-xs text-muted-foreground">{document.uploadedBy.name}</p>
    <p className="text-xs text-muted-foreground">{formatDate(document.updatedAt)}</p>
  </div>
  {document.currentVersion > 1 && (
    <Badge variant="secondary" className="text-xs">v{document.currentVersion}</Badge>
  )}
</div>
```

- [ ] **Step 5: Verify the hub page renders**

Run dev server, navigate to `/{locale}/documents`. Should show the page with filters and document cards (may be empty if no docs exist).

- [ ] **Step 6: Commit**

```bash
git add src/app/[locale]/documents/page.tsx src/components/documents/document-hub.tsx src/components/documents/document-filters.tsx src/components/documents/document-card.tsx
git commit -m "feat(dms): add Document Hub page with filters and card list"
```

---

### Task 8: Document Detail Panel

**Files:**
- Create: `src/components/documents/document-detail-panel.tsx`
- Create: `src/components/documents/document-preview.tsx`
- Create: `src/components/documents/version-history.tsx`

- [ ] **Step 1: Create DocumentDetailPanel**

Create `src/components/documents/document-detail-panel.tsx`:

This is a Sheet (slide-in panel) that opens when a document card is clicked. Uses `useDocumentPanel()` to read `documentId` and control open/close.

When opened, it fetches the document detail and version history. Contains:
- Document name + file type icon
- `<DocumentPreview>` component
- Action buttons: Download, Upload New Version
- Metadata section: deal path, uploader, date, file size
- `<VersionHistory>` component
- Close button

```tsx
"use client";

import { useEffect, useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetDescription } from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { useDocumentPanel } from "@/hooks/use-document-panel";
import { getVersionHistory } from "@/actions/documents";
import { formatFileSize } from "@/lib/format";
import { DocumentPreview } from "./document-preview";
import { VersionHistory } from "./version-history";
import { Download, Upload, X, Loader2 } from "lucide-react";

// Fetch document detail via server action or pass as prop
// For the hub, we already have the document data in the parent
// Pass the full document list to the panel and look up by ID

export function DocumentDetailPanel({ documents }: { documents: DocumentItem[] }) {
  const t = useTranslations("document");
  const documentId = useDocumentPanel((s) => s.documentId);
  const close = useDocumentPanel((s) => s.close);
  const isOpen = documentId !== null;

  const document = documents.find((d) => d.id === documentId);

  // Fetch version history when panel opens
  const [versions, setVersions] = useState<any[]>([]);
  const [loadingVersions, setLoadingVersions] = useState(false);

  useEffect(() => {
    if (documentId) {
      setLoadingVersions(true);
      getVersionHistory(documentId)
        .then(setVersions)
        .finally(() => setLoadingVersions(false));
    }
  }, [documentId]);

  if (!document) return null;

  return (
    <Sheet open={isOpen} onOpenChange={(open) => !open && close()}>
      <SheetContent side="right" className="w-full sm:max-w-lg overflow-y-auto">
        <SheetHeader>
          <SheetTitle>{document.name}</SheetTitle>
          <SheetDescription className="sr-only">{t("documents")}</SheetDescription>
        </SheetHeader>

        {/* Preview */}
        <DocumentPreview documentId={document.id} fileName={document.name} fileType={document.fileType} />

        {/* Actions */}
        <div className="flex gap-2 my-4">
          <Button asChild size="sm">
            <a href={`/api/documents/${document.id}/download`}><Download className="size-3.5 mr-1" />{t("download")}</a>
          </Button>
          <Button variant="outline" size="sm">
            <Upload className="size-3.5 mr-1" />{t("uploadNewVersion")}
          </Button>
        </div>

        {/* Metadata */}
        <div className="text-sm space-y-1 text-muted-foreground border-t pt-4">
          <p>{document.deal.name} → {document.workstream?.name ?? t("generalDocuments")}{document.task ? ` → ${document.task.title}` : ""}</p>
          <p>{document.uploadedBy.name} · {new Date(document.updatedAt).toLocaleDateString()}</p>
          <p>{formatFileSize(document.fileSize)}</p>
        </div>

        {/* Version History */}
        <div className="mt-4 border-t pt-4">
          <h3 className="text-sm font-medium mb-2">{t("versionHistory")}</h3>
          <VersionHistory
            documentId={document.id}
            currentVersion={document.currentVersion}
            versions={versions}
            loading={loadingVersions}
          />
        </div>
      </SheetContent>
    </Sheet>
  );
}
```

- [ ] **Step 2: Create DocumentPreview component**

Create `src/components/documents/document-preview.tsx`:

For PDF files: render an iframe pointing to `/api/documents/{id}/download?preview=true`
For images: render an img tag pointing to the same URL
For other files: render a large file type icon with the file name

```tsx
"use client";

import { File as FileIcon } from "lucide-react";

export function DocumentPreview({ documentId, fileName, fileType }: {
  documentId: string;
  fileName: string;
  fileType: string;
}) {
  const isPdf = fileType === "application/pdf";
  const isImage = fileType.startsWith("image/");
  const previewUrl = `/api/documents/${documentId}/download?preview=true`;

  if (isPdf) {
    return (
      <iframe
        src={previewUrl}
        className="w-full h-64 rounded-md border"
        title={fileName}
      />
    );
  }

  if (isImage) {
    return (
      <img
        src={previewUrl}
        alt={fileName}
        className="w-full max-h-64 object-contain rounded-md border"
      />
    );
  }

  // Non-previewable: show icon
  return (
    <div className="flex h-32 items-center justify-center rounded-md border bg-muted">
      <FileIcon className="size-12 text-muted-foreground" />
    </div>
  );
}
```

- [ ] **Step 3: Create VersionHistory component**

Create `src/components/documents/version-history.tsx`:

Renders a list of versions with: version number, uploader name, date, optional note, download button, and restore button. Current version is labeled with a badge.

```tsx
"use client";

import { useTranslations } from "next-intl";
import { useTransition } from "react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { restoreVersion } from "@/actions/documents";
import { Download, RotateCcw, Loader2 } from "lucide-react";

export function VersionHistory({ documentId, currentVersion, versions, loading }: {
  documentId: string;
  currentVersion: number;
  versions: Array<{
    id: string;
    versionNumber: number;
    name: string;
    uploadedBy: { name: string };
    createdAt: Date;
    note: string | null;
  }>;
  loading: boolean;
}) {
  const t = useTranslations("document");
  const [isPending, startTransition] = useTransition();

  function handleRestore(versionNumber: number) {
    if (!confirm(t("restoreConfirm", { version: versionNumber }))) return;
    startTransition(async () => {
      await restoreVersion(documentId, versionNumber);
    });
  }

  if (loading) return <Loader2 className="size-4 animate-spin" />;

  return (
    <div className="space-y-2">
      {/* Current version */}
      <div className="flex items-center gap-2 text-sm">
        <Badge variant="default">v{currentVersion}</Badge>
        <span className="text-muted-foreground">{t("currentVersion")}</span>
      </div>

      {/* Previous versions */}
      {versions.map((v) => (
        <div key={v.id} className="flex items-center gap-2 text-sm py-1.5 border-t">
          <Badge variant="outline">v{v.versionNumber}</Badge>
          <span className="flex-1 text-muted-foreground truncate">
            {v.uploadedBy.name} · {new Date(v.createdAt).toLocaleDateString()}
            {v.note && ` — ${v.note}`}
          </span>
          <Button variant="ghost" size="sm" asChild>
            <a href={`/api/documents/${documentId}/download?version=${v.versionNumber}`}>
              <Download className="size-3" />
            </a>
          </Button>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => handleRestore(v.versionNumber)}
            disabled={isPending}
          >
            <RotateCcw className="size-3" />
          </Button>
        </div>
      ))}
    </div>
  );
}
```

- [ ] **Step 4: Verify panel opens from hub**

Run dev server, navigate to Document Hub, click a document card. The detail panel should slide in from the right.

- [ ] **Step 5: Commit**

```bash
git add src/components/documents/document-detail-panel.tsx src/components/documents/document-preview.tsx src/components/documents/version-history.tsx
git commit -m "feat(dms): add document detail panel with preview and version history"
```

---

## Chunk 4: Integration

### Task 9: Upload Version Dialog

**Files:**
- Create: `src/components/documents/upload-version-dialog.tsx`
- Modify: `src/components/documents/document-upload.tsx`

- [ ] **Step 1: Create UploadVersionDialog**

Create `src/components/documents/upload-version-dialog.tsx`:

A Dialog that appears when the user uploads a file with the same name as an existing document. Shows two options:
1. "Upload as new version (vN)" — calls `uploadNewVersion()`
2. "Upload as separate document" — calls `uploadDocument()` as normal

```tsx
"use client";

import { useTranslations } from "next-intl";
import { useTransition } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { uploadNewVersion, uploadDocument } from "@/actions/documents";

interface Props {
  open: boolean;
  onClose: () => void;
  file: File;
  existingDocId: string;
  existingVersion: number;
  dealId: string;
  workstreamId: string | null;
  taskId: string | null;
}

export function UploadVersionDialog({
  open, onClose, file, existingDocId, existingVersion, dealId, workstreamId, taskId,
}: Props) {
  const t = useTranslations("document");
  const [isPending, startTransition] = useTransition();

  function handleUploadAsVersion() {
    startTransition(async () => {
      const formData = new FormData();
      formData.set("documentId", existingDocId);
      formData.set("file", file);
      await uploadNewVersion(formData);
      onClose();
    });
  }

  function handleUploadAsSeparate() {
    startTransition(async () => {
      const formData = new FormData();
      formData.set("dealId", dealId);
      formData.set("file", file);
      if (workstreamId) formData.set("workstreamId", workstreamId);
      if (taskId) formData.set("taskId", taskId);
      await uploadDocument(formData);
      onClose();
    });
  }

  return (
    <Dialog open={open} onOpenChange={(o) => !o && onClose()}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{t("fileExists", { name: file.name })}</DialogTitle>
        </DialogHeader>
        <div className="flex flex-col gap-3 mt-4">
          <Button onClick={handleUploadAsVersion} disabled={isPending}>
            {t("uploadAsNewVersion", { version: existingVersion + 1 })}
          </Button>
          <Button variant="outline" onClick={handleUploadAsSeparate} disabled={isPending}>
            {t("uploadAsSeparate")}
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}
```

- [ ] **Step 2: Update DocumentUpload to use version detection**

Modify `src/components/documents/document-upload.tsx`:

Before uploading, call `checkDuplicateName(file.name, dealId, taskId)`. If a match is found, show the `UploadVersionDialog` instead of uploading directly.

Key changes:
- Import `checkDuplicateName` from `@/actions/documents`
- Import `UploadVersionDialog`
- Add state: `duplicateInfo` (holds existing doc id/version), `pendingFile`
- On form submit: check for duplicate first. If found, set `duplicateInfo` and `pendingFile` to open dialog. If not found, upload normally.
- On dialog close: reset `duplicateInfo` and `pendingFile`, refresh.

- [ ] **Step 3: Verify upload with version detection**

Run dev server, upload a document. Upload the same filename again — dialog should appear with two options.

- [ ] **Step 4: Commit**

```bash
git add src/components/documents/upload-version-dialog.tsx src/components/documents/document-upload.tsx
git commit -m "feat(dms): add upload version detection dialog"
```

---

### Task 10: Task Panel Tab Refactor

**Files:**
- Modify: `src/components/tasks/task-panel.tsx`
- Create: `src/components/documents/task-documents-tab.tsx`

- [ ] **Step 1: Create TaskDocumentsTab component**

Create `src/components/documents/task-documents-tab.tsx`:

A component that shows documents bound to a specific task with upload capability.

```tsx
"use client";

import { useEffect, useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Upload, Download, FileText, Loader2 } from "lucide-react";
import { uploadDocument, checkDuplicateName, deleteDocument, getTaskDocuments } from "@/actions/documents";
import { UploadVersionDialog } from "./upload-version-dialog";

interface Props {
  taskId: string;
  dealId: string;
  workstreamId: string;
}

export function TaskDocumentsTab({ taskId, dealId, workstreamId }: Props) {
  const t = useTranslations("document");
  const [documents, setDocuments] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [isPending, startTransition] = useTransition();

  // Dialog state for version detection
  const [duplicateInfo, setDuplicateInfo] = useState<{ id: string; version: number } | null>(null);
  const [pendingFile, setPendingFile] = useState<File | null>(null);

  // Fetch documents for this task via a server action
  useEffect(() => {
    loadDocuments();
  }, [taskId]);

  async function loadDocuments() {
    setLoading(true);
    try {
      // Use a server action to fetch task documents
      const res = await getTaskDocuments(taskId);
      setDocuments(res);
    } finally {
      setLoading(false);
    }
  }

  async function handleFileSelect(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;

    // Check for duplicate name
    const existing = await checkDuplicateName(file.name, dealId, taskId);
    if (existing) {
      setDuplicateInfo({ id: existing.id, version: existing.currentVersion });
      setPendingFile(file);
      return;
    }

    // Upload directly
    startTransition(async () => {
      const formData = new FormData();
      formData.set("dealId", dealId);
      formData.set("file", file);
      formData.set("workstreamId", workstreamId);
      formData.set("taskId", taskId);
      await uploadDocument(formData);
      await loadDocuments();
    });

    // Reset input
    e.target.value = "";
  }

  // ... render document list, upload button, version dialog
}
```

The component also needs a `getTaskDocuments` server action. Add to `src/actions/documents.ts`:

```typescript
export async function getTaskDocuments(taskId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const task = await prisma.task.findUnique({
    where: { id: taskId },
    select: { workstream: { select: { dealId: true } } },
  });
  if (!task) throw new Error("Task not found");

  await assertDealMember(task.workstream.dealId, session.user.id);

  return prisma.document.findMany({
    where: { taskId },
    orderBy: { updatedAt: "desc" },
    include: {
      uploadedBy: { select: { name: true } },
    },
  });
}
```

- [ ] **Step 2: Refactor TaskPanel to use tabs**

Modify `src/components/tasks/task-panel.tsx`:

Import `Tabs, TabsList, TabsTrigger, TabsContent` from `@/components/ui/tabs` and `TaskDocumentsTab`.

Wrap the current panel content in tabs. The structure becomes:

**IMPORTANT:** The tabs component uses `@base-ui/react`, NOT Radix. Panels are matched to tabs by **render order** (positional matching), not by a `value` prop on `TabsContent`. Use numeric `value` on `TabsTrigger` and `defaultValue` on `Tabs`. Do NOT pass `value` to `TabsContent` — just ensure panels appear in the same order as triggers.

```tsx
<Tabs defaultValue={0}>
  <TabsList className="w-full">
    <TabsTrigger value={0} className="flex-1">{tDocument("details")}</TabsTrigger>
    <TabsTrigger value={1} className="flex-1">{tDocument("documents")}</TabsTrigger>
    <TabsTrigger value={2} className="flex-1">{tDocument("activity")}</TabsTrigger>
  </TabsList>

  {/* Panel 0: Details — must match TabsTrigger order */}
  <TabsContent>
    {/* Status, Priority, Assignee, DueDate, Description, Subtasks, Dependencies, Time Entries, Delete */}
  </TabsContent>

  {/* Panel 1: Documents */}
  <TabsContent>
    <TaskDocumentsTab
      taskId={task.id}
      dealId={task.workstream.dealId}
      workstreamId={task.workstreamId}
    />
  </TabsContent>

  {/* Panel 2: Activity */}
  <TabsContent>
    <TaskComments ... />
  </TabsContent>
</Tabs>
```

Key changes:
- Import `Tabs` components and `TaskDocumentsTab`
- Import `useTranslations("document")` as `tDocument`
- Wrap existing panel body in `<TabsContent value="details">`
- Move `<TaskComments>` to `<TabsContent value="activity">`
- Add `<TaskDocumentsTab>` in `<TabsContent value="documents">`
- The Delete button stays in the details tab

Note: `task.workstream.dealId` is already available — see line 301 of the current `task-panel.tsx` where `task.workstream.dealId` is used for TaskDependencies.

- [ ] **Step 3: Verify task panel tabs work**

Run dev server, open a task. Should see three tabs. Details tab shows existing content. Documents tab shows document list with upload. Activity tab shows comments.

- [ ] **Step 4: Commit**

```bash
git add src/components/documents/task-documents-tab.tsx src/components/tasks/task-panel.tsx src/actions/documents.ts
git commit -m "feat(dms): add document tab to task panel"
```

---

### Task 11: Deal Documents Page Upgrade

**Files:**
- Modify: `src/app/[locale]/deals/[dealId]/documents/page.tsx`

- [ ] **Step 1: Upgrade the deal documents page**

Rewrite `src/app/[locale]/deals/[dealId]/documents/page.tsx` to show documents grouped by workstream → task, with a "通用文档" section for deal-level documents.

Key changes from the current simple list:
- Query includes `task` relation on documents
- Group documents: first "通用文档" (where `taskId` is null), then by workstream, then by task within each workstream
- Each document card shows version badge, preview/download actions
- Upload section at top with workstream/task selector (existing DocumentUpload component, updated with version detection)
- Use DocumentDetailPanel for slide-in detail view

```typescript
// Fetch documents with task info
const deal = await prisma.deal.findUnique({
  where: { id: dealId },
  select: {
    id: true,
    name: true,
    members: { select: { userId: true } },
    workstreams: {
      orderBy: { sortOrder: "asc" },
      select: {
        id: true,
        name: true,
        tasks: {
          orderBy: { sortOrder: "asc" },
          select: { id: true, title: true },
        },
      },
    },
    documents: {
      orderBy: { updatedAt: "desc" },
      include: {
        workstream: { select: { id: true, name: true } },
        task: { select: { id: true, title: true } },
        uploadedBy: { select: { id: true, name: true } },
      },
    },
  },
});

// Group documents
const generalDocs = documentsData.filter((d) => !d.taskId);
const docsByWorkstream = new Map<string, { name: string; tasks: Map<string, { title: string; docs: typeof documentsData }> }>();

for (const doc of documentsData.filter((d) => d.taskId)) {
  const wsId = doc.workstream?.id ?? "unknown";
  const wsName = doc.workstream?.name ?? "";
  if (!docsByWorkstream.has(wsId)) {
    docsByWorkstream.set(wsId, { name: wsName, tasks: new Map() });
  }
  const ws = docsByWorkstream.get(wsId)!;
  const taskId = doc.task?.id ?? "unknown";
  const taskTitle = doc.task?.title ?? "";
  if (!ws.tasks.has(taskId)) {
    ws.tasks.set(taskId, { title: taskTitle, docs: [] });
  }
  ws.tasks.get(taskId)!.docs.push(doc);
}
```

Render structure:
```tsx
{/* 通用文档 section */}
{generalDocs.length > 0 && (
  <section>
    <h2>{t("generalDocuments")}</h2>
    {generalDocs.map(doc => <DocumentCard ... />)}
  </section>
)}

{/* Per-workstream sections */}
{Array.from(docsByWorkstream.entries()).map(([wsId, ws]) => (
  <section key={wsId}>
    <h2>{ws.name}</h2>
    {Array.from(ws.tasks.entries()).map(([taskId, task]) => (
      <div key={taskId}>
        <h3>{task.title}</h3>
        {task.docs.map(doc => <DocumentCard ... />)}
      </div>
    ))}
  </section>
))}
```

- [ ] **Step 2: Add DocumentDetailPanel to the page**

Import and render `<DocumentDetailPanel documents={documentsData} />` at the bottom of the page so clicking any document card opens the detail panel.

- [ ] **Step 3: Verify deal documents page**

Run dev server, navigate to a deal's documents page. Should see grouped documents with version badges and the detail panel working.

- [ ] **Step 4: Commit**

```bash
git add src/app/[locale]/deals/[dealId]/documents/page.tsx
git commit -m "feat(dms): upgrade deal documents page with workstream grouping"
```

---

### Task 12: Final Integration & Cleanup

**Files:**
- Modify: `src/components/documents/document-list.tsx` (update to use new fields)
- Verify: all pages work end-to-end

- [ ] **Step 1: Update DocumentList component**

Update `src/components/documents/document-list.tsx` to handle the new schema:
- Use `storagePath` instead of `filePath` (the component doesn't reference this directly — it uses `/api/documents/{id}/download` URL, so this should already work)
- Add version badge column
- Add preview button for PDF/image files
- Update the download URL

- [ ] **Step 2: Run full type check**

```bash
cd /Users/BBB/ccproj/maprojms/dealflow
npx tsc --noEmit
```

Fix any TypeScript errors.

- [ ] **Step 3: Run dev server and test end-to-end**

Verify:
1. Nav link "文档管理" navigates to Document Hub
2. Document Hub shows all accessible documents with filters
3. Upload a document from deal documents page
4. Upload the same filename — version dialog appears
5. Choose "new version" — version increments
6. Detail panel shows preview for PDF/images
7. Version history shows in detail panel
8. Restore a version — creates a new version
9. Delete a document — removes all versions
10. Task panel shows documents tab with upload
11. Deal documents page shows grouped documents

- [ ] **Step 4: Run database reset and seed to verify clean state**

```bash
npx prisma migrate reset --force
npx prisma db seed
```

Verify the app loads without errors.

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "feat(dms): complete DMS v1 integration and cleanup"
```

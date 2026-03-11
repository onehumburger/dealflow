# Document Management System (DMS) v1 — Design Spec

## Goal

Build an integrated document management system for DealFlow that replaces the need for external tools like iManage. Documents are organized by deal → workstream → task, with a centralized Document Hub for cross-deal search and access.

## Architecture

DMS v1 extends the existing DealFlow application. Documents are stored on the local filesystem and metadata is managed in PostgreSQL via Prisma. The system provides three access points: a global Document Hub page, a documents tab on deal detail pages, and a documents tab on task detail pages. Version history is tracked per document using a separate DocumentVersion table.

## Tech Stack

- Next.js 16 App Router (Server Actions for mutations)
- Prisma 7 + PostgreSQL (data model)
- Local filesystem storage (`storage/uploads/`)
- next-intl (bilingual i18n: zh/en)
- shadcn/ui components (consistent with existing UI)

---

## 1. Data Model

### Migration from Existing Document Model

The existing `Document` model has fields: `id`, `name`, `filePath`, `createdAt`, `dealId`, `workstreamId`, `taskId`, `uploadedById`. This migration:

1. Rename `filePath` → `storagePath`
2. Add new columns: `fileType` (String), `fileSize` (Int, default 0), `currentVersion` (Int, default 1), `updatedAt` (DateTime)
3. Create new `DocumentVersion` table
4. Backfill `fileType` by extracting extension from existing `name` field
5. Backfill `fileSize` by reading file sizes from disk (or set 0 if file missing)
6. Existing files remain at their current flat paths (`storage/uploads/{uuid}.{ext}`). The `storagePath` field stores the relative path as-is. Only new uploads use the nested path convention. The download route serves files based on whatever `storagePath` contains.

### Document

| Field | Type | Notes |
|---|---|---|
| id | String (cuid) | Primary key |
| name | String | Original filename (e.g. "股权转让协议.docx") |
| fileType | String | MIME type or extension |
| fileSize | Int | Bytes |
| storagePath | String | Relative path on local filesystem |
| currentVersion | Int | Default 1, incremented on new version upload (intentional denormalization for query performance) |
| dealId | String | Required — every document belongs to a deal |
| workstreamId | String? | Optional — inherited from task if uploaded via task |
| taskId | String? | Optional — null for deal-level documents |
| uploadedById | String | User who uploaded the current version |
| createdAt | DateTime | |
| updatedAt | DateTime | |

### DocumentVersion

| Field | Type | Notes |
|---|---|---|
| id | String (cuid) | Primary key |
| documentId | String | FK → Document |
| versionNumber | Int | 1, 2, 3... |
| name | String | Filename at time of this version |
| fileType | String | MIME type or extension for this version |
| fileSize | Int | Bytes |
| storagePath | String | Path to this version's file |
| uploadedById | String | User who uploaded this version |
| note | String? | Optional change note |
| createdAt | DateTime | |

### Version Control Flow

1. User uploads a file to a task or deal.
2. If a document with the same name exists on that task/deal, prompt: "Upload as new version or as a separate document?"
3. If new version: current file's metadata (name, fileType, fileSize, storagePath, uploadedById) is copied to a new DocumentVersion row with the current versionNumber. Document row is then updated with the new file's info and currentVersion is incremented.
4. If separate document: a new Document row is created.

### Restore Version Flow

Restoring an old version (e.g. restoring v1 when current is v3):
1. Current version (v3) is saved to DocumentVersion as usual.
2. Document row is updated with the restored version's file info (name, fileType, fileSize, storagePath from the v1 DocumentVersion row).
3. `currentVersion` is incremented to v4 (restore creates a new version, not a rollback).
4. Activity log records "Restored from v1".

This means the version history is always append-only. "Restore" = "create a new version with the same content as an old one."

### Storage Path Convention

```
storage/uploads/{dealId}/{documentId}/v{version}.{ext}
```

Original filename is preserved in the database `name` field. Files on disk use version-based naming to avoid conflicts. Legacy files uploaded before DMS v1 remain at their flat paths — the download route reads `storagePath` directly regardless of format.

## 2. Navigation

New sidebar nav entry "文档管理" (en: "Documents") added to the main header navigation.

**Order:** 工作台 | 项目 | 我的任务 | 日历 | 计时管理 | **文档管理** | 通讯录 | (用户管理)

**Route:** `/{locale}/documents`

## 3. Document Hub Page (文档管理)

The central page for browsing and searching all documents across all deals.

### Layout: Sidebar Filter + Card List

**Left sidebar — filters:**
- Deal (dropdown, all deals the user has access to)
- Workstream (dropdown, populated based on selected deal)
- File type (Word, PDF, Excel, PPT, Image, Other)
- Date range (uploaded date)
- Uploader (team member)

**Right — document card list:**
- Each card shows: file type icon, filename, context path (Deal → Workstream → Task), uploader, date, version badge
- Sort options: date (default), name, size, version count
- Metadata search bar at top: searches filename, deal name, task name, uploader name

### Document Detail — Slide-in Panel

Clicking a document card opens a slide-in panel from the right. The card list remains visible but dimmed.

**Panel contents:**
- Document name and file type icon
- Preview area:
  - PDF: inline preview via browser native PDF viewer (iframe)
  - Images (PNG, JPG, GIF): inline display
  - Word/Excel/PPT: file type icon + metadata (no inline preview)
- Action buttons: 下载 (download), 上传新版本 (upload new version)
- Metadata: deal → workstream → task path, uploader, upload date, file size
- Version history list:
  - Each version: version number, uploader, date, optional note
  - Download any version
  - Restore any version to current
- Close button (✕) to dismiss panel

## 4. Task Panel Integration

### Tab View

The existing task detail is a slide-in `Sheet` panel (`src/components/tasks/task-panel.tsx`). This panel is refactored to use tabs:

**详情 | 文档 | 活动**

The 详情 tab contains the current panel content (description, assignee, dates, etc.). The 文档 tab shows:
- Documents bound to this task
- Upload button + drag-and-drop zone
- Compact card list
- Click card → nested slide-in panel or modal for document detail (since we're already in a panel)
- Same-name detection on upload: prompt "upload as new version (vN) or separate document?"

The 活动 tab contains the existing activity feed (moved from inline to its own tab).

When a document is uploaded via a task panel:
- `dealId` is resolved via `task.workstream.dealId` (Task has no direct dealId — it goes through Workstream). Alternatively, the dealId is already available from the page URL params (`/deals/[dealId]/...`).
- `workstreamId` is set from `task.workstreamId`
- `taskId` is set to the current task

## 5. Deal Page Integration

### Documents Tab

Deal detail page gets a "文档" tab showing all documents across all workstreams and tasks for that deal.

**Grouping:**
- Grouped by workstream (e.g. "Phase 1 尽职调查")
- Within each workstream, grouped by task
- "通用文档" section at the top for deal-level documents (taskId = null)

**Upload:**
- Upload button at deal level creates a deal-level document (no task binding)
- User can also upload directly to a specific task from here

## 6. Upload Flow

### Standard Upload
1. User clicks "上传" or drags file into drop zone
2. File is validated (50MB max, allowed file types)
3. System checks if a document with the same filename exists in the current context (same task or same deal-level)
4. If duplicate found → prompt dialog: "文件 [name] 已存在。上传为新版本 (v{N}) 还是作为独立文档?"
5. File is saved to `storage/uploads/{dealId}/{documentId}/v{version}.{ext}`
6. Database records created/updated
7. Activity log entry created

### Allowed File Types
- Documents: .doc, .docx, .pdf, .txt, .rtf
- Spreadsheets: .xls, .xlsx, .csv
- Presentations: .ppt, .pptx
- Images: .png, .jpg, .jpeg, .gif
- Archives: .zip, .rar

### Upload Limit
- 50MB per file

## 7. Preview & Download

| File Type | Preview | Download |
|---|---|---|
| PDF | Inline (iframe, browser native) | Yes |
| Images (PNG, JPG, GIF) | Inline display | Yes |
| Word (.doc, .docx) | Metadata only | Yes |
| Excel (.xls, .xlsx) | Metadata only | Yes |
| PPT (.ppt, .pptx) | Metadata only | Yes |
| Other | Metadata only | Yes |

Download served via API route: `GET /api/documents/[id]/download?version={n}`
- Default: current version (reads `Document.storagePath`)
- Optional `version` param: looks up the `DocumentVersion` record for that version number and serves the file from its `storagePath`
- Content-Type header derived from file extension in `storagePath`

The existing download route (`src/app/api/documents/[id]/download/route.ts`) must be rewritten to support the version parameter and the renamed `storagePath` field.

## 8. Activity Logging

Document actions are logged to the existing activity feed. New `ActivityType` enum values needed:

| Activity | ActivityType enum value | Description text |
|---|---|---|
| Document uploaded | `DocumentUpload` (existing) | "{user} uploaded {filename}" |
| New version uploaded | `DocumentVersionUpload` (new) | "{user} uploaded {filename} v{N}" |
| Version restored | `DocumentRestore` (new) | "{user} restored {filename} to v{N} (from v{M})" |
| Document deleted | `DocumentDelete` (new) | "{user} deleted {filename}" |

Note: Document download is NOT logged to activity (too noisy, not meaningful to other team members).

## 9. Document Deletion

Deleting a document:
1. All `DocumentVersion` rows for this document are deleted from the database
2. The `Document` row is deleted
3. All version files on disk are deleted (`storage/uploads/{dealId}/{documentId}/` directory removed)
4. Activity log entry created with `DocumentDelete` type
5. Only the uploader or an Admin can delete a document

## 10. Pagination

Document Hub paginates at 50 documents per page. Deal-page and task-panel document lists are not paginated (unlikely to exceed 50 per task/deal in practice).

## 11. i18n

All UI text bilingual (zh default, en). New message keys added under `"documents"` namespace in `messages/zh.json` and `messages/en.json`.

Key terms:
| zh | en |
|---|---|
| 文档管理 | Documents |
| 上传 | Upload |
| 下载 | Download |
| 预览 | Preview |
| 版本历史 | Version History |
| 上传新版本 | Upload New Version |
| 通用文档 | General Documents |
| 当前版本 | Current Version |
| 恢复此版本 | Restore This Version |

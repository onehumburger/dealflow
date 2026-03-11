# Bulk Document Download (ZIP) Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Download all documents (all versions) for a deal, workstream, or task as a structured ZIP file.

**Architecture:** Single GET API route streams a ZIP using `archiver`. Three UI touchpoints call this endpoint via `window.open()`. Shared utility function constructs the download URL.

**Tech Stack:** archiver (npm), Next.js API route, existing shadcn/ui components

---

## File Structure

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `src/app/api/documents/bulk-download/route.ts` | GET endpoint — query docs, stream ZIP |
| Create | `src/lib/download-zip.ts` | Client utility `downloadDocumentsZip(params)` |
| Modify | `src/app/[locale]/deals/[dealId]/documents/deal-documents-content.tsx` | Add "Download All" button |
| Modify | `src/components/workstreams/workstream-section.tsx` | Add "Download Documents" menu item |
| Modify | `src/components/documents/task-documents-tab.tsx` | Add download ZIP button |
| Modify | `messages/zh.json` | Add i18n keys |
| Modify | `messages/en.json` | Add i18n keys |

---

### Task 1: Install archiver + add i18n keys

- [ ] `npm install archiver @types/archiver`
- [ ] Add to `messages/zh.json` under `document`: `"downloadAll": "下载全部"`, `"downloadDocs": "下载文档"`
- [ ] Add to `messages/en.json` under `document`: `"downloadAll": "Download All"`, `"downloadDocs": "Download Documents"`
- [ ] Commit

### Task 2: API route — `GET /api/documents/bulk-download`

**Create:** `src/app/api/documents/bulk-download/route.ts`

- [ ] Auth check + deal membership verification (same pattern as existing download route)
- [ ] Accept query params: `dealId` (required), `workstreamId` (optional), `taskId` (optional)
- [ ] Query documents with scope filter, include all DocumentVersions + workstream/task names
- [ ] Build ZIP with `archiver`: folder structure `{DealName}/{WorkstreamName}/{TaskTitle}/{DocName}/v{N}.{ext}`
- [ ] Use `_通用` folder for docs without workstream or without task
- [ ] Sanitize folder/file names (remove `/\` and other unsafe chars)
- [ ] Stream response with `Content-Disposition: attachment; filename="{name}.zip"`
- [ ] Commit

### Task 3: Client utility + UI buttons

**Create:** `src/lib/download-zip.ts`

- [ ] Export `downloadDocumentsZip({ dealId, workstreamId?, taskId? })` — constructs URL, calls `window.open()`

**Modify:** `deal-documents-content.tsx`

- [ ] Add "Download All" button at top when documents exist, passing `dealId`

**Modify:** `workstream-section.tsx`

- [ ] Add "Download Documents" item in ⋯ dropdown menu, passing `dealId` + `workstreamId`

**Modify:** `task-documents-tab.tsx`

- [ ] Add download ZIP button next to upload button, passing `dealId` + `workstreamId` + `taskId`

- [ ] Commit

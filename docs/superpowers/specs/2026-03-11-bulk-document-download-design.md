# Bulk Document Download (ZIP) Design

## Overview

Add the ability to download all documents for a deal, workstream, or task as a single ZIP file. The ZIP preserves the hierarchical folder structure and includes all document versions (not just the latest).

## API Endpoint

**`GET /api/documents/bulk-download`**

### Query Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `dealId` | Yes | Deal ID — used for permission check and scoping |
| `workstreamId` | No | Narrow scope to a single workstream |
| `taskId` | No | Narrow scope to a single task |

### Logic

1. Authenticate via `auth()`, verify deal membership
2. Query `Document` records filtered by scope, include all `DocumentVersion` records
3. Stream ZIP response using `archiver`
4. Set `Content-Disposition: attachment; filename="{deal name}.zip"`

### ZIP Folder Structure

```
{Deal Name}/
├── {Workstream Name}/
│   ├── {Task Title}/
│   │   └── {Document Name}/
│   │       ├── v1.docx
│   │       └── v2.docx
│   └── _通用/                ← workstream-level docs (no task)
│       └── {Document Name}/
│           └── v1.pdf
└── _通用/                    ← deal-level docs (no workstream)
    └── {Document Name}/
        └── v1.xlsx
```

When downloading at workstream scope, the top-level folder is the workstream name.
When downloading at task scope, the top-level folder is the task title.

Folder and file names are sanitized (remove `/`, `\`, and other filesystem-unsafe characters).

## UI Trigger Points

| Location | Component | Form |
|----------|-----------|------|
| Deal documents page | `deal-documents-content.tsx` | Button at top of page next to upload |
| Workstream | `workstream-section.tsx` | New item in `⋯` dropdown menu |
| Task panel | `task-documents-tab.tsx` | Download button next to upload button |

All three locations call a shared utility function `downloadDocumentsZip(params)` that constructs the URL and opens it via `window.open()`.

## Dependencies

- **`archiver`** — streaming ZIP generation (npm package). Chosen over `jszip` for streaming support with large files.

## i18n Keys

Add to `document` namespace in `messages/{zh,en}.json`:
- `downloadAll`: "下载全部" / "Download All"
- `downloadWorkstreamDocs`: "下载文档" / "Download Documents"
- `preparingDownload`: "正在准备下载..." / "Preparing download..."

## Security

- Reuse existing `assertDealMember()` pattern from `_helpers.ts`
- Validate all file paths start with `UPLOAD_DIR` before reading (same as single download route)
- No new permissions model needed — deal membership is sufficient

"use client";

import { useEffect, useRef, useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Upload, Download, FileText, Loader2, Trash2 } from "lucide-react";
import {
  uploadDocument,
  checkDuplicateName,
  deleteDocument,
  getTaskDocuments,
} from "@/actions/documents";
import { UploadVersionDialog } from "./upload-version-dialog";
import { formatFileSize } from "@/lib/format";

interface Props {
  taskId: string;
  dealId: string;
  workstreamId: string;
}

type TaskDocument = Awaited<ReturnType<typeof getTaskDocuments>>[number];

export function TaskDocumentsTab({ taskId, dealId, workstreamId }: Props) {
  const t = useTranslations("document");
  const tCommon = useTranslations("common");
  const [documents, setDocuments] = useState<TaskDocument[]>([]);
  const [loading, setLoading] = useState(true);
  const [isPending, startTransition] = useTransition();

  const fileInputRef = useRef<HTMLInputElement>(null);

  // Dialog state for version detection
  const [duplicateInfo, setDuplicateInfo] = useState<{
    id: string;
    version: number;
  } | null>(null);
  const [pendingFile, setPendingFile] = useState<File | null>(null);

  // Fetch documents for this task via a server action
  useEffect(() => {
    loadDocuments();
  }, [taskId]);

  async function loadDocuments() {
    setLoading(true);
    try {
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

  function handleDialogClose() {
    setDuplicateInfo(null);
    setPendingFile(null);
    if (fileInputRef.current) fileInputRef.current.value = "";
    // Refresh document list after dialog closes (version may have been uploaded)
    loadDocuments();
  }

  function handleDelete(docId: string) {
    if (!confirm(t("deleteConfirm"))) return;
    startTransition(async () => {
      await deleteDocument(docId);
      await loadDocuments();
    });
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center py-8">
        <Loader2 className="size-5 animate-spin text-muted-foreground" />
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-3 pt-3">
      {/* Upload button */}
      <div>
        <input
          ref={fileInputRef}
          type="file"
          className="hidden"
          onChange={handleFileSelect}
        />
        <Button
          variant="outline"
          size="sm"
          onClick={() => fileInputRef.current?.click()}
          disabled={isPending}
        >
          {isPending ? (
            <Loader2 className="mr-1.5 size-3.5 animate-spin" />
          ) : (
            <Upload className="mr-1.5 size-3.5" />
          )}
          {isPending ? tCommon("loading") : t("upload")}
        </Button>
      </div>

      {/* Document list */}
      {documents.length === 0 ? (
        <p className="py-6 text-center text-sm text-muted-foreground">
          {t("noDocuments")}
        </p>
      ) : (
        <div className="space-y-1">
          {documents.map((doc) => (
            <div
              key={doc.id}
              className="flex items-center gap-3 rounded-lg border p-3"
            >
              <FileText className="size-4 shrink-0 text-muted-foreground" />
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <span className="truncate text-sm font-medium">
                    {doc.name}
                  </span>
                  {doc.currentVersion > 1 && (
                    <Badge variant="secondary">v{doc.currentVersion}</Badge>
                  )}
                </div>
                <p className="text-xs text-muted-foreground">
                  {doc.uploadedBy.name} &middot;{" "}
                  {new Date(doc.updatedAt).toLocaleDateString()} &middot;{" "}
                  {formatFileSize(doc.fileSize)}
                </p>
              </div>
              <div className="flex items-center gap-1 shrink-0">
                <a href={`/api/documents/${doc.id}/download`}>
                  <Button variant="ghost" size="icon-sm">
                    <Download className="size-3.5" />
                  </Button>
                </a>
                <Button
                  variant="ghost"
                  size="icon-sm"
                  onClick={() => handleDelete(doc.id)}
                  disabled={isPending}
                >
                  <Trash2 className="size-3.5 text-destructive" />
                </Button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Version dialog */}
      {duplicateInfo && pendingFile && (
        <UploadVersionDialog
          open={true}
          onClose={handleDialogClose}
          file={pendingFile}
          existingDocId={duplicateInfo.id}
          existingVersion={duplicateInfo.version}
          dealId={dealId}
          workstreamId={workstreamId}
          taskId={taskId}
        />
      )}
    </div>
  );
}

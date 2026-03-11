"use client";

import { File as FileIcon } from "lucide-react";

interface DocumentPreviewProps {
  documentId: string;
  fileName: string;
  fileType: string;
}

export function DocumentPreview({
  documentId,
  fileName,
  fileType,
}: DocumentPreviewProps) {
  const previewUrl = `/api/documents/${documentId}/download?preview=true`;

  if (fileType === "application/pdf") {
    return (
      <iframe
        src={previewUrl}
        title={fileName}
        className="w-full h-64 rounded-md border"
      />
    );
  }

  if (fileType.startsWith("image/")) {
    return (
      <img
        src={previewUrl}
        alt={fileName}
        className="w-full max-h-64 object-contain rounded-md border"
      />
    );
  }

  return (
    <div className="flex h-32 items-center justify-center rounded-md border bg-muted">
      <FileIcon className="size-10 text-muted-foreground" />
    </div>
  );
}

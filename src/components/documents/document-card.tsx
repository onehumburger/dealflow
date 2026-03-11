"use client";

import { useTranslations } from "next-intl";
import {
  FileText,
  FileSpreadsheet,
  Presentation,
  Image,
  File,
} from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { formatFileSize } from "@/lib/format";
import type { DocumentItem } from "@/components/documents/document-hub";

interface DocumentCardProps {
  document: DocumentItem;
  onClick: () => void;
}

function getFileIcon(fileType: string) {
  const ext = fileType.toLowerCase();
  if (["doc", "docx", "pdf", "txt"].includes(ext)) return FileText;
  if (["xls", "xlsx"].includes(ext)) return FileSpreadsheet;
  if (["ppt", "pptx"].includes(ext)) return Presentation;
  if (["jpg", "jpeg", "png", "gif", "bmp", "svg", "webp"].includes(ext))
    return Image;
  return File;
}

export function DocumentCard({ document: doc, onClick }: DocumentCardProps) {
  const t = useTranslations("document");

  const Icon = getFileIcon(doc.fileType);

  const contextPath = doc.task
    ? `${doc.deal.name} → ${doc.workstream?.name ?? ""} → ${doc.task.title}`
    : doc.workstream
      ? `${doc.deal.name} → ${doc.workstream.name}`
      : `${doc.deal.name} → ${t("generalDocuments")}`;

  const dateStr = new Date(doc.updatedAt).toLocaleDateString();

  return (
    <div
      className="flex items-center gap-3 rounded-lg border p-3 cursor-pointer transition-colors hover:bg-accent"
      onClick={onClick}
    >
      <Icon className="size-5 shrink-0 text-muted-foreground" />
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <span className="truncate text-sm font-medium">{doc.name}</span>
          {doc.currentVersion > 1 && (
            <Badge variant="secondary">v{doc.currentVersion}</Badge>
          )}
        </div>
        <p className="truncate text-xs text-muted-foreground">{contextPath}</p>
      </div>
      <div className="shrink-0 text-right">
        <p className="text-xs text-muted-foreground">{doc.uploadedBy.name}</p>
        <p className="text-xs text-muted-foreground">
          {dateStr} &middot; {formatFileSize(doc.fileSize)}
        </p>
      </div>
    </div>
  );
}

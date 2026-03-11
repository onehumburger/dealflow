"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetDescription,
} from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { useDocumentPanel } from "@/hooks/use-document-panel";
import { getVersionHistory } from "@/actions/documents";
import { formatFileSize } from "@/lib/format";
import { DocumentPreview } from "./document-preview";
import { VersionHistory } from "./version-history";
import { Download, Upload, Loader2 } from "lucide-react";
import type { DocumentItem } from "./document-hub";

type VersionEntry = Awaited<ReturnType<typeof getVersionHistory>>[number];

interface DocumentDetailPanelProps {
  documents: DocumentItem[];
}

export function DocumentDetailPanel({ documents }: DocumentDetailPanelProps) {
  const t = useTranslations("document");

  const documentId = useDocumentPanel((s) => s.documentId);
  const close = useDocumentPanel((s) => s.close);
  const isOpen = documentId !== null;

  const [versions, setVersions] = useState<VersionEntry[]>([]);
  const [versionsLoading, setVersionsLoading] = useState(false);

  const document = documentId
    ? documents.find((d) => d.id === documentId) ?? null
    : null;

  /* eslint-disable react-hooks/set-state-in-effect -- data-fetching effect with cleanup */
  useEffect(() => {
    if (!documentId) return;

    let cancelled = false;
    setVersionsLoading(true);
    setVersions([]);

    getVersionHistory(documentId)
      .then((data) => {
        if (!cancelled) setVersions(data);
      })
      .catch(() => {
        if (!cancelled) setVersions([]);
      })
      .finally(() => {
        if (!cancelled) setVersionsLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [documentId]);
  /* eslint-enable react-hooks/set-state-in-effect */

  return (
    <Sheet open={isOpen} onOpenChange={(open) => !open && close()}>
      <SheetContent
        side="right"
        className="data-[side=right]:sm:max-w-xl w-full overflow-y-auto"
      >
        {!document ? (
          isOpen ? (
            <div className="flex h-full items-center justify-center">
              <Loader2 className="size-6 animate-spin text-muted-foreground" />
            </div>
          ) : null
        ) : (
          <div className="flex flex-col gap-5 px-4 pb-4">
            <SheetHeader className="px-0">
              <SheetTitle>{document.name}</SheetTitle>
              <SheetDescription className="sr-only">
                {t("documents")}
              </SheetDescription>
            </SheetHeader>

            {/* Preview */}
            <DocumentPreview
              documentId={document.id}
              fileName={document.name}
              fileType={document.fileType}
            />

            {/* Action buttons */}
            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                render={
                  <a
                    href={`/api/documents/${document.id}/download`}
                    download
                  />
                }
              >
                <Download className="size-3.5" />
                {t("download")}
              </Button>
              <Button variant="outline" size="sm" disabled>
                <Upload className="size-3.5" />
                {t("uploadNewVersion")}
              </Button>
            </div>

            {/* Metadata */}
            <div className="space-y-1.5 text-sm">
              <div className="text-muted-foreground">
                {document.deal.name}
                {document.workstream && (
                  <> &rsaquo; {document.workstream.name}</>
                )}
                {document.task && <> &rsaquo; {document.task.title}</>}
              </div>
              <div className="text-muted-foreground">
                {t("uploadedBy")}: {document.uploadedBy.name}
              </div>
              <div className="text-muted-foreground">
                {t("date")}:{" "}
                {new Date(document.updatedAt).toLocaleDateString()}
              </div>
              <div className="text-muted-foreground">
                {formatFileSize(document.fileSize)}
              </div>
            </div>

            {/* Version history */}
            <VersionHistory
              documentId={document.id}
              currentVersion={document.currentVersion}
              versions={versions}
              loading={versionsLoading}
            />
          </div>
        )}
      </SheetContent>
    </Sheet>
  );
}

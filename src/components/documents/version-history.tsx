"use client";

import { useTranslations } from "next-intl";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Download, Loader2 } from "lucide-react";

interface VersionEntry {
  id: string;
  versionNumber: number;
  name: string;
  uploadedBy: { name: string };
  createdAt: string | Date;
  note: string | null;
}

interface VersionHistoryProps {
  documentId: string;
  currentVersion: number;
  versions: VersionEntry[];
  loading: boolean;
}

export function VersionHistory({
  documentId,
  currentVersion,
  versions,
  loading,
}: VersionHistoryProps) {
  const t = useTranslations("document");

  return (
    <div>
      <h3 className="mb-2 text-sm font-medium">{t("versionHistory")}</h3>

      {/* Current version */}
      <div className="flex items-center gap-2 rounded-md border p-2 mb-2 bg-muted/50">
        <Badge variant="default">v{currentVersion}</Badge>
        <span className="text-xs text-muted-foreground">
          {t("currentVersion")}
        </span>
      </div>

      {/* Loading state */}
      {loading && (
        <div className="flex items-center justify-center py-4">
          <Loader2 className="size-4 animate-spin text-muted-foreground" />
        </div>
      )}

      {/* Previous versions */}
      {!loading && versions.length === 0 && (
        <p className="text-xs text-muted-foreground py-2">
          {/* No previous versions */}
        </p>
      )}

      {!loading && (
        <div className="space-y-2">
          {versions.map((v) => (
            <div
              key={v.id}
              className="flex items-start justify-between gap-2 rounded-md border p-2"
            >
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-0.5">
                  <Badge variant="outline">v{v.versionNumber}</Badge>
                  <span className="text-xs text-muted-foreground truncate">
                    {v.uploadedBy.name}
                  </span>
                </div>
                <div className="text-xs text-muted-foreground">
                  {new Date(v.createdAt).toLocaleDateString()}
                </div>
                {v.note && (
                  <div className="text-xs text-muted-foreground mt-0.5 italic">
                    {v.note}
                  </div>
                )}
              </div>
              <Button
                variant="ghost"
                size="icon-sm"
                nativeButton={false}
                render={
                  <a
                    href={`/api/documents/${documentId}/download?version=${v.versionNumber}`}
                    download
                  />
                }
              >
                <Download className="size-3.5" />
              </Button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

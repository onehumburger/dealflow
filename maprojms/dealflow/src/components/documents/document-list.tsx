"use client";

import { useTransition } from "react";
import { useTranslations } from "next-intl";
import { Download, Trash2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { deleteDocument } from "@/actions/documents";

export interface DocumentItem {
  id: string;
  name: string;
  workstream: { name: string } | null;
  uploadedBy: { name: string };
  createdAt: Date;
}

interface DocumentListProps {
  documents: DocumentItem[];
}

export function DocumentList({ documents }: DocumentListProps) {
  const t = useTranslations("document");
  const tCommon = useTranslations("common");
  const [isPending, startTransition] = useTransition();

  function handleDelete(docId: string) {
    if (!confirm(t("deleteConfirm"))) return;
    startTransition(async () => {
      await deleteDocument(docId);
    });
  }

  if (documents.length === 0) {
    return (
      <p className="py-8 text-center text-sm text-muted-foreground">
        {t("noDocuments")}
      </p>
    );
  }

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>{t("fileName")}</TableHead>
          <TableHead>{t("workstream")}</TableHead>
          <TableHead>{t("uploadedBy")}</TableHead>
          <TableHead>{t("date")}</TableHead>
          <TableHead />
        </TableRow>
      </TableHeader>
      <TableBody>
        {documents.map((doc) => (
          <TableRow key={doc.id}>
            <TableCell className="font-medium">{doc.name}</TableCell>
            <TableCell className="text-muted-foreground">
              {doc.workstream?.name ?? "\u2014"}
            </TableCell>
            <TableCell className="text-muted-foreground">
              {doc.uploadedBy.name}
            </TableCell>
            <TableCell className="text-muted-foreground">
              {new Date(doc.createdAt).toLocaleDateString()}
            </TableCell>
            <TableCell>
              <div className="flex items-center gap-1">
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
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}

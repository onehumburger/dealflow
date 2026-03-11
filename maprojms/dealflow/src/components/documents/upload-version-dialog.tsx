"use client";

import { useTransition } from "react";
import { useTranslations } from "next-intl";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { uploadDocument, uploadNewVersion } from "@/actions/documents";

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
  open,
  onClose,
  file,
  existingDocId,
  existingVersion,
  dealId,
  workstreamId,
  taskId,
}: Props) {
  const t = useTranslations("document");
  const [isNewVersionPending, startNewVersion] = useTransition();
  const [isSeparatePending, startSeparate] = useTransition();

  function handleUploadNewVersion() {
    const formData = new FormData();
    formData.set("documentId", existingDocId);
    formData.set("file", file);
    startNewVersion(async () => {
      await uploadNewVersion(formData);
      onClose();
    });
  }

  function handleUploadSeparate() {
    const formData = new FormData();
    formData.set("dealId", dealId);
    formData.set("file", file);
    if (workstreamId) formData.set("workstreamId", workstreamId);
    if (taskId) formData.set("taskId", taskId);
    startSeparate(async () => {
      await uploadDocument(formData);
      onClose();
    });
  }

  const isPending = isNewVersionPending || isSeparatePending;

  return (
    <Dialog open={open} onOpenChange={(isOpen) => { if (!isOpen) onClose(); }}>
      <DialogContent showCloseButton={!isPending}>
        <DialogHeader>
          <DialogTitle>{t("fileExists", { name: file.name })}</DialogTitle>
        </DialogHeader>
        <div className="flex flex-col gap-2 pt-2">
          <Button
            onClick={handleUploadNewVersion}
            disabled={isPending}
            variant="default"
          >
            {t("uploadAsNewVersion", { version: existingVersion + 1 })}
          </Button>
          <Button
            onClick={handleUploadSeparate}
            disabled={isPending}
            variant="outline"
          >
            {t("uploadAsSeparate")}
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}

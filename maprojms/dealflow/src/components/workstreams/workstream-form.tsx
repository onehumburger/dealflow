"use client";

import { useTransition, useRef, useState } from "react";
import { useTranslations } from "next-intl";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogClose,
} from "@/components/ui/dialog";
import { createWorkstream, updateWorkstream } from "@/actions/workstreams";

interface WorkstreamFormProps {
  dealId: string;
  /** If provided, this is an edit/rename operation */
  workstream?: { id: string; name: string };
  trigger: React.ReactNode;
}

export function WorkstreamForm({ dealId, workstream, trigger }: WorkstreamFormProps) {
  const t = useTranslations("workstream");
  const tCommon = useTranslations("common");
  const [isPending, startTransition] = useTransition();
  const formRef = useRef<HTMLFormElement>(null);

  const isEdit = !!workstream;

  function handleSubmit(formData: FormData) {
    startTransition(async () => {
      if (isEdit && workstream) {
        const name = formData.get("name") as string;
        await updateWorkstream(workstream.id, { name });
      } else {
        formData.set("dealId", dealId);
        await createWorkstream(formData);
      }
      formRef.current?.reset();
    });
  }

  return (
    <Dialog>
      <DialogTrigger nativeButton={false} render={<span />}>
        {trigger}
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>
            {isEdit ? t("renameWorkstream") : t("addWorkstream")}
          </DialogTitle>
        </DialogHeader>
        <form ref={formRef} action={handleSubmit} className="flex flex-col gap-4">
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="ws-name">{t("name")}</Label>
            <Input
              id="ws-name"
              name="name"
              defaultValue={workstream?.name ?? ""}
              placeholder={t("namePlaceholder")}
              required
              autoFocus
            />
          </div>
          <div className="flex justify-end gap-2">
            <DialogClose
              render={
                <Button variant="outline" size="sm" type="button" disabled={isPending} />
              }
            >
              {tCommon("cancel")}
            </DialogClose>
            <Button type="submit" size="sm" disabled={isPending}>
              {isEdit ? tCommon("save") : tCommon("create")}
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}

/**
 * State-driven variant for use inside DropdownMenu items.
 * The parent controls open state, avoiding nested trigger issues.
 */
interface WorkstreamRenameDialogProps {
  dealId: string;
  workstream: { id: string; name: string };
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function WorkstreamRenameDialog({
  dealId,
  workstream,
  open,
  onOpenChange,
}: WorkstreamRenameDialogProps) {
  const t = useTranslations("workstream");
  const tCommon = useTranslations("common");
  const [isPending, startTransition] = useTransition();
  const formRef = useRef<HTMLFormElement>(null);

  function handleSubmit(formData: FormData) {
    startTransition(async () => {
      const name = formData.get("name") as string;
      await updateWorkstream(workstream.id, { name });
      formRef.current?.reset();
      onOpenChange(false);
    });
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{t("renameWorkstream")}</DialogTitle>
        </DialogHeader>
        <form ref={formRef} action={handleSubmit} className="flex flex-col gap-4">
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="ws-rename">{t("name")}</Label>
            <Input
              id="ws-rename"
              name="name"
              defaultValue={workstream.name}
              placeholder={t("namePlaceholder")}
              required
              autoFocus
            />
          </div>
          <div className="flex justify-end gap-2">
            <Button
              variant="outline"
              size="sm"
              type="button"
              disabled={isPending}
              onClick={() => onOpenChange(false)}
            >
              {tCommon("cancel")}
            </Button>
            <Button type="submit" size="sm" disabled={isPending}>
              {tCommon("save")}
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}

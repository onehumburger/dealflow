"use client";

import { useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
} from "@/components/ui/dialog";
import { createContact, updateContact } from "@/actions/contacts";
import type { ContactRole } from "@/generated/prisma/client";

interface ContactData {
  id: string;
  name: string;
  organization: string | null;
  role: ContactRole;
  title: string | null;
  email: string | null;
  phone: string | null;
  timezone: string | null;
  notes: string | null;
}

interface ContactFormProps {
  contact?: ContactData;
  trigger: React.ReactNode;
  /** Called after successful create/update, e.g., to link to a deal */
  onSuccess?: (contactId: string) => void;
}

const ROLES: ContactRole[] = [
  "Client",
  "CounterpartyCounsel",
  "ExternalCounsel",
  "FA",
  "Accountant",
  "Regulator",
  "Other",
];

export function ContactForm({ contact, trigger, onSuccess }: ContactFormProps) {
  const t = useTranslations("contact");
  const tCommon = useTranslations("common");
  const [isPending, startTransition] = useTransition();
  const [open, setOpen] = useState(false);

  const isEdit = !!contact;

  const roleLabel = (r: ContactRole): string => {
    const map: Record<ContactRole, string> = {
      Client: t("roleClient"),
      CounterpartyCounsel: t("roleCounterpartyCounsel"),
      ExternalCounsel: t("roleExternalCounsel"),
      FA: t("roleFA"),
      Accountant: t("roleAccountant"),
      Regulator: t("roleRegulator"),
      Other: t("roleOther"),
    };
    return map[r];
  };

  function handleSubmit(formData: FormData) {
    startTransition(async () => {
      if (isEdit && contact) {
        await updateContact(contact.id, {
          name: formData.get("name") as string,
          organization: (formData.get("organization") as string) || null,
          role: formData.get("role") as ContactRole,
          title: (formData.get("title") as string) || null,
          email: (formData.get("email") as string) || null,
          phone: (formData.get("phone") as string) || null,
          timezone: (formData.get("timezone") as string) || null,
          notes: (formData.get("notes") as string) || null,
        });
        onSuccess?.(contact.id);
      } else {
        const result = await createContact(formData);
        onSuccess?.(result.id);
      }
      setOpen(false);
    });
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger nativeButton={false} render={<span />}>{trigger}</DialogTrigger>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>
            {isEdit ? tCommon("edit") : t("addContact")}
          </DialogTitle>
        </DialogHeader>

        <form action={handleSubmit} className="flex flex-col gap-4">
          {/* Name */}
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="ct-name">{t("name")}</Label>
            <Input
              id="ct-name"
              name="name"
              required
              defaultValue={contact?.name ?? ""}
            />
          </div>

          {/* Organization + Role side-by-side */}
          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="ct-org">{t("organization")}</Label>
              <Input
                id="ct-org"
                name="organization"
                defaultValue={contact?.organization ?? ""}
              />
            </div>
            <div className="flex flex-col gap-1.5">
              <Label>{t("role")}</Label>
              <Select
                name="role"
                defaultValue={contact?.role ?? "Other"}
              >
                <SelectTrigger className="w-full">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {ROLES.map((r) => (
                    <SelectItem key={r} value={r}>
                      {roleLabel(r)}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>

          {/* Title */}
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="ct-title">{t("jobTitle")}</Label>
            <Input
              id="ct-title"
              name="title"
              defaultValue={contact?.title ?? ""}
            />
          </div>

          {/* Email + Phone side-by-side */}
          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="ct-email">{t("email")}</Label>
              <Input
                id="ct-email"
                name="email"
                type="email"
                defaultValue={contact?.email ?? ""}
              />
            </div>
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="ct-phone">{t("phone")}</Label>
              <Input
                id="ct-phone"
                name="phone"
                defaultValue={contact?.phone ?? ""}
              />
            </div>
          </div>

          {/* Timezone */}
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="ct-tz">{t("timezone")}</Label>
            <Input
              id="ct-tz"
              name="timezone"
              placeholder="e.g. Asia/Shanghai"
              defaultValue={contact?.timezone ?? ""}
            />
          </div>

          {/* Notes */}
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="ct-notes">{t("notes")}</Label>
            <Textarea
              id="ct-notes"
              name="notes"
              rows={2}
              defaultValue={contact?.notes ?? ""}
            />
          </div>

          <DialogFooter>
            <Button type="submit" disabled={isPending}>
              {isPending
                ? tCommon("loading")
                : isEdit
                  ? tCommon("save")
                  : tCommon("create")}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}

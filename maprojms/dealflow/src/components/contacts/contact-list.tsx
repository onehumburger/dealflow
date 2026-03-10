"use client";

import { useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Trash2, Unlink } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { ContactForm } from "./contact-form";
import { deleteContact, unlinkContactFromDeal } from "@/actions/contacts";
import type { ContactRole } from "@/generated/prisma/client";

export interface ContactItem {
  id: string;
  name: string;
  organization: string | null;
  role: ContactRole;
  title: string | null;
  email: string | null;
  phone: string | null;
  timezone: string | null;
  notes: string | null;
  roleInDeal?: string | null;
}

interface ContactListProps {
  contacts: ContactItem[];
  /** If provided, renders in deal context with unlink instead of delete */
  dealId?: string;
  /** Whether to show global delete (only in global contacts page) */
  showDelete?: boolean;
}

export function ContactList({
  contacts,
  dealId,
  showDelete = false,
}: ContactListProps) {
  const t = useTranslations("contact");
  const tCommon = useTranslations("common");
  const [isPending, startTransition] = useTransition();

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

  function handleDelete(contactId: string) {
    if (!confirm(t("deleteConfirm"))) return;
    startTransition(async () => {
      await deleteContact(contactId);
    });
  }

  function handleUnlink(contactId: string) {
    if (!dealId) return;
    startTransition(async () => {
      await unlinkContactFromDeal(contactId, dealId);
    });
  }

  if (contacts.length === 0) {
    return (
      <p className="py-8 text-center text-sm text-muted-foreground">
        {tCommon("noResults")}
      </p>
    );
  }

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>{t("name")}</TableHead>
          <TableHead>{t("organization")}</TableHead>
          <TableHead>{t("role")}</TableHead>
          {dealId && <TableHead>{t("roleInDeal")}</TableHead>}
          <TableHead>{t("email")}</TableHead>
          <TableHead>{t("phone")}</TableHead>
          <TableHead />
        </TableRow>
      </TableHeader>
      <TableBody>
        {contacts.map((c) => (
          <TableRow key={c.id}>
            <TableCell className="font-medium">{c.name}</TableCell>
            <TableCell>{c.organization ?? "\u2014"}</TableCell>
            <TableCell>
              <Badge variant="outline">{roleLabel(c.role)}</Badge>
            </TableCell>
            {dealId && (
              <TableCell className="text-muted-foreground">
                {c.roleInDeal ?? "\u2014"}
              </TableCell>
            )}
            <TableCell>
              {c.email ? (
                <a
                  href={`mailto:${c.email}`}
                  className="text-primary underline-offset-2 hover:underline"
                >
                  {c.email}
                </a>
              ) : (
                "\u2014"
              )}
            </TableCell>
            <TableCell>{c.phone ?? "\u2014"}</TableCell>
            <TableCell>
              <div className="flex items-center gap-1">
                <ContactForm
                  contact={c}
                  trigger={
                    <button className="rounded px-1.5 py-0.5 text-xs text-muted-foreground hover:bg-muted">
                      {tCommon("edit")}
                    </button>
                  }
                />
                {dealId ? (
                  <Button
                    variant="ghost"
                    size="icon-sm"
                    onClick={() => handleUnlink(c.id)}
                    disabled={isPending}
                    title={t("unlinkFromDeal")}
                  >
                    <Unlink className="size-3.5" />
                  </Button>
                ) : showDelete ? (
                  <Button
                    variant="ghost"
                    size="icon-sm"
                    onClick={() => handleDelete(c.id)}
                    disabled={isPending}
                  >
                    <Trash2 className="size-3.5 text-destructive" />
                  </Button>
                ) : null}
              </div>
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}

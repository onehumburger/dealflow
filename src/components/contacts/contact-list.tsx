"use client";

import { useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { ChevronDown, ChevronRight, Trash2, Unlink } from "lucide-react";
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
  dealLinks?: { dealId: string; dealName: string; roleInDeal: string | null }[];
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
    <>
      {/* Mobile card view */}
      <div className="flex flex-col gap-2 md:hidden">
        {contacts.map((c) => (
          <div
            key={c.id}
            className="rounded-lg border bg-card p-3"
          >
            <div className="flex items-center gap-1.5">
              <span className="font-medium">{c.name}</span>
              {c.organization && (
                <span className="text-sm text-muted-foreground">
                  &middot; {c.organization}
                </span>
              )}
              {c.dealLinks && c.dealLinks.length > 1 && (
                <Badge variant="outline" className="text-xs px-1 py-0">
                  {t("linkedToDeals", { count: c.dealLinks.length })}
                </Badge>
              )}
            </div>

            <div className="mt-1">
              <Badge variant="outline">{roleLabel(c.role)}</Badge>
              {dealId && c.roleInDeal && (
                <span className="ml-2 text-sm text-muted-foreground">
                  {c.roleInDeal}
                </span>
              )}
            </div>

            {c.email && (
              <div className="mt-1.5 text-sm text-muted-foreground">
                <a
                  href={`mailto:${c.email}`}
                  className="text-primary underline-offset-2 hover:underline"
                >
                  {c.email}
                </a>
              </div>
            )}
            {c.phone && (
              <div className="text-sm text-muted-foreground">{c.phone}</div>
            )}

            <div className="mt-2 flex items-center gap-1">
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
          </div>
        ))}
      </div>

      {/* Desktop table view */}
      <div className="hidden md:block">
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
                <TableCell className="font-medium">
                  <span className="flex items-center gap-1.5">
                    {c.name}
                    {c.dealLinks && c.dealLinks.length > 1 && (
                      <Badge variant="outline" className="text-xs px-1 py-0">
                        {t("linkedToDeals", { count: c.dealLinks.length })}
                      </Badge>
                    )}
                  </span>
                </TableCell>
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
      </div>
    </>
  );
}

// --- Grouped view for global contacts page ---

interface DealGroup {
  dealName: string;
  contacts: (ContactItem & {
    dealLinks: { dealId: string; dealName: string; roleInDeal: string | null }[];
  })[];
}

interface GroupedContactListProps {
  groups: [string, DealGroup][];
  unlinked: (ContactItem & {
    dealLinks: { dealId: string; dealName: string; roleInDeal: string | null }[];
  })[];
}

export function GroupedContactList({ groups, unlinked }: GroupedContactListProps) {
  const t = useTranslations("contact");
  const tCommon = useTranslations("common");
  const [collapsed, setCollapsed] = useState<Record<string, boolean>>({});

  function toggleCollapse(key: string) {
    setCollapsed((prev) => ({ ...prev, [key]: !prev[key] }));
  }

  if (groups.length === 0 && unlinked.length === 0) {
    return (
      <p className="py-8 text-center text-sm text-muted-foreground">
        {tCommon("noResults")}
      </p>
    );
  }

  return (
    <div className="flex flex-col gap-6">
      {groups.map(([dealId, group]) => (
        <div key={dealId} className="rounded-lg border bg-card">
          <button
            type="button"
            className="flex w-full items-center justify-between px-4 py-3 text-left hover:bg-muted/50"
            onClick={() => toggleCollapse(dealId)}
          >
            <div className="flex items-center gap-2">
              {collapsed[dealId] ? (
                <ChevronRight className="size-4 text-muted-foreground" />
              ) : (
                <ChevronDown className="size-4 text-muted-foreground" />
              )}
              <span className="text-sm font-semibold">{group.dealName}</span>
            </div>
            <span className="text-xs text-muted-foreground">
              {group.contacts.length}
            </span>
          </button>
          {!collapsed[dealId] && (
            <div className="border-t">
              <ContactList contacts={group.contacts} showDelete />
            </div>
          )}
        </div>
      ))}

      {unlinked.length > 0 && (
        <div className="rounded-lg border bg-card">
          <button
            type="button"
            className="flex w-full items-center justify-between px-4 py-3 text-left hover:bg-muted/50"
            onClick={() => toggleCollapse("__unlinked")}
          >
            <div className="flex items-center gap-2">
              {collapsed["__unlinked"] ? (
                <ChevronRight className="size-4 text-muted-foreground" />
              ) : (
                <ChevronDown className="size-4 text-muted-foreground" />
              )}
              <span className="text-sm font-semibold text-muted-foreground">
                {t("unlinkedContacts")}
              </span>
            </div>
            <span className="text-xs text-muted-foreground">
              {unlinked.length}
            </span>
          </button>
          {!collapsed["__unlinked"] && (
            <div className="border-t">
              <ContactList contacts={unlinked} showDelete />
            </div>
          )}
        </div>
      )}
    </div>
  );
}

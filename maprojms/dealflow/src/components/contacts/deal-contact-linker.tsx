"use client";

import { useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Plus } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
} from "@/components/ui/dialog";
import { ContactForm } from "./contact-form";
import { linkContactToDeal } from "@/actions/contacts";
import type { ContactRole } from "@/generated/prisma/client";

interface AvailableContact {
  id: string;
  name: string;
  organization: string | null;
  role: ContactRole;
}

interface DealContactLinkerProps {
  dealId: string;
  availableContacts: AvailableContact[];
}

export function DealContactLinker({
  dealId,
  availableContacts,
}: DealContactLinkerProps) {
  const t = useTranslations("contact");
  const tCommon = useTranslations("common");
  const [isPending, startTransition] = useTransition();
  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState("");
  const [roleInDeal, setRoleInDeal] = useState("");

  const filtered = availableContacts.filter(
    (c) =>
      c.name.toLowerCase().includes(search.toLowerCase()) ||
      (c.organization &&
        c.organization.toLowerCase().includes(search.toLowerCase()))
  );

  function handleLink(contactId: string) {
    startTransition(async () => {
      await linkContactToDeal(contactId, dealId, roleInDeal || undefined);
      setOpen(false);
      setSearch("");
      setRoleInDeal("");
    });
  }

  function handleNewContactCreated(contactId: string) {
    // After creating a new contact, link it to the deal
    startTransition(async () => {
      await linkContactToDeal(contactId, dealId, roleInDeal || undefined);
      setOpen(false);
      setSearch("");
      setRoleInDeal("");
    });
  }

  return (
    <div className="flex items-center gap-2">
      <ContactForm
        trigger={
          <button className="rounded-md border border-dashed px-3 py-1.5 text-sm text-muted-foreground hover:bg-muted/50">
            + {t("addContact")}
          </button>
        }
        onSuccess={handleNewContactCreated}
      />

      <Dialog open={open} onOpenChange={setOpen}>
        <DialogTrigger render={<span />}>
          <button className="rounded-md bg-primary px-3 py-1.5 text-sm font-medium text-primary-foreground hover:bg-primary/90">
            + {t("linkExisting")}
          </button>
        </DialogTrigger>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>{t("linkExisting")}</DialogTitle>
          </DialogHeader>

          <div className="flex flex-col gap-3">
            <Input
              placeholder={tCommon("search")}
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />

            <div className="flex flex-col gap-1.5">
              <Label>{t("roleInDeal")}</Label>
              <Input
                placeholder={t("roleInDealPlaceholder")}
                value={roleInDeal}
                onChange={(e) => setRoleInDeal(e.target.value)}
              />
            </div>

            <div className="max-h-[300px] divide-y overflow-y-auto rounded-md border">
              {filtered.length === 0 && (
                <p className="p-3 text-center text-sm text-muted-foreground">
                  {tCommon("noResults")}
                </p>
              )}
              {filtered.map((c) => (
                <button
                  key={c.id}
                  className="flex w-full items-center gap-2 px-3 py-2 text-left text-sm hover:bg-muted/50"
                  onClick={() => handleLink(c.id)}
                  disabled={isPending}
                >
                  <Plus className="size-3.5 shrink-0" />
                  <div>
                    <span className="font-medium">{c.name}</span>
                    {c.organization && (
                      <span className="ml-1.5 text-muted-foreground">
                        ({c.organization})
                      </span>
                    )}
                  </div>
                </button>
              ))}
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}

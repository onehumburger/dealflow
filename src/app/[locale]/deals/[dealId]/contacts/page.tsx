import { auth } from "@/lib/auth";
import { redirect, notFound } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { getLocale, getTranslations } from "next-intl/server";
import Link from "next/link";
import { ChevronLeft } from "lucide-react";
import { ContactList } from "@/components/contacts/contact-list";
import { DealContactLinker } from "@/components/contacts/deal-contact-linker";

export default async function DealContactsPage({
  params,
}: {
  params: Promise<{ dealId: string; locale: string }>;
}) {
  const { dealId } = await params;
  const session = await auth();
  const locale = await getLocale();

  if (!session) {
    redirect(`/${locale}/login`);
  }

  const deal = await prisma.deal.findUnique({
    where: { id: dealId },
    select: {
      id: true,
      name: true,
      members: { select: { userId: true } },
      dealContacts: {
        include: {
          contact: true,
        },
      },
    },
  });

  if (!deal) {
    notFound();
  }

  const isMember = deal.members.some((m: { userId: string }) => m.userId === session.user?.id);
  if (!isMember) notFound();

  const t = await getTranslations("contact");

  const contactsData = deal.dealContacts.map((dc) => ({
    ...dc.contact,
    roleInDeal: dc.roleInDeal,
  }));

  // Get all contacts not yet linked to this deal, for the linker
  const linkedIds = deal.dealContacts.map((dc) => dc.contactId);
  const availableContacts = await prisma.contact.findMany({
    where: linkedIds.length > 0 ? { id: { notIn: linkedIds } } : {},
    orderBy: { name: "asc" },
    select: { id: true, name: true, organization: true, role: true },
  });

  return (
    <div className="mx-auto max-w-5xl px-4 py-6 sm:px-6">
      <div className="mb-4 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Link
            href={`/${locale}/deals/${dealId}`}
            className="text-muted-foreground hover:text-foreground"
          >
            <ChevronLeft className="size-4" />
          </Link>
          <h1 className="text-lg font-semibold">
            {deal.name} &mdash; {t("contacts")}
          </h1>
        </div>
        <DealContactLinker
          dealId={dealId}
          availableContacts={availableContacts}
        />
      </div>

      <ContactList contacts={contactsData} dealId={dealId} />
    </div>
  );
}

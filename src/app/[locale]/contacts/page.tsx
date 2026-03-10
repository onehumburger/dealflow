import { auth } from "@/lib/auth";
import { redirect } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { getLocale, getTranslations } from "next-intl/server";
import { GroupedContactList } from "@/components/contacts/contact-list";
import { ContactForm } from "@/components/contacts/contact-form";

export default async function GlobalContactsPage() {
  const session = await auth();
  const locale = await getLocale();

  if (!session?.user?.id) {
    redirect(`/${locale}/login`);
  }

  const t = await getTranslations("contact");

  // Get user's deals
  const memberships = await prisma.dealMember.findMany({
    where: { userId: session.user.id },
    select: { dealId: true, deal: { select: { id: true, name: true } } },
  });
  const dealIds = memberships.map((m) => m.dealId);

  // Get all contacts with their deal links
  const contacts = await prisma.contact.findMany({
    orderBy: { name: "asc" },
    include: {
      dealContacts: {
        where: { dealId: { in: dealIds } },
        select: {
          dealId: true,
          roleInDeal: true,
          deal: { select: { id: true, name: true } },
        },
      },
    },
  });

  // Build contact data with deal links
  const contactsData = contacts.map((c) => ({
    id: c.id,
    name: c.name,
    organization: c.organization,
    role: c.role,
    title: c.title,
    email: c.email,
    phone: c.phone,
    timezone: c.timezone,
    notes: c.notes,
    dealLinks: c.dealContacts.map((dc) => ({
      dealId: dc.deal.id,
      dealName: dc.deal.name,
      roleInDeal: dc.roleInDeal,
    })),
  }));

  // Group by deal
  const dealGroups: Record<
    string,
    { dealName: string; contacts: typeof contactsData }
  > = {};

  for (const c of contactsData) {
    for (const link of c.dealLinks) {
      if (!dealGroups[link.dealId]) {
        dealGroups[link.dealId] = { dealName: link.dealName, contacts: [] };
      }
      dealGroups[link.dealId].contacts.push(c);
    }
  }

  // Unlinked contacts
  const unlinked = contactsData.filter((c) => c.dealLinks.length === 0);

  // Sort deal groups by deal name
  const sortedGroups = Object.entries(dealGroups).sort((a, b) =>
    a[1].dealName.localeCompare(b[1].dealName)
  );

  return (
    <div className="mx-auto max-w-5xl px-4 py-6 sm:px-6">
      <div className="mb-4 flex items-center justify-between">
        <h1 className="text-lg font-semibold">{t("contacts")}</h1>
        <ContactForm
          trigger={
            <button className="rounded-md bg-primary px-3 py-1.5 text-sm font-medium text-primary-foreground hover:bg-primary/90">
              + {t("addContact")}
            </button>
          }
        />
      </div>

      <GroupedContactList groups={sortedGroups} unlinked={unlinked} />
    </div>
  );
}

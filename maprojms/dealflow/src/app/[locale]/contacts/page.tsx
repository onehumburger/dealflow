import { auth } from "@/lib/auth";
import { redirect } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { getLocale, getTranslations } from "next-intl/server";
import { ContactList } from "@/components/contacts/contact-list";
import { ContactForm } from "@/components/contacts/contact-form";

export default async function GlobalContactsPage() {
  const session = await auth();
  const locale = await getLocale();

  if (!session) {
    redirect(`/${locale}/login`);
  }

  const contacts = await prisma.contact.findMany({
    orderBy: { name: "asc" },
  });

  const t = await getTranslations("contact");

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
  }));

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

      <ContactList contacts={contactsData} showDelete />
    </div>
  );
}

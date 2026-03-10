"use server";

import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { assertDealMember, revalidateDeal } from "@/actions/_helpers";
import type { ContactRole } from "@/generated/prisma/client";
import { revalidatePath } from "next/cache";
import { getLocale } from "next-intl/server";

// ---------- createContact ----------

export async function createContact(formData: FormData) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const name = formData.get("name") as string;
  const organization = (formData.get("organization") as string) || null;
  const role = (formData.get("role") as string) || "Other";
  const title = (formData.get("title") as string) || null;
  const email = (formData.get("email") as string) || null;
  const phone = (formData.get("phone") as string) || null;
  const timezone = (formData.get("timezone") as string) || null;
  const notes = (formData.get("notes") as string) || null;

  if (!name) throw new Error("Name is required");

  const contact = await prisma.contact.create({
    data: {
      name,
      organization,
      role: role as ContactRole,
      title,
      email,
      phone,
      timezone,
      notes,
    },
  });

  return contact;
}

// ---------- updateContact ----------

export async function updateContact(
  contactId: string,
  data: {
    name?: string;
    organization?: string | null;
    role?: ContactRole;
    title?: string | null;
    email?: string | null;
    phone?: string | null;
    timezone?: string | null;
    notes?: string | null;
  }
) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const contact = await prisma.contact.findUnique({
    where: { id: contactId },
  });
  if (!contact) throw new Error("Contact not found");

  await prisma.contact.update({
    where: { id: contactId },
    data,
  });

  const locale = await getLocale();
  revalidatePath(`/${locale}/contacts`);
}

// ---------- deleteContact ----------

export async function deleteContact(contactId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const contact = await prisma.contact.findUnique({
    where: { id: contactId },
  });
  if (!contact) throw new Error("Contact not found");

  await prisma.contact.delete({ where: { id: contactId } });

  const locale = await getLocale();
  revalidatePath(`/${locale}/contacts`);
}

// ---------- linkContactToDeal ----------

export async function linkContactToDeal(
  contactId: string,
  dealId: string,
  roleInDeal?: string
) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  await assertDealMember(dealId, session.user.id);

  await prisma.dealContact.create({
    data: {
      contactId,
      dealId,
      roleInDeal: roleInDeal || null,
    },
  });

  await revalidateDeal(dealId, `/deals/${dealId}/contacts`);
}

// ---------- unlinkContactFromDeal ----------

export async function unlinkContactFromDeal(
  contactId: string,
  dealId: string
) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  await assertDealMember(dealId, session.user.id);

  await prisma.dealContact.delete({
    where: { dealId_contactId: { dealId, contactId } },
  });

  await revalidateDeal(dealId, `/deals/${dealId}/contacts`);
}

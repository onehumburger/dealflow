"use server";

import { prisma } from "@/lib/prisma";
import { revalidatePath } from "next/cache";
import { getLocale } from "next-intl/server";

export async function assertDealMember(dealId: string, userId: string) {
  const member = await prisma.dealMember.findUnique({
    where: { dealId_userId: { dealId, userId } },
  });
  if (!member) throw new Error("Forbidden");
}

export async function revalidateDeal(dealId: string, extraPath?: string) {
  const locale = await getLocale();
  revalidatePath(`/${locale}/deals/${dealId}`);
  revalidatePath(`/${locale}/deals`);
  if (extraPath) {
    revalidatePath(`/${locale}${extraPath}`);
  }
}

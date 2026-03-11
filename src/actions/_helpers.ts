"use server";

import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { revalidatePath } from "next/cache";
import { getLocale } from "next-intl/server";

/** Assert current user is Admin. Returns userId. */
export async function assertAdmin(): Promise<string> {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");
  const role = (session.user as unknown as { role: string }).role;
  if (role !== "Admin") throw new Error("Forbidden");
  return session.user.id;
}


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

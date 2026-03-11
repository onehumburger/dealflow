"use server";

import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { assertDealMember, revalidateDeal } from "@/actions/_helpers";
import type { ActivityType } from "@/generated/prisma/client";

// Allowed manual activity types
const MANUAL_ACTIVITY_TYPES: ActivityType[] = [
  "Note",
  "Call",
  "Meeting",
  "ClientInstruction",
];

// ---------- createActivityEntry ----------

export async function createActivityEntry(formData: FormData) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const dealId = formData.get("dealId") as string;
  const type = formData.get("type") as ActivityType;
  const content = formData.get("content") as string;
  const workstreamId = (formData.get("workstreamId") as string) || null;

  if (!dealId || !type || !content?.trim()) {
    throw new Error("Missing required fields");
  }

  if (!MANUAL_ACTIVITY_TYPES.includes(type)) {
    throw new Error("Invalid activity type");
  }

  await assertDealMember(dealId, session.user.id);

  // Validate workstream belongs to deal if provided
  if (workstreamId) {
    const ws = await prisma.workstream.findUnique({
      where: { id: workstreamId },
      select: { dealId: true },
    });
    if (!ws || ws.dealId !== dealId) {
      throw new Error("Workstream not found");
    }
  }

  const entry = await prisma.activityEntry.create({
    data: {
      type,
      content: content.trim(),
      dealId,
      workstreamId,
      authorId: session.user.id,
    },
  });

  await revalidateDeal(dealId);
  return entry;
}

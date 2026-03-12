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

// ---------- updateActivityEntry ----------

export async function updateActivityEntry(
  entryId: string,
  data: { content?: string; type?: ActivityType }
) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const entry = await prisma.activityEntry.findUnique({
    where: { id: entryId },
    select: { authorId: true, dealId: true, type: true },
  });
  if (!entry) throw new Error("Entry not found");

  await assertDealMember(entry.dealId, session.user.id);

  // Only author or admin can edit
  const user = await prisma.user.findUnique({
    where: { id: session.user.id },
    select: { role: true },
  });
  if (entry.authorId !== session.user.id && user?.role !== "Admin") {
    throw new Error("Permission denied");
  }

  // Only allow editing manual activity types
  if (!MANUAL_ACTIVITY_TYPES.includes(entry.type)) {
    throw new Error("Cannot edit system-generated entries");
  }

  if (data.type && !MANUAL_ACTIVITY_TYPES.includes(data.type)) {
    throw new Error("Invalid activity type");
  }

  await prisma.activityEntry.update({
    where: { id: entryId },
    data: {
      ...(data.content !== undefined && { content: data.content.trim() }),
      ...(data.type !== undefined && { type: data.type }),
    },
  });

  await revalidateDeal(entry.dealId);
}

// ---------- deleteActivityEntry ----------

export async function deleteActivityEntry(entryId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const entry = await prisma.activityEntry.findUnique({
    where: { id: entryId },
    select: { authorId: true, dealId: true, type: true },
  });
  if (!entry) throw new Error("Entry not found");

  await assertDealMember(entry.dealId, session.user.id);

  // Only author or admin can delete
  const user = await prisma.user.findUnique({
    where: { id: session.user.id },
    select: { role: true },
  });
  if (entry.authorId !== session.user.id && user?.role !== "Admin") {
    throw new Error("Permission denied");
  }

  if (!MANUAL_ACTIVITY_TYPES.includes(entry.type)) {
    throw new Error("Cannot delete system-generated entries");
  }

  await prisma.activityEntry.delete({ where: { id: entryId } });
  await revalidateDeal(entry.dealId);
}

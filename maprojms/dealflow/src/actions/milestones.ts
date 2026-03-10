"use server";

import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { assertDealMember, revalidateDeal } from "@/actions/_helpers";
import type { MilestoneType } from "@/generated/prisma/client";

// ---------- createMilestone ----------

export async function createMilestone(formData: FormData) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const dealId = formData.get("dealId") as string;
  const name = formData.get("name") as string;
  const dateRaw = formData.get("date") as string;
  const type = (formData.get("type") as string) || "Custom";

  if (!dealId || !name) throw new Error("Missing required fields");

  await assertDealMember(dealId, session.user.id);

  // Auto-increment sortOrder
  const existing = await prisma.milestone.findMany({
    where: { dealId },
    orderBy: { sortOrder: "desc" },
    take: 1,
    select: { sortOrder: true },
  });
  const nextSortOrder = existing.length > 0 ? existing[0].sortOrder + 1 : 0;

  const milestone = await prisma.milestone.create({
    data: {
      name,
      date: dateRaw ? new Date(dateRaw) : null,
      type: type as MilestoneType,
      sortOrder: nextSortOrder,
      dealId,
    },
  });

  await prisma.activityEntry.create({
    data: {
      type: "MilestoneChange",
      content: `Milestone created: ${name}`,
      dealId,
      authorId: session.user.id,
    },
  });

  await revalidateDeal(dealId);
  return milestone;
}

// ---------- updateMilestone ----------

export async function updateMilestone(
  milestoneId: string,
  data: {
    name?: string;
    date?: Date | null;
    type?: MilestoneType;
    isDone?: boolean;
  }
) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const milestone = await prisma.milestone.findUnique({
    where: { id: milestoneId },
    select: { name: true, dealId: true },
  });
  if (!milestone) throw new Error("Milestone not found");

  await assertDealMember(milestone.dealId, session.user.id);

  await prisma.milestone.update({
    where: { id: milestoneId },
    data,
  });

  // Activity entry for meaningful changes
  const changes: string[] = [];
  if (data.name && data.name !== milestone.name) changes.push(`renamed to "${data.name}"`);
  if (data.isDone !== undefined) changes.push(data.isDone ? "marked as done" : "marked as undone");
  if (data.date !== undefined) changes.push("date updated");

  if (changes.length > 0) {
    await prisma.activityEntry.create({
      data: {
        type: "MilestoneChange",
        content: `Milestone "${data.name || milestone.name}": ${changes.join(", ")}`,
        dealId: milestone.dealId,
        authorId: session.user.id,
      },
    });
  }

  await revalidateDeal(milestone.dealId);
}

// ---------- deleteMilestone ----------

export async function deleteMilestone(milestoneId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const milestone = await prisma.milestone.findUnique({
    where: { id: milestoneId },
    select: { name: true, dealId: true },
  });
  if (!milestone) throw new Error("Milestone not found");

  await assertDealMember(milestone.dealId, session.user.id);

  await prisma.milestone.delete({ where: { id: milestoneId } });

  await prisma.activityEntry.create({
    data: {
      type: "MilestoneChange",
      content: `Milestone "${milestone.name}" deleted`,
      dealId: milestone.dealId,
      authorId: session.user.id,
    },
  });

  await revalidateDeal(milestone.dealId);
}

// ---------- toggleMilestoneDone ----------

export async function toggleMilestoneDone(milestoneId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const milestone = await prisma.milestone.findUnique({
    where: { id: milestoneId },
    select: { name: true, isDone: true, dealId: true },
  });
  if (!milestone) throw new Error("Milestone not found");

  await assertDealMember(milestone.dealId, session.user.id);

  const newIsDone = !milestone.isDone;

  await prisma.milestone.update({
    where: { id: milestoneId },
    data: { isDone: newIsDone },
  });

  await prisma.activityEntry.create({
    data: {
      type: "MilestoneChange",
      content: `Milestone "${milestone.name}" marked as ${newIsDone ? "done" : "undone"}`,
      dealId: milestone.dealId,
      authorId: session.user.id,
    },
  });

  await revalidateDeal(milestone.dealId);
}

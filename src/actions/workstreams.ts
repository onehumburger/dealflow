"use server";

import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { assertDealMember, revalidateDeal } from "@/actions/_helpers";

// ---------- createWorkstream ----------

export async function createWorkstream(formData: FormData) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const dealId = formData.get("dealId") as string;
  const name = formData.get("name") as string;

  if (!dealId || !name?.trim()) throw new Error("Missing required fields");

  await assertDealMember(dealId, session.user.id);

  // Auto-increment sortOrder
  const existing = await prisma.workstream.findMany({
    where: { dealId },
    orderBy: { sortOrder: "desc" },
    take: 1,
    select: { sortOrder: true },
  });
  const nextSortOrder = existing.length > 0 ? existing[0].sortOrder + 1 : 0;

  const workstream = await prisma.workstream.create({
    data: {
      name: name.trim(),
      sortOrder: nextSortOrder,
      dealId,
    },
  });

  await prisma.activityEntry.create({
    data: {
      type: "TaskUpdate",
      content: `Workstream "${name.trim()}" created`,
      dealId,
      authorId: session.user.id,
    },
  });

  await revalidateDeal(dealId, "/tasks");
  return workstream;
}

// ---------- updateWorkstream ----------

export async function updateWorkstream(
  workstreamId: string,
  data: { name?: string; description?: string }
) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const workstream = await prisma.workstream.findUnique({
    where: { id: workstreamId },
    select: { name: true, dealId: true },
  });
  if (!workstream) throw new Error("Workstream not found");

  await assertDealMember(workstream.dealId, session.user.id);

  await prisma.workstream.update({
    where: { id: workstreamId },
    data,
  });

  await prisma.activityEntry.create({
    data: {
      type: "TaskUpdate",
      content: `Workstream renamed: "${workstream.name}" → "${data.name ?? workstream.name}"`,
      dealId: workstream.dealId,
      workstreamId,
      authorId: session.user.id,
    },
  });

  await revalidateDeal(workstream.dealId, "/tasks");
}

// ---------- deleteWorkstream ----------

export async function deleteWorkstream(workstreamId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const workstream = await prisma.workstream.findUnique({
    where: { id: workstreamId },
    select: { name: true, dealId: true },
  });
  if (!workstream) throw new Error("Workstream not found");

  await assertDealMember(workstream.dealId, session.user.id);

  await prisma.workstream.delete({ where: { id: workstreamId } });

  await prisma.activityEntry.create({
    data: {
      type: "TaskUpdate",
      content: `Workstream "${workstream.name}" deleted`,
      dealId: workstream.dealId,
      authorId: session.user.id,
    },
  });

  await revalidateDeal(workstream.dealId, "/tasks");
}

// ---------- reorderWorkstreams ----------

export async function reorderWorkstreams(dealId: string, orderedIds: string[]) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  await assertDealMember(dealId, session.user.id);

  // Validate all IDs belong to this deal before updating
  const count = await prisma.workstream.count({
    where: { id: { in: orderedIds }, dealId },
  });
  if (count !== orderedIds.length) throw new Error("Invalid workstream IDs");

  // Update each workstream's sortOrder in a transaction
  await prisma.$transaction(
    orderedIds.map((id, index) =>
      prisma.workstream.update({
        where: { id },
        data: { sortOrder: index },
      })
    )
  );

  await revalidateDeal(dealId, "/tasks");
}

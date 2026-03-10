"use server";

import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { getLocale } from "next-intl/server";
import type { DealType, DealRole, DealStatus, MilestoneType } from "@/generated/prisma/client";

interface TemplateDefinition {
  milestones: { name: string; type: string }[];
  workstreams: { name: string; tasks: string[] }[];
}

export async function createDeal(formData: FormData) {
  const session = await auth();
  if (!session?.user?.id) {
    throw new Error("Unauthorized");
  }

  const name = formData.get("name") as string;
  const codeName = (formData.get("codeName") as string) || null;
  const dealType = formData.get("dealType") as DealType;
  const ourRole = formData.get("ourRole") as DealRole;
  const clientName = formData.get("clientName") as string;
  const targetCompany = formData.get("targetCompany") as string;
  const jurisdictionsRaw = formData.get("jurisdictions") as string;
  const jurisdictions = jurisdictionsRaw
    ? jurisdictionsRaw.split(",").map((j) => j.trim()).filter(Boolean)
    : [];
  const dealLeadId = formData.get("dealLeadId") as string;
  const memberIdsRaw = formData.get("memberIds") as string;
  const memberIds = memberIdsRaw
    ? memberIdsRaw.split(",").filter(Boolean)
    : [];
  const summary = (formData.get("summary") as string) || null;
  const templateId = (formData.get("templateId") as string) || null;

  // Fetch template definition if provided
  let definition: TemplateDefinition | null = null;
  if (templateId) {
    const template = await prisma.template.findUnique({
      where: { id: templateId },
    });
    if (template) {
      definition = template.definition as unknown as TemplateDefinition;
    }
  }

  // Create deal with nested milestones, workstreams, and tasks
  const deal = await prisma.deal.create({
    data: {
      name,
      codeName,
      dealType,
      ourRole,
      clientName,
      targetCompany,
      jurisdictions,
      summary,
      dealLeadId,
      ...(definition
        ? {
            milestones: {
              create: definition.milestones.map((m, i) => ({
                name: m.name,
                type: m.type as MilestoneType,
                sortOrder: i,
              })),
            },
            workstreams: {
              create: definition.workstreams.map((ws, wsIndex) => ({
                name: ws.name,
                sortOrder: wsIndex,
                tasks: {
                  create: ws.tasks.map((taskTitle, taskIndex) => ({
                    title: taskTitle,
                    sortOrder: taskIndex,
                  })),
                },
              })),
            },
          }
        : {}),
    },
  });

  // Create DealMembers (deduplicated)
  const uniqueMemberIds = [...new Set([dealLeadId, ...memberIds])];
  await prisma.dealMember.createMany({
    data: uniqueMemberIds.map((userId) => ({
      dealId: deal.id,
      userId,
    })),
    skipDuplicates: true,
  });

  // Create initial activity entry
  await prisma.activityEntry.create({
    data: {
      type: "Note",
      content: "Deal created",
      dealId: deal.id,
      authorId: session.user.id,
    },
  });

  revalidatePath("/[locale]/deals");
  const locale = await getLocale();
  redirect(`/${locale}/deals/${deal.id}`);
}

export async function updateDeal(
  dealId: string,
  data: {
    name?: string;
    codeName?: string | null;
    clientName?: string;
    targetCompany?: string;
    jurisdictions?: string[];
    summary?: string | null;
    status?: DealStatus;
    dealLeadId?: string;
  }
) {
  const session = await auth();
  if (!session?.user?.id) {
    throw new Error("Unauthorized");
  }

  // Check if status is changing
  let oldStatus: DealStatus | null = null;
  if (data.status) {
    const existing = await prisma.deal.findUnique({
      where: { id: dealId },
      select: { status: true },
    });
    if (existing && existing.status !== data.status) {
      oldStatus = existing.status;
    }
  }

  await prisma.deal.update({
    where: { id: dealId },
    data,
  });

  // Log status change
  if (oldStatus && data.status) {
    await prisma.activityEntry.create({
      data: {
        type: "Note",
        content: `Deal status changed from ${oldStatus} to ${data.status}`,
        dealId,
        authorId: session.user.id,
      },
    });
  }

  revalidatePath(`/[locale]/deals/${dealId}`);
  revalidatePath("/[locale]/deals");
}

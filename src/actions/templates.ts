"use server";

import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { assertDealMember } from "@/actions/_helpers";
import { logAudit } from "@/lib/audit";

export async function saveDealAsTemplate(dealId: string, templateName: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  if (!templateName.trim()) throw new Error("Template name is required");

  await assertDealMember(dealId, session.user.id);

  const deal = await prisma.deal.findUnique({
    where: { id: dealId },
    include: {
      milestones: {
        orderBy: { sortOrder: "asc" },
        select: { name: true, type: true },
      },
      workstreams: {
        orderBy: { sortOrder: "asc" },
        select: {
          name: true,
          tasks: {
            orderBy: { sortOrder: "asc" },
            select: { title: true },
          },
        },
      },
    },
  });

  if (!deal) throw new Error("Deal not found");

  const definition = {
    milestones: deal.milestones.map((m) => ({
      name: m.name,
      type: m.type,
    })),
    workstreams: deal.workstreams.map((ws) => ({
      name: ws.name,
      tasks: ws.tasks.map((t) => t.title),
    })),
  };

  const template = await prisma.template.create({
    data: {
      name: templateName.trim(),
      dealType: deal.dealType,
      ourRole: deal.ourRole,
      isSystem: false,
      definition,
    },
  });

  await logAudit(
    session.user.id,
    "create_template",
    "Template",
    template.id,
    { fromDeal: { from: null, to: dealId } }
  );

  return template;
}

"use server";

import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { assertDealMember, revalidateDeal } from "@/actions/_helpers";
import { logAudit } from "@/lib/audit";
import type {
  DecisionSource,
  DecisionStatus,
} from "@/generated/prisma/client";

// ---------- createDecision ----------

export async function createDecision(formData: FormData) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const dealId = formData.get("dealId") as string;
  const title = formData.get("title") as string;
  const background = (formData.get("background") as string) || null;
  const source = (formData.get("source") as string) || "Other";
  const analysis = (formData.get("analysis") as string) || null;
  const clientDecision = (formData.get("clientDecision") as string) || null;
  const status = (formData.get("status") as string) || "PendingAnalysis";
  const workstreamId = (formData.get("workstreamId") as string) || null;

  if (!dealId || !title) throw new Error("Missing required fields");

  await assertDealMember(dealId, session.user.id);

  const decision = await prisma.decision.create({
    data: {
      title,
      background,
      source: source as DecisionSource,
      analysis,
      clientDecision,
      status: status as DecisionStatus,
      dealId,
      workstreamId: workstreamId || null,
    },
  });

  // Auto-create activity entry
  await prisma.activityEntry.create({
    data: {
      type: "DecisionCreated",
      content: `Decision created: ${title}`,
      dealId,
      authorId: session.user.id,
    },
  });

  await logAudit(session.user.id, "create_decision", "Decision", decision.id);

  await revalidateDeal(dealId, `/deals/${dealId}/decisions`);
  return decision;
}

// ---------- updateDecision ----------

export async function updateDecision(
  decisionId: string,
  data: {
    title?: string;
    background?: string | null;
    source?: DecisionSource;
    analysis?: string | null;
    clientDecision?: string | null;
    status?: DecisionStatus;
    workstreamId?: string | null;
  }
) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const decision = await prisma.decision.findUnique({
    where: { id: decisionId },
    select: { dealId: true },
  });
  if (!decision) throw new Error("Decision not found");

  await assertDealMember(decision.dealId, session.user.id);

  await prisma.decision.update({
    where: { id: decisionId },
    data,
  });

  await logAudit(session.user.id, "update_decision", "Decision", decisionId);

  await revalidateDeal(decision.dealId, `/deals/${decision.dealId}/decisions`);
}

// ---------- deleteDecision ----------

export async function deleteDecision(decisionId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const decision = await prisma.decision.findUnique({
    where: { id: decisionId },
    select: { title: true, dealId: true },
  });
  if (!decision) throw new Error("Decision not found");

  await assertDealMember(decision.dealId, session.user.id);

  await prisma.decision.delete({ where: { id: decisionId } });

  await prisma.activityEntry.create({
    data: {
      type: "Note",
      content: `Decision "${decision.title}" deleted`,
      dealId: decision.dealId,
      authorId: session.user.id,
    },
  });

  await revalidateDeal(decision.dealId, `/deals/${decision.dealId}/decisions`);
}

// ---------- addDecisionOption ----------

export async function addDecisionOption(
  decisionId: string,
  description: string,
  prosAndCons?: string
) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");
  if (!description.trim()) throw new Error("Description required");

  const decision = await prisma.decision.findUnique({
    where: { id: decisionId },
    select: {
      dealId: true,
      options: {
        orderBy: { sortOrder: "desc" },
        take: 1,
        select: { sortOrder: true },
      },
    },
  });
  if (!decision) throw new Error("Decision not found");

  await assertDealMember(decision.dealId, session.user.id);

  const nextSort =
    decision.options.length > 0 ? decision.options[0].sortOrder + 1 : 0;

  await prisma.decisionOption.create({
    data: {
      description: description.trim(),
      prosAndCons: prosAndCons?.trim() || null,
      sortOrder: nextSort,
      decisionId,
    },
  });

  await revalidateDeal(decision.dealId, `/deals/${decision.dealId}/decisions`);
}

// ---------- removeDecisionOption ----------

export async function removeDecisionOption(optionId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const option = await prisma.decisionOption.findUnique({
    where: { id: optionId },
    select: { decision: { select: { dealId: true } } },
  });
  if (!option) throw new Error("Option not found");

  await assertDealMember(option.decision.dealId, session.user.id);

  await prisma.decisionOption.delete({ where: { id: optionId } });
  await revalidateDeal(
    option.decision.dealId,
    `/deals/${option.decision.dealId}/decisions`
  );
}

// ---------- linkDecisionToTask ----------

export async function linkDecisionToTask(decisionId: string, taskId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const decision = await prisma.decision.findUnique({
    where: { id: decisionId },
    select: { dealId: true },
  });
  if (!decision) throw new Error("Decision not found");

  await assertDealMember(decision.dealId, session.user.id);

  await prisma.decisionTaskLink.create({
    data: { decisionId, taskId },
  });

  await revalidateDeal(decision.dealId, `/deals/${decision.dealId}/decisions`);
}

// ---------- unlinkDecisionFromTask ----------

export async function unlinkDecisionFromTask(
  decisionId: string,
  taskId: string
) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const decision = await prisma.decision.findUnique({
    where: { id: decisionId },
    select: { dealId: true },
  });
  if (!decision) throw new Error("Decision not found");

  await assertDealMember(decision.dealId, session.user.id);

  await prisma.decisionTaskLink.delete({
    where: { decisionId_taskId: { decisionId, taskId } },
  });

  await revalidateDeal(decision.dealId, `/deals/${decision.dealId}/decisions`);
}

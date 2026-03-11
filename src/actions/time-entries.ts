"use server";

import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { assertDealMember, revalidateDeal } from "@/actions/_helpers";
import { logAudit } from "@/lib/audit";

// ---------- helpers ----------

async function getTaskWithDeal(taskId: string) {
  const task = await prisma.task.findUnique({
    where: { id: taskId },
    select: {
      id: true,
      title: true,
      workstream: {
        select: {
          dealId: true,
          deal: { select: { name: true } },
        },
      },
    },
  });
  if (!task) throw new Error("Task not found");
  return task;
}

// ---------- startTimer ----------

export async function startTimer(taskId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const task = await getTaskWithDeal(taskId);
  const dealId = task.workstream.dealId;

  await assertDealMember(dealId, session.user.id);

  // Stop any running timer for this user
  const running = await prisma.timeEntry.findFirst({
    where: { userId: session.user.id, stoppedAt: null, isManual: false },
  });
  if (running) {
    const now = new Date();
    const durationMs = now.getTime() - (running.startedAt?.getTime() ?? now.getTime());
    await prisma.timeEntry.update({
      where: { id: running.id },
      data: {
        stoppedAt: now,
        durationMinutes: Math.max(1, Math.round(durationMs / 60000)),
      },
    });
  }

  const entry = await prisma.timeEntry.create({
    data: {
      startedAt: new Date(),
      durationMinutes: 0,
      isManual: false,
      taskId,
      userId: session.user.id,
      dealId,
    },
  });

  await revalidateDeal(dealId);

  return {
    entryId: entry.id,
    taskId: task.id,
    taskTitle: task.title,
    dealName: task.workstream.deal.name,
  };
}

// ---------- stopTimer ----------

export async function stopTimer(entryId: string, description?: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const entry = await prisma.timeEntry.findUnique({
    where: { id: entryId },
    select: { userId: true, startedAt: true, dealId: true },
  });
  if (!entry) throw new Error("Entry not found");
  if (entry.userId !== session.user.id) throw new Error("Forbidden");

  const now = new Date();
  const durationMs = now.getTime() - (entry.startedAt?.getTime() ?? now.getTime());

  await prisma.timeEntry.update({
    where: { id: entryId },
    data: {
      stoppedAt: now,
      durationMinutes: Math.max(1, Math.round(durationMs / 60000)),
      description: description?.trim() || null,
    },
  });

  await revalidateDeal(entry.dealId);
}

// ---------- logManualTime ----------

export async function logManualTime(
  taskId: string,
  data: { durationHours: number; date: string; description?: string }
) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const task = await getTaskWithDeal(taskId);
  const dealId = task.workstream.dealId;

  await assertDealMember(dealId, session.user.id);

  const durationMinutes = Math.round(data.durationHours * 60);
  if (durationMinutes <= 0) throw new Error("Duration must be positive");

  await prisma.timeEntry.create({
    data: {
      durationMinutes,
      isManual: true,
      startedAt: new Date(data.date),
      description: data.description?.trim() || null,
      taskId,
      userId: session.user.id,
      dealId,
    },
  });

  await revalidateDeal(dealId);
}

// ---------- updateTimeEntry ----------

export async function updateTimeEntry(
  entryId: string,
  data: {
    durationMinutes?: number;
    description?: string;
    isBillable?: boolean;
  }
) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const entry = await prisma.timeEntry.findUnique({
    where: { id: entryId },
    select: { userId: true, dealId: true, durationMinutes: true },
  });
  if (!entry) throw new Error("Entry not found");

  // Only owner or admin can edit
  const role = (session.user as unknown as { role: string }).role;
  if (entry.userId !== session.user.id && role !== "Admin") {
    throw new Error("Forbidden");
  }

  await prisma.timeEntry.update({
    where: { id: entryId },
    data: {
      ...(data.durationMinutes !== undefined && { durationMinutes: data.durationMinutes }),
      ...(data.description !== undefined && { description: data.description.trim() || null }),
      ...(data.isBillable !== undefined && { isBillable: data.isBillable }),
    },
  });

  await logAudit(session.user.id, "update_time_entry", "TimeEntry", entryId, {
    ...(data.durationMinutes !== undefined && {
      durationMinutes: { from: entry.durationMinutes, to: data.durationMinutes },
    }),
  });

  await revalidateDeal(entry.dealId);
}

// ---------- deleteTimeEntry ----------

export async function deleteTimeEntry(entryId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const entry = await prisma.timeEntry.findUnique({
    where: { id: entryId },
    select: { userId: true, dealId: true },
  });
  if (!entry) throw new Error("Entry not found");

  const role = (session.user as unknown as { role: string }).role;
  if (entry.userId !== session.user.id && role !== "Admin") {
    throw new Error("Forbidden");
  }

  await prisma.timeEntry.delete({ where: { id: entryId } });

  await logAudit(session.user.id, "delete_time_entry", "TimeEntry", entryId, {});

  await revalidateDeal(entry.dealId);
}

// ---------- getTaskTimeEntries ----------

export async function getTaskTimeEntries(taskId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const entries = await prisma.timeEntry.findMany({
    where: { taskId },
    orderBy: { createdAt: "desc" },
    select: {
      id: true,
      description: true,
      startedAt: true,
      stoppedAt: true,
      durationMinutes: true,
      isManual: true,
      isBillable: true,
      createdAt: true,
      user: { select: { id: true, name: true } },
    },
  });

  return entries;
}

// ---------- getDealTimeSummary ----------

export async function getDealTimeSummary(dealId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  await assertDealMember(dealId, session.user.id);

  const entries = await prisma.timeEntry.findMany({
    where: { dealId },
    select: {
      durationMinutes: true,
      isBillable: true,
      task: {
        select: {
          id: true,
          title: true,
          workstream: { select: { id: true, name: true } },
        },
      },
      user: { select: { id: true, name: true } },
    },
  });

  // Group by workstream → task
  const wsMap = new Map<string, {
    id: string;
    name: string;
    totalMinutes: number;
    billableMinutes: number;
    tasks: Map<string, { id: string; title: string; totalMinutes: number; billableMinutes: number }>;
  }>();

  for (const e of entries) {
    const ws = e.task.workstream;
    if (!wsMap.has(ws.id)) {
      wsMap.set(ws.id, {
        id: ws.id,
        name: ws.name,
        totalMinutes: 0,
        billableMinutes: 0,
        tasks: new Map(),
      });
    }
    const wsData = wsMap.get(ws.id)!;
    wsData.totalMinutes += e.durationMinutes;
    if (e.isBillable) wsData.billableMinutes += e.durationMinutes;

    if (!wsData.tasks.has(e.task.id)) {
      wsData.tasks.set(e.task.id, {
        id: e.task.id,
        title: e.task.title,
        totalMinutes: 0,
        billableMinutes: 0,
      });
    }
    const taskData = wsData.tasks.get(e.task.id)!;
    taskData.totalMinutes += e.durationMinutes;
    if (e.isBillable) taskData.billableMinutes += e.durationMinutes;
  }

  // Group by member
  const memberMap = new Map<string, {
    userId: string;
    userName: string;
    totalMinutes: number;
    billableMinutes: number;
  }>();

  for (const e of entries) {
    if (!memberMap.has(e.user.id)) {
      memberMap.set(e.user.id, {
        userId: e.user.id,
        userName: e.user.name,
        totalMinutes: 0,
        billableMinutes: 0,
      });
    }
    const m = memberMap.get(e.user.id)!;
    m.totalMinutes += e.durationMinutes;
    if (e.isBillable) m.billableMinutes += e.durationMinutes;
  }

  const totalMinutes = entries.reduce((sum, e) => sum + e.durationMinutes, 0);
  const billableMinutes = entries.filter((e) => e.isBillable).reduce((sum, e) => sum + e.durationMinutes, 0);

  return {
    byWorkstream: Array.from(wsMap.values()).map((ws) => ({
      ...ws,
      tasks: Array.from(ws.tasks.values()),
    })),
    byMember: Array.from(memberMap.values()),
    totalMinutes,
    billableMinutes,
  };
}

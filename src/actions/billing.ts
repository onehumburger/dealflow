"use server";

import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { logAudit } from "@/lib/audit";
import { revalidatePath } from "next/cache";
import { getLocale } from "next-intl/server";
import ExcelJS from "exceljs";
import { assertAdmin } from "@/actions/_helpers";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function isAdminUser(session: any): boolean {
  const role = (session?.user as unknown as { role: string } | undefined)?.role;
  return role === "Admin";
}

// ---------- getFilteredTimeEntries ----------

export async function getFilteredTimeEntries(filters: {
  dealId?: string;
  userId?: string;
  workstreamId?: string;
  startDate?: string;
  endDate?: string;
  billableOnly?: boolean;
}) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const admin = isAdminUser(session);
  const where: Record<string, unknown> = {};

  // Non-admin: scope to deals they belong to
  if (!admin) {
    const memberDealIds = await prisma.dealMember.findMany({
      where: { userId: session.user.id },
      select: { dealId: true },
    });
    const ids = memberDealIds.map((d) => d.dealId);
    if (filters.dealId) {
      if (!ids.includes(filters.dealId)) throw new Error("Forbidden");
      where.dealId = filters.dealId;
    } else {
      where.dealId = { in: ids };
    }
  } else if (filters.dealId) {
    where.dealId = filters.dealId;
  }
  if (filters.userId) where.userId = filters.userId;
  if (filters.billableOnly) where.isBillable = true;
  if (filters.workstreamId) where.task = { workstreamId: filters.workstreamId };

  if (filters.startDate || filters.endDate) {
    const dateFilter: Record<string, Date> = {};
    if (filters.startDate) dateFilter.gte = new Date(filters.startDate);
    if (filters.endDate) {
      const end = new Date(filters.endDate);
      end.setHours(23, 59, 59, 999);
      dateFilter.lte = end;
    }
    where.createdAt = dateFilter;
  }

  const entries = await prisma.timeEntry.findMany({
    where,
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
      task: {
        select: {
          id: true,
          title: true,
          workstream: { select: { id: true, name: true } },
        },
      },
      user: { select: { id: true, name: true } },
      deal: { select: { id: true, name: true } },
    },
  });

  return entries;
}

// ---------- setBillingRate ----------

export async function setBillingRate(
  dealId: string,
  userId: string,
  ratePerHour: number
) {
  const adminId = await assertAdmin();

  await prisma.dealBillingRate.upsert({
    where: { dealId_userId: { dealId, userId } },
    update: { ratePerHour },
    create: { dealId, userId, ratePerHour },
  });

  await logAudit(adminId, "set_billing_rate", "DealBillingRate", `${dealId}-${userId}`, {
    ratePerHour: { from: null, to: ratePerHour },
  });

  const locale = await getLocale();
  revalidatePath(`/${locale}/billing`);
}

// ---------- getDealBillingRates ----------

export async function getDealBillingRates(dealId?: string) {
  await assertAdmin();

  const where = dealId ? { dealId } : {};

  const rates = await prisma.dealBillingRate.findMany({
    where,
    select: {
      id: true,
      ratePerHour: true,
      currency: true,
      deal: { select: { id: true, name: true } },
      user: { select: { id: true, name: true } },
    },
  });

  return rates.map((r) => ({
    ...r,
    ratePerHour: Number(r.ratePerHour),
  }));
}

// ---------- getAdminFilterOptions ----------

export async function getAdminFilterOptions() {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const admin = isAdminUser(session);

  const deals = admin
    ? await prisma.deal.findMany({
        orderBy: { name: "asc" },
        select: { id: true, name: true },
      })
    : await prisma.deal.findMany({
        where: { members: { some: { userId: session.user.id } } },
        orderBy: { name: "asc" },
        select: { id: true, name: true },
      });

  const users = await prisma.user.findMany({
    orderBy: { name: "asc" },
    select: { id: true, name: true },
  });

  return { deals, users };
}

// ---------- getWorkstreamsForDeal ----------

export async function getWorkstreamsForDeal(dealId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  if (!isAdminUser(session)) {
    const membership = await prisma.dealMember.findFirst({
      where: { dealId, userId: session.user.id },
    });
    if (!membership) throw new Error("Forbidden");
  }

  const workstreams = await prisma.workstream.findMany({
    where: { dealId },
    orderBy: { sortOrder: "asc" },
    select: { id: true, name: true },
  });

  return workstreams;
}

// ---------- exportBillingExcel ----------

export async function exportBillingExcel(filters: {
  dealId?: string;
  userId?: string;
  workstreamId?: string;
  startDate?: string;
  endDate?: string;
  billableOnly?: boolean;
}): Promise<string> {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const admin = isAdminUser(session);
  const entries = await getFilteredTimeEntries(filters);
  const rates = admin ? await getDealBillingRates(filters.dealId) : [];

  // Build rate lookup: dealId-userId → ratePerHour
  const rateMap = new Map<string, number>();
  for (const r of rates) {
    rateMap.set(`${r.deal.id}-${r.user.id}`, r.ratePerHour);
  }

  const workbook = new ExcelJS.Workbook();

  // Sheet 1: Time Entries
  const ws1 = workbook.addWorksheet("Time Entries");
  ws1.columns = [
    { header: "Date", key: "date", width: 12 },
    { header: "Person", key: "person", width: 15 },
    { header: "Deal", key: "deal", width: 20 },
    { header: "Workstream", key: "workstream", width: 20 },
    { header: "Task", key: "task", width: 25 },
    { header: "Description", key: "description", width: 30 },
    { header: "Hours", key: "hours", width: 10 },
    { header: "Billable", key: "billable", width: 10 },
    { header: "Rate", key: "rate", width: 12 },
    { header: "Amount", key: "amount", width: 12 },
  ];

  for (const e of entries) {
    const hours = e.durationMinutes / 60;
    const rate = rateMap.get(`${e.deal.id}-${e.user.id}`) ?? 0;
    const amount = e.isBillable ? hours * rate : 0;

    ws1.addRow({
      date: e.startedAt ? new Date(e.startedAt).toLocaleDateString() : "",
      person: e.user.name,
      deal: e.deal.name,
      workstream: e.task.workstream.name,
      task: e.task.title,
      description: e.description || "",
      hours: parseFloat(hours.toFixed(2)),
      billable: e.isBillable ? "Yes" : "No",
      rate,
      amount: parseFloat(amount.toFixed(2)),
    });
  }

  // Sheet 2: Summary by Deal
  const ws2 = workbook.addWorksheet("By Deal");
  ws2.columns = [
    { header: "Deal", key: "deal", width: 20 },
    { header: "Person", key: "person", width: 15 },
    { header: "Total Hours", key: "totalHours", width: 12 },
    { header: "Billable Hours", key: "billableHours", width: 14 },
    { header: "Rate", key: "rate", width: 12 },
    { header: "Amount", key: "amount", width: 12 },
  ];

  // Group entries by deal+person
  const dealPersonMap = new Map<string, {
    deal: string;
    person: string;
    totalMinutes: number;
    billableMinutes: number;
    rate: number;
  }>();

  for (const e of entries) {
    const key = `${e.deal.id}-${e.user.id}`;
    if (!dealPersonMap.has(key)) {
      dealPersonMap.set(key, {
        deal: e.deal.name,
        person: e.user.name,
        totalMinutes: 0,
        billableMinutes: 0,
        rate: rateMap.get(key) ?? 0,
      });
    }
    const dp = dealPersonMap.get(key)!;
    dp.totalMinutes += e.durationMinutes;
    if (e.isBillable) dp.billableMinutes += e.durationMinutes;
  }

  for (const dp of dealPersonMap.values()) {
    const totalHours = dp.totalMinutes / 60;
    const billableHours = dp.billableMinutes / 60;
    ws2.addRow({
      deal: dp.deal,
      person: dp.person,
      totalHours: parseFloat(totalHours.toFixed(2)),
      billableHours: parseFloat(billableHours.toFixed(2)),
      rate: dp.rate,
      amount: parseFloat((billableHours * dp.rate).toFixed(2)),
    });
  }

  // Sheet 3: Summary by Person
  const ws3 = workbook.addWorksheet("By Person");
  ws3.columns = [
    { header: "Person", key: "person", width: 15 },
    { header: "Total Hours", key: "totalHours", width: 12 },
    { header: "Billable Hours", key: "billableHours", width: 14 },
    { header: "Amount", key: "amount", width: 12 },
  ];

  const personMap = new Map<string, {
    person: string;
    totalMinutes: number;
    billableMinutes: number;
    totalAmount: number;
  }>();

  for (const e of entries) {
    if (!personMap.has(e.user.id)) {
      personMap.set(e.user.id, {
        person: e.user.name,
        totalMinutes: 0,
        billableMinutes: 0,
        totalAmount: 0,
      });
    }
    const p = personMap.get(e.user.id)!;
    p.totalMinutes += e.durationMinutes;
    if (e.isBillable) {
      p.billableMinutes += e.durationMinutes;
      const rate = rateMap.get(`${e.deal.id}-${e.user.id}`) ?? 0;
      p.totalAmount += (e.durationMinutes / 60) * rate;
    }
  }

  for (const p of personMap.values()) {
    ws3.addRow({
      person: p.person,
      totalHours: parseFloat((p.totalMinutes / 60).toFixed(2)),
      billableHours: parseFloat((p.billableMinutes / 60).toFixed(2)),
      amount: parseFloat(p.totalAmount.toFixed(2)),
    });
  }

  // Style header rows
  for (const ws of [ws1, ws2, ws3]) {
    ws.getRow(1).font = { bold: true };
  }

  // Generate buffer and return as base64
  const buffer = await workbook.xlsx.writeBuffer();
  return Buffer.from(buffer).toString("base64");
}

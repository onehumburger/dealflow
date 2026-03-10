"use server";

import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { getLocale } from "next-intl/server";

export interface CalendarEvent {
  id: string;
  type: "milestone" | "task" | "activity";
  title: string;
  date: Date;
  dealId: string;
  dealName: string;
  dealColor: string;
  status?: string;
  isOverdue: boolean;
  href: string;
}

const DEAL_COLORS = [
  "#2563eb", "#16a34a", "#d97706", "#dc2626", "#7c3aed",
  "#0891b2", "#be185d", "#65a30d", "#ea580c", "#6366f1",
];

export async function getCalendarEvents(
  year: number,
  month: number,
  scopeDealIds?: string[]
): Promise<{ events: CalendarEvent[]; deals: { id: string; name: string; color: string }[] }> {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");
  const locale = await getLocale();

  const memberships = await prisma.dealMember.findMany({
    where: { userId: session.user.id },
    select: { dealId: true, deal: { select: { id: true, name: true } } },
  });

  const dealMap = new Map<string, { name: string; color: string }>();
  memberships.forEach((m, i) => {
    dealMap.set(m.dealId, {
      name: m.deal.name,
      color: DEAL_COLORS[i % DEAL_COLORS.length],
    });
  });

  const dealIds = scopeDealIds
    ? scopeDealIds.filter((id) => dealMap.has(id))
    : [...dealMap.keys()];

  if (dealIds.length === 0) {
    return { events: [], deals: [] };
  }

  const start = new Date(year, month - 1, 1);
  start.setDate(start.getDate() - 7);
  const end = new Date(year, month, 0);
  end.setDate(end.getDate() + 7);

  const now = new Date();

  const [milestones, tasks, activities] = await Promise.all([
    prisma.milestone.findMany({
      where: {
        dealId: { in: dealIds },
        date: { not: null, gte: start, lte: end },
      },
      select: {
        id: true, name: true, date: true, isDone: true,
        deal: { select: { id: true } },
      },
    }),
    prisma.task.findMany({
      where: {
        workstream: { dealId: { in: dealIds } },
        dueDate: { not: null, gte: start, lte: end },
      },
      select: {
        id: true, title: true, dueDate: true, status: true,
        workstream: { select: { deal: { select: { id: true } } } },
      },
    }),
    prisma.activityEntry.findMany({
      where: {
        dealId: { in: dealIds },
        createdAt: { gte: start, lte: end },
      },
      select: {
        id: true, content: true, type: true, createdAt: true, dealId: true,
      },
    }),
  ]);

  const events: CalendarEvent[] = [];

  for (const m of milestones) {
    if (!m.date) continue;
    const deal = dealMap.get(m.deal.id);
    if (!deal) continue;
    events.push({
      id: m.id, type: "milestone", title: m.name, date: m.date,
      dealId: m.deal.id, dealName: deal.name, dealColor: deal.color,
      status: m.isDone ? "done" : undefined,
      isOverdue: !m.isDone && m.date < now,
      href: `/${locale}/deals/${m.deal.id}`,
    });
  }

  for (const t of tasks) {
    if (!t.dueDate) continue;
    const dId = t.workstream.deal.id;
    const deal = dealMap.get(dId);
    if (!deal) continue;
    events.push({
      id: t.id, type: "task", title: t.title, date: t.dueDate,
      dealId: dId, dealName: deal.name, dealColor: deal.color,
      status: t.status, isOverdue: t.status !== "Done" && t.dueDate < now,
      href: `/${locale}/deals/${dId}`,
    });
  }

  for (const a of activities) {
    const deal = dealMap.get(a.dealId);
    if (!deal) continue;
    events.push({
      id: a.id, type: "activity",
      title: a.content.length > 60 ? a.content.slice(0, 60) + "..." : a.content,
      date: a.createdAt, dealId: a.dealId, dealName: deal.name,
      dealColor: deal.color, isOverdue: false,
      href: `/${locale}/deals/${a.dealId}`,
    });
  }

  events.sort((a, b) => a.date.getTime() - b.date.getTime());

  const deals = dealIds
    .map((id) => { const d = dealMap.get(id); return d ? { id, name: d.name, color: d.color } : null; })
    .filter(Boolean) as { id: string; name: string; color: string }[];

  return { events, deals };
}

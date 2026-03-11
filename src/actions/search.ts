"use server";

import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";

interface SearchResult {
  id: string;
  type: "deal" | "task" | "activity" | "contact" | "decision";
  title: string;
  subtitle: string;
  href: string;
}

interface SearchResults {
  deals: SearchResult[];
  tasks: SearchResult[];
  activity: SearchResult[];
  contacts: SearchResult[];
  decisions: SearchResult[];
}

export async function globalSearch(
  query: string,
  locale: string
): Promise<SearchResults> {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const trimmed = query.trim();
  if (!trimmed) {
    return { deals: [], tasks: [], activity: [], contacts: [], decisions: [] };
  }

  // Get deal IDs the user is a member of
  const memberships = await prisma.dealMember.findMany({
    where: { userId: session.user.id },
    select: { dealId: true },
  });
  const dealIds = memberships.map((m) => m.dealId);

  if (dealIds.length === 0) {
    return { deals: [], tasks: [], activity: [], contacts: [], decisions: [] };
  }

  // Run all 5 searches in parallel
  const [deals, tasks, activityEntries, contacts, decisions] = await Promise.all([
    prisma.deal.findMany({
      where: {
        id: { in: dealIds },
        OR: [
          { name: { contains: trimmed, mode: "insensitive" } },
          { codeName: { contains: trimmed, mode: "insensitive" } },
          { clientName: { contains: trimmed, mode: "insensitive" } },
          { targetCompany: { contains: trimmed, mode: "insensitive" } },
        ],
      },
      select: { id: true, name: true, clientName: true, targetCompany: true },
      take: 10,
    }),
    prisma.task.findMany({
      where: {
        workstream: { dealId: { in: dealIds } },
        title: { contains: trimmed, mode: "insensitive" },
      },
      select: {
        id: true,
        title: true,
        workstream: {
          select: { deal: { select: { id: true, name: true } } },
        },
      },
      take: 10,
    }),
    prisma.activityEntry.findMany({
      where: {
        dealId: { in: dealIds },
        content: { contains: trimmed, mode: "insensitive" },
      },
      select: {
        id: true,
        content: true,
        type: true,
        deal: { select: { id: true, name: true } },
      },
      orderBy: { createdAt: "desc" },
      take: 10,
    }),
    prisma.contact.findMany({
      where: {
        dealContacts: { some: { dealId: { in: dealIds } } },
        OR: [
          { name: { contains: trimmed, mode: "insensitive" } },
          { organization: { contains: trimmed, mode: "insensitive" } },
        ],
      },
      select: { id: true, name: true, organization: true },
      take: 10,
    }),
    prisma.decision.findMany({
      where: {
        dealId: { in: dealIds },
        OR: [
          { title: { contains: trimmed, mode: "insensitive" } },
          { background: { contains: trimmed, mode: "insensitive" } },
        ],
      },
      select: {
        id: true,
        title: true,
        deal: { select: { id: true, name: true } },
      },
      take: 10,
    }),
  ]);

  return {
    deals: deals.map((d) => ({
      id: d.id,
      type: "deal" as const,
      title: d.name,
      subtitle: `${d.clientName} / ${d.targetCompany}`,
      href: `/${locale}/deals/${d.id}`,
    })),
    tasks: tasks.map((t) => ({
      id: t.id,
      type: "task" as const,
      title: t.title,
      subtitle: t.workstream.deal.name,
      href: `/${locale}/deals/${t.workstream.deal.id}`,
    })),
    activity: activityEntries.map((a) => ({
      id: a.id,
      type: "activity" as const,
      title: a.content.length > 80 ? a.content.slice(0, 80) + "..." : a.content,
      subtitle: a.deal.name,
      href: `/${locale}/deals/${a.deal.id}`,
    })),
    contacts: contacts.map((c) => ({
      id: c.id,
      type: "contact" as const,
      title: c.name,
      subtitle: c.organization || "",
      href: `/${locale}/contacts`,
    })),
    decisions: decisions.map((d) => ({
      id: d.id,
      type: "decision" as const,
      title: d.title,
      subtitle: d.deal.name,
      href: `/${locale}/deals/${d.deal.id}/decisions`,
    })),
  };
}

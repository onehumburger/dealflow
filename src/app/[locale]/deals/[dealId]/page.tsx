import { auth } from "@/lib/auth";
import { redirect, notFound } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { getLocale, getTranslations } from "next-intl/server";
import Link from "next/link";
import { Separator } from "@/components/ui/separator";

import { DealHeader } from "@/components/deals/deal-header";
import { MilestoneTimeline } from "@/components/milestones/milestone-timeline";
import { WorkstreamList } from "@/components/workstreams/workstream-list";
import { ActivityFeed } from "@/components/activity/activity-feed";
import { TaskPanel } from "@/components/tasks/task-panel";
import { TaskFilters } from "@/components/tasks/task-filters";

export default async function DealDetailPage({
  params,
}: {
  params: Promise<{ dealId: string; locale: string }>;
}) {
  const { dealId } = await params;
  const session = await auth();
  const locale = await getLocale();

  if (!session?.user?.id) {
    redirect(`/${locale}/login`);
  }

  // Verify user is a member of this deal
  const isMember = await prisma.dealMember.findUnique({
    where: { dealId_userId: { dealId, userId: session.user.id } },
  });
  if (!isMember) {
    notFound();
  }

  const deal = await prisma.deal.findUnique({
    where: { id: dealId },
    include: {
      dealLead: { select: { name: true } },
      members: {
        include: { user: { select: { id: true, name: true } } },
      },
      milestones: { orderBy: { sortOrder: "asc" } },
      workstreams: {
        orderBy: { sortOrder: "asc" },
        include: {
          tasks: {
            orderBy: { sortOrder: "asc" },
            include: {
              assignee: { select: { id: true, name: true } },
            },
          },
        },
      },
      activityEntries: {
        orderBy: { createdAt: "desc" },
        include: { author: { select: { name: true } } },
      },
      _count: {
        select: {
          decisions: true,
          dealContacts: true,
          documents: true,
        },
      },
    },
  });

  if (!deal) {
    notFound();
  }

  const tDecision = await getTranslations("decision");
  const tContact = await getTranslations("contact");
  const tDocument = await getTranslations("document");
  const tCalendar = await getTranslations("calendar");
  const tTimer = await getTranslations("timer");

  // Serialize dates for client components
  const workstreamsData = deal.workstreams.map((ws) => ({
    id: ws.id,
    name: ws.name,
    tasks: ws.tasks.map((t) => ({
      id: t.id,
      title: t.title,
      status: t.status,
      priority: t.priority,
      dueDate: t.dueDate ? new Date(t.dueDate) : null,
      completedAt: t.completedAt ? new Date(t.completedAt) : null,
      assigneeId: t.assigneeId,
      assignee: t.assignee,
    })),
  }));

  const membersData = deal.members.map((m) => ({
    id: m.user.id,
    name: m.user.name,
  }));

  const activityData = deal.activityEntries.map((e) => ({
    id: e.id,
    type: e.type,
    content: e.content,
    createdAt: new Date(e.createdAt),
    author: e.author,
  }));

  const milestonesData = deal.milestones.map((m) => ({
    id: m.id,
    name: m.name,
    date: m.date ? new Date(m.date) : null,
    type: m.type,
    isDone: m.isDone,
  }));

  // Permission: can current user create/delete tasks?
  const userRole = (session.user as unknown as { role: string }).role;
  const canManageTasks =
    userRole === "Admin" || deal.dealLeadId === session.user.id;

  // Workstream options for ActivityForm
  const workstreamOptions = deal.workstreams.map((ws) => ({
    id: ws.id,
    name: ws.name,
  }));

  return (
    <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6">
      {/* Deal Header */}
      <DealHeader
        deal={{
          id: deal.id,
          name: deal.name,
          codeName: deal.codeName,
          status: deal.status,
          clientName: deal.clientName,
          targetCompany: deal.targetCompany,
          jurisdictions: deal.jurisdictions,
          summary: deal.summary,
          dealLead: deal.dealLead,
          phase: deal.phase,
          dealValue: deal.dealValue ? Number(deal.dealValue) : null,
          valueCurrency: deal.valueCurrency,
          keyTerms: deal.keyTerms,
          source: deal.source,
          sourceNote: deal.sourceNote,
        }}
      />

      <Separator className="my-4" />

      {/* Milestone Timeline */}
      <MilestoneTimeline milestones={milestonesData} locale={locale} dealId={dealId} />

      <Separator className="my-4" />

      {/* Task filter bar */}
      <TaskFilters members={membersData} />

      {/* Main content: Workstreams + Activity Feed */}
      <div className="flex flex-col lg:flex-row gap-6">
        {/* Workstreams (left) */}
        <div className="flex-1 min-w-0">
          <WorkstreamList workstreams={workstreamsData} dealId={dealId} dealStatus={deal.status} canManageTasks={canManageTasks} />
        </div>

        {/* Activity Feed (right) */}
        <div className="w-full lg:w-[340px] lg:shrink-0 order-2 lg:order-none">
          <ActivityFeed
            entries={activityData}
            dealId={dealId}
            workstreams={workstreamOptions}
          />
        </div>
      </div>

      <Separator className="my-6" />

      {/* Bottom Links: Decisions, Contacts, Documents */}
      <div className="flex flex-wrap items-center gap-3">
        <Link
          href={`/${locale}/deals/${dealId}/decisions`}
          className="rounded-md border px-4 py-2 text-sm font-medium transition-colors hover:bg-muted"
        >
          {tDecision("decisions")} ({deal._count.decisions})
        </Link>
        <Link
          href={`/${locale}/deals/${dealId}/contacts`}
          className="rounded-md border px-4 py-2 text-sm font-medium transition-colors hover:bg-muted"
        >
          {tContact("contacts")} ({deal._count.dealContacts})
        </Link>
        <Link
          href={`/${locale}/deals/${dealId}/documents`}
          className="rounded-md border px-4 py-2 text-sm font-medium transition-colors hover:bg-muted"
        >
          {tDocument("documents")} ({deal._count.documents})
        </Link>
        <Link
          href={`/${locale}/deals/${dealId}/calendar`}
          className="rounded-md border px-4 py-2 text-sm font-medium transition-colors hover:bg-muted"
        >
          {tCalendar("calendar")}
        </Link>
        <Link
          href={`/${locale}/deals/${dealId}/time`}
          className="rounded-md border px-4 py-2 text-sm font-medium transition-colors hover:bg-muted"
        >
          {tTimer("timeEntries")}
        </Link>
      </div>

      {/* Task slide-over panel */}
      <TaskPanel canManageTasks={canManageTasks} />
    </div>
  );
}

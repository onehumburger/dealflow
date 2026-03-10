import { auth } from "@/lib/auth";
import { redirect, notFound } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { getLocale, getTranslations } from "next-intl/server";
import { Separator } from "@/components/ui/separator";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
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

  if (!session) {
    redirect(`/${locale}/login`);
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
          status: deal.status,
          clientName: deal.clientName,
          targetCompany: deal.targetCompany,
          summary: deal.summary,
          dealLead: deal.dealLead,
        }}
      />

      <Separator className="my-4" />

      {/* Milestone Timeline */}
      <MilestoneTimeline milestones={milestonesData} locale={locale} dealId={dealId} />

      <Separator className="my-4" />

      {/* Task filter bar */}
      <TaskFilters members={membersData} />

      {/* Main content: Workstreams + Activity Feed */}
      <div className="flex gap-6">
        {/* Workstreams (left) */}
        <div className="flex-1 min-w-0">
          <WorkstreamList workstreams={workstreamsData} dealId={dealId} />
        </div>

        {/* Activity Feed (right) */}
        <div className="w-[340px] shrink-0">
          <ActivityFeed
            entries={activityData}
            dealId={dealId}
            workstreams={workstreamOptions}
          />
        </div>
      </div>

      <Separator className="my-6" />

      {/* Bottom Tabs: Decisions, Contacts, Documents */}
      <Tabs defaultValue="decisions">
        <TabsList>
          <TabsTrigger value="decisions">
            {tDecision("decisions")} ({deal._count.decisions})
          </TabsTrigger>
          <TabsTrigger value="contacts">
            {tContact("name")} ({deal._count.dealContacts})
          </TabsTrigger>
          <TabsTrigger value="documents">
            Documents ({deal._count.documents})
          </TabsTrigger>
        </TabsList>
        <TabsContent value="decisions">
          <p className="py-8 text-center text-sm text-muted-foreground">
            {tDecision("decisions")} &mdash; coming in a later chunk
          </p>
        </TabsContent>
        <TabsContent value="contacts">
          <p className="py-8 text-center text-sm text-muted-foreground">
            {tContact("name")} &mdash; coming in a later chunk
          </p>
        </TabsContent>
        <TabsContent value="documents">
          <p className="py-8 text-center text-sm text-muted-foreground">
            Documents &mdash; coming in a later chunk
          </p>
        </TabsContent>
      </Tabs>

      {/* Task slide-over panel */}
      <TaskPanel />
    </div>
  );
}

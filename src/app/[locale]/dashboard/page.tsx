import { auth } from "@/lib/auth";
import { redirect } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { getLocale, getTranslations } from "next-intl/server";

export const dynamic = "force-dynamic";

import { MyTasksWidget } from "@/components/dashboard/my-tasks-widget";
import { MilestonesWidget } from "@/components/dashboard/milestones-widget";
import { ActiveDealsWidget } from "@/components/dashboard/active-deals-widget";
import { RecentActivityWidget } from "@/components/dashboard/recent-activity-widget";

export default async function DashboardPage() {
  const session = await auth();
  const locale = await getLocale();

  if (!session?.user?.id) {
    redirect(`/${locale}/login`);
  }

  const userId = session.user.id;
  const tDashboard = await getTranslations("dashboard");
  const tTask = await getTranslations("task");
  const tMilestone = await getTranslations("milestone");
  const tCommon = await getTranslations("common");
  const tActivity = await getTranslations("activity");

  // Get deal IDs the user is a member of
  const memberships = await prisma.dealMember.findMany({
    where: { userId },
    select: { dealId: true },
  });
  const dealIds = memberships.map((m) => m.dealId);

  const now = new Date();

  // --- Parallel data fetching ---
  const [tasks, milestones, activeDeals, recentActivity] = await Promise.all([
    prisma.task.findMany({
      where: {
        assigneeId: userId,
        status: { not: "Done" },
        workstream: { deal: { id: { in: dealIds }, status: "Active" } },
      },
      orderBy: [{ dueDate: "asc" }, { createdAt: "desc" }],
      take: 10,
      select: {
        id: true,
        title: true,
        priority: true,
        dueDate: true,
        workstream: {
          select: {
            deal: { select: { id: true, name: true } },
          },
        },
      },
    }),
    prisma.milestone.findMany({
      where: {
        isDone: false,
        deal: { id: { in: dealIds }, status: "Active" },
        date: { not: null },
      },
      orderBy: { date: "asc" },
      take: 8,
      select: {
        id: true,
        name: true,
        date: true,
        deal: { select: { id: true, name: true } },
      },
    }),
    prisma.deal.findMany({
      where: {
        id: { in: dealIds },
        status: "Active",
      },
      orderBy: { updatedAt: "desc" },
      select: {
        id: true,
        name: true,
        status: true,
        clientName: true,
        targetCompany: true,
        workstreams: {
          select: {
            tasks: { select: { status: true } },
          },
        },
      },
    }),
    prisma.activityEntry.findMany({
      where: { dealId: { in: dealIds } },
      orderBy: { createdAt: "desc" },
      take: 20,
      select: {
        id: true,
        type: true,
        content: true,
        createdAt: true,
        author: { select: { name: true } },
        deal: { select: { id: true, name: true } },
      },
    }),
  ]);

  // Sort tasks: overdue first, then by due date
  const sortedTasks = tasks.sort((a, b) => {
    const aOverdue = a.dueDate && a.dueDate < now;
    const bOverdue = b.dueDate && b.dueDate < now;
    if (aOverdue && !bOverdue) return -1;
    if (!aOverdue && bOverdue) return 1;
    if (a.dueDate && b.dueDate) return a.dueDate.getTime() - b.dueDate.getTime();
    if (a.dueDate && !b.dueDate) return -1;
    if (!a.dueDate && b.dueDate) return 1;
    return 0;
  });

  const taskItems = sortedTasks.map((t) => ({
    id: t.id,
    title: t.title,
    priority: t.priority,
    dueDate: t.dueDate ? new Date(t.dueDate) : null,
    dealId: t.workstream.deal.id,
    dealName: t.workstream.deal.name,
  }));

  const milestoneItems = milestones.map((m) => {
    let daysRemaining: number | null = null;
    if (m.date) {
      const d = new Date(m.date);
      const diffMs = d.getTime() - now.getTime();
      daysRemaining = Math.ceil(diffMs / (1000 * 60 * 60 * 24));
    }
    return {
      id: m.id,
      name: m.name,
      date: m.date ? new Date(m.date) : null,
      dealId: m.deal.id,
      dealName: m.deal.name,
      daysRemaining,
    };
  });

  const dealItems = activeDeals.map((d) => {
    const allTasks = d.workstreams.flatMap((ws) => ws.tasks);
    return {
      id: d.id,
      name: d.name,
      status: d.status,
      clientName: d.clientName,
      targetCompany: d.targetCompany,
      tasksDone: allTasks.filter((t) => t.status === "Done").length,
      tasksTotal: allTasks.length,
    };
  });

  const activityItems = recentActivity.map((e) => ({
    id: e.id,
    type: e.type,
    content: e.content,
    createdAt: new Date(e.createdAt),
    authorName: e.author.name,
    dealId: e.deal.id,
    dealName: e.deal.name,
  }));

  return (
    <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6">
      <h1 className="mb-6 text-2xl font-bold">{tCommon("appName")}</h1>

      {/* Top: Active Deals */}
      <ActiveDealsWidget
        deals={dealItems}
        locale={locale}
        translations={{
          activeDeals: tDashboard("activeDeals"),
          noResults: tCommon("noResults"),
          tasks: tTask("tasks"),
        }}
      />

      <div className="mt-6 grid gap-6 lg:grid-cols-2">
        {/* My Tasks */}
        <MyTasksWidget
          tasks={taskItems}
          locale={locale}
          translations={{
            myTasks: tDashboard("myTasks"),
            high: tTask("high"),
            overdue: tTask("overdue"),
            noTasks: tTask("noTasks"),
            allDeals: tDashboard("allDeals"),
          }}
        />

        {/* Milestones */}
        <MilestonesWidget
          milestones={milestoneItems}
          locale={locale}
          translations={{
            upcomingMilestones: tDashboard("upcomingMilestones"),
            overdue: tMilestone("overdue"),
            noResults: tCommon("noResults"),
            allDeals: tDashboard("allDeals"),
          }}
        />
      </div>

      {/* Bottom: Recent Activity */}
      <div className="mt-6">
        <RecentActivityWidget
          entries={activityItems}
          locale={locale}
          translations={{
            recentActivity: tDashboard("recentActivity"),
            noResults: tCommon("noResults"),
            showTaskUpdates: tActivity("showTaskUpdates"),
            hideTaskUpdates: tActivity("hideTaskUpdates"),
          }}
          activityTranslations={{
            note: tActivity("note"),
            call: tActivity("call"),
            meeting: tActivity("meeting"),
            clientInstruction: tActivity("clientInstruction"),
            taskUpdate: tActivity("taskUpdate"),
            milestoneChange: tActivity("milestoneChange"),
            decisionCreated: tActivity("decisionCreated"),
            documentUpload: tActivity("documentUpload"),
            documentVersionUpload: tActivity("documentVersionUpload"),
            documentRestore: tActivity("documentRestore"),
            documentDelete: tActivity("documentDelete"),
          }}
        />
      </div>
    </div>
  );
}

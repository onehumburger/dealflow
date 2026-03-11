import { auth } from "@/lib/auth";
import { redirect } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { getLocale, getTranslations } from "next-intl/server";
import { MyTaskList } from "@/components/tasks/my-task-list";

export default async function MyTasksPage() {
  const session = await auth();
  const locale = await getLocale();

  if (!session?.user?.id) {
    redirect(`/${locale}/login`);
  }

  const tNav = await getTranslations("nav");

  const tasks = await prisma.task.findMany({
    where: { assigneeId: session.user.id, status: { not: "Done" } },
    orderBy: [{ dueDate: "asc" }, { createdAt: "desc" }],
    include: {
      workstream: {
        select: {
          name: true,
          deal: {
            select: { id: true, name: true },
          },
        },
      },
      assignee: { select: { name: true } },
    },
  });

  // Group by deal
  const dealMap = new Map<
    string,
    {
      dealId: string;
      dealName: string;
      tasks: typeof tasks;
    }
  >();

  for (const task of tasks) {
    const dealId = task.workstream.deal.id;
    const dealName = task.workstream.deal.name;
    if (!dealMap.has(dealId)) {
      dealMap.set(dealId, { dealId, dealName, tasks: [] });
    }
    dealMap.get(dealId)!.tasks.push(task);
  }

  // Sort deals: those with overdue tasks first
  const now = new Date();
  const dealGroups = Array.from(dealMap.values()).sort((a, b) => {
    const aHasOverdue = a.tasks.some(
      (t) => t.dueDate && t.dueDate < now && t.status !== "Done"
    );
    const bHasOverdue = b.tasks.some(
      (t) => t.dueDate && t.dueDate < now && t.status !== "Done"
    );
    if (aHasOverdue && !bHasOverdue) return -1;
    if (!aHasOverdue && bHasOverdue) return 1;
    return 0;
  });

  // Serialize dates
  const serialized = dealGroups.map((group) => ({
    ...group,
    tasks: group.tasks.map((t) => ({
      id: t.id,
      title: t.title,
      status: t.status,
      priority: t.priority,
      dueDate: t.dueDate ? new Date(t.dueDate) : null,
      completedAt: t.completedAt ? new Date(t.completedAt) : null,
      assignee: t.assignee,
      workstreamName: t.workstream.name,
    })),
  }));

  return (
    <div className="mx-auto max-w-5xl px-4 py-6 sm:px-6">
      <h1 className="text-2xl font-bold">{tNav("myTasks")}</h1>

      <div className="mt-6">
        {serialized.length === 0 ? (
          <p className="py-12 text-center text-sm text-muted-foreground">
            --
          </p>
        ) : (
          <MyTaskList dealGroups={serialized} locale={locale} />
        )}
      </div>
    </div>
  );
}

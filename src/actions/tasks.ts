"use server";

import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { assertDealMember, revalidateDeal } from "@/actions/_helpers";
import { logAudit } from "@/lib/audit";
import type {
  TaskStatus,
  TaskPriority,
  DependencyType,
} from "@/generated/prisma/client";

// ---------- helpers ----------

async function getDealIdForTask(taskId: string): Promise<string> {
  const task = await prisma.task.findUnique({
    where: { id: taskId },
    select: { workstream: { select: { dealId: true } } },
  });
  if (!task) throw new Error("Task not found");
  return task.workstream.dealId;
}

// ---------- updateTaskStatus ----------

export async function updateTaskStatus(taskId: string, status: TaskStatus) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const existing = await prisma.task.findUnique({
    where: { id: taskId },
    select: {
      title: true,
      status: true,
      workstream: { select: { dealId: true } },
    },
  });
  if (!existing) throw new Error("Task not found");

  await assertDealMember(existing.workstream.dealId, session.user.id);

  await prisma.task.update({
    where: { id: taskId },
    data: {
      status,
      completedAt: status === "Done" ? new Date() : null,
    },
  });

  // Activity entry
  await prisma.activityEntry.create({
    data: {
      type: "TaskUpdate",
      content: `Task "${existing.title}" → ${status}`,
      dealId: existing.workstream.dealId,
      authorId: session.user.id,
    },
  });

  await logAudit(session.user.id, "update_task_status", "Task", taskId, {
    status: { from: existing.status, to: status },
  });

  await revalidateDeal(existing.workstream.dealId, "/tasks");
}

// ---------- createTask ----------

export async function createTask(formData: FormData) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const workstreamId = formData.get("workstreamId") as string;
  const title = formData.get("title") as string;
  const priority = (formData.get("priority") as string) || "Normal";
  const assigneeId = (formData.get("assigneeId") as string) || null;
  const dueDateRaw = formData.get("dueDate") as string;
  const dueDate = dueDateRaw ? new Date(dueDateRaw) : null;

  if (!workstreamId || !title) throw new Error("Missing required fields");

  // Get deal for activity + auto-increment sortOrder
  const workstream = await prisma.workstream.findUnique({
    where: { id: workstreamId },
    select: {
      dealId: true,
      tasks: { orderBy: { sortOrder: "desc" }, take: 1, select: { sortOrder: true } },
    },
  });
  if (!workstream) throw new Error("Workstream not found");

  await assertDealMember(workstream.dealId, session.user.id);

  const nextSortOrder =
    workstream.tasks.length > 0 ? workstream.tasks[0].sortOrder + 1 : 0;

  const task = await prisma.task.create({
    data: {
      title,
      priority: priority as TaskPriority,
      assigneeId,
      dueDate,
      sortOrder: nextSortOrder,
      workstreamId,
    },
  });

  await prisma.activityEntry.create({
    data: {
      type: "TaskUpdate",
      content: `Task "${title}" created`,
      dealId: workstream.dealId,
      authorId: session.user.id,
    },
  });

  await revalidateDeal(workstream.dealId, "/tasks");
  return task;
}

// ---------- updateTask ----------

export async function updateTask(
  taskId: string,
  data: {
    title?: string;
    description?: string | null;
    assigneeId?: string | null;
    priority?: TaskPriority;
    dueDate?: Date | null;
    status?: TaskStatus;
  }
) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const dealId = await getDealIdForTask(taskId);

  await assertDealMember(dealId, session.user.id);

  await prisma.task.update({
    where: { id: taskId },
    data,
  });

  await revalidateDeal(dealId, "/tasks");
}

// ---------- deleteTask ----------

export async function deleteTask(taskId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const task = await prisma.task.findUnique({
    where: { id: taskId },
    select: {
      title: true,
      workstream: { select: { dealId: true } },
    },
  });
  if (!task) throw new Error("Task not found");

  await assertDealMember(task.workstream.dealId, session.user.id);

  await prisma.task.delete({ where: { id: taskId } });

  await prisma.activityEntry.create({
    data: {
      type: "TaskUpdate",
      content: `Task "${task.title}" deleted`,
      dealId: task.workstream.dealId,
      authorId: session.user.id,
    },
  });

  await revalidateDeal(task.workstream.dealId, "/tasks");
}

// ---------- getTaskDetail ----------

export async function getTaskDetail(taskId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const task = await prisma.task.findUnique({
    where: { id: taskId },
    include: {
      assignee: { select: { id: true, name: true } },
      subtasks: { orderBy: { sortOrder: "asc" } },
      comments: {
        orderBy: { createdAt: "asc" },
        include: { author: { select: { id: true, name: true } } },
      },
      blockedBy: {
        include: {
          dependsOn: {
            select: { id: true, title: true, status: true },
          },
        },
      },
      blocks: {
        include: {
          task: {
            select: { id: true, title: true, status: true },
          },
        },
      },
      workstream: {
        select: {
          dealId: true,
          deal: {
            select: {
              name: true,
              members: {
                include: { user: { select: { id: true, name: true } } },
              },
            },
          },
        },
      },
    },
  });

  if (!task) throw new Error("Task not found");

  await assertDealMember(task.workstream.dealId, session.user.id);

  return task;
}

// ---------- addTaskComment ----------

export async function addTaskComment(taskId: string, content: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");
  if (!content.trim()) throw new Error("Comment cannot be empty");

  const dealId = await getDealIdForTask(taskId);

  await assertDealMember(dealId, session.user.id);

  const comment = await prisma.taskComment.create({
    data: {
      content: content.trim(),
      taskId,
      authorId: session.user.id,
    },
    include: {
      author: { select: { id: true, name: true } },
    },
  });

  await revalidateDeal(dealId, "/tasks");
  return comment;
}

// ---------- addTaskDependency ----------

export async function addTaskDependency(
  taskId: string,
  dependsOnTaskId: string,
  type: DependencyType
) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  if (taskId === dependsOnTaskId) {
    throw new Error("A task cannot depend on itself");
  }

  const dealId = await getDealIdForTask(taskId);

  await assertDealMember(dealId, session.user.id);

  await prisma.taskDependency.create({
    data: {
      taskId,
      dependsOnTaskId,
      type,
    },
  });

  await revalidateDeal(dealId, "/tasks");
}

// ---------- removeTaskDependency ----------

export async function removeTaskDependency(dependencyId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const dep = await prisma.taskDependency.findUnique({
    where: { id: dependencyId },
    select: { task: { select: { workstream: { select: { dealId: true } } } } },
  });
  if (!dep) throw new Error("Dependency not found");

  await assertDealMember(dep.task.workstream.dealId, session.user.id);

  await prisma.taskDependency.delete({ where: { id: dependencyId } });
  await revalidateDeal(dep.task.workstream.dealId, "/tasks");
}

// ---------- Subtask actions ----------

export async function addSubtask(taskId: string, title: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");
  if (!title.trim()) throw new Error("Title required");

  const dealId = await getDealIdForTask(taskId);

  await assertDealMember(dealId, session.user.id);

  const existing = await prisma.subtask.findMany({
    where: { taskId },
    orderBy: { sortOrder: "desc" },
    take: 1,
    select: { sortOrder: true },
  });
  const nextSort = existing.length > 0 ? existing[0].sortOrder + 1 : 0;

  await prisma.subtask.create({
    data: {
      title: title.trim(),
      sortOrder: nextSort,
      taskId,
    },
  });

  await revalidateDeal(dealId, "/tasks");
}

export async function toggleSubtask(subtaskId: string, isDone: boolean) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const subtask = await prisma.subtask.findUnique({
    where: { id: subtaskId },
    select: { task: { select: { workstream: { select: { dealId: true } } } } },
  });
  if (!subtask) throw new Error("Subtask not found");

  await assertDealMember(subtask.task.workstream.dealId, session.user.id);

  await prisma.subtask.update({
    where: { id: subtaskId },
    data: { isDone },
  });

  await revalidateDeal(subtask.task.workstream.dealId, "/tasks");
}

export async function deleteSubtask(subtaskId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const subtask = await prisma.subtask.findUnique({
    where: { id: subtaskId },
    select: { task: { select: { workstream: { select: { dealId: true } } } } },
  });
  if (!subtask) throw new Error("Subtask not found");

  await assertDealMember(subtask.task.workstream.dealId, session.user.id);

  await prisma.subtask.delete({ where: { id: subtaskId } });
  await revalidateDeal(subtask.task.workstream.dealId, "/tasks");
}

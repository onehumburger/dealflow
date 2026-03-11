import { prisma } from "@/lib/prisma";
import { Prisma } from "@/generated/prisma/client";

export async function logAudit(
  userId: string,
  action: string,
  entityType: string,
  entityId: string,
  changes?: Record<string, { from: unknown; to: unknown }>
) {
  try {
    await prisma.auditLog.create({
      data: {
        userId,
        action,
        entityType,
        entityId,
        changes: changes
          ? (changes as unknown as Prisma.InputJsonValue)
          : Prisma.JsonNull,
      },
    });
  } catch (e) {
    console.error(`Audit log failed [${action}/${entityType}/${entityId}]:`, e);
  }
}

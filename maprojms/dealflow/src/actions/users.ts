"use server";

import { prisma } from "@/lib/prisma";
import { revalidatePath } from "next/cache";
import { getLocale } from "next-intl/server";
import { logAudit } from "@/lib/audit";
import bcrypt from "bcryptjs";
import type { UserRole } from "@/generated/prisma/client";
import { assertAdmin } from "@/actions/_helpers";

export async function getUsers() {
  await assertAdmin();
  return prisma.user.findMany({
    orderBy: { createdAt: "desc" },
    select: {
      id: true,
      name: true,
      email: true,
      role: true,
      locale: true,
      createdAt: true,
    },
  });
}

export async function createUser(formData: FormData) {
  const adminId = await assertAdmin();
  const locale = await getLocale();

  const name = formData.get("name") as string;
  const email = formData.get("email") as string;
  const password = formData.get("password") as string;
  const role = formData.get("role") as string;

  if (!name || !email || !password) {
    throw new Error("Missing required fields");
  }

  const validRoles = ["Admin", "Member"];
  if (!validRoles.includes(role)) {
    throw new Error("Invalid role");
  }

  // Check for existing email
  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) {
    throw new Error("Email already in use");
  }

  const passwordHash = await bcrypt.hash(password, 10);

  const user = await prisma.user.create({
    data: {
      name,
      email,
      passwordHash,
      role: role as UserRole,
    },
  });

  await logAudit(adminId, "create_user", "User", user.id);

  revalidatePath(`/${locale}/admin/users`);
  return { id: user.id };
}

export async function updateUser(
  userId: string,
  data: {
    name?: string;
    email?: string;
    role?: UserRole;
    locale?: string;
  }
) {
  const adminId = await assertAdmin();
  const locale = await getLocale();

  const validRoles = ["Admin", "Member"];
  const validLocales = ["zh", "en"];
  if (data.role && !validRoles.includes(data.role)) {
    throw new Error("Invalid role");
  }
  if (data.locale && !validLocales.includes(data.locale)) {
    throw new Error("Invalid locale");
  }

  if (data.email) {
    const existing = await prisma.user.findUnique({
      where: { email: data.email },
    });
    if (existing && existing.id !== userId) {
      throw new Error("Email already in use");
    }
  }

  await prisma.user.update({
    where: { id: userId },
    data,
  });

  await logAudit(adminId, "update_user", "User", userId);

  revalidatePath(`/${locale}/admin/users`);
}

export async function deleteUser(userId: string) {
  const adminId = await assertAdmin();
  const locale = await getLocale();

  // Prevent self-deletion
  if (userId === adminId) throw new Error("Cannot delete yourself");

  await prisma.user.delete({ where: { id: userId } });

  await logAudit(adminId, "delete_user", "User", userId);

  revalidatePath(`/${locale}/admin/users`);
}

export async function resetPassword(userId: string, newPassword: string) {
  const adminId = await assertAdmin();
  const locale = await getLocale();

  if (!newPassword || newPassword.length < 6) {
    throw new Error("Password must be at least 6 characters");
  }

  const passwordHash = await bcrypt.hash(newPassword, 10);

  await prisma.user.update({
    where: { id: userId },
    data: { passwordHash },
  });

  await logAudit(adminId, "reset_password", "User", userId);

  revalidatePath(`/${locale}/admin/users`);
}

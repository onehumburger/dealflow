import { auth } from "@/lib/auth";
import { redirect } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { getLocale, getTranslations } from "next-intl/server";
import { UserList } from "@/components/users/user-list";
import { UserForm } from "@/components/users/user-form";

export default async function AdminUsersPage() {
  const session = await auth();
  const locale = await getLocale();

  if (!session?.user?.id) {
    redirect(`/${locale}/login`);
  }

  const role = (session.user as unknown as { role: string }).role;
  if (role !== "Admin") {
    redirect(`/${locale}/dashboard`);
  }

  const t = await getTranslations("user");

  const users = await prisma.user.findMany({
    orderBy: { createdAt: "desc" },
    select: {
      id: true,
      name: true,
      email: true,
      role: true,
      createdAt: true,
    },
  });

  const usersData = users.map((u) => ({
    ...u,
    createdAt: new Date(u.createdAt),
  }));

  return (
    <div className="mx-auto max-w-5xl px-4 py-6 sm:px-6">
      <div className="mb-4 flex items-center justify-between">
        <h1 className="text-lg font-semibold">{t("users")}</h1>
        <UserForm
          trigger={
            <button className="rounded-md bg-primary px-3 py-1.5 text-sm font-medium text-primary-foreground hover:bg-primary/90">
              + {t("addUser")}
            </button>
          }
        />
      </div>

      <UserList users={usersData} />
    </div>
  );
}

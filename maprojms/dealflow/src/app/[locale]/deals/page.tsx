import { auth } from "@/lib/auth";
import { redirect } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { getLocale, getTranslations } from "next-intl/server";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Plus } from "lucide-react";
import { DealList } from "@/components/deals/deal-list";

export default async function DealsPage() {
  const session = await auth();
  const locale = await getLocale();

  if (!session?.user?.id) {
    redirect(`/${locale}/login`);
  }

  const t = await getTranslations("deal");
  const tNav = await getTranslations("nav");
  const tTask = await getTranslations("task");

  // Scope to deals where user is a member
  const memberships = await prisma.dealMember.findMany({
    where: { userId: session.user.id },
    select: { dealId: true },
  });
  const dealIds = memberships.map((m) => m.dealId);

  const deals = await prisma.deal.findMany({
    where: { id: { in: dealIds } },
    orderBy: { updatedAt: "desc" },
    include: {
      dealLead: { select: { name: true } },
      workstreams: {
        include: {
          tasks: { select: { status: true } },
        },
      },
    },
  });

  return (
    <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">{tNav("deals")}</h1>
        <Link href={`/${locale}/deals/new`}>
          <Button>
            <Plus className="size-4" />
            {t("newDeal")}
          </Button>
        </Link>
      </div>

      <div className="mt-6">
        <DealList
          deals={deals.map((d) => ({
            ...d,
            dealValue: d.dealValue ? Number(d.dealValue) : null,
          }))}
          locale={locale}
          translations={{
            name: t("name"),
            codeName: t("codeName"),
            clientName: t("clientName"),
            targetCompany: t("targetCompany"),
            status: t("status"),
            dealLead: t("dealLead"),
            tasks: tTask("tasks"),
            phase: t("phase"),
            dealValue: t("dealValue"),
          }}
        />
      </div>
    </div>
  );
}

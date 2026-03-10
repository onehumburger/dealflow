import { auth } from "@/lib/auth";
import { redirect, notFound } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { getLocale, getTranslations } from "next-intl/server";
import { getCalendarEvents } from "@/actions/calendar";
import { CalendarView } from "@/components/calendar/calendar-view";

export const dynamic = "force-dynamic";

export default async function DealCalendarPage({
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

  // Verify membership
  const isMember = await prisma.dealMember.findUnique({
    where: { dealId_userId: { dealId, userId: session.user.id } },
  });
  if (!isMember) {
    notFound();
  }

  const deal = await prisma.deal.findUnique({
    where: { id: dealId },
    select: { name: true },
  });
  if (!deal) notFound();

  const t = await getTranslations("calendar");
  const now = new Date();
  const { events } = await getCalendarEvents(
    now.getFullYear(),
    now.getMonth() + 1,
    [dealId]
  );

  return (
    <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6">
      <h1 className="mb-4 text-2xl font-bold">
        {deal.name} — {t("calendar")}
      </h1>
      <CalendarView initialEvents={events} scopeDealId={dealId} />
    </div>
  );
}

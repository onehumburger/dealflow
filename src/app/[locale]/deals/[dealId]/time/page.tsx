import { auth } from "@/lib/auth";
import { redirect, notFound } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { getLocale } from "next-intl/server";
import { getDealTimeSummary } from "@/actions/time-entries";
import { DealTimeSummary } from "@/components/time/deal-time-summary";
import Link from "next/link";

export default async function DealTimePage({
  params,
}: {
  params: Promise<{ dealId: string }>;
}) {
  const { dealId } = await params;
  const session = await auth();
  const locale = await getLocale();

  if (!session?.user?.id) {
    redirect(`/${locale}/login`);
  }

  const isMember = await prisma.dealMember.findUnique({
    where: { dealId_userId: { dealId, userId: session.user.id } },
  });
  if (!isMember) notFound();

  const deal = await prisma.deal.findUnique({
    where: { id: dealId },
    select: { name: true },
  });
  if (!deal) notFound();

  const summary = await getDealTimeSummary(dealId);

  return (
    <div className="mx-auto max-w-5xl px-4 py-6 sm:px-6">
      <div className="mb-4">
        <Link
          href={`/${locale}/deals/${dealId}`}
          className="text-sm text-muted-foreground hover:text-foreground"
        >
          &larr; {deal.name}
        </Link>
      </div>

      <DealTimeSummary dealName={deal.name} summary={summary} />
    </div>
  );
}

import { auth } from "@/lib/auth";
import { redirect, notFound } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { getLocale, getTranslations } from "next-intl/server";
import Link from "next/link";
import { ChevronLeft } from "lucide-react";
import { DecisionList } from "@/components/decisions/decision-list";
import { DecisionForm } from "@/components/decisions/decision-form";

export default async function DecisionsPage({
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
    select: {
      id: true,
      name: true,
      members: { select: { userId: true } },
      workstreams: {
        orderBy: { sortOrder: "asc" },
        select: { id: true, name: true },
      },
      decisions: {
        orderBy: { createdAt: "desc" },
        include: {
          workstream: { select: { id: true, name: true } },
          options: { orderBy: { sortOrder: "asc" } },
          linkedTasks: {
            include: {
              task: { select: { id: true, title: true, status: true } },
            },
          },
        },
      },
    },
  });

  if (!deal) {
    notFound();
  }

  const isMember = deal.members.some((m: { userId: string }) => m.userId === session.user?.id);
  if (!isMember) notFound();

  const t = await getTranslations("decision");

  const decisionsData = deal.decisions.map((d) => ({
    ...d,
    createdAt: new Date(d.createdAt),
  }));

  const workstreamOptions = deal.workstreams.map((ws) => ({
    id: ws.id,
    name: ws.name,
  }));

  return (
    <div className="mx-auto max-w-5xl px-4 py-6 sm:px-6">
      <div className="mb-4 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Link
            href={`/${locale}/deals/${dealId}`}
            className="text-muted-foreground hover:text-foreground"
          >
            <ChevronLeft className="size-4" />
          </Link>
          <h1 className="text-lg font-semibold">
            {deal.name} &mdash; {t("decisions")}
          </h1>
        </div>
        <DecisionForm
          dealId={dealId}
          workstreams={workstreamOptions}
          trigger={
            <button className="rounded-md bg-primary px-3 py-1.5 text-sm font-medium text-primary-foreground hover:bg-primary/90">
              + {t("newDecision")}
            </button>
          }
        />
      </div>

      <DecisionList decisions={decisionsData} dealId={dealId} />
    </div>
  );
}

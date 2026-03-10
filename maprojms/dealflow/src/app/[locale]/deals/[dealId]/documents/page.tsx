import { auth } from "@/lib/auth";
import { redirect, notFound } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { getLocale, getTranslations } from "next-intl/server";
import Link from "next/link";
import { ChevronLeft } from "lucide-react";
import { DocumentList } from "@/components/documents/document-list";
import { DocumentUpload } from "@/components/documents/document-upload";

export default async function DocumentsPage({
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
        select: {
          id: true,
          name: true,
          tasks: {
            orderBy: { sortOrder: "asc" },
            select: { id: true, title: true },
          },
        },
      },
      documents: {
        orderBy: { createdAt: "desc" },
        include: {
          workstream: { select: { name: true } },
          uploadedBy: { select: { name: true } },
        },
      },
    },
  });

  if (!deal) {
    notFound();
  }

  const isMember = deal.members.some((m: { userId: string }) => m.userId === session.user?.id);
  if (!isMember) notFound();

  const t = await getTranslations("document");

  const documentsData = deal.documents.map((d) => ({
    id: d.id,
    name: d.name,
    workstream: d.workstream,
    uploadedBy: d.uploadedBy,
    createdAt: new Date(d.createdAt),
  }));

  const workstreamOptions = deal.workstreams.map((ws) => ({
    id: ws.id,
    name: ws.name,
  }));

  const allTasks = deal.workstreams.flatMap((ws) =>
    ws.tasks.map((t) => ({ id: t.id, title: t.title }))
  );

  return (
    <div className="mx-auto max-w-5xl px-4 py-6 sm:px-6">
      <div className="mb-4 flex items-center gap-2">
        <Link
          href={`/${locale}/deals/${dealId}`}
          className="text-muted-foreground hover:text-foreground"
        >
          <ChevronLeft className="size-4" />
        </Link>
        <h1 className="text-lg font-semibold">
          {deal.name} &mdash; {t("documents")}
        </h1>
      </div>

      <DocumentUpload
        dealId={dealId}
        workstreams={workstreamOptions}
        tasks={allTasks}
      />

      <div className="mt-4">
        <DocumentList documents={documentsData} />
      </div>
    </div>
  );
}

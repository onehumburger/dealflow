import { auth } from "@/lib/auth";
import { redirect, notFound } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { getLocale, getTranslations } from "next-intl/server";
import Link from "next/link";
import { ChevronLeft } from "lucide-react";
import { DocumentUpload } from "@/components/documents/document-upload";
import { DealDocumentsContent } from "./deal-documents-content";
import type { DocumentItem } from "@/components/documents/document-hub";

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
          deal: { select: { id: true, name: true } },
          workstream: { select: { id: true, name: true } },
          task: { select: { id: true, title: true } },
          uploadedBy: { select: { id: true, name: true } },
        },
      },
    },
  });

  if (!deal) {
    notFound();
  }

  const isMember = deal.members.some(
    (m: { userId: string }) => m.userId === session.user?.id
  );
  if (!isMember) notFound();

  const t = await getTranslations("document");

  // Serialize documents to DocumentItem[] with ISO date strings
  const documentsData: DocumentItem[] = deal.documents.map((d) => ({
    id: d.id,
    name: d.name,
    fileType: d.fileType,
    fileSize: d.fileSize,
    currentVersion: d.currentVersion,
    createdAt: d.createdAt.toISOString(),
    updatedAt: d.updatedAt.toISOString(),
    deal: d.deal,
    workstream: d.workstream,
    task: d.task,
    uploadedBy: d.uploadedBy,
  }));

  const workstreamOptions = deal.workstreams.map((ws) => ({
    id: ws.id,
    name: ws.name,
  }));

  const allTasks = deal.workstreams.flatMap((ws) =>
    ws.tasks.map((t) => ({ id: t.id, title: t.title }))
  );

  // Build workstream ordering map for grouping
  const workstreamOrder = deal.workstreams.map((ws) => ({
    id: ws.id,
    name: ws.name,
    tasks: ws.tasks.map((t) => ({ id: t.id, title: t.title })),
  }));

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

      <div className="mt-6">
        <DealDocumentsContent
          dealId={dealId}
          documents={documentsData}
          workstreams={workstreamOrder}
        />
      </div>
    </div>
  );
}

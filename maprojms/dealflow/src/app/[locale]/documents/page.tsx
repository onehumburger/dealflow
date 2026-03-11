import { auth } from "@/lib/auth";
import { redirect } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { getLocale, getTranslations } from "next-intl/server";
import { DocumentHub } from "@/components/documents/document-hub";

export default async function DocumentsHubPage() {
  const session = await auth();
  const locale = await getLocale();

  if (!session?.user?.id) {
    redirect(`/${locale}/login`);
  }

  // Get all deals the user is a member of
  const memberships = await prisma.dealMember.findMany({
    where: { userId: session.user.id },
    select: { dealId: true },
  });

  const dealIds = memberships.map((m) => m.dealId);

  // Fetch all documents across those deals
  const documents = await prisma.document.findMany({
    where: { dealId: { in: dealIds } },
    orderBy: { updatedAt: "desc" },
    include: {
      deal: { select: { id: true, name: true } },
      workstream: { select: { id: true, name: true } },
      task: { select: { id: true, title: true } },
      uploadedBy: { select: { id: true, name: true } },
    },
  });

  // Fetch deals with workstreams and members for filter options
  const deals = await prisma.deal.findMany({
    where: { id: { in: dealIds } },
    orderBy: { name: "asc" },
    select: {
      id: true,
      name: true,
      workstreams: {
        orderBy: { sortOrder: "asc" },
        select: { id: true, name: true },
      },
      members: {
        include: { user: { select: { id: true, name: true } } },
      },
    },
  });

  const t = await getTranslations("document");

  // Serialize dates to ISO strings for client components
  const documentsData = documents.map((doc) => ({
    id: doc.id,
    name: doc.name,
    fileType: doc.fileType,
    fileSize: doc.fileSize,
    currentVersion: doc.currentVersion,
    createdAt: doc.createdAt.toISOString(),
    updatedAt: doc.updatedAt.toISOString(),
    deal: doc.deal,
    workstream: doc.workstream,
    task: doc.task,
    uploadedBy: doc.uploadedBy,
  }));

  const dealsData = deals.map((deal) => ({
    id: deal.id,
    name: deal.name,
    workstreams: deal.workstreams,
    members: deal.members.map((m) => ({
      id: m.user.id,
      name: m.user.name,
    })),
  }));

  return (
    <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6">
      <h1 className="mb-6 text-lg font-semibold">{t("documents")}</h1>
      <DocumentHub documents={documentsData} deals={dealsData} />
    </div>
  );
}

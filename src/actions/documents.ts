"use server";

import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { assertDealMember, revalidateDeal } from "@/actions/_helpers";
import { writeFile, unlink, mkdir } from "fs/promises";
import { join } from "path";
import { randomUUID } from "crypto";

const UPLOAD_DIR = join(process.cwd(), "storage", "uploads");

async function ensureUploadDir() {
  await mkdir(UPLOAD_DIR, { recursive: true });
}

// ---------- uploadDocument ----------

export async function uploadDocument(formData: FormData) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const dealId = formData.get("dealId") as string;
  const file = formData.get("file") as File;
  const workstreamId = (formData.get("workstreamId") as string) || null;
  const taskId = (formData.get("taskId") as string) || null;

  if (!dealId || !file || !(file instanceof File)) {
    throw new Error("Missing required fields");
  }

  const MAX_FILE_SIZE = 50 * 1024 * 1024; // 50 MB
  if (file.size > MAX_FILE_SIZE) throw new Error("File too large (max 50 MB)");

  await assertDealMember(dealId, session.user.id);

  // Write file to storage/uploads/
  await ensureUploadDir();

  const ext = file.name.includes(".")
    ? "." + file.name.split(".").pop()
    : "";
  const storedName = `${randomUUID()}${ext}`;
  const filePath = join(UPLOAD_DIR, storedName);

  const bytes = await file.arrayBuffer();
  await writeFile(filePath, Buffer.from(bytes));

  const document = await prisma.document.create({
    data: {
      name: file.name,
      filePath: storedName,
      dealId,
      workstreamId: workstreamId || null,
      taskId: taskId || null,
      uploadedById: session.user.id,
    },
  });

  // Auto-create activity entry
  await prisma.activityEntry.create({
    data: {
      type: "DocumentUpload",
      content: `Document uploaded: ${file.name}`,
      dealId,
      authorId: session.user.id,
    },
  });

  await revalidateDeal(dealId, `/deals/${dealId}/documents`);
  return document;
}

// ---------- deleteDocument ----------

export async function deleteDocument(documentId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const document = await prisma.document.findUnique({
    where: { id: documentId },
    select: { name: true, filePath: true, dealId: true },
  });
  if (!document) throw new Error("Document not found");

  await assertDealMember(document.dealId, session.user.id);

  // Delete file from disk
  try {
    const fullPath = join(UPLOAD_DIR, document.filePath);
    await unlink(fullPath);
  } catch {
    // File may already be removed, continue with DB cleanup
  }

  await prisma.document.delete({ where: { id: documentId } });

  await prisma.activityEntry.create({
    data: {
      type: "Note",
      content: `Document "${document.name}" deleted`,
      dealId: document.dealId,
      authorId: session.user.id,
    },
  });

  await revalidateDeal(
    document.dealId,
    `/deals/${document.dealId}/documents`
  );
}

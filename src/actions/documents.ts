"use server";

import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { assertDealMember, revalidateDeal } from "@/actions/_helpers";
import { writeFile, unlink, mkdir, rm } from "fs/promises";
import { join } from "path";

const UPLOAD_DIR = join(process.cwd(), "storage", "uploads");

async function ensureDir(dir: string) {
  await mkdir(dir, { recursive: true });
}

function getFileExtension(filename: string): string {
  return filename.includes(".") ? "." + filename.split(".").pop() : "";
}

function getFileType(filename: string): string {
  const ext = filename.split(".").pop()?.toLowerCase() || "";
  const mimeTypes: Record<string, string> = {
    pdf: "application/pdf",
    doc: "application/msword",
    docx: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    xls: "application/vnd.ms-excel",
    xlsx: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    ppt: "application/vnd.ms-powerpoint",
    pptx: "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    png: "image/png",
    jpg: "image/jpeg",
    jpeg: "image/jpeg",
    gif: "image/gif",
    txt: "text/plain",
    csv: "text/csv",
    zip: "application/zip",
    rar: "application/x-rar-compressed",
    rtf: "application/rtf",
  };
  return mimeTypes[ext] || "application/octet-stream";
}

// ---------- checkDuplicateName ----------

export async function checkDuplicateName(
  name: string,
  dealId: string,
  taskId: string | null
) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  await assertDealMember(dealId, session.user.id);

  const existing = await prisma.document.findFirst({
    where: {
      name,
      dealId,
      taskId: taskId ?? null,
    },
    select: { id: true, currentVersion: true },
  });
  return existing;
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

  const ext = getFileExtension(file.name);
  const fileType = getFileType(file.name);
  const bytes = await file.arrayBuffer();
  const buffer = Buffer.from(bytes);

  // Create document record first to get the ID
  const document = await prisma.document.create({
    data: {
      name: file.name,
      fileType,
      fileSize: file.size,
      storagePath: "", // placeholder, updated below
      currentVersion: 1,
      dealId,
      workstreamId: workstreamId || null,
      taskId: taskId || null,
      uploadedById: session.user.id,
    },
  });

  // Write file with new path convention
  const docDir = join(UPLOAD_DIR, dealId, document.id);
  await ensureDir(docDir);
  const storagePath = `${dealId}/${document.id}/v1${ext}`;
  await writeFile(join(UPLOAD_DIR, storagePath), buffer);

  // Update storagePath
  await prisma.document.update({
    where: { id: document.id },
    data: { storagePath },
  });

  // Activity log
  await prisma.activityEntry.create({
    data: {
      type: "DocumentUpload",
      content: `Document uploaded: ${file.name}`,
      dealId,
      authorId: session.user.id,
    },
  });

  await revalidateDeal(dealId, `/deals/${dealId}/documents`);
  return { ...document, storagePath };
}

// ---------- uploadNewVersion ----------

export async function uploadNewVersion(formData: FormData) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const documentId = formData.get("documentId") as string;
  const file = formData.get("file") as File;
  const note = (formData.get("note") as string) || null;

  if (!documentId || !file || !(file instanceof File)) {
    throw new Error("Missing required fields");
  }

  const MAX_FILE_SIZE = 50 * 1024 * 1024;
  if (file.size > MAX_FILE_SIZE) throw new Error("File too large (max 50 MB)");

  const existing = await prisma.document.findUnique({
    where: { id: documentId },
    select: {
      id: true, name: true, fileType: true, fileSize: true,
      storagePath: true, currentVersion: true, dealId: true,
      uploadedById: true,
    },
  });
  if (!existing) throw new Error("Document not found");

  await assertDealMember(existing.dealId, session.user.id);

  const newVersion = existing.currentVersion + 1;
  const ext = getFileExtension(file.name);
  const fileType = getFileType(file.name);

  // Save current version to DocumentVersion
  await prisma.documentVersion.create({
    data: {
      documentId: existing.id,
      versionNumber: existing.currentVersion,
      name: existing.name,
      fileType: existing.fileType,
      fileSize: existing.fileSize,
      storagePath: existing.storagePath,
      uploadedById: existing.uploadedById,
    },
  });

  // Write new file
  const storagePath = `${existing.dealId}/${existing.id}/v${newVersion}${ext}`;
  const docDir = join(UPLOAD_DIR, existing.dealId, existing.id);
  await ensureDir(docDir);
  const bytes = await file.arrayBuffer();
  await writeFile(join(UPLOAD_DIR, storagePath), Buffer.from(bytes));

  // Update document to new version
  await prisma.document.update({
    where: { id: documentId },
    data: {
      name: file.name,
      fileType,
      fileSize: file.size,
      storagePath,
      currentVersion: newVersion,
      uploadedById: session.user.id,
    },
  });

  // Activity log
  await prisma.activityEntry.create({
    data: {
      type: "DocumentVersionUpload",
      content: `New version uploaded: ${file.name} v${newVersion}${note ? ` — ${note}` : ""}`,
      dealId: existing.dealId,
      authorId: session.user.id,
    },
  });

  await revalidateDeal(existing.dealId, `/deals/${existing.dealId}/documents`);
}

// ---------- restoreVersion ----------

export async function restoreVersion(documentId: string, versionNumber: number) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const document = await prisma.document.findUnique({
    where: { id: documentId },
    select: {
      id: true, name: true, fileType: true, fileSize: true,
      storagePath: true, currentVersion: true, dealId: true,
      uploadedById: true,
    },
  });
  if (!document) throw new Error("Document not found");

  await assertDealMember(document.dealId, session.user.id);

  const targetVersion = await prisma.documentVersion.findFirst({
    where: { documentId, versionNumber },
  });
  if (!targetVersion) throw new Error("Version not found");

  const newVersionNum = document.currentVersion + 1;

  // Save current as a version
  await prisma.documentVersion.create({
    data: {
      documentId: document.id,
      versionNumber: document.currentVersion,
      name: document.name,
      fileType: document.fileType,
      fileSize: document.fileSize,
      storagePath: document.storagePath,
      uploadedById: document.uploadedById,
    },
  });

  // Restore: update document with the target version's data
  await prisma.document.update({
    where: { id: documentId },
    data: {
      name: targetVersion.name,
      fileType: targetVersion.fileType,
      fileSize: targetVersion.fileSize,
      storagePath: targetVersion.storagePath,
      currentVersion: newVersionNum,
      uploadedById: session.user.id,
    },
  });

  // Activity log
  await prisma.activityEntry.create({
    data: {
      type: "DocumentRestore",
      content: `Restored ${targetVersion.name} from v${versionNumber} (now v${newVersionNum})`,
      dealId: document.dealId,
      authorId: session.user.id,
    },
  });

  await revalidateDeal(document.dealId, `/deals/${document.dealId}/documents`);
}

// ---------- getVersionHistory ----------

export async function getVersionHistory(documentId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const document = await prisma.document.findUnique({
    where: { id: documentId },
    select: { dealId: true },
  });
  if (!document) throw new Error("Document not found");

  await assertDealMember(document.dealId, session.user.id);

  return prisma.documentVersion.findMany({
    where: { documentId },
    orderBy: { versionNumber: "desc" },
    include: { uploadedBy: { select: { name: true } } },
  });
}

// ---------- getTaskDocuments ----------

export async function getTaskDocuments(taskId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const task = await prisma.task.findUnique({
    where: { id: taskId },
    select: { workstream: { select: { dealId: true } } },
  });
  if (!task) throw new Error("Task not found");

  await assertDealMember(task.workstream.dealId, session.user.id);

  return prisma.document.findMany({
    where: { taskId },
    orderBy: { updatedAt: "desc" },
    include: {
      uploadedBy: { select: { name: true } },
    },
  });
}

// ---------- deleteDocument ----------

export async function deleteDocument(documentId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error("Unauthorized");

  const document = await prisma.document.findUnique({
    where: { id: documentId },
    select: { name: true, storagePath: true, dealId: true, uploadedById: true },
  });
  if (!document) throw new Error("Document not found");

  await assertDealMember(document.dealId, session.user.id);

  // Check permission: only uploader or admin
  const user = await prisma.user.findUnique({
    where: { id: session.user.id },
    select: { role: true },
  });
  if (document.uploadedById !== session.user.id && user?.role !== "Admin") {
    throw new Error("Only the uploader or an admin can delete documents");
  }

  // Delete all version files and directory
  const docDir = join(UPLOAD_DIR, document.dealId, documentId);
  try {
    await rm(docDir, { recursive: true, force: true });
  } catch {
    // Directory may not exist (legacy flat-path files)
  }

  // Also try deleting legacy flat file
  if (!document.storagePath.includes("/")) {
    try {
      await unlink(join(UPLOAD_DIR, document.storagePath));
    } catch {
      // File may already be removed
    }
  }

  // Cascade: DocumentVersion rows deleted automatically via onDelete: Cascade
  await prisma.document.delete({ where: { id: documentId } });

  await prisma.activityEntry.create({
    data: {
      type: "DocumentDelete",
      content: `Document deleted: ${document.name}`,
      dealId: document.dealId,
      authorId: session.user.id,
    },
  });

  await revalidateDeal(document.dealId, `/deals/${document.dealId}/documents`);
}

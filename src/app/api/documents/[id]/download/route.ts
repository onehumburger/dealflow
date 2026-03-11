import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { NextRequest, NextResponse } from "next/server";
import { readFile } from "fs/promises";
import { join } from "path";

const UPLOAD_DIR = join(process.cwd(), "storage", "uploads");

const contentTypes: Record<string, string> = {
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

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const session = await auth();
  if (!session?.user?.id) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const { id } = await params;
  const versionParam = request.nextUrl.searchParams.get("version");

  const document = await prisma.document.findUnique({
    where: { id },
    select: {
      name: true,
      storagePath: true,
      dealId: true,
      fileType: true,
    },
  });

  if (!document) {
    return NextResponse.json({ error: "Not found" }, { status: 404 });
  }

  // Check user is a member of the deal
  const membership = await prisma.dealMember.findUnique({
    where: {
      dealId_userId: { dealId: document.dealId, userId: session.user.id },
    },
  });

  if (!membership) {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }

  // Determine which file to serve
  let filePath: string;
  let fileName: string;

  if (versionParam) {
    const version = await prisma.documentVersion.findFirst({
      where: { documentId: id, versionNumber: parseInt(versionParam, 10) },
      select: { storagePath: true, name: true },
    });
    if (!version) {
      return NextResponse.json({ error: "Version not found" }, { status: 404 });
    }
    filePath = version.storagePath;
    fileName = version.name;
  } else {
    filePath = document.storagePath;
    fileName = document.name;
  }

  try {
    const fullPath = join(UPLOAD_DIR, filePath);
    if (!fullPath.startsWith(UPLOAD_DIR)) {
      return NextResponse.json({ error: "Invalid file path" }, { status: 400 });
    }
    const fileBuffer = await readFile(fullPath);

    const ext = fileName.split(".").pop()?.toLowerCase() || "";
    const contentType = contentTypes[ext] || "application/octet-stream";

    // For preview mode (PDF/images), use inline disposition
    const previewParam = request.nextUrl.searchParams.get("preview");
    const isPreviewable = ["pdf", "png", "jpg", "jpeg", "gif"].includes(ext);
    const disposition = previewParam && isPreviewable ? "inline" : "attachment";

    return new NextResponse(fileBuffer, {
      headers: {
        "Content-Type": contentType,
        "Content-Disposition": `${disposition}; filename="${encodeURIComponent(fileName)}"`,
      },
    });
  } catch {
    return NextResponse.json(
      { error: "File not found on disk" },
      { status: 404 }
    );
  }
}

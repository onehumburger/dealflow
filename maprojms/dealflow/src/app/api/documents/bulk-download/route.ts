import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { NextRequest, NextResponse } from "next/server";
import { createReadStream } from "fs";
import { join } from "path";
import { stat } from "fs/promises";
import archiver from "archiver";
import { PassThrough } from "stream";

const UPLOAD_DIR = join(process.cwd(), "storage", "uploads");

/** Remove characters unsafe for folder/file names */
function sanitize(name: string): string {
  return name.replace(/[/\\:*?"<>|]/g, "_").trim() || "_";
}

export async function GET(request: NextRequest) {
  const session = await auth();
  if (!session?.user?.id) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const { searchParams } = request.nextUrl;
  const dealId = searchParams.get("dealId");
  const workstreamId = searchParams.get("workstreamId");
  const taskId = searchParams.get("taskId");

  if (!dealId) {
    return NextResponse.json({ error: "dealId required" }, { status: 400 });
  }

  // Verify deal membership
  const membership = await prisma.dealMember.findUnique({
    where: {
      dealId_userId: { dealId, userId: session.user.id },
    },
  });
  if (!membership) {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }

  // Build filter
  const where: Record<string, unknown> = { dealId };
  if (taskId) {
    where.taskId = taskId;
  } else if (workstreamId) {
    where.workstreamId = workstreamId;
  }

  // Query documents with all versions
  const documents = await prisma.document.findMany({
    where,
    include: {
      deal: { select: { name: true } },
      workstream: { select: { name: true } },
      task: { select: { title: true } },
      versions: {
        orderBy: { versionNumber: "asc" },
        select: {
          versionNumber: true,
          storagePath: true,
          fileType: true,
        },
      },
    },
  });

  if (documents.length === 0) {
    return NextResponse.json({ error: "No documents found" }, { status: 404 });
  }

  // Determine ZIP root name
  let zipName: string;
  if (taskId) {
    zipName = sanitize(documents[0].task?.title ?? "task");
  } else if (workstreamId) {
    zipName = sanitize(documents[0].workstream?.name ?? "workstream");
  } else {
    zipName = sanitize(documents[0].deal.name);
  }

  // Create archive
  const archive = archiver("zip", { zlib: { level: 5 } });
  const passthrough = new PassThrough();
  archive.pipe(passthrough);

  // Add files to archive
  for (const doc of documents) {
    const docName = sanitize(doc.name);

    // Build folder path based on hierarchy
    const parts: string[] = [];

    if (!taskId && !workstreamId) {
      // Deal-level download: include full hierarchy
      parts.push(zipName);
      if (doc.workstream) {
        parts.push(sanitize(doc.workstream.name));
        if (doc.task) {
          parts.push(sanitize(doc.task.title));
        }
      }
    } else if (workstreamId && !taskId) {
      // Workstream-level download
      parts.push(zipName);
      if (doc.task) {
        parts.push(sanitize(doc.task.title));
      }
    } else {
      // Task-level download
      parts.push(zipName);
    }

    parts.push(docName);
    const folderPath = parts.join("/");

    for (const v of doc.versions) {
      const fullPath = join(UPLOAD_DIR, v.storagePath);

      // Validate path to prevent traversal
      if (!fullPath.startsWith(UPLOAD_DIR)) continue;

      // Check file exists
      try {
        await stat(fullPath);
      } catch {
        continue; // Skip missing files
      }

      const fileName = `v${v.versionNumber}.${v.fileType}`;
      archive.append(createReadStream(fullPath), {
        name: `${folderPath}/${fileName}`,
      });
    }
  }

  archive.finalize();

  // Convert PassThrough to ReadableStream for NextResponse
  const readable = new ReadableStream({
    start(controller) {
      passthrough.on("data", (chunk: Buffer) => {
        controller.enqueue(new Uint8Array(chunk));
      });
      passthrough.on("end", () => {
        controller.close();
      });
      passthrough.on("error", (err) => {
        controller.error(err);
      });
    },
  });

  const encodedName = encodeURIComponent(`${zipName}.zip`);

  return new NextResponse(readable, {
    headers: {
      "Content-Type": "application/zip",
      "Content-Disposition": `attachment; filename="${encodedName}"`,
    },
  });
}

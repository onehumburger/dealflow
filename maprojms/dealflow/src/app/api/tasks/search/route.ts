import { auth } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { NextRequest, NextResponse } from "next/server";

export async function GET(request: NextRequest) {
  const session = await auth();
  if (!session?.user?.id) {
    return NextResponse.json([], { status: 401 });
  }

  const { searchParams } = request.nextUrl;
  const dealId = searchParams.get("dealId");
  const q = searchParams.get("q") || "";
  const exclude = searchParams.get("exclude") || "";

  if (!dealId) {
    return NextResponse.json([]);
  }

  const membership = await prisma.dealMember.findUnique({
    where: { dealId_userId: { dealId, userId: session.user.id } },
  });
  if (!membership) {
    return NextResponse.json([], { status: 403 });
  }

  const tasks = await prisma.task.findMany({
    where: {
      workstream: { dealId },
      title: { contains: q, mode: "insensitive" },
      id: { not: exclude },
    },
    select: { id: true, title: true },
    take: 10,
  });

  return NextResponse.json(tasks);
}

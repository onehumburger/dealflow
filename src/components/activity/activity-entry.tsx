"use client";

import { useLocale, useTranslations } from "next-intl";
import { cn } from "@/lib/utils";
import type { ActivityType } from "@/generated/prisma/client";

interface ActivityEntryProps {
  entry: {
    id: string;
    type: ActivityType;
    content: string;
    createdAt: Date;
    author: { name: string };
  };
}

const typeStyles: Record<ActivityType, string> = {
  Note: "bg-blue-100 text-blue-700",
  Call: "bg-green-100 text-green-700",
  Meeting: "bg-purple-100 text-purple-700",
  ClientInstruction: "bg-amber-100 text-amber-700",
  TaskUpdate: "bg-gray-100 text-gray-700",
  MilestoneChange: "bg-emerald-100 text-emerald-700",
  DecisionCreated: "bg-rose-100 text-rose-700",
  DocumentUpload: "bg-sky-100 text-sky-700",
  DocumentVersionUpload: "bg-sky-100 text-sky-700",
  DocumentRestore: "bg-teal-100 text-teal-700",
  DocumentDelete: "bg-red-100 text-red-700",
};

const typeToTranslationKey: Record<ActivityType, string> = {
  Note: "note",
  Call: "call",
  Meeting: "meeting",
  ClientInstruction: "clientInstruction",
  TaskUpdate: "taskUpdate",
  MilestoneChange: "milestoneChange",
  DecisionCreated: "decisionCreated",
  DocumentUpload: "documentUpload",
  DocumentVersionUpload: "documentVersionUpload",
  DocumentRestore: "documentRestore",
  DocumentDelete: "documentDelete",
};

function formatTimestamp(date: Date, locale: string): string {
  return new Intl.DateTimeFormat(locale, {
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  }).format(date);
}

export function ActivityEntryItem({ entry }: ActivityEntryProps) {
  const locale = useLocale();
  const t = useTranslations("activity");
  const labelKey = typeToTranslationKey[entry.type];

  return (
    <div className="flex gap-3 py-2">
      <span
        className={cn(
          "mt-0.5 inline-flex h-5 shrink-0 items-center rounded px-1.5 text-xs font-medium uppercase",
          typeStyles[entry.type] || "bg-gray-100 text-gray-600"
        )}
      >
        {t(labelKey as Parameters<typeof t>[0])}
      </span>
      <div className="flex-1 min-w-0">
        <p className="text-sm">{entry.content}</p>
        <p className="mt-0.5 text-xs text-muted-foreground">
          {entry.author.name} &middot; {formatTimestamp(entry.createdAt, locale)}
        </p>
      </div>
    </div>
  );
}

"use client";

import { useState } from "react";
import Link from "next/link";
import { cn } from "@/lib/utils";
import type { ActivityType } from "@/generated/prisma/client";

interface ActivityItem {
  id: string;
  type: ActivityType;
  content: string;
  createdAt: Date;
  authorName: string;
  dealId: string;
  dealName: string;
}

interface RecentActivityWidgetProps {
  entries: ActivityItem[];
  locale: string;
  translations: {
    recentActivity: string;
    noResults: string;
    showTaskUpdates: string;
    hideTaskUpdates: string;
  };
  activityTranslations: {
    note: string;
    call: string;
    meeting: string;
    clientInstruction: string;
    taskUpdate: string;
    milestoneChange: string;
    decisionCreated: string;
    documentUpload: string;
    documentVersionUpload: string;
    documentRestore: string;
    documentDelete: string;
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

const typeToKey: Record<ActivityType, keyof RecentActivityWidgetProps["activityTranslations"]> = {
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

export function RecentActivityWidget({
  entries,
  locale,
  translations,
  activityTranslations,
}: RecentActivityWidgetProps) {
  const [hideTaskUpdates, setHideTaskUpdates] = useState(true);

  const filtered = hideTaskUpdates
    ? entries.filter((e) => e.type !== "TaskUpdate")
    : entries;

  return (
    <div className="rounded-lg border bg-card">
      <div className="flex items-center justify-between border-b px-4 py-3">
        <h3 className="text-base font-semibold">{translations.recentActivity}</h3>
        <button
          onClick={() => setHideTaskUpdates(!hideTaskUpdates)}
          className="rounded-md border border-dashed px-2 py-1 text-xs text-muted-foreground hover:bg-muted/50"
        >
          {hideTaskUpdates ? translations.showTaskUpdates : translations.hideTaskUpdates}
        </button>
      </div>
      <div className="divide-y max-h-[400px] overflow-y-auto">
        {filtered.length === 0 ? (
          <p className="px-4 py-6 text-center text-sm text-muted-foreground">
            {translations.noResults}
          </p>
        ) : (
          filtered.map((entry) => (
            <Link
              key={entry.id}
              href={`/${locale}/deals/${entry.dealId}`}
              className="flex gap-3 px-4 py-2.5 hover:bg-muted/50 transition-colors"
            >
              <span
                className={cn(
                  "mt-0.5 inline-flex h-5 shrink-0 items-center rounded px-1.5 text-xs font-medium",
                  typeStyles[entry.type] || "bg-gray-100 text-gray-600"
                )}
              >
                {activityTranslations[typeToKey[entry.type]]}
              </span>
              <div className="min-w-0 flex-1">
                <p className="text-sm truncate">{entry.content}</p>
                <p className="mt-0.5 text-xs text-muted-foreground">
                  {entry.dealName} &middot; {entry.authorName} &middot;{" "}
                  {formatTimestamp(entry.createdAt, locale)}
                </p>
              </div>
            </Link>
          ))
        )}
      </div>
    </div>
  );
}

"use client";

import { useState, useTransition } from "react";
import { useLocale, useTranslations } from "next-intl";
import { cn } from "@/lib/utils";
import { Pencil, Trash2, Check, X } from "lucide-react";
import { Textarea } from "@/components/ui/textarea";
import {
  updateActivityEntry,
  deleteActivityEntry,
} from "@/actions/activity";
import type { ActivityType } from "@/generated/prisma/client";

const MANUAL_TYPES: ActivityType[] = ["Note", "Call", "Meeting", "ClientInstruction"];

interface ActivityEntryProps {
  entry: {
    id: string;
    type: ActivityType;
    content: string;
    createdAt: Date;
    authorId: string;
    author: { name: string };
    workstreamName: string | null;
  };
  currentUserId: string;
  isAdmin: boolean;
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

export function ActivityEntryItem({
  entry,
  currentUserId,
  isAdmin,
}: ActivityEntryProps) {
  const locale = useLocale();
  const t = useTranslations("activity");
  const tCommon = useTranslations("common");
  const [isPending, startTransition] = useTransition();
  const [editing, setEditing] = useState(false);
  const [editContent, setEditContent] = useState(entry.content);

  const labelKey = typeToTranslationKey[entry.type];
  const isManual = MANUAL_TYPES.includes(entry.type);
  const canEdit = isManual && (entry.authorId === currentUserId || isAdmin);

  function handleSave() {
    if (!editContent.trim()) return;
    startTransition(async () => {
      await updateActivityEntry(entry.id, { content: editContent });
      setEditing(false);
    });
  }

  function handleDelete() {
    if (!confirm(t("deleteEntryConfirm"))) return;
    startTransition(async () => {
      await deleteActivityEntry(entry.id);
    });
  }

  return (
    <div className="group flex gap-3 py-2">
      <span
        className={cn(
          "mt-0.5 inline-flex h-5 shrink-0 items-center rounded px-1.5 text-xs font-medium",
          typeStyles[entry.type] || "bg-gray-100 text-gray-600"
        )}
      >
        {t(labelKey as Parameters<typeof t>[0])}
      </span>
      <div className="flex-1 min-w-0">
        {editing ? (
          <div className="flex flex-col gap-1.5">
            <Textarea
              value={editContent}
              onChange={(e) => setEditContent(e.target.value)}
              className="min-h-12 text-sm"
              autoFocus
            />
            <div className="flex justify-end gap-1">
              <button
                type="button"
                onClick={() => {
                  setEditContent(entry.content);
                  setEditing(false);
                }}
                disabled={isPending}
                className="inline-flex items-center gap-1 rounded px-2 py-1 text-xs text-muted-foreground hover:bg-muted"
              >
                <X className="size-3" />
                {tCommon("cancel")}
              </button>
              <button
                type="button"
                onClick={handleSave}
                disabled={isPending || !editContent.trim()}
                className="inline-flex items-center gap-1 rounded bg-primary px-2 py-1 text-xs text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
              >
                <Check className="size-3" />
                {tCommon("save")}
              </button>
            </div>
          </div>
        ) : (
          <>
            <p className="text-sm">{entry.content}</p>
            <p className="mt-0.5 text-xs text-muted-foreground">
              {entry.author.name}
              {entry.workstreamName && (
                <> &middot; {entry.workstreamName}</>
              )}
              {" "}&middot; {formatTimestamp(entry.createdAt, locale)}
            </p>
          </>
        )}
      </div>
      {canEdit && !editing && (
        <div className="flex shrink-0 items-start gap-0.5 opacity-0 group-hover:opacity-100 transition-opacity">
          <button
            type="button"
            onClick={() => setEditing(true)}
            className="rounded p-1 text-muted-foreground hover:bg-muted hover:text-foreground"
            title={t("editEntry")}
          >
            <Pencil className="size-3" />
          </button>
          <button
            type="button"
            onClick={handleDelete}
            disabled={isPending}
            className="rounded p-1 text-muted-foreground hover:bg-destructive/10 hover:text-destructive"
            title={t("deleteEntry")}
          >
            <Trash2 className="size-3" />
          </button>
        </div>
      )}
    </div>
  );
}

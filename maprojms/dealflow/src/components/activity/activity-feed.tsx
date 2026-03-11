"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";
import { PanelRightClose, PanelRightOpen } from "lucide-react";
import { Button } from "@/components/ui/button";
import { ActivityEntryItem } from "./activity-entry";
import { ActivityForm } from "./activity-form";
import type { ActivityType } from "@/generated/prisma/client";

interface ActivityItem {
  id: string;
  type: ActivityType;
  content: string;
  createdAt: Date;
  author: { name: string };
}

interface WorkstreamOption {
  id: string;
  name: string;
}

interface ActivityFeedProps {
  entries: ActivityItem[];
  dealId: string;
  workstreams: WorkstreamOption[];
}

export function ActivityFeed({ entries, dealId, workstreams }: ActivityFeedProps) {
  const t = useTranslations("activity");
  const [collapsed, setCollapsed] = useState(false);
  const [showForm, setShowForm] = useState(false);
  const [hideTaskUpdates, setHideTaskUpdates] = useState(true);

  const filtered = hideTaskUpdates
    ? entries.filter((e) => e.type !== "TaskUpdate")
    : entries;

  return (
    <div className="flex flex-col">
      <div className="flex items-center justify-between pb-2">
        <Button
          variant="ghost"
          size="icon-sm"
          onClick={() => setCollapsed(!collapsed)}
        >
          {collapsed ? (
            <PanelRightOpen className="size-4" />
          ) : (
            <PanelRightClose className="size-4" />
          )}
        </Button>
        {!collapsed && (
          <div className="flex items-center gap-2">
            <button
              onClick={() => setHideTaskUpdates(!hideTaskUpdates)}
              className={`rounded-md border px-2 py-1 text-xs transition-colors ${
                hideTaskUpdates
                  ? "border-primary bg-primary/10 text-primary"
                  : "border-dashed text-muted-foreground hover:bg-muted/50"
              }`}
            >
              {hideTaskUpdates ? t("showTaskUpdates") : t("hideTaskUpdates")}
            </button>
            <button
              onClick={() => setShowForm(!showForm)}
              className="rounded-md border border-dashed px-2 py-1 text-xs text-muted-foreground hover:bg-muted/50"
            >
              + {t("addNote")}
            </button>
          </div>
        )}
      </div>

      {!collapsed && (
        <>
          {showForm && (
            <ActivityForm
              dealId={dealId}
              workstreams={workstreams}
              onClose={() => setShowForm(false)}
            />
          )}
          <div className="divide-y overflow-y-auto max-h-[600px]">
            {filtered.length === 0 && (
              <p className="py-4 text-center text-sm text-muted-foreground">
                --
              </p>
            )}
            {filtered.map((entry) => (
              <ActivityEntryItem key={entry.id} entry={entry} />
            ))}
          </div>
        </>
      )}
    </div>
  );
}

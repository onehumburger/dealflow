"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";
import { PanelRightClose, PanelRightOpen } from "lucide-react";
import { Button } from "@/components/ui/button";
import { ActivityEntryItem } from "./activity-entry";
import type { ActivityType } from "@/generated/prisma/client";

interface ActivityItem {
  id: string;
  type: ActivityType;
  content: string;
  createdAt: Date;
  author: { name: string };
}

interface ActivityFeedProps {
  entries: ActivityItem[];
}

export function ActivityFeed({ entries }: ActivityFeedProps) {
  const t = useTranslations("activity");
  const [collapsed, setCollapsed] = useState(false);

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
          <button className="rounded-md border border-dashed px-2 py-1 text-xs text-muted-foreground hover:bg-muted/50">
            + {t("addNote")}
          </button>
        )}
      </div>

      {!collapsed && (
        <div className="divide-y overflow-y-auto max-h-[600px]">
          {entries.length === 0 && (
            <p className="py-4 text-center text-sm text-muted-foreground">
              --
            </p>
          )}
          {entries.map((entry) => (
            <ActivityEntryItem key={entry.id} entry={entry} />
          ))}
        </div>
      )}
    </div>
  );
}

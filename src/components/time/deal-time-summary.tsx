"use client";

import { useTranslations } from "next-intl";

function formatHours(minutes: number): string {
  return (minutes / 60).toFixed(1) + "h";
}

interface WorkstreamSummary {
  id: string;
  name: string;
  totalMinutes: number;
  billableMinutes: number;
  tasks: {
    id: string;
    title: string;
    totalMinutes: number;
    billableMinutes: number;
  }[];
}

interface MemberSummary {
  userId: string;
  userName: string;
  totalMinutes: number;
  billableMinutes: number;
}

interface DealTimeSummaryProps {
  dealName: string;
  summary: {
    byWorkstream: WorkstreamSummary[];
    byMember: MemberSummary[];
    totalMinutes: number;
    billableMinutes: number;
  };
}

export function DealTimeSummary({ dealName, summary }: DealTimeSummaryProps) {
  const tBilling = useTranslations("billing");
  const tTimer = useTranslations("timer");

  return (
    <div className="flex flex-col gap-6">
      <h1 className="text-lg font-semibold">
        {dealName} — {tTimer("timeEntries")}
      </h1>

      {/* By Workstream */}
      <div className="rounded-lg border">
        <div className="flex items-center justify-between border-b px-4 py-2.5 text-sm font-medium">
          <span>{tBilling("byWorkstream")}</span>
          <div className="flex gap-6 text-muted-foreground">
            <span>{tBilling("totalHours")}</span>
            <span>{tBilling("billable")}</span>
          </div>
        </div>

        {summary.byWorkstream.map((ws) => (
          <div key={ws.id} className="border-b last:border-b-0">
            <div className="flex items-center justify-between px-4 py-2 bg-muted/30">
              <span className="text-sm font-medium">{ws.name}</span>
              <div className="flex gap-6 text-sm">
                <span className="w-16 text-right">{formatHours(ws.totalMinutes)}</span>
                <span className="w-16 text-right">{formatHours(ws.billableMinutes)}</span>
              </div>
            </div>

            {ws.tasks.map((task) => (
              <div key={task.id} className="flex items-center justify-between px-4 py-1.5 pl-8">
                <span className="text-sm text-muted-foreground">{task.title}</span>
                <div className="flex gap-6 text-sm text-muted-foreground">
                  <span className="w-16 text-right">{formatHours(task.totalMinutes)}</span>
                  <span className="w-16 text-right">{formatHours(task.billableMinutes)}</span>
                </div>
              </div>
            ))}
          </div>
        ))}

        {summary.byWorkstream.length === 0 && (
          <div className="px-4 py-3 text-sm text-muted-foreground">
            {tTimer("noEntries")}
          </div>
        )}
      </div>

      {/* By Member */}
      <div className="rounded-lg border">
        <div className="flex items-center justify-between border-b px-4 py-2.5 text-sm font-medium">
          <span>{tBilling("byMember")}</span>
          <div className="flex gap-6 text-muted-foreground">
            <span>{tBilling("totalHours")}</span>
            <span>{tBilling("billable")}</span>
          </div>
        </div>

        {summary.byMember.map((m) => (
          <div key={m.userId} className="flex items-center justify-between border-b last:border-b-0 px-4 py-2">
            <span className="text-sm">{m.userName}</span>
            <div className="flex gap-6 text-sm">
              <span className="w-16 text-right">{formatHours(m.totalMinutes)}</span>
              <span className="w-16 text-right">{formatHours(m.billableMinutes)}</span>
            </div>
          </div>
        ))}
      </div>

      {/* Total */}
      <div className="flex items-center justify-between rounded-lg border bg-muted/30 px-4 py-3 text-sm font-medium">
        <span>{tTimer("totalTime")}</span>
        <div className="flex gap-6">
          <span className="w-16 text-right">{formatHours(summary.totalMinutes)}</span>
          <span className="w-16 text-right">{formatHours(summary.billableMinutes)}</span>
        </div>
      </div>
    </div>
  );
}

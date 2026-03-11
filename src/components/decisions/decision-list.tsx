"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";
import { Badge } from "@/components/ui/badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { DecisionDetail } from "./decision-detail";
import type {
  DecisionSource,
  DecisionStatus,
} from "@/generated/prisma/client";

interface DecisionOption {
  id: string;
  description: string;
  prosAndCons: string | null;
  sortOrder: number;
}

interface LinkedTask {
  taskId: string;
  task: { id: string; title: string; status: string };
}

export interface DecisionItem {
  id: string;
  title: string;
  background: string | null;
  source: DecisionSource;
  analysis: string | null;
  clientDecision: string | null;
  status: DecisionStatus;
  workstreamId: string | null;
  workstream: { id: string; name: string } | null;
  options: DecisionOption[];
  linkedTasks: LinkedTask[];
  createdAt: Date;
}

interface DecisionListProps {
  decisions: DecisionItem[];
  dealId: string;
}

const STATUS_VARIANTS: Record<DecisionStatus, "default" | "secondary" | "outline"> = {
  PendingAnalysis: "outline",
  Reported: "secondary",
  Decided: "default",
  Implemented: "default",
};

export function DecisionList({ decisions, dealId }: DecisionListProps) {
  const t = useTranslations("decision");
  const [expandedId, setExpandedId] = useState<string | null>(null);

  const statusLabel = (s: DecisionStatus): string => {
    const map: Record<DecisionStatus, string> = {
      PendingAnalysis: t("pendingAnalysis"),
      Reported: t("reported"),
      Decided: t("decided"),
      Implemented: t("implemented"),
    };
    return map[s];
  };

  const sourceLabel = (s: DecisionSource): string => {
    const map: Record<DecisionSource, string> = {
      DDFinding: t("ddFinding"),
      Negotiation: t("negotiation"),
      Regulatory: t("regulatory"),
      Other: t("other"),
    };
    return map[s];
  };

  if (decisions.length === 0) {
    return (
      <p className="py-8 text-center text-sm text-muted-foreground">
        {t("noDecisions")}
      </p>
    );
  }

  return (
    <div>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>{t("title")}</TableHead>
            <TableHead>{t("source")}</TableHead>
            <TableHead>{t("status")}</TableHead>
            <TableHead>{t("workstream")}</TableHead>
            <TableHead>{t("date")}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {decisions.map((d) => (
            <TableRow
              key={d.id}
              className="cursor-pointer"
              onClick={() =>
                setExpandedId(expandedId === d.id ? null : d.id)
              }
            >
              <TableCell className="font-medium">{d.title}</TableCell>
              <TableCell>{sourceLabel(d.source)}</TableCell>
              <TableCell>
                <Badge variant={STATUS_VARIANTS[d.status]}>
                  {statusLabel(d.status)}
                </Badge>
              </TableCell>
              <TableCell className="text-muted-foreground">
                {d.workstream?.name ?? "\u2014"}
              </TableCell>
              <TableCell className="text-muted-foreground">
                {new Date(d.createdAt).toLocaleDateString()}
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>

      {expandedId && (
        <DecisionDetail
          decision={decisions.find((d) => d.id === expandedId)!}
          dealId={dealId}
          onClose={() => setExpandedId(null)}
        />
      )}
    </div>
  );
}

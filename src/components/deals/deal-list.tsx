import Link from "next/link";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { DealStatusBadge } from "./deal-status-badge";
import { DealPhaseBadge } from "./deal-phase-badge";
import type { DealStatus } from "@/generated/prisma/client";
import type { DealPhase } from "@/generated/prisma/client";

export interface DealListItem {
  id: string;
  name: string;
  codeName: string | null;
  clientName: string;
  targetCompany: string;
  status: DealStatus;
  dealLead: { name: string };
  phase: DealPhase;
  dealValue: number | null;
  valueCurrency: string;
  workstreams: {
    tasks: { status: string }[];
  }[];
}

interface DealListProps {
  deals: DealListItem[];
  locale: string;
  translations: {
    name: string;
    codeName: string;
    clientName: string;
    targetCompany: string;
    status: string;
    dealLead: string;
    tasks: string;
    phase: string;
    dealValue: string;
  };
}

export function DealList({ deals, locale, translations }: DealListProps) {
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>{translations.name}</TableHead>
          <TableHead>{translations.codeName}</TableHead>
          <TableHead>{translations.clientName}</TableHead>
          <TableHead>{translations.targetCompany}</TableHead>
          <TableHead>{translations.status}</TableHead>
          <TableHead>{translations.phase}</TableHead>
          <TableHead>{translations.dealValue}</TableHead>
          <TableHead>{translations.dealLead}</TableHead>
          <TableHead>{translations.tasks}</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {deals.map((deal) => {
          const allTasks = deal.workstreams.flatMap((ws) => ws.tasks);
          const doneTasks = allTasks.filter((t) => t.status === "Done").length;
          const totalTasks = allTasks.length;

          return (
            <TableRow key={deal.id}>
              <TableCell>
                <Link
                  href={`/${locale}/deals/${deal.id}`}
                  className="font-medium text-foreground hover:underline"
                >
                  {deal.name}
                </Link>
              </TableCell>
              <TableCell className="text-muted-foreground">
                {deal.codeName || "\u2014"}
              </TableCell>
              <TableCell>{deal.clientName}</TableCell>
              <TableCell>{deal.targetCompany}</TableCell>
              <TableCell>
                <DealStatusBadge status={deal.status} locale={locale} />
              </TableCell>
              <TableCell>
                <DealPhaseBadge phase={deal.phase} locale={locale} />
              </TableCell>
              <TableCell className="text-muted-foreground">
                {deal.dealValue !== null
                  ? `${deal.valueCurrency} ${deal.dealValue.toLocaleString(locale === "zh" ? "zh-CN" : "en-US", { minimumFractionDigits: 0, maximumFractionDigits: 2 })}`
                  : "\u2014"}
              </TableCell>
              <TableCell>{deal.dealLead.name}</TableCell>
              <TableCell className="text-muted-foreground">
                {totalTasks > 0 ? `${doneTasks}/${totalTasks}` : "\u2014"}
              </TableCell>
            </TableRow>
          );
        })}
      </TableBody>
    </Table>
  );
}

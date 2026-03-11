import { Badge } from "@/components/ui/badge";
import type { DealPhase } from "@/generated/prisma/client";

const phaseConfig: Record<DealPhase, { className: string }> = {
  Intake: { className: "bg-blue-100 text-blue-800" },
  DueDiligence: { className: "bg-indigo-100 text-indigo-800" },
  Negotiation: { className: "bg-purple-100 text-purple-800" },
  Signing: { className: "bg-pink-100 text-pink-800" },
  Closing: { className: "bg-amber-100 text-amber-800" },
  PostClosing: { className: "bg-gray-100 text-gray-800" },
};

const phaseLabels: Record<string, Record<DealPhase, string>> = {
  en: {
    Intake: "Intake",
    DueDiligence: "Due Diligence",
    Negotiation: "Negotiation",
    Signing: "Signing",
    Closing: "Closing",
    PostClosing: "Post-Closing",
  },
  zh: {
    Intake: "立项",
    DueDiligence: "尽调",
    Negotiation: "谈判",
    Signing: "签约",
    Closing: "交割",
    PostClosing: "结项",
  },
};

export function DealPhaseBadge({
  phase,
  locale = "zh",
}: {
  phase: DealPhase;
  locale?: string;
}) {
  const config = phaseConfig[phase];
  const labels = phaseLabels[locale] || phaseLabels.zh;
  return (
    <Badge variant="secondary" className={config.className}>
      {labels[phase]}
    </Badge>
  );
}

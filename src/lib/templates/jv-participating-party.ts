import { DealType, DealRole } from "@/generated/prisma/client";

export const jvParticipatingParty = {
  name: "Joint Venture — Participating Party",
  dealType: DealType.JV,
  ourRole: DealRole.ParticipatingParty,
  definition: {
    milestones: [
      { name: "MOU Signed", type: "Contractual" },
      { name: "DD Complete", type: "Internal" },
      { name: "JV Agreement Signed", type: "Contractual" },
      { name: "Incorporation", type: "Regulatory" },
      { name: "Operational Launch", type: "Internal" },
    ],
    workstreams: [
      {
        name: "Due Diligence",
        tasks: [
          "Review lead party's DD materials",
          "Independent verification where needed",
        ],
      },
      {
        name: "JV Agreement & Governance",
        tasks: [
          "Review lead party's draft JV agreement",
          "Negotiate protective provisions (veto rights, exit mechanisms)",
          "Shareholder agreement review",
        ],
      },
      {
        name: "Regulatory",
        tasks: [
          "Own regulatory filings",
          "Track lead party's filing progress",
        ],
      },
      {
        name: "Commercial & Structure",
        tasks: [
          "Review contribution terms and valuation",
          "Negotiate IP and operational arrangements",
        ],
      },
      {
        name: "Client Communication & Strategy",
        tasks: [
          "Engagement letter and team setup",
          "Protective rights strategy",
          "Client decisions on key terms",
        ],
      },
      {
        name: "Conditions Precedent Tracker",
        tasks: [
          "Regulatory approvals",
          "Lead party capital contribution confirmation",
          "Third-party consents",
        ],
      },
      {
        name: "Incorporation & Launch Checklist",
        tasks: [
          "JV company registration",
          "Bank accounts opened",
          "Initial capital contributed",
          "Board seat confirmed",
          "Key personnel appointed",
        ],
      },
    ],
  },
};

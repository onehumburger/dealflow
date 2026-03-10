import { DealType, DealRole } from "@/generated/prisma/client";

export const jvLeadParty = {
  name: "Joint Venture — Lead Party",
  dealType: DealType.JV,
  ourRole: DealRole.LeadParty,
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
          "Bilateral DD (if applicable)",
          "Partner background and financial check",
          "Key Issue List",
        ],
      },
      {
        name: "JV Agreement & Governance",
        tasks: [
          "Draft MOU / Framework Agreement",
          "Negotiate JV agreement and articles of association",
          "Design governance structure (board, voting, deadlock)",
          "Shareholder agreement",
        ],
      },
      {
        name: "Regulatory",
        tasks: [
          "Foreign investment review",
          "Antitrust filing (if thresholds met)",
          "Industry-specific approvals",
        ],
      },
      {
        name: "Commercial & Structure",
        tasks: [
          "Contribution ratios and valuation",
          "IP licensing arrangements",
          "Operational planning",
        ],
      },
      {
        name: "Client Communication & Strategy",
        tasks: [
          "Engagement letter and team setup",
          "Partner negotiation strategy",
          "Client decisions on governance and economics",
        ],
      },
      {
        name: "Conditions Precedent Tracker",
        tasks: [
          "Regulatory approvals",
          "Partner capital contribution confirmation",
          "Third-party consents",
          "IP transfer / licensing execution",
        ],
      },
      {
        name: "Incorporation & Launch Checklist",
        tasks: [
          "JV company registration",
          "Business licenses obtained",
          "Bank accounts opened",
          "Initial capital contributed",
          "First board meeting held",
          "Key personnel appointed",
        ],
      },
    ],
  },
};

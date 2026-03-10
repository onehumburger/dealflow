import { DealType, DealRole } from "@/generated/prisma/client";

export const auctionBuySide = {
  name: "Auction — Buy-Side",
  dealType: DealType.Auction,
  ourRole: DealRole.BuySide,
  definition: {
    milestones: [
      { name: "NDA Signed", type: "External" },
      { name: "NBO Due", type: "External" },
      { name: "BO Due", type: "External" },
      { name: "Signing", type: "Contractual" },
      { name: "Closing", type: "Contractual" },
    ],
    workstreams: [
      {
        name: "Due Diligence",
        tasks: [
          "Sign NDA and access VDR",
          "Phase 1 DD — coordinate external counsel across jurisdictions",
          "Phase 2 DD — deep dive, management presentations",
          "Compile Key Issue List",
          "Confirm all DD reports received",
        ],
      },
      {
        name: "SPA & Documentation",
        tasks: [
          "Review seller's draft SPA",
          "Internal review and mark-up",
          "Negotiate reps & warranties, indemnities, CPs",
          "Final SPA agreed",
        ],
      },
      {
        name: "Regulatory",
        tasks: [
          "Identify required filings (antitrust, FDI, industry-specific)",
          "Pre-consultation with regulators",
          "Prepare and submit filings",
          "Track review periods and respond to queries",
        ],
      },
      {
        name: "Deal Structure & Tax",
        tasks: [
          "Confirm acquisition vehicle (direct / SPV / JV)",
          "Obtain tax structuring advice",
          "Finalize funding and financing arrangements",
        ],
      },
      {
        name: "Client Communication & Strategy",
        tasks: [
          "Initial client briefing and engagement letter",
          "Pricing strategy discussion",
          "Prepare NBO / BO cover letters",
          "Client decision on key DD findings",
          "Pre-signing client approval",
        ],
      },
      {
        name: "Conditions Precedent Tracker",
        tasks: [
          "Regulatory approvals (per jurisdiction)",
          "Third-party consents (change-of-control)",
          "Board / shareholder approvals",
          "No material adverse change confirmation",
          "Officer certificates",
          "Legal opinions (each jurisdiction)",
          "SAFE registration and fund remittance",
        ],
      },
      {
        name: "Closing Checklist",
        tasks: [
          "Signature pages collected",
          "Board resolutions executed",
          "Legal opinions delivered",
          "Funds transfer instructions confirmed",
          "Closing funds wired and confirmed",
          "Share transfer / business registration filings",
          "Post-closing notices",
          "File closing binder",
        ],
      },
    ],
  },
};

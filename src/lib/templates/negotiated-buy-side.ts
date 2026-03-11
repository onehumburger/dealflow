import { DealType, DealRole } from "@/generated/prisma/client";

export const negotiatedBuySide = {
  name: "Negotiated Deal — Buy-Side",
  dealType: DealType.Negotiated,
  ourRole: DealRole.BuySide,
  definition: {
    milestones: [
      { name: "NDA Signed", type: "External" },
      { name: "LOI Signed", type: "Contractual" },
      { name: "DD Complete", type: "Internal" },
      { name: "Signing", type: "Contractual" },
      { name: "Closing", type: "Contractual" },
    ],
    workstreams: [
      {
        name: "Due Diligence",
        tasks: [
          "Sign NDA and request initial materials",
          "Coordinate external counsel DD",
          "Compile Key Issue List",
          "Confirm all DD reports received",
        ],
      },
      {
        name: "SPA & Documentation",
        tasks: [
          "Negotiate LOI / Term Sheet",
          "Draft or review SPA",
          "Negotiate to final form",
        ],
      },
      {
        name: "Regulatory",
        tasks: [
          "Identify required filings",
          "Pre-consultation and filings",
          "Track review periods",
        ],
      },
      {
        name: "Deal Structure & Tax",
        tasks: [
          "Confirm acquisition vehicle",
          "Obtain tax structuring advice",
          "Finalize financing",
        ],
      },
      {
        name: "Client Communication & Strategy",
        tasks: [
          "Engagement letter and team setup",
          "LOI strategy discussion",
          "Client decisions on key DD findings",
          "Pre-signing approval",
        ],
      },
      {
        name: "Conditions Precedent Tracker",
        tasks: [
          "Regulatory approvals",
          "Third-party consents",
          "Board / shareholder approvals",
          "No MAC confirmation",
          "Legal opinions",
          "SAFE registration and fund remittance",
        ],
      },
      {
        name: "Closing Checklist",
        tasks: [
          "Signature pages collected",
          "Board resolutions executed",
          "Legal opinions delivered",
          "Funds transfer confirmed",
          "Share transfer / registration filings",
          "Post-closing notices",
          "File closing binder",
        ],
      },
    ],
  },
};

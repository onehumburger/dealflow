import { DealType, DealRole } from "@/generated/prisma/client";

export const negotiatedSellSide = {
  name: "Negotiated Deal — Sell-Side",
  dealType: DealType.Negotiated,
  ourRole: DealRole.SellSide,
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
        name: "DD Preparation & Support",
        tasks: [
          "Prepare VDR / information packages",
          "Respond to buyer DD requests",
          "Coordinate management access",
        ],
      },
      {
        name: "SPA & Documentation",
        tasks: [
          "Negotiate LOI / Term Sheet",
          "Review buyer's draft SPA (or draft our own)",
          "Negotiate to final form",
        ],
      },
      {
        name: "Regulatory",
        tasks: [
          "Support buyer regulatory filings",
          "Track approval timelines",
        ],
      },
      {
        name: "Client Communication & Strategy",
        tasks: [
          "Engagement letter and team setup",
          "LOI strategy discussion",
          "Pre-signing approval",
        ],
      },
      {
        name: "Conditions Precedent Tracker",
        tasks: [
          "Buyer regulatory approvals",
          "Third-party consents",
          "Buyer financing confirmation",
          "No MAC confirmation",
        ],
      },
      {
        name: "Closing Checklist",
        tasks: [
          "Signature pages collected",
          "Board resolutions executed",
          "Legal opinions delivered",
          "Funds receipt confirmed",
          "Share transfer / registration filings",
          "File closing binder",
        ],
      },
    ],
  },
};

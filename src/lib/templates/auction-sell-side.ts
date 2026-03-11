import { DealType, DealRole } from "@/generated/prisma/client";

export const auctionSellSide = {
  name: "Auction — Sell-Side",
  dealType: DealType.Auction,
  ourRole: DealRole.SellSide,
  definition: {
    milestones: [
      { name: "VDR Ready", type: "Internal" },
      { name: "Phase 1 Bids Due", type: "External" },
      { name: "Phase 2 Bids Due", type: "External" },
      { name: "Signing", type: "Contractual" },
      { name: "Closing", type: "Contractual" },
    ],
    workstreams: [
      {
        name: "VDR & DD Management",
        tasks: [
          "Prepare VDR structure and populate documents",
          "Prepare IM, Teaser, Process Letter",
          "Manage buyer Q&A during Phase 1",
          "Arrange management presentations for Phase 2",
          "Respond to supplemental DD requests",
        ],
      },
      {
        name: "Bid Management",
        tasks: [
          "Distribute materials to potential buyers",
          "Collect Phase 1 NBOs",
          "Shortlist bidders with client",
          "Collect Phase 2 BOs and SPA mark-ups",
          "Evaluate bids — prepare comparison memo",
        ],
      },
      {
        name: "SPA & Documentation",
        tasks: [
          "Draft SPA and disclosure schedules",
          "Review buyer mark-ups",
          "Negotiate to final form",
        ],
      },
      {
        name: "Regulatory",
        tasks: [
          "Identify buyer-side filing requirements",
          "Support buyer regulatory filings",
          "Track approval timelines",
        ],
      },
      {
        name: "Client Communication & Strategy",
        tasks: [
          "Engagement letter and team setup",
          "Bid evaluation and recommendation",
          "Advise on preferred bidder selection",
          "Pre-signing client approval",
        ],
      },
      {
        name: "Conditions Precedent Tracker",
        tasks: [
          "Buyer regulatory approvals",
          "Third-party consents",
          "Buyer financing confirmation",
          "No MAC confirmation",
          "Legal opinions",
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
          "Post-closing notices",
          "File closing binder",
        ],
      },
    ],
  },
};

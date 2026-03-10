import { PrismaClient, DealType, DealRole } from "../src/generated/prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

// Define templates inline to avoid path alias issues in seed script
const allTemplates = [
  {
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
  },
  {
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
  },
  {
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
  },
  {
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
  },
  {
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
  },
  {
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
  },
];

async function main() {
  // Seed templates
  for (const template of allTemplates) {
    await prisma.template.upsert({
      where: { id: `system-${template.dealType}-${template.ourRole}` },
      update: { definition: template.definition },
      create: {
        id: `system-${template.dealType}-${template.ourRole}`,
        name: template.name,
        dealType: template.dealType,
        ourRole: template.ourRole,
        definition: template.definition,
        isSystem: true,
      },
    });
  }

  // Seed demo admin user
  const passwordHash = await bcrypt.hash("admin123", 10);
  await prisma.user.upsert({
    where: { email: "admin@dealflow.local" },
    update: {},
    create: {
      name: "Admin",
      email: "admin@dealflow.local",
      passwordHash,
      role: "Admin",
      locale: "zh",
    },
  });

  console.log("Seed complete: 6 templates + 1 admin user");
}

main()
  .then(() => prisma.$disconnect())
  .catch((e) => {
    console.error(e);
    prisma.$disconnect();
    process.exit(1);
  });

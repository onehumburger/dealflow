/**
 * Replace existing .txt legal templates with proper .docx Word documents.
 * Usage: npx tsx prisma/seed-legal-docx.ts
 */
import { PrismaClient } from "../src/generated/prisma/client";
import {
  Document,
  Packer,
  Paragraph,
  TextRun,
  HeadingLevel,
  AlignmentType,
  TabStopPosition,
  TabStopType,
} from "docx";
import fs from "fs";
import path from "path";

const prisma = new PrismaClient();
const STORAGE_ROOT = path.resolve(__dirname, "..", "storage", "uploads");

// ---------------------------------------------------------------------------
// Helper to build a docx buffer
// ---------------------------------------------------------------------------

function heading(text: string, level: (typeof HeadingLevel)[keyof typeof HeadingLevel] = HeadingLevel.HEADING_1) {
  return new Paragraph({ heading: level, children: [new TextRun({ text, bold: true })] });
}

function para(text: string, { bold = false, indent = 0 }: { bold?: boolean; indent?: number } = {}) {
  return new Paragraph({
    indent: indent ? { left: indent } : undefined,
    children: [new TextRun({ text, bold })],
  });
}

function signBlock(leftLabel: string, rightLabel: string) {
  return [
    new Paragraph({ children: [] }),
    new Paragraph({ children: [] }),
    new Paragraph({
      tabStops: [{ type: TabStopType.LEFT, position: TabStopPosition.MAX / 2 }],
      children: [
        new TextRun({ text: `${leftLabel}:` }),
        new TextRun({ text: "\t" }),
        new TextRun({ text: `${rightLabel}:` }),
      ],
    }),
    new Paragraph({ children: [] }),
    new Paragraph({
      tabStops: [{ type: TabStopType.LEFT, position: TabStopPosition.MAX / 2 }],
      children: [
        new TextRun({ text: "_____________________________" }),
        new TextRun({ text: "\t" }),
        new TextRun({ text: "_____________________________" }),
      ],
    }),
    new Paragraph({
      tabStops: [{ type: TabStopType.LEFT, position: TabStopPosition.MAX / 2 }],
      children: [
        new TextRun({ text: "Name:  [AUTHORIZED SIGNATORY]" }),
        new TextRun({ text: "\t" }),
        new TextRun({ text: "Name:  [AUTHORIZED SIGNATORY]" }),
      ],
    }),
    new Paragraph({
      tabStops: [{ type: TabStopType.LEFT, position: TabStopPosition.MAX / 2 }],
      children: [
        new TextRun({ text: "Title: [TITLE]" }),
        new TextRun({ text: "\t" }),
        new TextRun({ text: "Title: [TITLE]" }),
      ],
    }),
    new Paragraph({
      tabStops: [{ type: TabStopType.LEFT, position: TabStopPosition.MAX / 2 }],
      children: [
        new TextRun({ text: "Date:  [DATE]" }),
        new TextRun({ text: "\t" }),
        new TextRun({ text: "Date:  [DATE]" }),
      ],
    }),
  ];
}

// ---------------------------------------------------------------------------
// SPA
// ---------------------------------------------------------------------------
async function buildSPA(): Promise<Buffer> {
  const doc = new Document({
    sections: [{
      children: [
        heading("SHARE PURCHASE AGREEMENT"),
        para(""),
        para('This Share Purchase Agreement ("Agreement") is entered into as of [DATE], by and between:'),
        para('(1) [BUYER], a company incorporated under the laws of [JURISDICTION], with its registered office at [BUYER ADDRESS] (the "Buyer"); and', { indent: 360 }),
        para('(2) [SELLER], a company incorporated under the laws of [JURISDICTION], with its registered office at [SELLER ADDRESS] (the "Seller").', { indent: 360 }),
        para('(each a "Party" and together the "Parties")'),
        para(""),
        heading("RECITALS", HeadingLevel.HEADING_2),
        para("WHEREAS, the Seller is the legal and beneficial owner of [NUMBER] shares (the \"Sale Shares\"), representing [PERCENTAGE]% of the total issued and outstanding share capital of [COMPANY]; and"),
        para("WHEREAS, the Seller wishes to sell, and the Buyer wishes to purchase, the Sale Shares on the terms and conditions set forth in this Agreement."),
        para("NOW, THEREFORE, in consideration of the mutual covenants herein, the Parties agree as follows:"),
        para(""),
        heading("ARTICLE 1 — DEFINITIONS AND INTERPRETATION", HeadingLevel.HEADING_2),
        para('1.1  "Business Day" means a day on which banks are open for general business in [CITY].', { indent: 360 }),
        para('1.2  "Closing" means the completion of the sale and purchase of the Sale Shares in accordance with Article 5.', { indent: 360 }),
        para('1.3  "Material Adverse Effect" means any event materially adverse to the business, assets, financial condition or results of operations of the Company.', { indent: 360 }),
        para(""),
        heading("ARTICLE 2 — SALE AND PURCHASE", HeadingLevel.HEADING_2),
        para("2.1  The Seller hereby agrees to sell, and the Buyer hereby agrees to purchase, the Sale Shares free from all Encumbrances and together with all rights attaching thereto.", { indent: 360 }),
        para("2.2  The aggregate purchase price for the Sale Shares shall be [CURRENCY] [AMOUNT] (the \"Purchase Price\").", { indent: 360 }),
        para(""),
        heading("ARTICLE 3 — CONDITIONS PRECEDENT", HeadingLevel.HEADING_2),
        para("3.1  Closing shall be conditional upon: (a) all regulatory approvals; (b) no Material Adverse Effect; (c) representations and warranties being true; (d) all third-party consents obtained.", { indent: 360 }),
        para("3.2  Long Stop Date: If Conditions are not satisfied by [LONG STOP DATE], either Party may terminate.", { indent: 360 }),
        para(""),
        heading("ARTICLE 4 — PAYMENT", HeadingLevel.HEADING_2),
        para("4.1  Deposit: [CURRENCY] [DEPOSIT AMOUNT] within [NUMBER] Business Days of execution into escrow.", { indent: 360 }),
        para("4.2  Closing Payment: Balance paid by wire transfer on the Closing Date.", { indent: 360 }),
        para(""),
        heading("ARTICLE 5 — CLOSING", HeadingLevel.HEADING_2),
        para("5.1  Closing shall take place at [LAW FIRM] at [ADDRESS] on the Closing Date."),
        para("5.2  Seller delivers: share transfer forms, share certificates, board resolutions."),
        para("5.3  Buyer delivers: Closing Payment, required documents."),
        para(""),
        heading("ARTICLE 6 — REPRESENTATIONS AND WARRANTIES", HeadingLevel.HEADING_2),
        para("6.1  Seller represents: full power and authority; Sale Shares fully paid and free from Encumbrances."),
        para("6.2  Buyer represents: full power and authority; sufficient available funds."),
        para(""),
        heading("ARTICLE 7 — INDEMNIFICATION", HeadingLevel.HEADING_2),
        para("7.1  Seller indemnifies Buyer against losses from breach of Seller's representations."),
        para("7.2  Buyer indemnifies Seller against losses from breach of Buyer's representations."),
        para("7.3  Aggregate Seller liability shall not exceed [PERCENTAGE]% of Purchase Price."),
        para(""),
        heading("ARTICLE 8 — CONFIDENTIALITY", HeadingLevel.HEADING_2),
        para("Each Party shall keep confidential all information relating to the other Party or the transactions contemplated hereby."),
        para(""),
        heading("ARTICLE 9 — GOVERNING LAW", HeadingLevel.HEADING_2),
        para("This Agreement shall be governed by the laws of [GOVERNING LAW JURISDICTION]. Disputes submitted to arbitration under [ARBITRATION BODY]."),
        para(""),
        heading("ARTICLE 10 — MISCELLANEOUS", HeadingLevel.HEADING_2),
        para("10.1  Entire Agreement. 10.2  Amendment requires writing. 10.3  May be executed in counterparts."),
        para(""),
        new Paragraph({
          alignment: AlignmentType.CENTER,
          children: [new TextRun({ text: "IN WITNESS WHEREOF, the Parties have executed this Agreement.", italics: true })],
        }),
        ...signBlock("BUYER", "SELLER"),
      ],
    }],
  });
  return Buffer.from(await Packer.toBuffer(doc));
}

// ---------------------------------------------------------------------------
// LOI
// ---------------------------------------------------------------------------
async function buildLOI(): Promise<Buffer> {
  const doc = new Document({
    sections: [{
      children: [
        heading("LETTER OF INTENT"),
        para(""),
        para("Date: [DATE]"),
        para("To: [SELLER], [SELLER ADDRESS]"),
        para("Attn: [CONTACT PERSON]"),
        para("Re: Non-Binding Letter of Intent for the Proposed Acquisition of [PERCENTAGE]% of [COMPANY]"),
        para(""),
        para('This Letter of Intent ("LOI") sets forth the principal terms on which [BUYER] proposes to acquire [PERCENTAGE]% of the issued and outstanding share capital of [COMPANY] from [SELLER].'),
        para(""),
        heading("1. TRANSACTION STRUCTURE", HeadingLevel.HEADING_2),
        para("The Buyer proposes to purchase [NUMBER] shares representing [PERCENTAGE]% of the Company from the Seller."),
        para(""),
        heading("2. PURCHASE PRICE", HeadingLevel.HEADING_2),
        para("The proposed aggregate purchase price shall be [CURRENCY] [AMOUNT], subject to customary adjustments."),
        para(""),
        heading("3. DUE DILIGENCE", HeadingLevel.HEADING_2),
        para("The Buyer shall be granted [NUMBER] weeks to conduct financial, legal, tax, and commercial due diligence."),
        para(""),
        heading("4. EXCLUSIVITY", HeadingLevel.HEADING_2),
        para("During the Exclusivity Period until [DATE], the Seller shall not solicit or negotiate with third parties."),
        para(""),
        heading("5. CONDITIONS PRECEDENT", HeadingLevel.HEADING_2),
        para("(a) Satisfactory due diligence; (b) Execution of definitive SPA; (c) Regulatory approvals; (d) Third-party consents; (e) No Material Adverse Effect."),
        para(""),
        heading("6. TIMELINE", HeadingLevel.HEADING_2),
        para("The Parties intend to execute a definitive SPA within [NUMBER] weeks."),
        para(""),
        heading("7. CONFIDENTIALITY", HeadingLevel.HEADING_2),
        para("The existence and terms of this LOI shall be kept strictly confidential."),
        para(""),
        heading("8. NON-BINDING NATURE", HeadingLevel.HEADING_2),
        para("Except for Sections 4 (Exclusivity), 7 (Confidentiality), and this Section 8, this LOI is non-binding."),
        para(""),
        heading("9. GOVERNING LAW", HeadingLevel.HEADING_2),
        para("This LOI shall be governed by the laws of [GOVERNING LAW JURISDICTION]."),
        para(""),
        heading("10. EXPIRATION", HeadingLevel.HEADING_2),
        para("This LOI expires if not accepted by [EXPIRATION DATE]."),
        para(""),
        ...signBlock("BUYER", "SELLER (ACCEPTED AND AGREED)"),
      ],
    }],
  });
  return Buffer.from(await Packer.toBuffer(doc));
}

// ---------------------------------------------------------------------------
// NDA
// ---------------------------------------------------------------------------
async function buildNDA(): Promise<Buffer> {
  const doc = new Document({
    sections: [{
      children: [
        heading("NON-DISCLOSURE AGREEMENT"),
        para(""),
        para('This Non-Disclosure Agreement ("Agreement") is entered into as of [DATE], by and between:'),
        para('(1) [BUYER] (the "Receiving Party"); and', { indent: 360 }),
        para('(2) [SELLER] (the "Disclosing Party").', { indent: 360 }),
        para(""),
        heading("RECITALS", HeadingLevel.HEADING_2),
        para("WHEREAS, the Disclosing Party is considering a potential transaction involving [COMPANY]; and the Disclosing Party may disclose certain confidential information to the Receiving Party."),
        para(""),
        heading("1. DEFINITION OF CONFIDENTIAL INFORMATION", HeadingLevel.HEADING_2),
        para("\"Confidential Information\" means all information disclosed in connection with the Transaction, including: (a) financial data; (b) customer and supplier lists; (c) technical information and trade secrets; (d) the existence and terms of discussions; (e) all derived notes and analyses."),
        para(""),
        para("Exclusions: (i) publicly available information; (ii) already in possession; (iii) independently developed; (iv) disclosed by non-bound third party."),
        para(""),
        heading("2. OBLIGATIONS", HeadingLevel.HEADING_2),
        para("The Receiving Party shall: (a) keep Confidential Information strictly confidential; (b) limit disclosure to Representatives with need-to-know; (c) use solely for evaluating the Transaction; (d) apply reasonable protective measures."),
        para(""),
        heading("3. NON-SOLICITATION", HeadingLevel.HEADING_2),
        para("For [NUMBER] months, the Receiving Party shall not solicit or hire any employee of the Company."),
        para(""),
        heading("4. RETURN OR DESTRUCTION", HeadingLevel.HEADING_2),
        para("Upon request or termination, the Receiving Party shall promptly return or destroy all Confidential Information."),
        para(""),
        heading("5. NO REPRESENTATION OR WARRANTY", HeadingLevel.HEADING_2),
        para("The Disclosing Party makes no representation as to accuracy or completeness of any Confidential Information."),
        para(""),
        heading("6. TERM", HeadingLevel.HEADING_2),
        para("This Agreement remains in effect for [NUMBER] years. Confidentiality obligations survive termination."),
        para(""),
        heading("7. REMEDIES", HeadingLevel.HEADING_2),
        para("Breach may cause irreparable harm. The Disclosing Party is entitled to seek equitable relief including injunction."),
        para(""),
        heading("8. GOVERNING LAW", HeadingLevel.HEADING_2),
        para("Governed by the laws of [GOVERNING LAW JURISDICTION]. Disputes submitted to courts of [JURISDICTION]."),
        para(""),
        heading("9. MISCELLANEOUS", HeadingLevel.HEADING_2),
        para("(a) Entire agreement; (b) Amendment requires writing; (c) May be executed in counterparts; (d) Severability."),
        para(""),
        new Paragraph({
          alignment: AlignmentType.CENTER,
          children: [new TextRun({ text: "IN WITNESS WHEREOF, the Parties have executed this Agreement.", italics: true })],
        }),
        ...signBlock("RECEIVING PARTY", "DISCLOSING PARTY"),
      ],
    }],
  });
  return Buffer.from(await Packer.toBuffer(doc));
}

// ---------------------------------------------------------------------------
// Main — delete old .txt templates, create .docx replacements
// ---------------------------------------------------------------------------

async function main() {
  // Find existing template documents
  const existing = await prisma.document.findMany({
    where: { name: { endsWith: "- Template" } },
    select: { id: true, name: true, storagePath: true },
  });

  // Delete old records & files
  for (const doc of existing) {
    await prisma.documentVersion.deleteMany({ where: { documentId: doc.id } });
    await prisma.document.delete({ where: { id: doc.id } });
    const dir = path.join(STORAGE_ROOT, path.dirname(doc.storagePath));
    if (fs.existsSync(dir)) fs.rmSync(dir, { recursive: true });
    console.log(`Deleted old: ${doc.name}`);
  }

  // Build .docx files
  const templates: { name: string; build: () => Promise<Buffer> }[] = [
    { name: "Share Purchase Agreement (SPA) - Template", build: buildSPA },
    { name: "Letter of Intent (LOI) - Template", build: buildLOI },
    { name: "Non-Disclosure Agreement (NDA) - Template", build: buildNDA },
  ];

  // Get Project Alpha deal & workstream IDs from existing data
  const deal = await prisma.deal.findFirst({ where: { name: { contains: "Alpha" } } });
  if (!deal) throw new Error("Project Alpha not found");
  const ws = await prisma.workstream.findFirst({ where: { dealId: deal.id, name: { contains: "尽职调查" } } });
  const admin = await prisma.user.findFirst({ where: { role: "Admin" } });
  if (!admin) throw new Error("Admin user not found");

  for (const tmpl of templates) {
    const buf = await tmpl.build();

    const document = await prisma.document.create({
      data: {
        name: tmpl.name,
        fileType: "docx",
        fileSize: buf.length,
        storagePath: "",
        currentVersion: 1,
        dealId: deal.id,
        workstreamId: ws?.id ?? null,
        uploadedById: admin.id,
      },
    });

    const storagePath = `${deal.id}/${document.id}/v1.docx`;
    await prisma.document.update({ where: { id: document.id }, data: { storagePath } });

    await prisma.documentVersion.create({
      data: {
        versionNumber: 1,
        name: tmpl.name,
        fileType: "docx",
        fileSize: buf.length,
        storagePath,
        note: "Initial template version",
        documentId: document.id,
        uploadedById: admin.id,
      },
    });

    const fullDir = path.join(STORAGE_ROOT, deal.id, document.id);
    fs.mkdirSync(fullDir, { recursive: true });
    fs.writeFileSync(path.join(fullDir, "v1.docx"), buf);

    console.log(`Created: ${tmpl.name} (${(buf.length / 1024).toFixed(1)} KB)`);
  }

  console.log("\nDone. 3 .docx template documents created for Project Alpha.");
}

main()
  .then(() => prisma.$disconnect())
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });

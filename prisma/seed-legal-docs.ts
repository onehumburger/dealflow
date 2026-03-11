import { PrismaClient } from "../src/generated/prisma/client";
import fs from "fs";
import path from "path";

const prisma = new PrismaClient();

const DEAL_ID = "cmmkzn5g70007m9bpw3ms5d75";       // Project Alpha
const USER_ID = "cmmku8f2f0000m9b5y6m56wz1";        // Admin
const WORKSTREAM_ID = "cmmkzn5hb000nm9bpqkhyhseh";   // 尽职调查

const STORAGE_ROOT = path.resolve(__dirname, "..", "storage", "uploads");

// ---------------------------------------------------------------------------
// Document content
// ---------------------------------------------------------------------------

const SPA_CONTENT = `SHARE PURCHASE AGREEMENT

This Share Purchase Agreement ("Agreement") is entered into as of [DATE],
by and between:

(1) [BUYER], a company incorporated under the laws of [JURISDICTION],
    with its registered office at [BUYER ADDRESS] (the "Buyer"); and

(2) [SELLER], a company incorporated under the laws of [JURISDICTION],
    with its registered office at [SELLER ADDRESS] (the "Seller").

(each a "Party" and together the "Parties")

RECITALS

WHEREAS, the Seller is the legal and beneficial owner of [NUMBER] shares
(the "Sale Shares"), representing [PERCENTAGE]% of the total issued and
outstanding share capital of [COMPANY], a company incorporated under the
laws of [JURISDICTION] (the "Company"); and

WHEREAS, the Seller wishes to sell, and the Buyer wishes to purchase,
the Sale Shares on the terms and conditions set forth in this Agreement.

NOW, THEREFORE, in consideration of the mutual covenants and agreements
herein contained, the Parties agree as follows:

                              ARTICLE 1
                      DEFINITIONS AND INTERPRETATION

1.1  Definitions. In this Agreement, unless the context otherwise requires:

     "Business Day" means a day (other than a Saturday, Sunday or public
     holiday) on which banks are open for general business in [CITY].

     "Closing" means the completion of the sale and purchase of the Sale
     Shares in accordance with Article 5.

     "Closing Date" means the date on which Closing occurs, being the
     date falling [NUMBER] Business Days after satisfaction or waiver
     of all Conditions Precedent.

     "Encumbrance" means any mortgage, charge, pledge, lien, option,
     restriction, equity, claim or other third-party right or interest
     of any kind.

     "Material Adverse Effect" means any event, circumstance, change
     or effect that, individually or in the aggregate, is or would
     reasonably be expected to be materially adverse to the business,
     assets, financial condition or results of operations of the Company.

1.2  Interpretation. In this Agreement, unless the context otherwise
     requires: (a) headings are for convenience only; (b) words in the
     singular include the plural and vice versa; (c) a reference to a
     statute includes any amendment or re-enactment thereof.

                              ARTICLE 2
                       SALE AND PURCHASE

2.1  Sale of Shares. Subject to the terms and conditions of this
     Agreement, the Seller hereby agrees to sell, and the Buyer hereby
     agrees to purchase, the Sale Shares free from all Encumbrances
     and together with all rights attaching thereto.

2.2  Purchase Price. The aggregate purchase price for the Sale Shares
     shall be [CURRENCY] [AMOUNT] (the "Purchase Price"), payable in
     accordance with Article 4.

                              ARTICLE 3
                       CONDITIONS PRECEDENT

3.1  Conditions. Closing shall be conditional upon the satisfaction or
     waiver of the following conditions:

     (a) Regulatory Approvals: All regulatory approvals, consents and
         filings necessary for the transactions contemplated by this
         Agreement shall have been obtained or made;

     (b) No Material Adverse Effect: No Material Adverse Effect shall
         have occurred since the date of this Agreement;

     (c) Representations and Warranties: The representations and
         warranties of each Party shall be true and correct in all
         material respects as of the Closing Date;

     (d) Third-Party Consents: All third-party consents required under
         the Company's material contracts shall have been obtained.

3.2  Long Stop Date. If the Conditions are not satisfied or waived by
     [LONG STOP DATE] (the "Long Stop Date"), either Party may terminate
     this Agreement by written notice to the other Party.

                              ARTICLE 4
                       PAYMENT OF PURCHASE PRICE

4.1  Payment. The Purchase Price shall be paid as follows:

     (a) Deposit: Within [NUMBER] Business Days of execution of this
         Agreement, the Buyer shall pay [CURRENCY] [DEPOSIT AMOUNT]
         (the "Deposit") into an escrow account designated by the Parties;

     (b) Closing Payment: On the Closing Date, the Buyer shall pay the
         balance of the Purchase Price less the Deposit by wire transfer
         of immediately available funds to the Seller's designated account.

4.2  Adjustments. The Purchase Price shall be subject to adjustment
     based on the Closing Date balance sheet prepared in accordance
     with the agreed accounting principles.

                              ARTICLE 5
                              CLOSING

5.1  Closing. Closing shall take place at the offices of [LAW FIRM]
     located at [ADDRESS] at [TIME] on the Closing Date, or at such
     other place and time as the Parties may agree.

5.2  Seller's Obligations at Closing. At Closing, the Seller shall:

     (a) deliver duly executed share transfer forms in respect of the
         Sale Shares;
     (b) deliver the share certificates representing the Sale Shares;
     (c) deliver board resolutions approving the transfer;
     (d) deliver all other documents required under this Agreement.

5.3  Buyer's Obligations at Closing. At Closing, the Buyer shall:

     (a) pay the Closing Payment in accordance with Article 4.1(b);
     (b) deliver all documents required under this Agreement.

                              ARTICLE 6
                    REPRESENTATIONS AND WARRANTIES

6.1  Seller's Representations. The Seller represents and warrants to
     the Buyer that, as of the date hereof and as of the Closing Date:

     (a) the Seller has full power and authority to execute and perform
         this Agreement;
     (b) the Sale Shares are fully paid and free from all Encumbrances;
     (c) the execution and performance of this Agreement will not
         conflict with any agreement to which the Seller is a party.

6.2  Buyer's Representations. The Buyer represents and warrants to
     the Seller that, as of the date hereof and as of the Closing Date:

     (a) the Buyer has full power and authority to execute and perform
         this Agreement;
     (b) the Buyer has available funds sufficient to pay the Purchase Price;
     (c) the execution and performance of this Agreement will not
         conflict with any agreement to which the Buyer is a party.

                              ARTICLE 7
                          INDEMNIFICATION

7.1  Seller's Indemnity. The Seller shall indemnify the Buyer against
     all losses arising from any breach of the Seller's representations,
     warranties and obligations under this Agreement.

7.2  Buyer's Indemnity. The Buyer shall indemnify the Seller against
     all losses arising from any breach of the Buyer's representations,
     warranties and obligations under this Agreement.

7.3  Limitations. The aggregate liability of the Seller under this
     Article 7 shall not exceed [PERCENTAGE]% of the Purchase Price.
     No claim may be brought after [NUMBER] months from the Closing Date.

                              ARTICLE 8
                          CONFIDENTIALITY

8.1  Each Party shall keep confidential and shall not disclose to any
     third party (except its professional advisors) any information
     relating to the other Party or the transactions contemplated by
     this Agreement.

                              ARTICLE 9
                       GOVERNING LAW AND DISPUTE

9.1  Governing Law. This Agreement shall be governed by and construed
     in accordance with the laws of [GOVERNING LAW JURISDICTION].

9.2  Arbitration. Any dispute arising out of or in connection with this
     Agreement shall be submitted to arbitration under the rules of
     [ARBITRATION BODY] by [NUMBER] arbitrator(s) appointed in
     accordance with said rules. The seat of arbitration shall be [CITY].

                              ARTICLE 10
                           MISCELLANEOUS

10.1 Entire Agreement. This Agreement constitutes the entire agreement
     between the Parties with respect to the subject matter hereof.

10.2 Amendment. No amendment to this Agreement shall be effective unless
     in writing and signed by both Parties.

10.3 Counterparts. This Agreement may be executed in any number of
     counterparts, each of which shall be deemed an original.


IN WITNESS WHEREOF, the Parties have executed this Agreement as of the
date first written above.


BUYER:                                SELLER:

_____________________________         _____________________________
Name:  [AUTHORIZED SIGNATORY]        Name:  [AUTHORIZED SIGNATORY]
Title: [TITLE]                        Title: [TITLE]
Date:  [DATE]                         Date:  [DATE]
`;

const LOI_CONTENT = `LETTER OF INTENT

Date: [DATE]

To:     [SELLER]
        [SELLER ADDRESS]

Attn:   [CONTACT PERSON]

Re:     Non-Binding Letter of Intent for the Proposed Acquisition of
        [PERCENTAGE]% of the Shares of [COMPANY] (the "Transaction")

Dear [CONTACT PERSON],

This Letter of Intent ("LOI") sets forth the principal terms on which
[BUYER] ("Buyer") proposes to acquire [PERCENTAGE]% of the issued and
outstanding share capital of [COMPANY] (the "Company") from [SELLER]
("Seller"). This LOI is intended to form the basis for the negotiation
of a definitive Share Purchase Agreement ("SPA").

1.  TRANSACTION STRUCTURE

    The Buyer proposes to purchase [NUMBER] shares of the Company (the
    "Sale Shares"), representing [PERCENTAGE]% of the total issued and
    outstanding share capital of the Company, from the Seller.

2.  PURCHASE PRICE

    The proposed aggregate purchase price for the Sale Shares shall be
    [CURRENCY] [AMOUNT] (the "Purchase Price"), subject to customary
    adjustments for working capital, net debt, and other items to be
    agreed upon in the SPA.

3.  DUE DILIGENCE

    The Buyer shall be granted a period of [NUMBER] weeks from the date
    of acceptance of this LOI to conduct financial, legal, tax, and
    commercial due diligence on the Company. The Seller shall provide
    reasonable access to the Company's books, records, premises, and
    key management personnel during this period.

4.  EXCLUSIVITY

    During the period from acceptance of this LOI until [EXCLUSIVITY
    END DATE] (the "Exclusivity Period"), the Seller shall not, and
    shall cause its affiliates and advisors not to, directly or
    indirectly solicit, encourage, negotiate, or enter into any
    agreement with any third party regarding any sale or transfer of
    the Sale Shares or substantially all assets of the Company.

5.  CONDITIONS PRECEDENT

    Closing of the Transaction shall be subject to the following
    conditions precedent:

    (a) Satisfactory completion of due diligence by the Buyer;
    (b) Execution of a definitive SPA on terms acceptable to both Parties;
    (c) Receipt of all required regulatory approvals;
    (d) Receipt of all required third-party consents;
    (e) No Material Adverse Effect having occurred.

6.  TIMELINE

    The Parties intend to use commercially reasonable efforts to
    negotiate and execute a definitive SPA within [NUMBER] weeks from
    the date of acceptance of this LOI.

7.  CONFIDENTIALITY

    The existence and terms of this LOI shall be kept strictly
    confidential by both Parties and shall not be disclosed to any
    third party without the prior written consent of the other Party,
    except as required by applicable law or regulation.

8.  NON-BINDING NATURE

    Except for Sections 4 (Exclusivity), 7 (Confidentiality), and this
    Section 8, this LOI is non-binding and does not constitute a
    legally enforceable obligation of either Party. No binding
    obligation shall arise until the execution of a definitive SPA.

9.  GOVERNING LAW

    This LOI shall be governed by and construed in accordance with the
    laws of [GOVERNING LAW JURISDICTION].

10. EXPIRATION

    This LOI shall expire if not accepted in writing by the Seller
    on or before [EXPIRATION DATE].

We look forward to working with you on this Transaction.

Sincerely,

_____________________________
[BUYER]
Name:  [AUTHORIZED SIGNATORY]
Title: [TITLE]


ACCEPTED AND AGREED:

_____________________________
[SELLER]
Name:  [AUTHORIZED SIGNATORY]
Title: [TITLE]
Date:  [DATE]
`;

const NDA_CONTENT = `NON-DISCLOSURE AGREEMENT

This Non-Disclosure Agreement ("Agreement") is entered into as of [DATE],
by and between:

(1) [BUYER], a company incorporated under the laws of [JURISDICTION],
    with its registered office at [BUYER ADDRESS]
    (the "Receiving Party"); and

(2) [SELLER], a company incorporated under the laws of [JURISDICTION],
    with its registered office at [SELLER ADDRESS]
    (the "Disclosing Party").

(each a "Party" and together the "Parties")

RECITALS

WHEREAS, the Disclosing Party is considering a potential transaction
(the "Transaction") involving [COMPANY] (the "Company"); and

WHEREAS, in connection with the evaluation of the Transaction, the
Disclosing Party may disclose certain confidential information to the
Receiving Party;

NOW, THEREFORE, in consideration of the mutual covenants herein, the
Parties agree as follows:

1.  DEFINITION OF CONFIDENTIAL INFORMATION

    "Confidential Information" means all information, whether written,
    oral, electronic, or visual, disclosed by or on behalf of the
    Disclosing Party to the Receiving Party in connection with the
    Transaction, including but not limited to:

    (a) financial data, projections, and business plans;
    (b) customer and supplier lists, pricing information;
    (c) technical information, trade secrets, know-how;
    (d) the existence and terms of discussions regarding the Transaction;
    (e) all notes, analyses, compilations, and other materials prepared
        by the Receiving Party that contain or reflect such information.

    Confidential Information does not include information that:
    (i)   is or becomes publicly available other than through breach
          of this Agreement;
    (ii)  was already in the possession of the Receiving Party prior
          to disclosure;
    (iii) is independently developed by the Receiving Party without
          use of the Confidential Information; or
    (iv)  is disclosed to the Receiving Party by a third party not
          bound by an obligation of confidentiality.

2.  OBLIGATIONS OF THE RECEIVING PARTY

    The Receiving Party shall:

    (a) keep the Confidential Information strictly confidential;
    (b) not disclose the Confidential Information to any person other
        than its directors, officers, employees, and professional
        advisors (collectively, "Representatives") who have a need
        to know such information for purposes of evaluating the
        Transaction and who are bound by obligations of confidentiality
        no less restrictive than those set forth herein;
    (c) use the Confidential Information solely for the purpose of
        evaluating the Transaction and for no other purpose;
    (d) take all reasonable measures to protect the confidentiality
        of the Confidential Information, applying no less care than
        the Receiving Party applies to its own confidential information.

3.  NON-SOLICITATION

    For a period of [NUMBER] months from the date of this Agreement,
    the Receiving Party shall not, directly or indirectly, solicit or
    hire any employee of the Company without the prior written consent
    of the Disclosing Party.

4.  RETURN OR DESTRUCTION OF INFORMATION

    Upon written request of the Disclosing Party or upon termination
    of discussions regarding the Transaction, the Receiving Party shall
    promptly return or destroy all Confidential Information and any
    copies thereof, and shall certify in writing that it has done so,
    provided that the Receiving Party may retain one archival copy
    solely for compliance and legal purposes.

5.  NO REPRESENTATION OR WARRANTY

    The Disclosing Party makes no representation or warranty, express
    or implied, as to the accuracy or completeness of any Confidential
    Information. The Receiving Party acknowledges that it shall rely
    solely on its own investigations in evaluating the Transaction.

6.  TERM

    This Agreement shall remain in effect for a period of [NUMBER]
    years from the date hereof. The obligations of confidentiality
    shall survive the termination of this Agreement with respect to
    Confidential Information disclosed during the term.

7.  REMEDIES

    The Receiving Party acknowledges that any breach of this Agreement
    may cause irreparable harm to the Disclosing Party, and that
    monetary damages may be inadequate. Accordingly, the Disclosing
    Party shall be entitled to seek equitable relief, including
    injunction and specific performance, in addition to all other
    remedies available at law or in equity.

8.  GOVERNING LAW AND JURISDICTION

    This Agreement shall be governed by and construed in accordance
    with the laws of [GOVERNING LAW JURISDICTION]. Any dispute arising
    under this Agreement shall be submitted to the exclusive
    jurisdiction of the courts of [JURISDICTION].

9.  MISCELLANEOUS

    (a) This Agreement constitutes the entire agreement between the
        Parties with respect to the subject matter hereof.
    (b) No amendment shall be effective unless in writing and signed
        by both Parties.
    (c) This Agreement may be executed in counterparts.
    (d) If any provision is held invalid, the remaining provisions
        shall continue in full force and effect.


IN WITNESS WHEREOF, the Parties have executed this Agreement as of the
date first written above.


RECEIVING PARTY:                      DISCLOSING PARTY:

_____________________________         _____________________________
[BUYER]                               [SELLER]
Name:  [AUTHORIZED SIGNATORY]        Name:  [AUTHORIZED SIGNATORY]
Title: [TITLE]                        Title: [TITLE]
Date:  [DATE]                         Date:  [DATE]
`;

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

interface DocSpec {
  name: string;
  content: string;
}

async function main() {
  const docs: DocSpec[] = [
    { name: "Share Purchase Agreement (SPA) - Template",  content: SPA_CONTENT },
    { name: "Letter of Intent (LOI) - Template",          content: LOI_CONTENT },
    { name: "Non-Disclosure Agreement (NDA) - Template",  content: NDA_CONTENT },
  ];

  for (const doc of docs) {
    const buf = Buffer.from(doc.content, "utf-8");
    const fileSize = buf.length;

    // Create Document record
    const document = await prisma.document.create({
      data: {
        name: doc.name,
        fileType: "txt",
        fileSize,
        storagePath: "",          // placeholder, updated below
        currentVersion: 1,
        dealId: DEAL_ID,
        workstreamId: WORKSTREAM_ID,
        uploadedById: USER_ID,
      },
    });

    const storagePath = `${DEAL_ID}/${document.id}/v1.txt`;
    const fullDir = path.join(STORAGE_ROOT, DEAL_ID, document.id);

    // Update storagePath now that we have the document id
    await prisma.document.update({
      where: { id: document.id },
      data: { storagePath },
    });

    // Create DocumentVersion record
    await prisma.documentVersion.create({
      data: {
        versionNumber: 1,
        name: doc.name,
        fileType: "txt",
        fileSize,
        storagePath,
        note: "Initial template version",
        documentId: document.id,
        uploadedById: USER_ID,
      },
    });

    // Write file to disk
    fs.mkdirSync(fullDir, { recursive: true });
    fs.writeFileSync(path.join(fullDir, "v1.txt"), buf);

    console.log(`Created: ${doc.name}`);
    console.log(`   DB id:        ${document.id}`);
    console.log(`   storagePath:  ${storagePath}`);
    console.log(`   fileSize:     ${fileSize} bytes`);
    console.log(`   disk:         ${path.join(fullDir, "v1.txt")}`);
    console.log();
  }

  console.log("Done. 3 template legal documents created for Project Alpha.");
}

main()
  .then(() => prisma.$disconnect())
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });

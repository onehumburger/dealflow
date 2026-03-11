-- CreateEnum
CREATE TYPE "DealPhase" AS ENUM ('Intake', 'DueDiligence', 'Negotiation', 'Signing', 'Closing', 'PostClosing');

-- CreateEnum
CREATE TYPE "DealSource" AS ENUM ('FAReferral', 'DirectClient', 'PartnerReferral', 'Repeat', 'Other');

-- AlterTable
ALTER TABLE "Deal" ADD COLUMN     "dealValue" DECIMAL(18,2),
ADD COLUMN     "keyTerms" TEXT,
ADD COLUMN     "phase" "DealPhase" NOT NULL DEFAULT 'Intake',
ADD COLUMN     "source" "DealSource",
ADD COLUMN     "sourceNote" TEXT,
ADD COLUMN     "valueCurrency" TEXT NOT NULL DEFAULT 'USD';

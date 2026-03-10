-- AddForeignKey
ALTER TABLE "Document" ADD CONSTRAINT "Document_workstreamId_fkey" FOREIGN KEY ("workstreamId") REFERENCES "Workstream"("id") ON DELETE SET NULL ON UPDATE CASCADE;

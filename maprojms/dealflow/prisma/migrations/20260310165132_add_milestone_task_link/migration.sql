-- CreateTable
CREATE TABLE "MilestoneTask" (
    "milestoneId" TEXT NOT NULL,
    "taskId" TEXT NOT NULL,

    CONSTRAINT "MilestoneTask_pkey" PRIMARY KEY ("milestoneId","taskId")
);

-- AddForeignKey
ALTER TABLE "MilestoneTask" ADD CONSTRAINT "MilestoneTask_milestoneId_fkey" FOREIGN KEY ("milestoneId") REFERENCES "Milestone"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MilestoneTask" ADD CONSTRAINT "MilestoneTask_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES "Task"("id") ON DELETE CASCADE ON UPDATE CASCADE;

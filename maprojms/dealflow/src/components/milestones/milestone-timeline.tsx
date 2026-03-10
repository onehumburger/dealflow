import { cn } from "@/lib/utils";

interface MilestoneItem {
  id: string;
  name: string;
  date: Date | null;
  isDone: boolean;
}

interface MilestoneTimelineProps {
  milestones: MilestoneItem[];
}

function formatDate(date: Date | null): string {
  if (!date) return "\u2014";
  return new Intl.DateTimeFormat("en", {
    month: "short",
    day: "numeric",
  }).format(date);
}

function isOverdue(milestone: MilestoneItem): boolean {
  if (milestone.isDone) return false;
  if (!milestone.date) return false;
  return milestone.date < new Date();
}

export function MilestoneTimeline({ milestones }: MilestoneTimelineProps) {
  if (milestones.length === 0) return null;

  return (
    <div className="overflow-x-auto py-2">
      <div className="flex items-start gap-0 min-w-fit px-4">
        {milestones.map((ms, i) => {
          const done = ms.isDone;
          const overdue = isOverdue(ms);

          return (
            <div key={ms.id} className="flex items-start">
              {/* Dot + label column */}
              <div className="flex flex-col items-center">
                <div
                  className={cn(
                    "size-3.5 rounded-full border-2",
                    done
                      ? "border-emerald-600 bg-emerald-600"
                      : overdue
                        ? "border-red-500 bg-red-500"
                        : "border-muted-foreground bg-background"
                  )}
                />
                <span
                  className={cn(
                    "mt-1.5 max-w-[80px] text-center text-xs leading-tight",
                    done
                      ? "text-emerald-700"
                      : overdue
                        ? "text-red-500"
                        : "text-muted-foreground"
                  )}
                >
                  {ms.name}
                </span>
                <span className="mt-0.5 text-[10px] text-muted-foreground">
                  {formatDate(ms.date)}
                </span>
              </div>

              {/* Connector line */}
              {i < milestones.length - 1 && (
                <div className="mt-1.5 h-px w-10 bg-border" />
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}

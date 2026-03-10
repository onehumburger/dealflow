"use client";

import { useTransition } from "react";
import { useTranslations } from "next-intl";
import { Trash2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import {
  createMilestone,
  updateMilestone,
  deleteMilestone,
  toggleMilestoneDone,
} from "@/actions/milestones";
import type { MilestoneType } from "@/generated/prisma/client";

interface MilestoneData {
  id: string;
  name: string;
  date: Date | null;
  type?: MilestoneType;
  isDone: boolean;
}

interface MilestoneFormProps {
  dealId: string;
  milestone?: MilestoneData;
  trigger: React.ReactNode;
}

const MILESTONE_TYPES: MilestoneType[] = [
  "External",
  "Contractual",
  "Regulatory",
  "Internal",
  "Custom",
];

function formatDateForInput(date: Date | null): string {
  if (!date) return "";
  return date.toISOString().split("T")[0];
}

export function MilestoneForm({ dealId, milestone, trigger }: MilestoneFormProps) {
  const t = useTranslations("milestone");
  const tCommon = useTranslations("common");
  const [isPending, startTransition] = useTransition();

  const isEdit = !!milestone;

  function handleSubmit(formData: FormData) {
    startTransition(async () => {
      if (isEdit && milestone) {
        const name = formData.get("name") as string;
        const dateRaw = formData.get("date") as string;
        const type = formData.get("type") as MilestoneType;
        await updateMilestone(milestone.id, {
          name,
          date: dateRaw ? new Date(dateRaw) : null,
          type,
        });
      } else {
        formData.set("dealId", dealId);
        await createMilestone(formData);
      }
    });
  }

  function handleDelete() {
    if (!milestone) return;
    startTransition(async () => {
      await deleteMilestone(milestone.id);
    });
  }

  function handleToggleDone() {
    if (!milestone) return;
    startTransition(async () => {
      await toggleMilestoneDone(milestone.id);
    });
  }

  return (
    <Popover>
      <PopoverTrigger render={<span />}>
        {trigger}
      </PopoverTrigger>
      <PopoverContent align="start" className="w-80">
        <form action={handleSubmit} className="flex flex-col gap-3">
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="ms-name">{t("name")}</Label>
            <Input
              id="ms-name"
              name="name"
              defaultValue={milestone?.name ?? ""}
              placeholder={t("name")}
              required
            />
          </div>

          <div className="flex flex-col gap-1.5">
            <Label htmlFor="ms-date">{t("date")}</Label>
            <Input
              id="ms-date"
              name="date"
              type="date"
              defaultValue={formatDateForInput(milestone?.date ?? null)}
            />
          </div>

          <div className="flex flex-col gap-1.5">
            <Label htmlFor="ms-type">{t("type")}</Label>
            <Select name="type" defaultValue={milestone?.type ?? "Custom"}>
              <SelectTrigger className="w-full">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {MILESTONE_TYPES.map((mt) => (
                  <SelectItem key={mt} value={mt}>
                    {t(`types.${mt}` as Parameters<typeof t>[0])}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="flex items-center justify-between pt-1">
            <div className="flex gap-1">
              {isEdit && (
                <>
                  <Button
                    type="button"
                    variant="ghost"
                    size="icon-sm"
                    onClick={handleToggleDone}
                    disabled={isPending}
                    title={milestone?.isDone ? t("markUndone") : t("markDone")}
                  >
                    <span className="text-xs">
                      {milestone?.isDone ? t("markUndone") : t("markDone")}
                    </span>
                  </Button>
                  <Button
                    type="button"
                    variant="destructive"
                    size="icon-sm"
                    onClick={handleDelete}
                    disabled={isPending}
                  >
                    <Trash2 className="size-3.5" />
                  </Button>
                </>
              )}
            </div>
            <Button type="submit" size="sm" disabled={isPending}>
              {isEdit ? tCommon("save") : tCommon("create")}
            </Button>
          </div>
        </form>
      </PopoverContent>
    </Popover>
  );
}

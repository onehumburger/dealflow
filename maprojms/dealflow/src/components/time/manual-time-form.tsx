"use client";

import { useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Plus } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { logManualTime } from "@/actions/time-entries";

interface ManualTimeFormProps {
  taskId: string;
  onDone: () => void;
}

export function ManualTimeForm({ taskId, onDone }: ManualTimeFormProps) {
  const t = useTranslations("timer");
  const tCommon = useTranslations("common");
  const [open, setOpen] = useState(false);
  const [hours, setHours] = useState("");
  const [date, setDate] = useState(new Date().toISOString().split("T")[0]);
  const [description, setDescription] = useState("");
  const [isPending, startTransition] = useTransition();

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const h = parseFloat(hours);
    if (isNaN(h) || h <= 0) return;

    startTransition(async () => {
      await logManualTime(taskId, {
        durationHours: h,
        date,
        description: description.trim() || undefined,
      });
      setHours("");
      setDescription("");
      setOpen(false);
      onDone();
    });
  }

  if (!open) {
    return (
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="flex items-center gap-1.5 text-xs text-muted-foreground hover:text-foreground"
      >
        <Plus className="size-3" />
        {t("logTime")}
      </button>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-2 rounded border p-2">
      <div className="flex items-center gap-2">
        <Input
          type="number"
          step="0.25"
          min="0.25"
          value={hours}
          onChange={(e) => setHours(e.target.value)}
          placeholder={t("hours")}
          className="h-7 w-20 text-sm"
          autoFocus
          required
        />
        <Input
          type="date"
          value={date}
          onChange={(e) => setDate(e.target.value)}
          className="h-7 text-sm"
        />
      </div>
      <Input
        value={description}
        onChange={(e) => setDescription(e.target.value)}
        placeholder={t("description")}
        className="h-7 text-sm"
      />
      <div className="flex items-center gap-2">
        <Button type="submit" size="xs" disabled={isPending}>
          {t("logTime")}
        </Button>
        <Button
          type="button"
          variant="ghost"
          size="xs"
          onClick={() => setOpen(false)}
        >
          {tCommon("cancel")}
        </Button>
      </div>
    </form>
  );
}

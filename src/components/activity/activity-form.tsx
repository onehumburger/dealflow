"use client";

import { useTransition, useRef, useState } from "react";
import { useTranslations } from "next-intl";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
} from "@/components/ui/select";
import { createActivityEntry } from "@/actions/activity";
import type { ActivityType } from "@/generated/prisma/client";

interface WorkstreamOption {
  id: string;
  name: string;
}

interface ActivityFormProps {
  dealId: string;
  workstreams: WorkstreamOption[];
  onClose: () => void;
}

const MANUAL_ACTIVITY_TYPES: ActivityType[] = [
  "Note",
  "Call",
  "Meeting",
  "ClientInstruction",
];

const typeToKey: Record<string, string> = {
  Note: "note",
  Call: "call",
  Meeting: "meeting",
  ClientInstruction: "clientInstruction",
};

export function ActivityForm({ dealId, workstreams, onClose }: ActivityFormProps) {
  const t = useTranslations("activity");
  const tCommon = useTranslations("common");
  const [isPending, startTransition] = useTransition();
  const formRef = useRef<HTMLFormElement>(null);
  const [selectedType, setSelectedType] = useState<ActivityType>("Note");
  const [selectedWsId, setSelectedWsId] = useState("");

  function handleSubmit(formData: FormData) {
    formData.set("dealId", dealId);
    formData.set("type", selectedType);
    formData.set("workstreamId", selectedWsId);
    startTransition(async () => {
      await createActivityEntry(formData);
      formRef.current?.reset();
      onClose();
    });
  }

  const selectedWsName = selectedWsId
    ? workstreams.find((ws) => ws.id === selectedWsId)?.name
    : null;

  return (
    <form ref={formRef} action={handleSubmit} className="flex flex-col gap-2.5 border-b pb-3 mb-2">
      <div className="flex gap-2">
        <div className="flex-1">
          <Label htmlFor="activity-type" className="sr-only">
            {t("type")}
          </Label>
          <Select value={selectedType} onValueChange={(v) => setSelectedType(v as ActivityType)}>
            <SelectTrigger className="w-full">
              <span className="flex flex-1 text-left truncate">
                {t(typeToKey[selectedType] as Parameters<typeof t>[0])}
              </span>
            </SelectTrigger>
            <SelectContent>
              {MANUAL_ACTIVITY_TYPES.map((at) => (
                <SelectItem key={at} value={at}>
                  {t(typeToKey[at] as Parameters<typeof t>[0])}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        {workstreams.length > 0 && (
          <div className="flex-1">
            <Label htmlFor="activity-ws" className="sr-only">
              {t("workstream")}
            </Label>
            <Select value={selectedWsId} onValueChange={(v) => setSelectedWsId(v ?? "")}>
              <SelectTrigger className="w-full">
                <span className="flex flex-1 text-left truncate text-muted-foreground">
                  {selectedWsName ?? t("allWorkstreams")}
                </span>
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="">
                  {t("allWorkstreams")}
                </SelectItem>
                {workstreams.map((ws) => (
                  <SelectItem key={ws.id} value={ws.id}>
                    {ws.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        )}
      </div>

      <Textarea
        name="content"
        placeholder={t("contentPlaceholder")}
        required
        className="min-h-12"
      />

      <div className="flex justify-end gap-2">
        <Button
          type="button"
          variant="ghost"
          size="sm"
          onClick={onClose}
          disabled={isPending}
        >
          {tCommon("cancel")}
        </Button>
        <Button type="submit" size="sm" disabled={isPending}>
          {tCommon("save")}
        </Button>
      </div>
    </form>
  );
}

"use client";

import { useRef, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Upload } from "lucide-react";
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
import { uploadDocument } from "@/actions/documents";

interface WorkstreamOption {
  id: string;
  name: string;
}

interface TaskOption {
  id: string;
  title: string;
}

interface DocumentUploadProps {
  dealId: string;
  workstreams: WorkstreamOption[];
  tasks: TaskOption[];
}

export function DocumentUpload({
  dealId,
  workstreams,
  tasks,
}: DocumentUploadProps) {
  const t = useTranslations("document");
  const tCommon = useTranslations("common");
  const [isPending, startTransition] = useTransition();
  const formRef = useRef<HTMLFormElement>(null);

  function handleSubmit(formData: FormData) {
    formData.set("dealId", dealId);
    startTransition(async () => {
      await uploadDocument(formData);
      formRef.current?.reset();
    });
  }

  return (
    <form
      ref={formRef}
      action={handleSubmit}
      className="flex flex-wrap items-end gap-3 rounded-lg border border-dashed p-4"
    >
      {/* File input */}
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="doc-file">{t("selectFile")}</Label>
        <Input id="doc-file" name="file" type="file" required />
      </div>

      {/* Workstream dropdown */}
      {workstreams.length > 0 && (
        <div className="flex flex-col gap-1.5">
          <Label>{t("workstream")}</Label>
          <Select name="workstreamId" defaultValue="">
            <SelectTrigger className="w-[180px]">
              <SelectValue placeholder={"\u2014"} />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="">{"\u2014"}</SelectItem>
              {workstreams.map((ws) => (
                <SelectItem key={ws.id} value={ws.id}>
                  {ws.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      )}

      {/* Task dropdown */}
      {tasks.length > 0 && (
        <div className="flex flex-col gap-1.5">
          <Label>{t("task")}</Label>
          <Select name="taskId" defaultValue="">
            <SelectTrigger className="w-[180px]">
              <SelectValue placeholder={"\u2014"} />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="">{"\u2014"}</SelectItem>
              {tasks.map((task) => (
                <SelectItem key={task.id} value={task.id}>
                  {task.title}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      )}

      <Button type="submit" disabled={isPending} size="sm">
        <Upload className="mr-1.5 size-3.5" />
        {isPending ? tCommon("loading") : t("upload")}
      </Button>
    </form>
  );
}

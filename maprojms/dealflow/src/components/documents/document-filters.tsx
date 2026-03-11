"use client";

import { useTranslations } from "next-intl";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
} from "@/components/ui/select";
import type { DealOption } from "@/components/documents/document-hub";

interface DocumentFiltersProps {
  deals: DealOption[];
  dealId: string;
  workstreamId: string;
  fileType: string;
  uploaderId: string;
  onDealChange: (value: string) => void;
  onWorkstreamChange: (value: string) => void;
  onFileTypeChange: (value: string) => void;
  onUploaderChange: (value: string) => void;
}

const FILE_TYPE_OPTIONS = [
  { value: "word", label: "Word (.doc/.docx)" },
  { value: "pdf", label: "PDF (.pdf)" },
  { value: "excel", label: "Excel (.xls/.xlsx)" },
  { value: "ppt", label: "PPT (.ppt/.pptx)" },
  { value: "image", label: "Image" },
  { value: "other", label: "Other" },
];

export function DocumentFilters({
  deals,
  dealId,
  workstreamId,
  fileType,
  uploaderId,
  onDealChange,
  onWorkstreamChange,
  onFileTypeChange,
  onUploaderChange,
}: DocumentFiltersProps) {
  const t = useTranslations("document");

  const selectedDeal = deals.find((d) => d.id === dealId);
  const workstreams = selectedDeal?.workstreams ?? [];
  const members = selectedDeal?.members ?? [];

  return (
    <div className="space-y-4">
      {/* Deal filter */}
      <div>
        <label className="mb-1 block text-xs text-muted-foreground">
          {t("allDeals")}
        </label>
        <Select value={dealId} onValueChange={(v) => onDealChange(v ?? "")}>
          <SelectTrigger className="w-full h-8 text-sm">
            <span className="truncate">
              {dealId
                ? deals.find((d) => d.id === dealId)?.name
                : t("allDeals")}
            </span>
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="">{t("allDeals")}</SelectItem>
            {deals.map((d) => (
              <SelectItem key={d.id} value={d.id}>
                {d.name}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      {/* Workstream filter (only when a deal is selected) */}
      {dealId && workstreams.length > 0 && (
        <div>
          <label className="mb-1 block text-xs text-muted-foreground">
            {t("workstream")}
          </label>
          <Select
            value={workstreamId}
            onValueChange={(v) => onWorkstreamChange(v ?? "")}
          >
            <SelectTrigger className="w-full h-8 text-sm">
              <span className="truncate">
                {workstreamId
                  ? workstreams.find((w) => w.id === workstreamId)?.name
                  : t("allWorkstreams")}
              </span>
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="">{t("allWorkstreams")}</SelectItem>
              {workstreams.map((w) => (
                <SelectItem key={w.id} value={w.id}>
                  {w.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      )}

      {/* File type filter */}
      <div>
        <label className="mb-1 block text-xs text-muted-foreground">
          {t("allTypes")}
        </label>
        <Select
          value={fileType}
          onValueChange={(v) => onFileTypeChange(v ?? "")}
        >
          <SelectTrigger className="w-full h-8 text-sm">
            <span className="truncate">
              {fileType
                ? FILE_TYPE_OPTIONS.find((o) => o.value === fileType)?.label
                : t("allTypes")}
            </span>
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="">{t("allTypes")}</SelectItem>
            {FILE_TYPE_OPTIONS.map((opt) => (
              <SelectItem key={opt.value} value={opt.value}>
                {opt.label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      {/* Uploader filter (only when a deal is selected) */}
      {dealId && members.length > 0 && (
        <div>
          <label className="mb-1 block text-xs text-muted-foreground">
            {t("uploader")}
          </label>
          <Select
            value={uploaderId}
            onValueChange={(v) => onUploaderChange(v ?? "")}
          >
            <SelectTrigger className="w-full h-8 text-sm">
              <span className="truncate">
                {uploaderId
                  ? members.find((m) => m.id === uploaderId)?.name
                  : t("uploader")}
              </span>
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="">{t("uploader")}</SelectItem>
              {members.map((m) => (
                <SelectItem key={m.id} value={m.id}>
                  {m.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      )}
    </div>
  );
}

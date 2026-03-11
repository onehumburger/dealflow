"use client";

import { useMemo, useState } from "react";
import { useTranslations } from "next-intl";
import { Search } from "lucide-react";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
} from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { DocumentFilters } from "@/components/documents/document-filters";
import { DocumentCard } from "@/components/documents/document-card";
import { useDocumentPanel } from "@/hooks/use-document-panel";

export type DocumentItem = {
  id: string;
  name: string;
  fileType: string;
  fileSize: number;
  currentVersion: number;
  createdAt: string;
  updatedAt: string;
  deal: { id: string; name: string };
  workstream: { id: string; name: string } | null;
  task: { id: string; title: string } | null;
  uploadedBy: { id: string; name: string };
};

export type DealOption = {
  id: string;
  name: string;
  workstreams: { id: string; name: string }[];
  members: { id: string; name: string }[];
};

const PAGE_SIZE = 50;

interface DocumentHubProps {
  documents: DocumentItem[];
  deals: DealOption[];
}

export function DocumentHub({ documents, deals }: DocumentHubProps) {
  const t = useTranslations("document");
  const tCommon = useTranslations("common");

  const { documentId, open } = useDocumentPanel();

  // Filter state
  const [dealId, setDealId] = useState("");
  const [workstreamId, setWorkstreamId] = useState("");
  const [fileType, setFileType] = useState("");
  const [uploaderId, setUploaderId] = useState("");
  const [searchQuery, setSearchQuery] = useState("");

  // Sort state
  const [sortBy, setSortBy] = useState("date");

  // Pagination state
  const [page, setPage] = useState(0);

  // Reset dependent filters when deal changes
  function handleDealChange(value: string) {
    setDealId(value);
    setWorkstreamId("");
    setUploaderId("");
    setPage(0);
  }

  function handleWorkstreamChange(value: string) {
    setWorkstreamId(value);
    setPage(0);
  }

  function handleFileTypeChange(value: string) {
    setFileType(value);
    setPage(0);
  }

  function handleUploaderChange(value: string) {
    setUploaderId(value);
    setPage(0);
  }

  function handleSearchChange(value: string) {
    setSearchQuery(value);
    setPage(0);
  }

  // Filter + sort + paginate
  const filtered = useMemo(() => {
    let result = documents;

    // Filter by deal
    if (dealId) {
      result = result.filter((d) => d.deal.id === dealId);
    }

    // Filter by workstream
    if (workstreamId) {
      result = result.filter((d) => d.workstream?.id === workstreamId);
    }

    // Filter by file type category
    if (fileType) {
      result = result.filter((d) => {
        const ext = d.fileType.toLowerCase();
        switch (fileType) {
          case "word":
            return ext === "doc" || ext === "docx";
          case "pdf":
            return ext === "pdf";
          case "excel":
            return ext === "xls" || ext === "xlsx";
          case "ppt":
            return ext === "ppt" || ext === "pptx";
          case "image":
            return ["jpg", "jpeg", "png", "gif", "bmp", "svg", "webp"].includes(ext);
          case "other":
            return !["doc", "docx", "pdf", "xls", "xlsx", "ppt", "pptx", "jpg", "jpeg", "png", "gif", "bmp", "svg", "webp"].includes(ext);
          default:
            return true;
        }
      });
    }

    // Filter by uploader
    if (uploaderId) {
      result = result.filter((d) => d.uploadedBy.id === uploaderId);
    }

    // Filter by search query
    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      result = result.filter(
        (d) =>
          d.name.toLowerCase().includes(q) ||
          d.deal.name.toLowerCase().includes(q) ||
          (d.workstream?.name.toLowerCase().includes(q) ?? false) ||
          (d.task?.title.toLowerCase().includes(q) ?? false)
      );
    }

    // Sort
    result = [...result].sort((a, b) => {
      switch (sortBy) {
        case "name":
          return a.name.localeCompare(b.name);
        case "size":
          return b.fileSize - a.fileSize;
        case "date":
        default:
          return new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime();
      }
    });

    return result;
  }, [documents, dealId, workstreamId, fileType, uploaderId, searchQuery, sortBy]);

  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const paginated = filtered.slice(page * PAGE_SIZE, (page + 1) * PAGE_SIZE);

  return (
    <div className="flex gap-6">
      <div className="w-[240px] shrink-0">
        <DocumentFilters
          deals={deals}
          dealId={dealId}
          workstreamId={workstreamId}
          fileType={fileType}
          uploaderId={uploaderId}
          onDealChange={handleDealChange}
          onWorkstreamChange={handleWorkstreamChange}
          onFileTypeChange={handleFileTypeChange}
          onUploaderChange={handleUploaderChange}
        />
      </div>
      <div className="flex-1 min-w-0">
        {/* Search bar + Sort */}
        <div className="mb-4 flex items-center gap-3">
          <div className="relative flex-1">
            <Search className="absolute left-2.5 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              placeholder={tCommon("search")}
              value={searchQuery}
              onChange={(e) => handleSearchChange(e.target.value)}
              className="pl-8"
            />
          </div>
          <Select value={sortBy} onValueChange={(v) => setSortBy(v ?? "date")}>
            <SelectTrigger className="w-28 h-8 text-sm">
              <span>
                {sortBy === "date"
                  ? t("sortByDate")
                  : sortBy === "name"
                    ? t("sortByName")
                    : t("sortBySize")}
              </span>
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="date">{t("sortByDate")}</SelectItem>
              <SelectItem value="name">{t("sortByName")}</SelectItem>
              <SelectItem value="size">{t("sortBySize")}</SelectItem>
            </SelectContent>
          </Select>
        </div>

        {/* Document card list */}
        <div
          className={`space-y-1 ${documentId ? "opacity-50" : ""}`}
        >
          {paginated.length === 0 ? (
            <p className="py-8 text-center text-sm text-muted-foreground">
              {t("noDocuments")}
            </p>
          ) : (
            paginated.map((doc) => (
              <DocumentCard
                key={doc.id}
                document={doc}
                onClick={() => open(doc.id)}
              />
            ))
          )}
        </div>

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="mt-4 flex items-center justify-center gap-2">
            <Button
              variant="outline"
              size="sm"
              disabled={page === 0}
              onClick={() => setPage((p) => p - 1)}
            >
              &lsaquo;
            </Button>
            <span className="text-sm text-muted-foreground">
              {page + 1} / {totalPages}
            </span>
            <Button
              variant="outline"
              size="sm"
              disabled={page >= totalPages - 1}
              onClick={() => setPage((p) => p + 1)}
            >
              &rsaquo;
            </Button>
          </div>
        )}
      </div>
    </div>
  );
}

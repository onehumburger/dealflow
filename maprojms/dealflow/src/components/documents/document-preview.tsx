"use client";

/* eslint-disable @next/next/no-img-element */
import { useEffect, useState } from "react";
import { File as FileIcon, Loader2 } from "lucide-react";

interface DocumentPreviewProps {
  documentId: string;
  fileName: string;
  fileType: string;
}

const TEXT_EXTENSIONS = ["txt", "md", "csv", "json", "xml", "html", "log"];

export function DocumentPreview({
  documentId,
  fileName,
  fileType,
}: DocumentPreviewProps) {
  const previewUrl = `/api/documents/${documentId}/download?preview=true`;

  if (fileType === "pdf") {
    return (
      <iframe
        src={previewUrl}
        title={fileName}
        className="w-full h-64 rounded-md border"
      />
    );
  }

  if (["jpg", "jpeg", "png", "gif", "bmp", "svg", "webp"].includes(fileType)) {
    return (
      <img
        src={previewUrl}
        alt={fileName}
        className="w-full max-h-64 object-contain rounded-md border"
      />
    );
  }

  if (TEXT_EXTENSIONS.includes(fileType)) {
    return <TextPreview url={previewUrl} />;
  }

  if (["docx", "doc"].includes(fileType)) {
    return <DocxPreview url={previewUrl} />;
  }

  return (
    <div className="flex h-32 items-center justify-center rounded-md border bg-muted">
      <FileIcon className="size-10 text-muted-foreground" />
    </div>
  );
}

function TextPreview({ url }: { url: string }) {
  const [text, setText] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    fetch(url)
      .then((r) => r.text())
      .then((t) => {
        if (!cancelled) setText(t);
      })
      .catch(() => {
        if (!cancelled) setText(null);
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [url]);

  if (loading) {
    return (
      <div className="flex h-32 items-center justify-center rounded-md border bg-muted">
        <Loader2 className="size-5 animate-spin text-muted-foreground" />
      </div>
    );
  }

  if (text === null) {
    return (
      <div className="flex h-32 items-center justify-center rounded-md border bg-muted">
        <FileIcon className="size-10 text-muted-foreground" />
      </div>
    );
  }

  return (
    <pre className="max-h-64 overflow-auto whitespace-pre-wrap rounded-md border bg-muted p-3 text-xs leading-relaxed">
      {text}
    </pre>
  );
}

function DocxPreview({ url }: { url: string }) {
  const [html, setHtml] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const res = await fetch(url);
        const arrayBuffer = await res.arrayBuffer();
        const mammoth = await import("mammoth");
        const result = await mammoth.convertToHtml({ arrayBuffer });
        if (!cancelled) setHtml(result.value);
      } catch {
        if (!cancelled) setHtml(null);
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [url]);

  if (loading) {
    return (
      <div className="flex h-32 items-center justify-center rounded-md border bg-muted">
        <Loader2 className="size-5 animate-spin text-muted-foreground" />
      </div>
    );
  }

  if (html === null) {
    return (
      <div className="flex h-32 items-center justify-center rounded-md border bg-muted">
        <FileIcon className="size-10 text-muted-foreground" />
      </div>
    );
  }

  return (
    <div
      className="max-h-64 overflow-auto rounded-md border bg-white p-3 text-sm leading-relaxed prose prose-sm max-w-none"
      dangerouslySetInnerHTML={{ __html: html }}
    />
  );
}

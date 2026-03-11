"use client";

import { useMemo } from "react";
import { useTranslations } from "next-intl";
import { DocumentCard } from "@/components/documents/document-card";
import { DocumentDetailPanel } from "@/components/documents/document-detail-panel";
import { useDocumentPanel } from "@/hooks/use-document-panel";
import type { DocumentItem } from "@/components/documents/document-hub";

interface WorkstreamInfo {
  id: string;
  name: string;
  tasks: { id: string; title: string }[];
}

interface DealDocumentsContentProps {
  documents: DocumentItem[];
  workstreams: WorkstreamInfo[];
}

type TaskGroup = {
  title: string;
  docs: DocumentItem[];
};

type WorkstreamGroup = {
  name: string;
  tasks: Map<string, TaskGroup>;
};

export function DealDocumentsContent({
  documents,
  workstreams,
}: DealDocumentsContentProps) {
  const t = useTranslations("document");
  const { open } = useDocumentPanel();

  // Group documents: general docs (taskId is null) and by workstream → task
  const { generalDocs, docsByWorkstream } = useMemo(() => {
    const general: DocumentItem[] = [];
    const wsMap = new Map<string, WorkstreamGroup>();

    // Initialize workstream groups in order
    for (const ws of workstreams) {
      const taskMap = new Map<string, TaskGroup>();
      for (const task of ws.tasks) {
        taskMap.set(task.id, { title: task.title, docs: [] });
      }
      wsMap.set(ws.id, { name: ws.name, tasks: taskMap });
    }

    for (const doc of documents) {
      if (!doc.task) {
        // No task association → general documents
        general.push(doc);
      } else if (doc.workstream) {
        // Has task + workstream → group under workstream → task
        const wsGroup = wsMap.get(doc.workstream.id);
        if (wsGroup) {
          const taskGroup = wsGroup.tasks.get(doc.task.id);
          if (taskGroup) {
            taskGroup.docs.push(doc);
          } else {
            // Task not found in prebuilt map (edge case) — add it
            wsGroup.tasks.set(doc.task.id, {
              title: doc.task.title,
              docs: [doc],
            });
          }
        } else {
          // Workstream not in prebuilt map (edge case) — add it
          const taskMap = new Map<string, TaskGroup>();
          taskMap.set(doc.task.id, {
            title: doc.task.title,
            docs: [doc],
          });
          wsMap.set(doc.workstream.id, {
            name: doc.workstream.name,
            tasks: taskMap,
          });
        }
      } else {
        // Has task but no workstream (unusual) → treat as general
        general.push(doc);
      }
    }

    return { generalDocs: general, docsByWorkstream: wsMap };
  }, [documents, workstreams]);

  // Check if there are any documents at all
  const hasAnyDocs =
    generalDocs.length > 0 ||
    Array.from(docsByWorkstream.values()).some((ws) =>
      Array.from(ws.tasks.values()).some((tg) => tg.docs.length > 0)
    );

  if (!hasAnyDocs) {
    return (
      <>
        <p className="py-8 text-center text-sm text-muted-foreground">
          {t("noDocuments")}
        </p>
        <DocumentDetailPanel documents={documents} />
      </>
    );
  }

  return (
    <>
      <div className="space-y-6">
        {/* General documents (no task association) */}
        {generalDocs.length > 0 && (
          <section>
            <h2 className="mb-2 text-sm font-semibold text-muted-foreground">
              {t("generalDocuments")}
            </h2>
            <div className="space-y-1">
              {generalDocs.map((doc) => (
                <DocumentCard
                  key={doc.id}
                  document={doc}
                  onClick={() => open(doc.id)}
                />
              ))}
            </div>
          </section>
        )}

        {/* Documents grouped by workstream → task */}
        {Array.from(docsByWorkstream.entries()).map(([wsId, wsGroup]) => {
          // Only render workstreams that have at least one document
          const hasDocs = Array.from(wsGroup.tasks.values()).some(
            (tg) => tg.docs.length > 0
          );
          if (!hasDocs) return null;

          return (
            <section key={wsId}>
              <h2 className="mb-3 text-sm font-semibold">{wsGroup.name}</h2>
              <div className="space-y-4 pl-3 border-l-2 border-muted">
                {Array.from(wsGroup.tasks.entries()).map(
                  ([taskId, taskGroup]) => {
                    if (taskGroup.docs.length === 0) return null;

                    return (
                      <div key={taskId}>
                        <h3 className="mb-1.5 text-xs font-medium text-muted-foreground">
                          {taskGroup.title}
                        </h3>
                        <div className="space-y-1">
                          {taskGroup.docs.map((doc) => (
                            <DocumentCard
                              key={doc.id}
                              document={doc}
                              onClick={() => open(doc.id)}
                            />
                          ))}
                        </div>
                      </div>
                    );
                  }
                )}
              </div>
            </section>
          );
        })}
      </div>

      <DocumentDetailPanel documents={documents} />
    </>
  );
}

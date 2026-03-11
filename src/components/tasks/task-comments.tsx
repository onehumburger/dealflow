"use client";

import { useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Send } from "lucide-react";
import { addTaskComment } from "@/actions/tasks";

interface CommentData {
  id: string;
  content: string;
  createdAt: Date;
  author: { id: string; name: string };
}

interface TaskCommentsProps {
  taskId: string;
  comments: CommentData[];
  onRefresh: () => void;
}

export function TaskComments({ taskId, comments, onRefresh }: TaskCommentsProps) {
  const t = useTranslations("task");
  const [isPending, startTransition] = useTransition();
  const [content, setContent] = useState("");

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!content.trim()) return;

    startTransition(async () => {
      await addTaskComment(taskId, content.trim());
      setContent("");
      onRefresh();
    });
  }

  function formatTime(date: Date) {
    const d = new Date(date);
    return new Intl.DateTimeFormat(undefined, {
      month: "short",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    }).format(d);
  }

  return (
    <div>
      <span className="mb-1.5 block text-xs font-medium text-muted-foreground">
        {t("addComment")}
      </span>

      {/* Thread */}
      <div className="flex flex-col gap-3 mb-3">
        {comments.length === 0 && (
          <p className="text-xs text-muted-foreground py-2">--</p>
        )}
        {comments.map((c) => (
          <div key={c.id} className="flex gap-2">
            <Avatar size="sm">
              <AvatarFallback>
                {c.author.name.charAt(0).toUpperCase()}
              </AvatarFallback>
            </Avatar>
            <div className="flex-1 min-w-0">
              <div className="flex items-baseline gap-2">
                <span className="text-xs font-medium">{c.author.name}</span>
                <span className="text-[10px] text-muted-foreground">
                  {formatTime(c.createdAt)}
                </span>
              </div>
              <p className="text-xs text-foreground whitespace-pre-wrap mt-0.5">
                {c.content}
              </p>
            </div>
          </div>
        ))}
      </div>

      {/* Input */}
      <form onSubmit={handleSubmit} className="flex items-end gap-1.5">
        <Textarea
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder={t("addComment")}
          className="min-h-8 text-xs"
          rows={1}
          onKeyDown={(e) => {
            if (e.key === "Enter" && !e.shiftKey) {
              e.preventDefault();
              handleSubmit(e);
            }
          }}
        />
        <Button
          type="submit"
          size="icon-xs"
          disabled={isPending || !content.trim()}
        >
          <Send className="size-3" />
        </Button>
      </form>
    </div>
  );
}

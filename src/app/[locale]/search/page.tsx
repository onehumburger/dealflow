"use client";

import { useRef, useState, useTransition } from "react";
import { useLocale, useTranslations } from "next-intl";
import Link from "next/link";
import { Search, Briefcase, CheckSquare, MessageSquare, Users, Scale } from "lucide-react";
import { Input } from "@/components/ui/input";
import { globalSearch } from "@/actions/search";

interface SearchResult {
  id: string;
  type: "deal" | "task" | "activity" | "contact" | "decision";
  title: string;
  subtitle: string;
  href: string;
}

interface SearchResults {
  deals: SearchResult[];
  tasks: SearchResult[];
  activity: SearchResult[];
  contacts: SearchResult[];
  decisions: SearchResult[];
}

const typeIcons = {
  deal: Briefcase,
  task: CheckSquare,
  activity: MessageSquare,
  contact: Users,
  decision: Scale,
};

export default function SearchPage() {
  const locale = useLocale();
  const t = useTranslations("search");
  const tCommon = useTranslations("common");
  const tNav = useTranslations("nav");
  const tTask = useTranslations("task");
  const tActivity = useTranslations("activity");
  const tContact = useTranslations("contact");
  const tDecision = useTranslations("decision");

  const [query, setQuery] = useState("");
  const [results, setResults] = useState<SearchResults | null>(null);
  const [isPending, startTransition] = useTransition();

  const timeoutRef = useRef<NodeJS.Timeout>(undefined);

  function handleSearch(value: string) {
    setQuery(value);
    clearTimeout(timeoutRef.current);
    if (value.trim().length < 2) {
      setResults(null);
      return;
    }
    timeoutRef.current = setTimeout(() => {
      startTransition(async () => {
        const data = await globalSearch(value, locale);
        setResults(data);
      });
    }, 300);
  }

  const groupLabels: Record<keyof SearchResults, string> = {
    deals: tNav("deals"),
    tasks: tTask("tasks"),
    activity: t("activityResults"),
    contacts: tContact("contacts"),
    decisions: tDecision("decisions"),
  };

  const totalResults = results
    ? results.deals.length +
      results.tasks.length +
      results.activity.length +
      results.contacts.length +
      results.decisions.length
    : 0;

  return (
    <div className="mx-auto max-w-3xl px-4 py-6 sm:px-6">
      <h1 className="mb-4 text-2xl font-bold">{tCommon("search")}</h1>

      <div className="relative">
        <Search className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          value={query}
          onChange={(e) => handleSearch(e.target.value)}
          placeholder={t("placeholder")}
          className="pl-9"
          autoFocus
        />
      </div>

      {isPending && (
        <p className="mt-4 text-sm text-muted-foreground">{tCommon("loading")}</p>
      )}

      {results && !isPending && totalResults === 0 && query.trim().length >= 2 && (
        <p className="mt-6 text-center text-sm text-muted-foreground">
          {tCommon("noResults")}
        </p>
      )}

      {results && !isPending && totalResults > 0 && (
        <div className="mt-4 space-y-6">
          {(Object.keys(results) as (keyof SearchResults)[]).map((group) => {
            const items = results[group];
            if (items.length === 0) return null;

            return (
              <div key={group}>
                <h2 className="mb-2 text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                  {groupLabels[group]} ({items.length})
                </h2>
                <div className="divide-y rounded-lg border bg-card">
                  {items.map((item) => {
                    const Icon = typeIcons[item.type];
                    return (
                      <Link
                        key={`${item.type}-${item.id}`}
                        href={item.href}
                        className="flex items-center gap-3 px-4 py-2.5 text-sm hover:bg-muted/50 transition-colors"
                      >
                        <Icon className="size-4 shrink-0 text-muted-foreground" />
                        <div className="min-w-0 flex-1">
                          <p className="truncate font-medium">{item.title}</p>
                          {item.subtitle && (
                            <p className="truncate text-xs text-muted-foreground">
                              {item.subtitle}
                            </p>
                          )}
                        </div>
                      </Link>
                    );
                  })}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

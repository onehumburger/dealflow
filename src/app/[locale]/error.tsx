"use client";

import { useTranslations } from "next-intl";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export default function RootError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  const t = useTranslations("error");

  return (
    <div className="flex min-h-[60vh] items-center justify-center px-4">
      <Card className="w-full max-w-md text-center">
        <CardHeader>
          <CardTitle className="text-lg">{t("title")}</CardTitle>
        </CardHeader>
        <CardContent className="flex flex-col items-center gap-4">
          <p className="text-sm text-muted-foreground">
            {t("description")}
          </p>
          {error.digest && (
            <p className="font-mono text-xs text-muted-foreground">
              {t("errorCode")}: {error.digest}
            </p>
          )}
          <Button onClick={reset}>{t("tryAgain")}</Button>
        </CardContent>
      </Card>
    </div>
  );
}

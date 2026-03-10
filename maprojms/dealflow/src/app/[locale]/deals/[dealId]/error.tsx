"use client";

import { useTranslations } from "next-intl";
import { useParams } from "next/navigation";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export default function DealDetailError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  const t = useTranslations("error");
  const params = useParams();
  const locale = params.locale as string;

  return (
    <div className="flex min-h-[60vh] items-center justify-center px-4">
      <Card className="w-full max-w-md text-center">
        <CardHeader>
          <CardTitle className="text-lg">{t("dealErrorTitle")}</CardTitle>
        </CardHeader>
        <CardContent className="flex flex-col items-center gap-4">
          <p className="text-sm text-muted-foreground">
            {t("dealErrorDescription")}
          </p>
          {error.digest && (
            <p className="font-mono text-xs text-muted-foreground">
              {t("errorCode")}: {error.digest}
            </p>
          )}
          <div className="flex gap-2">
            <Button onClick={reset}>{t("tryAgain")}</Button>
            <Link href={`/${locale}/deals`}>
              <Button variant="outline">{t("backToDeals")}</Button>
            </Link>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}

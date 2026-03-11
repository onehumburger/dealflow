import { auth } from "@/lib/auth";
import { redirect } from "next/navigation";
import { getLocale, getTranslations } from "next-intl/server";
import { getCalendarEvents } from "@/actions/calendar";
import { CalendarView } from "@/components/calendar/calendar-view";

export const dynamic = "force-dynamic";

export default async function DashboardCalendarPage() {
  const session = await auth();
  const locale = await getLocale();

  if (!session?.user?.id) {
    redirect(`/${locale}/login`);
  }

  const t = await getTranslations("calendar");
  const now = new Date();
  const { events, deals } = await getCalendarEvents(
    now.getFullYear(),
    now.getMonth() + 1
  );

  return (
    <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6">
      <h1 className="mb-4 text-2xl font-bold">{t("calendar")}</h1>
      <CalendarView initialEvents={events} deals={deals} />
    </div>
  );
}

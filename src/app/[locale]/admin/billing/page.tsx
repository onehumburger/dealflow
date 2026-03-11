import { auth } from "@/lib/auth";
import { redirect } from "next/navigation";
import { getLocale } from "next-intl/server";
import {
  getFilteredTimeEntries,
  getDealBillingRates,
  getAdminFilterOptions,
} from "@/actions/billing";
import { BillingPageClient } from "@/components/billing/billing-page-client";

export default async function AdminBillingPage() {
  const session = await auth();
  const locale = await getLocale();

  if (!session?.user?.id) {
    redirect(`/${locale}/login`);
  }

  const role = (session.user as unknown as { role: string }).role;
  if (role !== "Admin") {
    redirect(`/${locale}/dashboard`);
  }

  const [entries, rates, options] = await Promise.all([
    getFilteredTimeEntries({}),
    getDealBillingRates(),
    getAdminFilterOptions(),
  ]);

  return (
    <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6">
      <BillingPageClient
        deals={options.deals}
        users={options.users}
        initialEntries={entries}
        initialRates={rates}
      />
    </div>
  );
}

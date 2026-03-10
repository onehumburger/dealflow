import { auth } from "@/lib/auth";
import { getLocale, getTranslations } from "next-intl/server";
import Link from "next/link";
import { LocaleSwitcher } from "./locale-switcher";
import { LogoutButton } from "./logout-button";

export async function AppShell({ children }: { children: React.ReactNode }) {
  const session = await auth();
  const locale = await getLocale();
  const t = await getTranslations("nav");

  if (!session) {
    return <>{children}</>;
  }

  const navLinks = [
    { href: `/${locale}/dashboard`, label: t("dashboard") },
    { href: `/${locale}/deals`, label: t("deals") },
    { href: `/${locale}/tasks`, label: t("myTasks") },
    { href: `/${locale}/contacts`, label: t("contacts") },
  ];

  return (
    <div className="min-h-screen bg-muted/30">
      <header className="sticky top-0 z-50 border-b bg-background">
        <div className="flex h-14 items-center gap-4 px-4 sm:px-6">
          <Link
            href={`/${locale}/dashboard`}
            className="text-lg font-bold tracking-tight"
          >
            DealFlow
          </Link>

          <nav className="ml-4 hidden items-center gap-1 md:flex">
            {navLinks.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className="rounded-md px-3 py-1.5 text-sm font-medium text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
              >
                {link.label}
              </Link>
            ))}
          </nav>

          <div className="ml-auto flex items-center gap-2">
            <LocaleSwitcher />
            <span className="hidden text-sm text-muted-foreground sm:inline">
              {session.user?.name}
            </span>
            <LogoutButton />
          </div>
        </div>
      </header>

      <main>{children}</main>
    </div>
  );
}

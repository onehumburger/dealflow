import createMiddleware from "next-intl/middleware";
import { NextRequest, NextResponse } from "next/server";
import { routing } from "./i18n/routing";

const intlMiddleware = createMiddleware(routing);

export default async function middleware(request: NextRequest) {
  // Let next-intl handle locale routing first
  const response = intlMiddleware(request);

  const { pathname } = request.nextUrl;

  // Skip auth check for: login pages, API auth routes, static files
  if (
    pathname.includes("/login") ||
    pathname.startsWith("/api/auth") ||
    pathname.startsWith("/_next") ||
    pathname.includes(".")
  ) {
    return response;
  }

  // Check for Auth.js session token cookie (JWT strategy)
  const sessionToken =
    request.cookies.get("authjs.session-token")?.value ||
    request.cookies.get("__Secure-authjs.session-token")?.value;

  if (!sessionToken) {
    // Determine the locale from the pathname or use default
    const localeMatch = pathname.match(/^\/(zh|en)(\/|$)/);
    const locale = localeMatch ? localeMatch[1] : routing.defaultLocale;

    const loginUrl = new URL(`/${locale}/login`, request.url);
    return NextResponse.redirect(loginUrl);
  }

  return response;
}

export const config = {
  matcher: ["/((?!api|_next|.*\\..*).*)"],
};

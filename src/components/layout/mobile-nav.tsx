"use client";

import { useState } from "react";
import Link from "next/link";
import { Menu } from "lucide-react";
import {
  Sheet,
  SheetContent,
  SheetTrigger,
  SheetTitle,
  SheetDescription,
} from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";

interface NavLink {
  href: string;
  label: string;
}

export function MobileNav({ navLinks }: { navLinks: NavLink[] }) {
  const [open, setOpen] = useState(false);

  return (
    <Sheet open={open} onOpenChange={setOpen}>
      <SheetTrigger
        render={
          <Button variant="ghost" size="icon-sm" className="md:hidden" />
        }
      >
        <Menu className="size-5" />
        <span className="sr-only">Open menu</span>
      </SheetTrigger>
      <SheetContent side="left">
        <SheetTitle className="p-4 text-lg font-bold tracking-tight">
          DealFlow
        </SheetTitle>
        <SheetDescription className="sr-only">
          Navigation menu
        </SheetDescription>
        <nav className="flex flex-col gap-1 px-2">
          {navLinks.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              onClick={() => setOpen(false)}
              className="rounded-md px-3 py-2 text-sm font-medium text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
            >
              {link.label}
            </Link>
          ))}
        </nav>
      </SheetContent>
    </Sheet>
  );
}

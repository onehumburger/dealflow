"use client";

import { useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
} from "@/components/ui/dialog";
import { createUser, updateUser } from "@/actions/users";
import type { UserRole } from "@/generated/prisma/client";

interface UserData {
  id: string;
  name: string;
  email: string;
  role: UserRole;
}

interface UserFormProps {
  user?: UserData;
  trigger: React.ReactNode;
}

export function UserForm({ user, trigger }: UserFormProps) {
  const t = useTranslations("user");
  const tCommon = useTranslations("common");
  const [isPending, startTransition] = useTransition();
  const [open, setOpen] = useState(false);

  const isEdit = !!user;

  function handleSubmit(formData: FormData) {
    startTransition(async () => {
      if (isEdit && user) {
        await updateUser(user.id, {
          name: formData.get("name") as string,
          email: formData.get("email") as string,
          role: formData.get("role") as UserRole,
        });
      } else {
        await createUser(formData);
      }
      setOpen(false);
    });
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger nativeButton={false} render={<span />}>{trigger}</DialogTrigger>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>
            {isEdit ? tCommon("edit") : t("addUser")}
          </DialogTitle>
        </DialogHeader>

        <form action={handleSubmit} className="flex flex-col gap-4">
          {/* Name */}
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="user-name">{t("name")}</Label>
            <Input
              id="user-name"
              name="name"
              required
              defaultValue={user?.name ?? ""}
            />
          </div>

          {/* Email */}
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="user-email">{t("email")}</Label>
            <Input
              id="user-email"
              name="email"
              type="email"
              required
              defaultValue={user?.email ?? ""}
            />
          </div>

          {/* Password (create only) */}
          {!isEdit && (
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="user-password">{t("password")}</Label>
              <Input
                id="user-password"
                name="password"
                type="password"
                required
                minLength={6}
                placeholder={t("passwordPlaceholder")}
              />
            </div>
          )}

          {/* Role */}
          <div className="flex flex-col gap-1.5">
            <Label>{t("role")}</Label>
            <Select
              name="role"
              defaultValue={user?.role ?? "Member"}
            >
              <SelectTrigger className="w-full">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="Admin">{t("admin")}</SelectItem>
                <SelectItem value="Member">{t("member")}</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <DialogFooter>
            <Button type="submit" disabled={isPending}>
              {isPending
                ? tCommon("loading")
                : isEdit
                  ? tCommon("save")
                  : tCommon("create")}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}

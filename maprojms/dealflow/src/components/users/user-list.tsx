"use client";

import { useState, useTransition } from "react";
import { useTranslations } from "next-intl";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { UserForm } from "./user-form";
import { resetPassword, deleteUser } from "@/actions/users";
import type { UserRole } from "@/generated/prisma/client";

export interface UserItem {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  createdAt: Date;
}

interface UserListProps {
  users: UserItem[];
}

export function UserList({ users }: UserListProps) {
  const t = useTranslations("user");
  const tCommon = useTranslations("common");
  const [isPending, startTransition] = useTransition();
  const [resetUserId, setResetUserId] = useState<string | null>(null);
  const [newPassword, setNewPassword] = useState("");

  function handleResetPassword() {
    if (!resetUserId || !newPassword) return;
    startTransition(async () => {
      await resetPassword(resetUserId, newPassword);
      setResetUserId(null);
      setNewPassword("");
    });
  }

  function handleDelete(userId: string) {
    if (!confirm(t("deleteUserConfirm"))) return;
    startTransition(async () => {
      await deleteUser(userId);
    });
  }

  if (users.length === 0) {
    return (
      <p className="py-8 text-center text-sm text-muted-foreground">
        {tCommon("noResults")}
      </p>
    );
  }

  return (
    <>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>{t("name")}</TableHead>
            <TableHead>{t("email")}</TableHead>
            <TableHead>{t("role")}</TableHead>
            <TableHead />
          </TableRow>
        </TableHeader>
        <TableBody>
          {users.map((user) => (
            <TableRow key={user.id}>
              <TableCell className="font-medium">{user.name}</TableCell>
              <TableCell>{user.email}</TableCell>
              <TableCell>
                <Badge variant={user.role === "Admin" ? "default" : "outline"}>
                  {user.role === "Admin" ? t("admin") : t("member")}
                </Badge>
              </TableCell>
              <TableCell>
                <div className="flex items-center gap-1">
                  <UserForm
                    user={user}
                    trigger={
                      <button className="rounded px-1.5 py-0.5 text-xs text-muted-foreground hover:bg-muted">
                        {tCommon("edit")}
                      </button>
                    }
                  />
                  <button
                    className="rounded px-1.5 py-0.5 text-xs text-muted-foreground hover:bg-muted"
                    onClick={() => {
                      setResetUserId(user.id);
                      setNewPassword("");
                    }}
                  >
                    {t("resetPassword")}
                  </button>
                  <button
                    className="rounded px-1.5 py-0.5 text-xs text-red-500 hover:bg-red-50"
                    onClick={() => handleDelete(user.id)}
                    disabled={isPending}
                  >
                    {tCommon("delete")}
                  </button>
                </div>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>

      {/* Reset Password Dialog */}
      <Dialog
        open={resetUserId !== null}
        onOpenChange={(open) => {
          if (!open) {
            setResetUserId(null);
            setNewPassword("");
          }
        }}
      >
        <DialogContent className="sm:max-w-sm">
          <DialogHeader>
            <DialogTitle>{t("resetPassword")}</DialogTitle>
          </DialogHeader>
          <div className="flex flex-col gap-3">
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="new-password">{t("newPassword")}</Label>
              <Input
                id="new-password"
                type="password"
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                placeholder={t("newPasswordPlaceholder")}
                minLength={6}
              />
            </div>
          </div>
          <DialogFooter>
            <Button
              onClick={handleResetPassword}
              disabled={isPending || newPassword.length < 6}
            >
              {isPending ? tCommon("loading") : tCommon("save")}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
}

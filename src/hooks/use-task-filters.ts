"use client";

import { create } from "zustand";
import type { TaskStatus } from "@/generated/prisma/client";

interface TaskFiltersState {
  statusFilter: TaskStatus | "all";
  assigneeFilter: string | "all";
  setStatusFilter: (status: TaskStatus | "all") => void;
  setAssigneeFilter: (assigneeId: string | "all") => void;
  reset: () => void;
}

export const useTaskFilters = create<TaskFiltersState>((set) => ({
  statusFilter: "all",
  assigneeFilter: "all",
  setStatusFilter: (statusFilter) => set({ statusFilter }),
  setAssigneeFilter: (assigneeFilter) => set({ assigneeFilter }),
  reset: () => set({ statusFilter: "all", assigneeFilter: "all" }),
}));

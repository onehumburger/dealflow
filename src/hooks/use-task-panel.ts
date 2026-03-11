"use client";

import { create } from "zustand";

interface TaskPanelState {
  taskId: string | null;
  open: (taskId: string) => void;
  close: () => void;
}

export const useTaskPanel = create<TaskPanelState>((set) => ({
  taskId: null,
  open: (taskId) => set({ taskId }),
  close: () => set({ taskId: null }),
}));

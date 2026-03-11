"use client";

import { create } from "zustand";
import { persist } from "zustand/middleware";

interface TimerState {
  activeEntryId: string | null;
  taskId: string | null;
  taskTitle: string;
  dealName: string;
  startedAt: number | null; // timestamp ms
  start: (entryId: string, taskId: string, taskTitle: string, dealName: string) => void;
  stop: () => void;
}

export const useTimer = create<TimerState>()(
  persist(
    (set) => ({
      activeEntryId: null,
      taskId: null,
      taskTitle: "",
      dealName: "",
      startedAt: null,
      start: (entryId, taskId, taskTitle, dealName) =>
        set({
          activeEntryId: entryId,
          taskId,
          taskTitle,
          dealName,
          startedAt: Date.now(),
        }),
      stop: () =>
        set({
          activeEntryId: null,
          taskId: null,
          taskTitle: "",
          dealName: "",
          startedAt: null,
        }),
    }),
    {
      name: "dealflow-timer",
    }
  )
);

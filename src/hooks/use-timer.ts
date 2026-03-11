"use client";

import { create } from "zustand";
import { persist } from "zustand/middleware";

interface TimerState {
  activeEntryId: string | null;
  taskId: string | null;
  taskTitle: string;
  dealName: string;
  startedAt: number | null; // timestamp ms of current active segment
  accumulatedMs: number; // time accumulated from previous segments (pauses)
  paused: boolean;
  requestStop: boolean; // signals timer bar to show description input
  start: (entryId: string, taskId: string, taskTitle: string, dealName: string) => void;
  stop: () => void;
  pause: () => void;
  resume: () => void;
  triggerStop: () => void; // called by timer-button to request stop via timer bar
}

export const useTimer = create<TimerState>()(
  persist(
    (set, get) => ({
      activeEntryId: null,
      taskId: null,
      taskTitle: "",
      dealName: "",
      startedAt: null,
      accumulatedMs: 0,
      paused: false,
      requestStop: false,
      start: (entryId, taskId, taskTitle, dealName) =>
        set({
          activeEntryId: entryId,
          taskId,
          taskTitle,
          dealName,
          startedAt: Date.now(),
          accumulatedMs: 0,
          paused: false,
          requestStop: false,
        }),
      stop: () =>
        set({
          activeEntryId: null,
          taskId: null,
          taskTitle: "",
          dealName: "",
          startedAt: null,
          accumulatedMs: 0,
          paused: false,
          requestStop: false,
        }),
      pause: () => {
        const { startedAt, accumulatedMs } = get();
        const segmentMs = startedAt ? Date.now() - startedAt : 0;
        set({
          accumulatedMs: accumulatedMs + segmentMs,
          startedAt: null,
          paused: true,
        });
      },
      resume: () =>
        set({
          startedAt: Date.now(),
          paused: false,
        }),
      triggerStop: () =>
        set({ requestStop: true }),
    }),
    {
      name: "dealflow-timer",
    }
  )
);

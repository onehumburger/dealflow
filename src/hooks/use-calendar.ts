import { create } from "zustand";

interface CalendarState {
  year: number;
  month: number;
  showMilestones: boolean;
  showTasks: boolean;
  showActivity: boolean;
  selectedDealIds: string[] | null;
  prevMonth: () => void;
  nextMonth: () => void;
  goToToday: () => void;
  toggleMilestones: () => void;
  toggleTasks: () => void;
  toggleActivity: () => void;
  setSelectedDealIds: (ids: string[] | null) => void;
}

const now = new Date();

export const useCalendar = create<CalendarState>((set) => ({
  year: now.getFullYear(),
  month: now.getMonth() + 1,
  showMilestones: true,
  showTasks: true,
  showActivity: false,
  selectedDealIds: null,
  prevMonth: () =>
    set((s) => {
      if (s.month === 1) return { year: s.year - 1, month: 12 };
      return { month: s.month - 1 };
    }),
  nextMonth: () =>
    set((s) => {
      if (s.month === 12) return { year: s.year + 1, month: 1 };
      return { month: s.month + 1 };
    }),
  goToToday: () =>
    set({
      year: new Date().getFullYear(),
      month: new Date().getMonth() + 1,
    }),
  toggleMilestones: () => set((s) => ({ showMilestones: !s.showMilestones })),
  toggleTasks: () => set((s) => ({ showTasks: !s.showTasks })),
  toggleActivity: () => set((s) => ({ showActivity: !s.showActivity })),
  setSelectedDealIds: (ids) => set({ selectedDealIds: ids }),
}));

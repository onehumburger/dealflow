"use client";

import { create } from "zustand";

interface DocumentPanelState {
  documentId: string | null;
  open: (id: string) => void;
  close: () => void;
}

export const useDocumentPanel = create<DocumentPanelState>((set) => ({
  documentId: null,
  open: (id) => set({ documentId: id }),
  close: () => set({ documentId: null }),
}));

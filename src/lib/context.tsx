"use client";

import {
  createContext,
  useContext,
  useState,
  useEffect,
  useCallback,
  type ReactNode,
} from "react";
import type { AppState, TransactionType, Category, ParentConfig } from "./types";
import {
  loadState,
  addTransaction as addTx,
  updateHunger,
  addWish as addW,
  waterWish as waterW,
  deleteWish as deleteW,
  toggleAccessory as toggleAcc,
  approveTransaction as approveTx,
  sendHeart as sendH,
  updateParentConfig as updatePC,
  applyInterest as applyI,
  getBalance,
  getTotalSaved,
} from "./store";

type AppContextValue = {
  state: AppState;
  balance: number;
  totalSaved: number;
  addTransaction: (data: {
    amount: number;
    category: Category;
    type: TransactionType;
    note: string;
  }) => void;
  addWish: (data: { name: string; emoji: string; targetAmount: number }) => void;
  waterWish: (wishId: string, amount: number) => void;
  deleteWish: (wishId: string) => void;
  toggleAccessory: (accessoryId: string) => void;
  approveTransaction: (txId: string) => void;
  sendHeart: (txId: string) => void;
  updateParentConfig: (config: Partial<ParentConfig>) => void;
  applyInterest: () => void;
};

const AppContext = createContext<AppContextValue | null>(null);

export function AppProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AppState | null>(null);

  useEffect(() => {
    const s = loadState();
    setState(updateHunger(s));
  }, []);

  const addTransaction = useCallback(
    (data: { amount: number; category: Category; type: TransactionType; note: string }) => {
      setState((prev) => (prev ? addTx(prev, data) : prev));
    },
    []
  );

  const addWish = useCallback(
    (data: { name: string; emoji: string; targetAmount: number }) => {
      setState((prev) => (prev ? addW(prev, data) : prev));
    },
    []
  );

  const waterWish = useCallback((wishId: string, amount: number) => {
    setState((prev) => (prev ? waterW(prev, wishId, amount) : prev));
  }, []);

  const deleteWish = useCallback((wishId: string) => {
    setState((prev) => (prev ? deleteW(prev, wishId) : prev));
  }, []);

  const toggleAccessory = useCallback((accessoryId: string) => {
    setState((prev) => (prev ? toggleAcc(prev, accessoryId) : prev));
  }, []);

  const approveTransaction = useCallback((txId: string) => {
    setState((prev) => (prev ? approveTx(prev, txId) : prev));
  }, []);

  const sendHeart = useCallback((txId: string) => {
    setState((prev) => (prev ? sendH(prev, txId) : prev));
  }, []);

  const updateParentConfig = useCallback((config: Partial<ParentConfig>) => {
    setState((prev) => (prev ? updatePC(prev, config) : prev));
  }, []);

  const applyInterest = useCallback(() => {
    setState((prev) => (prev ? applyI(prev) : prev));
  }, []);

  if (!state) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <span className="text-4xl animate-bounce-coin">🪙</span>
      </div>
    );
  }

  const value: AppContextValue = {
    state,
    balance: getBalance(state.transactions),
    totalSaved: getTotalSaved(state.transactions),
    addTransaction,
    addWish,
    waterWish,
    deleteWish,
    toggleAccessory,
    approveTransaction,
    sendHeart,
    updateParentConfig,
    applyInterest,
  };

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
}

export function useApp(): AppContextValue {
  const ctx = useContext(AppContext);
  if (!ctx) throw new Error("useApp must be used within AppProvider");
  return ctx;
}

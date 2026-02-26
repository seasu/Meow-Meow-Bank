"use client";

import {
  createContext,
  useContext,
  useReducer,
  useEffect,
  useRef,
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

type Action =
  | { type: "INIT"; state: AppState }
  | { type: "ADD_TX"; data: { amount: number; category: Category; type: TransactionType; note: string } }
  | { type: "ADD_WISH"; data: { name: string; emoji: string; targetAmount: number } }
  | { type: "WATER_WISH"; wishId: string; amount: number }
  | { type: "DELETE_WISH"; wishId: string }
  | { type: "TOGGLE_ACCESSORY"; accessoryId: string }
  | { type: "APPROVE_TX"; txId: string }
  | { type: "SEND_HEART"; txId: string }
  | { type: "UPDATE_PARENT_CONFIG"; config: Partial<ParentConfig> }
  | { type: "APPLY_INTEREST" };

function reducer(state: AppState | null, action: Action): AppState | null {
  if (action.type === "INIT") return action.state;
  if (!state) return state;

  switch (action.type) {
    case "ADD_TX": return addTx(state, action.data);
    case "ADD_WISH": return addW(state, action.data);
    case "WATER_WISH": return waterW(state, action.wishId, action.amount);
    case "DELETE_WISH": return deleteW(state, action.wishId);
    case "TOGGLE_ACCESSORY": return toggleAcc(state, action.accessoryId);
    case "APPROVE_TX": return approveTx(state, action.txId);
    case "SEND_HEART": return sendH(state, action.txId);
    case "UPDATE_PARENT_CONFIG": return updatePC(state, action.config);
    case "APPLY_INTEREST": return applyI(state);
    default: return state;
  }
}

type AppContextValue = {
  state: AppState;
  balance: number;
  totalSaved: number;
  addTransaction: (data: { amount: number; category: Category; type: TransactionType; note: string }) => void;
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
  const [state, dispatch] = useReducer(reducer, null);
  const initialized = useRef(false);

  useEffect(() => {
    if (initialized.current) return;
    initialized.current = true;
    dispatch({ type: "INIT", state: updateHunger(loadState()) });
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
    addTransaction: (data) => dispatch({ type: "ADD_TX", data }),
    addWish: (data) => dispatch({ type: "ADD_WISH", data }),
    waterWish: (wishId, amount) => dispatch({ type: "WATER_WISH", wishId, amount }),
    deleteWish: (wishId) => dispatch({ type: "DELETE_WISH", wishId }),
    toggleAccessory: (accessoryId) => dispatch({ type: "TOGGLE_ACCESSORY", accessoryId }),
    approveTransaction: (txId) => dispatch({ type: "APPROVE_TX", txId }),
    sendHeart: (txId) => dispatch({ type: "SEND_HEART", txId }),
    updateParentConfig: (config) => dispatch({ type: "UPDATE_PARENT_CONFIG", config }),
    applyInterest: () => dispatch({ type: "APPLY_INTEREST" }),
  };

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
}

export function useApp(): AppContextValue {
  const ctx = useContext(AppContext);
  if (!ctx) throw new Error("useApp must be used within AppProvider");
  return ctx;
}

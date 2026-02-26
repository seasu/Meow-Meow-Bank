import type {
  AppState,
  Transaction,
  TransactionType,
  Category,
  Wish,
  BuildingLevel,
  ParentConfig,
} from "./types";
import {
  BUILDING_THRESHOLDS,
  ACCESSORIES,
  MAX_HUNGER,
  HUNGER_DECAY_PER_DAY,
  HUNGER_FEED_AMOUNT,
} from "./constants";

const STORAGE_KEY = "meow-meow-bank";

function defaultState(): AppState {
  return {
    transactions: [],
    wishes: [],
    profile: {
      name: "小朋友",
      lastRecordDate: null,
      streak: 0,
      catHunger: MAX_HUNGER,
      buildingLevel: 0,
      unlockedAccessories: [],
      equippedAccessories: [],
    },
    parentConfig: {
      interestRate: 1,
      interestPeriod: "weekly",
      lastInterestDate: new Date().toISOString().split("T")[0],
    },
  };
}

export function loadState(): AppState {
  if (typeof window === "undefined") return defaultState();
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return defaultState();
    return JSON.parse(raw) as AppState;
  } catch {
    return defaultState();
  }
}

export function saveState(state: AppState): void {
  if (typeof window === "undefined") return;
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function today(): string {
  return new Date().toISOString().split("T")[0];
}

function daysBetween(a: string, b: string): number {
  const d1 = new Date(a);
  const d2 = new Date(b);
  return Math.floor(Math.abs(d2.getTime() - d1.getTime()) / 86400000);
}

export function getBalance(transactions: Transaction[]): number {
  return transactions.reduce(
    (sum, tx) => (tx.type === "income" ? sum + tx.amount : sum - tx.amount),
    0
  );
}

export function getTotalSaved(transactions: Transaction[]): number {
  return transactions.reduce(
    (sum, tx) => (tx.type === "income" ? sum + tx.amount : sum),
    0
  );
}

export function addTransaction(
  state: AppState,
  data: { amount: number; category: Category; type: TransactionType; note: string }
): AppState {
  const tx: Transaction = {
    id: crypto.randomUUID(),
    amount: data.amount,
    category: data.category,
    type: data.type,
    note: data.note,
    createdAt: new Date().toISOString(),
    approved: false,
    parentHeart: false,
  };

  const todayStr = today();
  const prevDate = state.profile.lastRecordDate;
  let streak = state.profile.streak;

  if (!prevDate) {
    streak = 1;
  } else if (prevDate === todayStr) {
    // same day, no change
  } else if (daysBetween(prevDate, todayStr) === 1) {
    streak += 1;
  } else {
    streak = 1;
  }

  const hunger = Math.min(MAX_HUNGER, state.profile.catHunger + HUNGER_FEED_AMOUNT);

  const newTransactions = [...state.transactions, tx];
  const totalSaved = getTotalSaved(newTransactions);

  let buildingLevel: BuildingLevel = 0;
  if (totalSaved >= BUILDING_THRESHOLDS[2]) buildingLevel = 2;
  else if (totalSaved >= BUILDING_THRESHOLDS[1]) buildingLevel = 1;

  const unlockedAccessories = [...state.profile.unlockedAccessories];
  for (const acc of ACCESSORIES) {
    if (unlockedAccessories.includes(acc.id)) continue;
    if (acc.requirement.type === "streak" && streak >= acc.requirement.days) {
      unlockedAccessories.push(acc.id);
    }
    if (acc.requirement.type === "savings" && totalSaved >= acc.requirement.amount) {
      unlockedAccessories.push(acc.id);
    }
  }

  const newState: AppState = {
    ...state,
    transactions: newTransactions,
    profile: {
      ...state.profile,
      lastRecordDate: todayStr,
      streak,
      catHunger: hunger,
      buildingLevel,
      unlockedAccessories,
    },
  };

  saveState(newState);
  return newState;
}

export function updateHunger(state: AppState): AppState {
  const todayStr = today();
  const lastDate = state.profile.lastRecordDate;
  if (!lastDate) return state;

  const days = daysBetween(lastDate, todayStr);
  if (days <= 0) return state;

  const hunger = Math.max(0, state.profile.catHunger - days * HUNGER_DECAY_PER_DAY);
  const streak = days > 1 ? 0 : state.profile.streak;

  const newState: AppState = {
    ...state,
    profile: { ...state.profile, catHunger: hunger, streak },
  };
  saveState(newState);
  return newState;
}

export function addWish(
  state: AppState,
  data: { name: string; emoji: string; targetAmount: number }
): AppState {
  const wish: Wish = {
    id: crypto.randomUUID(),
    name: data.name,
    emoji: data.emoji,
    targetAmount: data.targetAmount,
    savedAmount: 0,
    createdAt: new Date().toISOString(),
    completedAt: null,
  };
  const newState: AppState = {
    ...state,
    wishes: [...state.wishes, wish],
  };
  saveState(newState);
  return newState;
}

export function waterWish(
  state: AppState,
  wishId: string,
  amount: number
): AppState {
  const balance = getBalance(state.transactions);
  if (amount > balance) return state;

  const wishes = state.wishes.map((w) => {
    if (w.id !== wishId) return w;
    const newSaved = Math.min(w.savedAmount + amount, w.targetAmount);
    return {
      ...w,
      savedAmount: newSaved,
      completedAt: newSaved >= w.targetAmount ? new Date().toISOString() : null,
    };
  });

  const newState: AppState = { ...state, wishes };
  saveState(newState);
  return newState;
}

export function toggleAccessory(state: AppState, accessoryId: string): AppState {
  const equipped = state.profile.equippedAccessories.includes(accessoryId)
    ? state.profile.equippedAccessories.filter((id) => id !== accessoryId)
    : [...state.profile.equippedAccessories, accessoryId];

  const newState: AppState = {
    ...state,
    profile: { ...state.profile, equippedAccessories: equipped },
  };
  saveState(newState);
  return newState;
}

export function approveTransaction(state: AppState, txId: string): AppState {
  const transactions = state.transactions.map((tx) =>
    tx.id === txId ? { ...tx, approved: true } : tx
  );
  const newState: AppState = { ...state, transactions };
  saveState(newState);
  return newState;
}

export function sendHeart(state: AppState, txId: string): AppState {
  const transactions = state.transactions.map((tx) =>
    tx.id === txId ? { ...tx, parentHeart: true } : tx
  );
  const newState: AppState = { ...state, transactions };
  saveState(newState);
  return newState;
}

export function updateParentConfig(
  state: AppState,
  config: Partial<ParentConfig>
): AppState {
  const newState: AppState = {
    ...state,
    parentConfig: { ...state.parentConfig, ...config },
  };
  saveState(newState);
  return newState;
}

export function applyInterest(state: AppState): AppState {
  const balance = getBalance(state.transactions);
  if (balance <= 0) return state;

  const rate = state.parentConfig.interestRate / 100;
  const interest = Math.round(balance * rate);
  if (interest <= 0) return state;

  const interestCategory: Category = {
    id: "interest",
    name: "利息",
    emoji: "🏦",
    type: "income",
  };

  const tx: Transaction = {
    id: crypto.randomUUID(),
    amount: interest,
    category: interestCategory,
    type: "income",
    note: `${state.parentConfig.interestPeriod === "weekly" ? "週" : "月"}利息`,
    createdAt: new Date().toISOString(),
    approved: true,
    parentHeart: false,
  };

  const newState: AppState = {
    ...state,
    transactions: [...state.transactions, tx],
    parentConfig: {
      ...state.parentConfig,
      lastInterestDate: today(),
    },
  };
  saveState(newState);
  return newState;
}

export function deleteWish(state: AppState, wishId: string): AppState {
  const newState: AppState = {
    ...state,
    wishes: state.wishes.filter((w) => w.id !== wishId),
  };
  saveState(newState);
  return newState;
}

import { describe, it, expect, beforeEach, vi } from "vitest";
import {
  loadState,
  addTransaction,
  getBalance,
  getTotalSaved,
  addWish,
  waterWish,
  deleteWish,
  toggleAccessory,
  approveTransaction,
  sendHeart,
  updateParentConfig,
  applyInterest,
  updateHunger,
} from "../store";
import { CATEGORIES, MAX_HUNGER } from "../constants";
import type { AppState, Category } from "../types";

function freshState(): AppState {
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

const foodCat = CATEGORIES.find((c) => c.id === "food")!;
const allowanceCat = CATEGORIES.find((c) => c.id === "allowance")!;

describe("store", () => {
  beforeEach(() => {
    vi.stubGlobal("localStorage", {
      getItem: vi.fn(() => null),
      setItem: vi.fn(),
      removeItem: vi.fn(),
      clear: vi.fn(),
      length: 0,
      key: vi.fn(),
    });
  });

  describe("getBalance / getTotalSaved", () => {
    it("returns 0 for empty transactions", () => {
      expect(getBalance([])).toBe(0);
      expect(getTotalSaved([])).toBe(0);
    });

    it("calculates balance correctly", () => {
      const state = freshState();
      let s = addTransaction(state, {
        amount: 100,
        category: allowanceCat,
        type: "income",
        note: "",
      });
      s = addTransaction(s, {
        amount: 30,
        category: foodCat,
        type: "expense",
        note: "",
      });
      expect(getBalance(s.transactions)).toBe(70);
      expect(getTotalSaved(s.transactions)).toBe(100);
    });
  });

  describe("addTransaction", () => {
    it("adds a transaction and updates streak", () => {
      const state = freshState();
      const s = addTransaction(state, {
        amount: 50,
        category: allowanceCat,
        type: "income",
        note: "零用錢",
      });
      expect(s.transactions).toHaveLength(1);
      expect(s.profile.streak).toBe(1);
      expect(s.profile.lastRecordDate).toBeTruthy();
    });

    it("feeds the cat on record", () => {
      const state = freshState();
      state.profile.catHunger = 50;
      const s = addTransaction(state, {
        amount: 10,
        category: foodCat,
        type: "expense",
        note: "",
      });
      expect(s.profile.catHunger).toBe(80);
    });

    it("upgrades building when savings threshold met", () => {
      const state = freshState();
      const s = addTransaction(state, {
        amount: 600,
        category: allowanceCat,
        type: "income",
        note: "",
      });
      expect(s.profile.buildingLevel).toBe(1);
    });

    it("unlocks accessories based on savings", () => {
      const state = freshState();
      const s = addTransaction(state, {
        amount: 250,
        category: allowanceCat,
        type: "income",
        note: "",
      });
      expect(s.profile.unlockedAccessories).toContain("cat-bed");
    });
  });

  describe("wishes", () => {
    it("adds a wish", () => {
      const state = freshState();
      const s = addWish(state, { name: "玩具車", emoji: "🚗", targetAmount: 200 });
      expect(s.wishes).toHaveLength(1);
      expect(s.wishes[0].name).toBe("玩具車");
    });

    it("waters a wish", () => {
      let state = freshState();
      state = addTransaction(state, {
        amount: 100,
        category: allowanceCat,
        type: "income",
        note: "",
      });
      state = addWish(state, { name: "玩具", emoji: "🧸", targetAmount: 50 });
      const wishId = state.wishes[0].id;
      state = waterWish(state, wishId, 30);
      expect(state.wishes[0].savedAmount).toBe(30);
      expect(state.wishes[0].completedAt).toBeNull();
    });

    it("completes a wish when target is reached", () => {
      let state = freshState();
      state = addTransaction(state, {
        amount: 200,
        category: allowanceCat,
        type: "income",
        note: "",
      });
      state = addWish(state, { name: "玩具", emoji: "🧸", targetAmount: 50 });
      const wishId = state.wishes[0].id;
      state = waterWish(state, wishId, 50);
      expect(state.wishes[0].completedAt).toBeTruthy();
    });

    it("deletes a wish", () => {
      let state = freshState();
      state = addWish(state, { name: "玩具", emoji: "🧸", targetAmount: 50 });
      const wishId = state.wishes[0].id;
      state = deleteWish(state, wishId);
      expect(state.wishes).toHaveLength(0);
    });
  });

  describe("accessories", () => {
    it("toggles accessory equip", () => {
      const state = freshState();
      state.profile.unlockedAccessories = ["red-bell"];
      const s = toggleAccessory(state, "red-bell");
      expect(s.profile.equippedAccessories).toContain("red-bell");
      const s2 = toggleAccessory(s, "red-bell");
      expect(s2.profile.equippedAccessories).not.toContain("red-bell");
    });
  });

  describe("parent features", () => {
    it("approves a transaction", () => {
      let state = freshState();
      state = addTransaction(state, {
        amount: 20,
        category: foodCat,
        type: "expense",
        note: "",
      });
      const txId = state.transactions[0].id;
      state = approveTransaction(state, txId);
      expect(state.transactions[0].approved).toBe(true);
    });

    it("sends heart", () => {
      let state = freshState();
      state = addTransaction(state, {
        amount: 20,
        category: foodCat,
        type: "expense",
        note: "",
      });
      const txId = state.transactions[0].id;
      state = sendHeart(state, txId);
      expect(state.transactions[0].parentHeart).toBe(true);
    });

    it("updates parent config", () => {
      const state = freshState();
      const s = updateParentConfig(state, { interestRate: 5 });
      expect(s.parentConfig.interestRate).toBe(5);
    });

    it("applies interest", () => {
      let state = freshState();
      state = addTransaction(state, {
        amount: 1000,
        category: allowanceCat,
        type: "income",
        note: "",
      });
      state.parentConfig.interestRate = 10;
      state = applyInterest(state);
      expect(state.transactions).toHaveLength(2);
      expect(state.transactions[1].amount).toBe(100);
      expect(state.transactions[1].category.id).toBe("interest");
    });
  });
});

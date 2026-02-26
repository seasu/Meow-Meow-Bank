import { describe, it, expect, beforeEach } from "vitest";
import {
  addTransaction,
  getTransactions,
  getBalance,
  resetTransactions,
  CATEGORIES,
} from "../transactions";

describe("transactions", () => {
  beforeEach(() => {
    resetTransactions();
  });

  it("starts with empty transactions", () => {
    expect(getTransactions()).toEqual([]);
    expect(getBalance()).toBe(0);
  });

  it("adds an income transaction", () => {
    const category = CATEGORIES.find((c) => c.id === "allowance")!;
    const tx = addTransaction({
      amount: 100,
      category,
      type: "income",
      note: "零用錢",
    });

    expect(tx.id).toBeDefined();
    expect(tx.amount).toBe(100);
    expect(tx.type).toBe("income");
    expect(getBalance()).toBe(100);
  });

  it("adds an expense transaction", () => {
    const incomeCategory = CATEGORIES.find((c) => c.id === "allowance")!;
    const expenseCategory = CATEGORIES.find((c) => c.id === "food")!;

    addTransaction({
      amount: 100,
      category: incomeCategory,
      type: "income",
      note: "",
    });

    addTransaction({
      amount: 30,
      category: expenseCategory,
      type: "expense",
      note: "買糖果",
    });

    expect(getTransactions()).toHaveLength(2);
    expect(getBalance()).toBe(70);
  });

  it("returns a copy of transactions", () => {
    const txs1 = getTransactions();
    const txs2 = getTransactions();
    expect(txs1).not.toBe(txs2);
  });
});

"use client";

import { useState } from "react";
import { CATEGORIES } from "@/lib/constants";
import type { TransactionType } from "@/lib/types";

type TransactionFormProps = {
  onSubmit: (data: {
    amount: number;
    categoryId: string;
    type: TransactionType;
    note: string;
  }) => void;
};

export default function TransactionForm({ onSubmit }: TransactionFormProps) {
  const [type, setType] = useState<TransactionType>("expense");
  const [amount, setAmount] = useState("");
  const [categoryId, setCategoryId] = useState("");
  const [note, setNote] = useState("");

  const filteredCategories = CATEGORIES.filter(
    (c) => c.type === type && c.id !== "interest"
  );

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!amount || !categoryId) return;
    onSubmit({ amount: Number(amount), categoryId, type, note });
    setAmount("");
    setCategoryId("");
    setNote("");
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4 w-full max-w-sm">
      {/* Type toggle */}
      <div className="flex gap-2">
        <button
          type="button"
          onClick={() => { setType("expense"); setCategoryId(""); }}
          className={`flex-1 py-3 rounded-2xl text-lg font-bold transition-all duration-200 ${
            type === "expense"
              ? "bg-pink-400 text-white shadow-md scale-[1.02]"
              : "bg-pink-50 text-pink-300 hover:bg-pink-100"
          }`}
        >
          💸 支出
        </button>
        <button
          type="button"
          onClick={() => { setType("income"); setCategoryId(""); }}
          className={`flex-1 py-3 rounded-2xl text-lg font-bold transition-all duration-200 ${
            type === "income"
              ? "bg-amber-400 text-white shadow-md scale-[1.02]"
              : "bg-amber-50 text-amber-300 hover:bg-amber-100"
          }`}
        >
          🪙 收入
        </button>
      </div>

      {/* Category grid */}
      <div className="flex flex-wrap gap-2 justify-center">
        {filteredCategories.map((cat) => (
          <button
            key={cat.id}
            type="button"
            onClick={() => setCategoryId(cat.id)}
            className={`px-4 py-3 rounded-xl transition-all duration-200 ${
              categoryId === cat.id
                ? "bg-amber-200 shadow-md scale-110 ring-2 ring-amber-400"
                : "bg-white shadow-sm hover:shadow-md hover:scale-105"
            }`}
          >
            <span className="text-2xl block">{cat.emoji}</span>
            <span className="text-xs mt-1 block font-medium">{cat.name}</span>
          </button>
        ))}
      </div>

      {/* Amount input */}
      <div className="relative">
        <span className="absolute left-4 top-1/2 -translate-y-1/2 text-xl text-amber-400">$</span>
        <input
          type="number"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          placeholder="輸入金額"
          min="1"
          className="w-full pl-10 pr-4 py-3 rounded-2xl text-xl text-center bg-white shadow-sm border-2 border-amber-200 focus:border-amber-400 focus:outline-none focus:shadow-md transition-all"
        />
      </div>

      {/* Note input */}
      <input
        type="text"
        value={note}
        onChange={(e) => setNote(e.target.value)}
        placeholder="備註（選填）✏️"
        className="w-full px-4 py-3 rounded-2xl bg-white shadow-sm border-2 border-amber-200 focus:border-amber-400 focus:outline-none focus:shadow-md transition-all"
      />

      {/* Submit */}
      <button
        type="submit"
        disabled={!amount || !categoryId}
        className="w-full py-4 rounded-2xl text-xl font-bold text-white bg-gradient-to-r from-amber-400 to-pink-400 shadow-lg hover:shadow-xl hover:scale-[1.01] active:scale-[0.99] transition-all disabled:opacity-40 disabled:cursor-not-allowed disabled:hover:scale-100"
      >
        記帳喵！🐾
      </button>
    </form>
  );
}

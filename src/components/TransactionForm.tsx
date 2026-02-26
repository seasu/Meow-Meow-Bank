"use client";

import { useState } from "react";
import { CATEGORIES, type TransactionType } from "@/lib/transactions";

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

  const filteredCategories = CATEGORIES.filter((c) => c.type === type);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!amount || !categoryId) return;
    onSubmit({
      amount: Number(amount),
      categoryId,
      type,
      note,
    });
    setAmount("");
    setCategoryId("");
    setNote("");
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4 w-full max-w-sm">
      <div className="flex gap-2">
        <button
          type="button"
          onClick={() => {
            setType("expense");
            setCategoryId("");
          }}
          className={`flex-1 py-3 rounded-2xl text-lg font-bold transition-colors ${
            type === "expense"
              ? "bg-pink-400 text-white shadow-md"
              : "bg-pink-100 text-pink-400"
          }`}
        >
          💸 支出
        </button>
        <button
          type="button"
          onClick={() => {
            setType("income");
            setCategoryId("");
          }}
          className={`flex-1 py-3 rounded-2xl text-lg font-bold transition-colors ${
            type === "income"
              ? "bg-amber-400 text-white shadow-md"
              : "bg-amber-100 text-amber-500"
          }`}
        >
          🪙 收入
        </button>
      </div>

      <div className="flex flex-wrap gap-2 justify-center">
        {filteredCategories.map((cat) => (
          <button
            key={cat.id}
            type="button"
            onClick={() => setCategoryId(cat.id)}
            className={`px-4 py-3 rounded-xl text-lg transition-all ${
              categoryId === cat.id
                ? "bg-amber-200 shadow-md scale-110"
                : "bg-white shadow-sm hover:shadow-md"
            }`}
          >
            <span className="text-2xl">{cat.emoji}</span>
            <div className="text-xs mt-1">{cat.name}</div>
          </button>
        ))}
      </div>

      <input
        type="number"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
        placeholder="金額 💰"
        min="1"
        className="w-full px-4 py-3 rounded-2xl text-xl text-center bg-white shadow-sm border-2 border-amber-200 focus:border-amber-400 focus:outline-none"
      />

      <input
        type="text"
        value={note}
        onChange={(e) => setNote(e.target.value)}
        placeholder="備註（選填）✏️"
        className="w-full px-4 py-3 rounded-2xl bg-white shadow-sm border-2 border-amber-200 focus:border-amber-400 focus:outline-none"
      />

      <button
        type="submit"
        disabled={!amount || !categoryId}
        className="w-full py-4 rounded-2xl text-xl font-bold text-white bg-gradient-to-r from-amber-400 to-pink-400 shadow-lg hover:shadow-xl transition-all disabled:opacity-50 disabled:cursor-not-allowed"
      >
        記帳喵！🐾
      </button>
    </form>
  );
}

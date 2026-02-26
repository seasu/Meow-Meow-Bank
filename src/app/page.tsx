"use client";

import { useState, useCallback } from "react";
import LuckyCat from "@/components/LuckyCat";
import CoinDrop from "@/components/CoinDrop";
import TransactionForm from "@/components/TransactionForm";
import TransactionList from "@/components/TransactionList";
import type { Transaction, TransactionType } from "@/lib/transactions";

export default function Home() {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [balance, setBalance] = useState(0);
  const [lastAction, setLastAction] = useState<TransactionType | null>(null);
  const [showCoins, setShowCoins] = useState(false);
  const [lastAmount, setLastAmount] = useState(0);

  const handleSubmit = useCallback(
    async (data: {
      amount: number;
      categoryId: string;
      type: TransactionType;
      note: string;
    }) => {
      const res = await fetch("/api/transactions", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });

      if (!res.ok) return;

      setLastAction(data.type);
      setLastAmount(data.amount);
      setShowCoins(true);
      setTimeout(() => setShowCoins(false), 2000);

      const listRes = await fetch("/api/transactions");
      const listData = await listRes.json();
      setTransactions(listData.transactions);
      setBalance(listData.balance);
    },
    []
  );

  return (
    <main className="flex flex-col items-center px-4 py-8 gap-6 max-w-lg mx-auto">
      <header className="text-center">
        <h1 className="text-3xl font-bold text-amber-700">🏦 喵喵金幣屋</h1>
        <p className="text-sm text-amber-500 mt-1">
          存出你的小夢想！Save your dreams, one meow at a time.
        </p>
      </header>

      <LuckyCat lastAction={lastAction} />

      {showCoins && <CoinDrop amount={lastAmount} type={lastAction!} />}

      <div className="bg-gradient-to-r from-amber-100 to-pink-100 rounded-2xl px-6 py-4 text-center shadow-md w-full max-w-sm">
        <div className="text-sm text-amber-600">目前餘額</div>
        <div
          className={`text-4xl font-bold ${
            balance >= 0 ? "text-green-600" : "text-pink-500"
          }`}
        >
          ${balance}
        </div>
      </div>

      <TransactionForm onSubmit={handleSubmit} />

      <TransactionList transactions={transactions} />
    </main>
  );
}

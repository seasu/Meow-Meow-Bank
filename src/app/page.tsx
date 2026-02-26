"use client";

import { useState, useRef } from "react";
import { useApp } from "@/lib/context";
import { CATEGORIES } from "@/lib/constants";
import LuckyCat from "@/components/LuckyCat";
import CoinDrop from "@/components/CoinDrop";
import BuildingScene from "@/components/BuildingScene";
import TransactionForm from "@/components/TransactionForm";
import TransactionList from "@/components/TransactionList";
import type { TransactionType } from "@/lib/types";

type CatAnimation = {
  mood: "excited" | "remind";
  message: string;
  isWaving: boolean;
};

export default function Home() {
  const { state, balance, totalSaved, addTransaction } = useApp();
  const [showCoins, setShowCoins] = useState(false);
  const [lastAmount, setLastAmount] = useState(0);
  const [lastType, setLastType] = useState<TransactionType>("income");
  const [catAnim, setCatAnim] = useState<CatAnimation | null>(null);
  const timers = useRef<ReturnType<typeof setTimeout>[]>([]);

  function clearTimers() {
    timers.current.forEach(clearTimeout);
    timers.current = [];
  }

  function handleSubmit(data: { amount: number; categoryId: string; type: TransactionType; note: string }) {
    const category = CATEGORIES.find((c) => c.id === data.categoryId);
    if (!category) return;

    addTransaction({ amount: data.amount, category, type: data.type, note: data.note });

    clearTimers();

    setLastAmount(data.amount);
    setLastType(data.type);
    setShowCoins(true);

    if (data.type === "income") {
      setCatAnim({ mood: "excited", message: "太棒了！存錢真開心喵～✨", isWaving: true });
      timers.current.push(setTimeout(() => setCatAnim((prev) => prev ? { ...prev, isWaving: false } : null), 1500));
    } else {
      setCatAnim({ mood: "remind", message: "花錢要想一想喔～🤔", isWaving: false });
    }

    timers.current.push(setTimeout(() => setShowCoins(false), 2500));
    timers.current.push(setTimeout(() => setCatAnim(null), 3000));
  }

  return (
    <main className="flex flex-col items-center px-4 py-6 gap-5 max-w-lg mx-auto">
      <header className="text-center">
        <h1 className="text-3xl font-bold text-amber-700">🏦 喵喵金幣屋</h1>
        <p className="text-xs text-amber-500 mt-1">
          存出你的小夢想！Save your dreams, one meow at a time.
        </p>
      </header>

      <BuildingScene level={state.profile.buildingLevel} totalSaved={totalSaved} />

      <LuckyCat
        hunger={state.profile.catHunger}
        mood={catAnim?.mood}
        message={catAnim?.message}
        isWaving={catAnim?.isWaving}
        equippedAccessories={state.profile.equippedAccessories}
      />

      {showCoins && <CoinDrop amount={lastAmount} type={lastType} />}

      <div className="bg-gradient-to-r from-amber-100 to-pink-100 rounded-2xl px-6 py-4 text-center shadow-md w-full max-w-sm">
        <div className="flex justify-between items-center">
          <div>
            <div className="text-xs text-amber-600 text-left">目前餘額</div>
            <div className={`text-3xl font-bold ${balance >= 0 ? "text-green-600" : "text-pink-500"}`}>
              ${balance}
            </div>
          </div>
          <div className="text-right">
            <div className="text-xs text-amber-600">連續記帳</div>
            <div className="text-xl font-bold text-amber-700">
              🔥 {state.profile.streak} 天
            </div>
          </div>
        </div>
      </div>

      <TransactionForm onSubmit={handleSubmit} />
      <TransactionList transactions={state.transactions} />
    </main>
  );
}

"use client";

import { useState, useRef } from "react";
import { useApp } from "@/lib/context";
import { CATEGORIES } from "@/lib/constants";
import { playCoinSound, playMeowSound, playSuccessSound, playExpenseSound } from "@/lib/sounds";
import LuckyCat from "@/components/LuckyCat";
import CoinDrop from "@/components/CoinDrop";
import CoinTray from "@/components/CoinTray";
import BuildingScene from "@/components/BuildingScene";
import TransactionForm from "@/components/TransactionForm";
import TransactionList from "@/components/TransactionList";
import type { TransactionType } from "@/lib/types";

type CatAnimation = {
  mood: "excited" | "remind";
  message: string;
  isWaving: boolean;
  headTilt: boolean;
};

export default function Home() {
  const { state, balance, totalSaved, addTransaction } = useApp();
  const [showCoins, setShowCoins] = useState(false);
  const [lastAmount, setLastAmount] = useState(0);
  const [lastType, setLastType] = useState<TransactionType>("income");
  const [catAnim, setCatAnim] = useState<CatAnimation | null>(null);
  const [dragTotal, setDragTotal] = useState(0);
  const [mode, setMode] = useState<"drag" | "form">("drag");
  const [dragCategory, setDragCategory] = useState("income");
  const [dragNote, setDragNote] = useState("");
  const [showSparkle, setShowSparkle] = useState(false);
  const catDropRef = useRef<HTMLDivElement | null>(null);
  const timers = useRef<ReturnType<typeof setTimeout>[]>([]);

  function clearTimers() {
    timers.current.forEach(clearTimeout);
    timers.current = [];
  }

  function triggerAnimation(type: TransactionType, amount: number) {
    clearTimers();
    setLastAmount(amount);
    setLastType(type);
    setShowCoins(true);

    if (type === "income") {
      setCatAnim({ mood: "excited", message: "太棒了！存錢真開心喵～✨", isWaving: true, headTilt: false });
      playMeowSound();
      setTimeout(playSuccessSound, 200);
      setShowSparkle(true);
      timers.current.push(setTimeout(() => setShowSparkle(false), 1500));
      timers.current.push(setTimeout(() => setCatAnim((p) => p ? { ...p, isWaving: false } : null), 1500));
    } else {
      setCatAnim({ mood: "remind", message: "花錢要想一想喔～🤔", isWaving: false, headTilt: true });
      playExpenseSound();
      timers.current.push(setTimeout(() => setCatAnim((p) => p ? { ...p, headTilt: false } : null), 1000));
    }

    timers.current.push(setTimeout(() => setShowCoins(false), 2500));
    timers.current.push(setTimeout(() => setCatAnim(null), 3000));
  }

  function handleCoinDropped(value: number) {
    playCoinSound();
    setDragTotal((prev) => prev + value);
  }

  function handleDragSubmit() {
    if (dragTotal <= 0) return;
    const cat = CATEGORIES.find((c) => c.id === dragCategory);
    if (!cat) return;

    addTransaction({ amount: dragTotal, category: cat, type: cat.type, note: dragNote });
    triggerAnimation(cat.type, dragTotal);
    setDragTotal(0);
    setDragNote("");
  }

  function handleFormSubmit(data: { amount: number; categoryId: string; type: TransactionType; note: string }) {
    const category = CATEGORIES.find((c) => c.id === data.categoryId);
    if (!category) return;
    addTransaction({ amount: data.amount, category, type: data.type, note: data.note });
    triggerAnimation(data.type, data.amount);
  }

  const expenseCategories = CATEGORIES.filter((c) => c.type === "expense");
  const incomeCategories = CATEGORIES.filter((c) => c.type === "income" && c.id !== "interest");

  return (
    <main className="flex flex-col items-center px-4 py-6 gap-4 max-w-lg mx-auto">
      <header className="text-center">
        <h1 className="text-3xl font-bold text-amber-700">🏦 喵喵金幣屋</h1>
        <p className="text-xs text-amber-500 mt-1">
          存出你的小夢想！Save your dreams, one meow at a time.
        </p>
      </header>

      <BuildingScene level={state.profile.buildingLevel} totalSaved={totalSaved} />

      {/* Cat drop target */}
      <div ref={catDropRef} className={`relative ${mode === "drag" ? "animate-drop-target rounded-full" : ""}`}>
        <LuckyCat
          hunger={state.profile.catHunger}
          mood={catAnim?.mood}
          message={catAnim?.message}
          isWaving={catAnim?.isWaving}
          headTilt={catAnim?.headTilt}
          equippedAccessories={state.profile.equippedAccessories}
        />
        {showSparkle && (
          <div className="absolute inset-0 pointer-events-none flex items-center justify-center">
            {[0, 1, 2, 3, 4, 5].map((i) => (
              <span
                key={i}
                className="absolute text-lg animate-sparkle"
                style={{
                  animationDelay: `${i * 0.1}s`,
                  top: `${20 + Math.sin(i * 1.2) * 30}%`,
                  left: `${20 + Math.cos(i * 1.2) * 30}%`,
                }}
              >
                ✨
              </span>
            ))}
          </div>
        )}
      </div>

      {showCoins && <CoinDrop amount={lastAmount} type={lastType} />}

      {/* Balance card */}
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
            <div className="text-xl font-bold text-amber-700">🔥 {state.profile.streak} 天</div>
          </div>
        </div>
      </div>

      {/* Mode toggle */}
      <div className="flex gap-2 w-full max-w-sm">
        <button
          onClick={() => setMode("drag")}
          className={`flex-1 py-2.5 rounded-2xl text-sm font-bold transition-all ${
            mode === "drag"
              ? "bg-amber-500 text-white shadow-md"
              : "bg-amber-50 text-amber-400 hover:bg-amber-100"
          }`}
        >
          🪙 拖拉記帳
        </button>
        <button
          onClick={() => setMode("form")}
          className={`flex-1 py-2.5 rounded-2xl text-sm font-bold transition-all ${
            mode === "form"
              ? "bg-amber-500 text-white shadow-md"
              : "bg-amber-50 text-amber-400 hover:bg-amber-100"
          }`}
        >
          ✏️ 輸入記帳
        </button>
      </div>

      {/* Drag mode */}
      {mode === "drag" && (
        <div className="w-full max-w-sm space-y-3 animate-fade-in-up">
          <CoinTray onCoinDropped={handleCoinDropped} dropTargetRef={catDropRef} />

          {/* Drag accumulator */}
          <div className="bg-white rounded-2xl p-4 shadow-sm space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-sm text-amber-700 font-medium">已投入金額</span>
              <span className="text-2xl font-black text-amber-600">${dragTotal}</span>
            </div>

            {/* Category selection for drag mode */}
            <div className="flex flex-wrap gap-1.5 justify-center">
              {[...incomeCategories, ...expenseCategories].map((cat) => (
                <button
                  key={cat.id}
                  type="button"
                  onClick={() => setDragCategory(cat.id)}
                  className={`px-3 py-2 rounded-xl transition-all text-sm ${
                    dragCategory === cat.id
                      ? "bg-amber-200 shadow-md scale-105 ring-2 ring-amber-400"
                      : "bg-gray-50 hover:bg-gray-100"
                  }`}
                >
                  <span className="text-lg">{cat.emoji}</span>
                  <span className="text-[10px] block">{cat.name}</span>
                </button>
              ))}
            </div>

            <input
              type="text"
              value={dragNote}
              onChange={(e) => setDragNote(e.target.value)}
              placeholder="備註（選填）✏️"
              className="w-full px-3 py-2 rounded-xl bg-gray-50 border border-amber-200 focus:border-amber-400 focus:outline-none text-sm"
            />

            <div className="flex gap-2">
              <button
                onClick={handleDragSubmit}
                disabled={dragTotal <= 0}
                className="flex-1 py-3 rounded-2xl text-lg font-bold text-white bg-gradient-to-r from-amber-400 to-pink-400 shadow-lg hover:shadow-xl active:scale-[0.98] transition-all disabled:opacity-40 disabled:cursor-not-allowed"
              >
                記帳喵！🐾
              </button>
              {dragTotal > 0 && (
                <button
                  onClick={() => setDragTotal(0)}
                  className="px-4 py-3 rounded-2xl text-sm text-gray-400 bg-gray-100 hover:bg-gray-200 transition-colors"
                >
                  重置
                </button>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Form mode */}
      {mode === "form" && (
        <div className="animate-fade-in-up w-full flex justify-center">
          <TransactionForm onSubmit={handleFormSubmit} />
        </div>
      )}

      <TransactionList transactions={state.transactions} />
    </main>
  );
}

"use client";

import { useState } from "react";
import { useApp } from "@/lib/context";

const WISH_EMOJIS = ["🚗", "🧸", "🎮", "📚", "🎨", "⚽", "🎸", "🎂", "👟", "🎪"];

export default function DreamTreePage() {
  const { state, balance, addWish, waterWish, deleteWish } = useApp();
  const { wishes } = state;
  const [showForm, setShowForm] = useState(false);
  const [name, setName] = useState("");
  const [emoji, setEmoji] = useState("🧸");
  const [target, setTarget] = useState("");
  const [waterAmounts, setWaterAmounts] = useState<Record<string, string>>({});

  function handleAddWish(e: React.FormEvent) {
    e.preventDefault();
    if (!name || !target) return;
    addWish({ name, emoji, targetAmount: Number(target) });
    setName("");
    setEmoji("🧸");
    setTarget("");
    setShowForm(false);
  }

  function handleWater(wishId: string) {
    const amount = Number(waterAmounts[wishId] || 0);
    if (amount <= 0) return;
    waterWish(wishId, amount);
    setWaterAmounts((prev) => ({ ...prev, [wishId]: "" }));
  }

  const activeWishes = wishes.filter((w) => !w.completedAt);
  const completedWishes = wishes.filter((w) => w.completedAt);

  return (
    <main className="flex flex-col items-center px-4 py-6 gap-5 max-w-lg mx-auto">
      <h1 className="text-2xl font-bold text-amber-700">🌳 夢想樹</h1>
      <p className="text-xs text-amber-500 -mt-3">設定願望目標，灌溉你的夢想！</p>

      {/* Balance reminder */}
      <div className="bg-amber-50 rounded-xl px-4 py-2 text-sm text-amber-700 w-full max-w-sm text-center">
        可用餘額: <span className="font-bold">${balance}</span>
      </div>

      {/* Active wishes */}
      {activeWishes.length > 0 && (
        <div className="w-full max-w-sm space-y-3">
          {activeWishes.map((wish) => {
            const progress = Math.min((wish.savedAmount / wish.targetAmount) * 100, 100);
            const treeStage =
              progress >= 100 ? "🌳" : progress >= 60 ? "🌿" : progress >= 30 ? "🌱" : "🫘";

            return (
              <div key={wish.id} className="bg-white rounded-2xl p-4 shadow-sm">
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-2">
                    <span className="text-2xl">{wish.emoji}</span>
                    <div>
                      <div className="font-bold text-sm">{wish.name}</div>
                      <div className="text-xs text-gray-400">
                        ${wish.savedAmount} / ${wish.targetAmount}
                      </div>
                    </div>
                  </div>
                  <div className="text-3xl">{treeStage}</div>
                </div>

                {/* Progress bar */}
                <div className="h-3 bg-green-100 rounded-full overflow-hidden mb-3">
                  <div
                    className="h-full bg-gradient-to-r from-green-300 to-green-500 rounded-full transition-all duration-500"
                    style={{ width: `${progress}%` }}
                  />
                </div>

                {/* Water controls */}
                <div className="flex gap-2">
                  <input
                    type="number"
                    placeholder="灌溉金額"
                    min="1"
                    max={balance}
                    value={waterAmounts[wish.id] || ""}
                    onChange={(e) =>
                      setWaterAmounts((prev) => ({ ...prev, [wish.id]: e.target.value }))
                    }
                    className="flex-1 px-3 py-2 rounded-xl text-sm bg-green-50 border border-green-200 focus:border-green-400 focus:outline-none"
                  />
                  <button
                    onClick={() => handleWater(wish.id)}
                    disabled={!waterAmounts[wish.id] || Number(waterAmounts[wish.id]) > balance}
                    className="px-4 py-2 rounded-xl text-sm font-bold text-white bg-green-400 hover:bg-green-500 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                  >
                    💧 灌溉
                  </button>
                  <button
                    onClick={() => deleteWish(wish.id)}
                    className="px-3 py-2 rounded-xl text-sm text-gray-400 hover:bg-red-50 hover:text-red-400 transition-colors"
                  >
                    🗑️
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Add wish button */}
      {!showForm && (
        <button
          onClick={() => setShowForm(true)}
          className="w-full max-w-sm py-4 rounded-2xl text-lg font-bold text-green-600 bg-green-50 border-2 border-dashed border-green-300 hover:bg-green-100 transition-colors"
        >
          + 新增願望 🌟
        </button>
      )}

      {/* New wish form */}
      {showForm && (
        <form
          onSubmit={handleAddWish}
          className="w-full max-w-sm bg-white rounded-2xl p-4 shadow-sm space-y-3"
        >
          <h3 className="font-bold text-amber-800">🌟 新願望</h3>

          <div className="flex flex-wrap gap-2">
            {WISH_EMOJIS.map((e) => (
              <button
                key={e}
                type="button"
                onClick={() => setEmoji(e)}
                className={`text-2xl p-1 rounded-lg transition-all ${
                  emoji === e ? "bg-amber-200 scale-110" : "hover:bg-gray-100"
                }`}
              >
                {e}
              </button>
            ))}
          </div>

          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="願望名稱（例如：遙控汽車）"
            className="w-full px-3 py-2 rounded-xl bg-gray-50 border border-gray-200 focus:border-amber-400 focus:outline-none"
          />

          <input
            type="number"
            value={target}
            onChange={(e) => setTarget(e.target.value)}
            placeholder="目標金額"
            min="1"
            className="w-full px-3 py-2 rounded-xl bg-gray-50 border border-gray-200 focus:border-amber-400 focus:outline-none"
          />

          <div className="flex gap-2">
            <button
              type="submit"
              disabled={!name || !target}
              className="flex-1 py-2 rounded-xl font-bold text-white bg-amber-400 hover:bg-amber-500 disabled:opacity-40 transition-colors"
            >
              種下夢想 🌱
            </button>
            <button
              type="button"
              onClick={() => setShowForm(false)}
              className="px-4 py-2 rounded-xl text-gray-400 hover:bg-gray-100 transition-colors"
            >
              取消
            </button>
          </div>
        </form>
      )}

      {/* Completed wishes */}
      {completedWishes.length > 0 && (
        <div className="w-full max-w-sm">
          <h3 className="text-sm font-bold text-green-600 mb-2">🎉 已達成的願望</h3>
          <div className="space-y-2">
            {completedWishes.map((wish) => (
              <div
                key={wish.id}
                className="flex items-center justify-between bg-green-50 rounded-xl px-4 py-3"
              >
                <div className="flex items-center gap-2">
                  <span className="text-xl">{wish.emoji}</span>
                  <span className="font-medium text-sm">{wish.name}</span>
                </div>
                <span className="text-sm text-green-600 font-bold">✅ ${wish.targetAmount}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {wishes.length === 0 && !showForm && (
        <div className="text-center py-4">
          <span className="text-4xl block mb-2">🌱</span>
          <p className="text-amber-600 text-sm">還沒有願望喔，來許個願吧！</p>
        </div>
      )}
    </main>
  );
}

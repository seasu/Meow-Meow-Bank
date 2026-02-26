"use client";

import { useApp } from "@/lib/context";
import { ACCESSORIES } from "@/lib/constants";

export default function AccessoriesPage() {
  const { state, totalSaved, toggleAccessory } = useApp();
  const { unlockedAccessories, equippedAccessories, streak } = state.profile;

  return (
    <main className="flex flex-col items-center px-4 py-6 gap-5 max-w-lg mx-auto">
      <h1 className="text-2xl font-bold text-amber-700">✨ 收藏櫃</h1>
      <p className="text-xs text-amber-500 -mt-3">收集配件，打扮你的招財貓！</p>

      {/* Stats bar */}
      <div className="flex gap-4 text-sm">
        <div className="bg-amber-50 rounded-xl px-4 py-2">
          🔥 連續 <span className="font-bold text-amber-700">{streak}</span> 天
        </div>
        <div className="bg-green-50 rounded-xl px-4 py-2">
          💰 存款 <span className="font-bold text-green-600">${totalSaved}</span>
        </div>
      </div>

      {/* Cat preview */}
      <div className="bg-gradient-to-b from-amber-100 to-pink-50 rounded-2xl p-6 w-full max-w-sm text-center shadow-sm">
        <div className="text-6xl mb-2">🐱</div>
        {equippedAccessories.length > 0 ? (
          <div className="flex justify-center gap-2 mb-2">
            {equippedAccessories.map((id) => {
              const acc = ACCESSORIES.find((a) => a.id === id);
              return (
                <span key={id} className="text-2xl">
                  {acc?.emoji ?? "🎀"}
                </span>
              );
            })}
          </div>
        ) : (
          <p className="text-xs text-amber-400 mb-2">還沒裝備配件喔～</p>
        )}
        <p className="text-xs text-amber-600">
          已解鎖 {unlockedAccessories.length} / {ACCESSORIES.length} 個配件
        </p>
      </div>

      {/* Accessories grid */}
      <div className="w-full max-w-sm grid grid-cols-2 gap-3">
        {ACCESSORIES.map((acc) => {
          const unlocked = unlockedAccessories.includes(acc.id);
          const equipped = equippedAccessories.includes(acc.id);

          let progressText = "";
          if (!unlocked) {
            if (acc.requirement.type === "streak") {
              progressText = `${streak}/${acc.requirement.days} 天`;
            } else {
              progressText = `$${totalSaved}/$${acc.requirement.amount}`;
            }
          }

          let progress = 0;
          if (!unlocked) {
            if (acc.requirement.type === "streak") {
              progress = Math.min((streak / acc.requirement.days) * 100, 100);
            } else {
              progress = Math.min((totalSaved / acc.requirement.amount) * 100, 100);
            }
          }

          return (
            <div
              key={acc.id}
              className={`rounded-2xl p-4 shadow-sm transition-all ${
                unlocked
                  ? equipped
                    ? "bg-amber-100 ring-2 ring-amber-400"
                    : "bg-white hover:shadow-md cursor-pointer"
                  : "bg-gray-100 opacity-70"
              }`}
              onClick={() => unlocked && toggleAccessory(acc.id)}
            >
              <div className="flex items-center gap-2 mb-2">
                <span className={`text-3xl ${!unlocked ? "grayscale" : ""}`}>
                  {acc.emoji}
                </span>
                <div>
                  <div className="text-sm font-bold">{acc.name}</div>
                  {equipped && (
                    <span className="text-[10px] text-amber-600 font-medium">裝備中</span>
                  )}
                </div>
              </div>

              {unlocked ? (
                <p className="text-xs text-green-500">✅ 已解鎖</p>
              ) : (
                <div>
                  <p className="text-xs text-gray-400 mb-1">{acc.description}</p>
                  <div className="h-1.5 bg-gray-200 rounded-full overflow-hidden">
                    <div
                      className="h-full bg-amber-400 rounded-full transition-all"
                      style={{ width: `${progress}%` }}
                    />
                  </div>
                  <p className="text-[10px] text-gray-400 mt-0.5 text-right">{progressText}</p>
                </div>
              )}
            </div>
          );
        })}
      </div>
    </main>
  );
}

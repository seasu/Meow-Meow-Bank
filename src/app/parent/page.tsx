"use client";

import { useState } from "react";
import { useApp } from "@/lib/context";

export default function ParentPage() {
  const {
    state,
    balance,
    totalSaved,
    approveTransaction,
    sendHeart,
    updateParentConfig,
    applyInterest,
  } = useApp();
  const { transactions } = state;
  const { interestRate, interestPeriod } = state.parentConfig;
  const [showSettings, setShowSettings] = useState(false);
  const [rateInput, setRateInput] = useState(String(interestRate));
  const [periodInput, setPeriodInput] = useState(interestPeriod);

  const pendingTx = transactions.filter((tx) => !tx.approved);
  const recentTx = transactions.slice().reverse().slice(0, 20);

  function handleSaveSettings() {
    updateParentConfig({
      interestRate: Number(rateInput) || 1,
      interestPeriod: periodInput,
    });
    setShowSettings(false);
  }

  return (
    <main className="flex flex-col items-center px-4 py-6 gap-5 max-w-lg mx-auto">
      <h1 className="text-2xl font-bold text-amber-700">👨‍👩‍👧 家長面板</h1>

      {/* Summary */}
      <div className="grid grid-cols-3 gap-3 w-full max-w-sm">
        <div className="bg-blue-50 rounded-xl p-3 text-center">
          <div className="text-xs text-blue-600">連續記帳</div>
          <div className="text-lg font-bold text-blue-700">{state.profile.streak} 天</div>
        </div>
        <div className="bg-green-50 rounded-xl p-3 text-center">
          <div className="text-xs text-green-600">餘額</div>
          <div className="text-lg font-bold text-green-600">${balance}</div>
        </div>
        <div className="bg-amber-50 rounded-xl p-3 text-center">
          <div className="text-xs text-amber-600">總收入</div>
          <div className="text-lg font-bold text-amber-600">${totalSaved}</div>
        </div>
      </div>

      {/* Pending approvals */}
      {pendingTx.length > 0 && (
        <div className="w-full max-w-sm">
          <h2 className="text-sm font-bold text-amber-800 mb-2">
            📋 待審核 ({pendingTx.length})
          </h2>
          <div className="space-y-2">
            {pendingTx.slice().reverse().map((tx) => (
              <div
                key={tx.id}
                className="flex items-center justify-between bg-white rounded-xl px-4 py-3 shadow-sm"
              >
                <div className="flex items-center gap-2">
                  <span className="text-xl">{tx.category.emoji}</span>
                  <div>
                    <div className="text-sm font-medium">{tx.category.name}</div>
                    <div className="text-xs text-gray-400">
                      {tx.note || (tx.type === "income" ? "收入" : "支出")} ·{" "}
                      {tx.type === "income" ? "+" : "-"}${tx.amount}
                    </div>
                  </div>
                </div>
                <div className="flex gap-1.5">
                  <button
                    onClick={() => approveTransaction(tx.id)}
                    className="px-3 py-1.5 rounded-lg text-xs font-bold text-white bg-green-400 hover:bg-green-500 transition-colors"
                  >
                    ✓ 核准
                  </button>
                  <button
                    onClick={() => sendHeart(tx.id)}
                    disabled={tx.parentHeart}
                    className="px-3 py-1.5 rounded-lg text-xs font-bold text-pink-500 bg-pink-50 hover:bg-pink-100 disabled:opacity-40 transition-colors"
                  >
                    ❤️
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Interest settings */}
      <div className="w-full max-w-sm bg-white rounded-2xl p-4 shadow-sm">
        <div className="flex justify-between items-center mb-3">
          <h2 className="text-sm font-bold text-amber-800">🏦 虛擬利息設定</h2>
          <button
            onClick={() => setShowSettings(!showSettings)}
            className="text-xs text-amber-500 hover:text-amber-700"
          >
            {showSettings ? "取消" : "⚙️ 設定"}
          </button>
        </div>

        {!showSettings && (
          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span className="text-gray-500">利率</span>
              <span className="font-medium">{interestRate}%</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-500">計息週期</span>
              <span className="font-medium">
                {interestPeriod === "weekly" ? "每週" : "每月"}
              </span>
            </div>
            <button
              onClick={applyInterest}
              disabled={balance <= 0}
              className="w-full py-2 rounded-xl text-sm font-bold text-white bg-blue-400 hover:bg-blue-500 disabled:opacity-40 disabled:cursor-not-allowed transition-colors mt-2"
            >
              💰 發放利息
            </button>
          </div>
        )}

        {showSettings && (
          <div className="space-y-3">
            <div>
              <label className="text-xs text-gray-500 block mb-1">利率 (%)</label>
              <input
                type="number"
                value={rateInput}
                onChange={(e) => setRateInput(e.target.value)}
                min="0.1"
                max="50"
                step="0.1"
                className="w-full px-3 py-2 rounded-lg bg-gray-50 border border-gray-200 focus:border-blue-400 focus:outline-none text-sm"
              />
            </div>
            <div>
              <label className="text-xs text-gray-500 block mb-1">計息週期</label>
              <select
                value={periodInput}
                onChange={(e) => setPeriodInput(e.target.value as "weekly" | "monthly")}
                className="w-full px-3 py-2 rounded-lg bg-gray-50 border border-gray-200 focus:border-blue-400 focus:outline-none text-sm"
              >
                <option value="weekly">每週</option>
                <option value="monthly">每月</option>
              </select>
            </div>
            <button
              onClick={handleSaveSettings}
              className="w-full py-2 rounded-xl text-sm font-bold text-white bg-amber-400 hover:bg-amber-500 transition-colors"
            >
              儲存設定
            </button>
          </div>
        )}
      </div>

      {/* Recent transactions */}
      <div className="w-full max-w-sm">
        <h2 className="text-sm font-bold text-amber-800 mb-2">📖 最近記錄</h2>
        {recentTx.length === 0 ? (
          <p className="text-sm text-gray-400 text-center py-4">還沒有紀錄</p>
        ) : (
          <div className="space-y-1.5">
            {recentTx.map((tx) => (
              <div
                key={tx.id}
                className="flex items-center justify-between bg-white rounded-xl px-3 py-2 shadow-sm"
              >
                <div className="flex items-center gap-2">
                  <span className="text-lg">{tx.category.emoji}</span>
                  <div>
                    <div className="text-xs font-medium">{tx.category.name}</div>
                    {tx.note && <div className="text-[10px] text-gray-400">{tx.note}</div>}
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  {tx.parentHeart && <span className="text-xs">❤️</span>}
                  {tx.approved && <span className="text-[10px] text-green-400">✓已核</span>}
                  <span
                    className={`font-bold text-sm ${
                      tx.type === "income" ? "text-green-500" : "text-pink-500"
                    }`}
                  >
                    {tx.type === "income" ? "+" : "-"}${tx.amount}
                  </span>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </main>
  );
}

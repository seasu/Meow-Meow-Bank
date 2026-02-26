"use client";

import { useMemo } from "react";
import { useApp } from "@/lib/context";
import type { Transaction } from "@/lib/types";

export default function StatsPage() {
  const { state, balance, totalSaved } = useApp();
  const { transactions } = state;

  const totalExpense = useMemo(
    () => transactions.filter((t) => t.type === "expense").reduce((s, t) => s + t.amount, 0),
    [transactions]
  );

  const categoryStats = useMemo(() => {
    const map = new Map<string, { emoji: string; name: string; total: number; count: number }>();
    for (const tx of transactions) {
      const key = tx.category.id;
      const prev = map.get(key) ?? { emoji: tx.category.emoji, name: tx.category.name, total: 0, count: 0 };
      map.set(key, { ...prev, total: prev.total + tx.amount, count: prev.count + 1 });
    }
    return [...map.values()].sort((a, b) => b.total - a.total);
  }, [transactions]);

  const expenseCategories = useMemo(
    () => {
      const map = new Map<string, { emoji: string; name: string; total: number }>();
      for (const tx of transactions.filter((t) => t.type === "expense")) {
        const key = tx.category.id;
        const prev = map.get(key) ?? { emoji: tx.category.emoji, name: tx.category.name, total: 0 };
        map.set(key, { ...prev, total: prev.total + tx.amount });
      }
      return [...map.values()].sort((a, b) => b.total - a.total);
    },
    [transactions]
  );

  const recentDays = useMemo(() => {
    const days: { date: string; income: number; expense: number }[] = [];
    const now = new Date();
    for (let i = 6; i >= 0; i--) {
      const d = new Date(now.getTime() - i * 86400000);
      const dateStr = d.toISOString().split("T")[0];
      const dayTx = transactions.filter((t) => t.createdAt.split("T")[0] === dateStr);
      days.push({
        date: `${d.getMonth() + 1}/${d.getDate()}`,
        income: dayTx.filter((t) => t.type === "income").reduce((s, t) => s + t.amount, 0),
        expense: dayTx.filter((t) => t.type === "expense").reduce((s, t) => s + t.amount, 0),
      });
    }
    return days;
  }, [transactions]);

  const maxDayAmount = Math.max(...recentDays.map((d) => Math.max(d.income, d.expense)), 1);

  return (
    <main className="flex flex-col items-center px-4 py-6 gap-5 max-w-lg mx-auto">
      <h1 className="text-2xl font-bold text-amber-700">📊 收支統計</h1>

      {/* Summary cards */}
      <div className="grid grid-cols-3 gap-3 w-full max-w-sm">
        <div className="bg-green-50 rounded-xl p-3 text-center shadow-sm">
          <div className="text-xs text-green-600">總收入</div>
          <div className="text-lg font-bold text-green-600">${totalSaved}</div>
        </div>
        <div className="bg-pink-50 rounded-xl p-3 text-center shadow-sm">
          <div className="text-xs text-pink-500">總支出</div>
          <div className="text-lg font-bold text-pink-500">${totalExpense}</div>
        </div>
        <div className="bg-amber-50 rounded-xl p-3 text-center shadow-sm">
          <div className="text-xs text-amber-600">餘額</div>
          <div className={`text-lg font-bold ${balance >= 0 ? "text-green-600" : "text-pink-500"}`}>
            ${balance}
          </div>
        </div>
      </div>

      {/* 7-day chart */}
      <div className="w-full max-w-sm bg-white rounded-2xl p-4 shadow-sm">
        <h3 className="text-sm font-bold text-amber-800 mb-3">📅 近七天</h3>
        <div className="flex items-end gap-1 h-32">
          {recentDays.map((day) => (
            <div key={day.date} className="flex-1 flex flex-col items-center gap-0.5">
              <div className="flex flex-col items-center w-full gap-0.5" style={{ height: "100px" }}>
                <div className="flex-1 w-full flex items-end justify-center gap-0.5">
                  <div
                    className="w-2.5 bg-green-400 rounded-t-sm transition-all"
                    style={{ height: `${(day.income / maxDayAmount) * 80}px`, minHeight: day.income ? "4px" : "0" }}
                  />
                  <div
                    className="w-2.5 bg-pink-400 rounded-t-sm transition-all"
                    style={{ height: `${(day.expense / maxDayAmount) * 80}px`, minHeight: day.expense ? "4px" : "0" }}
                  />
                </div>
              </div>
              <span className="text-[10px] text-gray-400">{day.date}</span>
            </div>
          ))}
        </div>
        <div className="flex justify-center gap-4 mt-2 text-xs text-gray-400">
          <span className="flex items-center gap-1">
            <span className="w-2 h-2 bg-green-400 rounded-sm" /> 收入
          </span>
          <span className="flex items-center gap-1">
            <span className="w-2 h-2 bg-pink-400 rounded-sm" /> 支出
          </span>
        </div>
      </div>

      {/* Expense breakdown */}
      {expenseCategories.length > 0 && (
        <div className="w-full max-w-sm bg-white rounded-2xl p-4 shadow-sm">
          <h3 className="text-sm font-bold text-amber-800 mb-3">💸 支出分析</h3>
          <div className="space-y-2">
            {expenseCategories.map((cat) => {
              const pct = totalExpense > 0 ? (cat.total / totalExpense) * 100 : 0;
              return (
                <div key={cat.name} className="flex items-center gap-2">
                  <span className="text-xl w-8">{cat.emoji}</span>
                  <div className="flex-1">
                    <div className="flex justify-between text-xs mb-0.5">
                      <span className="font-medium">{cat.name}</span>
                      <span className="text-gray-400">${cat.total} ({Math.round(pct)}%)</span>
                    </div>
                    <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
                      <div
                        className="h-full bg-pink-400 rounded-full transition-all"
                        style={{ width: `${pct}%` }}
                      />
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* All categories */}
      {categoryStats.length > 0 && (
        <div className="w-full max-w-sm bg-white rounded-2xl p-4 shadow-sm">
          <h3 className="text-sm font-bold text-amber-800 mb-3">📋 所有類別</h3>
          <div className="grid grid-cols-2 gap-2">
            {categoryStats.map((cat) => (
              <div key={cat.name} className="flex items-center gap-2 bg-gray-50 rounded-lg p-2">
                <span className="text-xl">{cat.emoji}</span>
                <div>
                  <div className="text-xs font-medium">{cat.name}</div>
                  <div className="text-xs text-gray-400">{cat.count} 筆 / ${cat.total}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {transactions.length === 0 && (
        <div className="text-center py-8">
          <span className="text-4xl block mb-2">📈</span>
          <p className="text-amber-600">開始記帳後就能看到統計囉！</p>
        </div>
      )}
    </main>
  );
}

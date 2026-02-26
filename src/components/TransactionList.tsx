"use client";

import type { Transaction } from "@/lib/transactions";

type TransactionListProps = {
  transactions: Transaction[];
};

export default function TransactionList({
  transactions,
}: TransactionListProps) {
  if (transactions.length === 0) {
    return (
      <p className="text-center text-amber-600 py-4">
        還沒有記帳紀錄喔，快來記第一筆吧！🐾
      </p>
    );
  }

  return (
    <div className="space-y-2 w-full max-w-sm">
      <h2 className="text-lg font-bold text-amber-800">📖 記帳紀錄</h2>
      {transactions
        .slice()
        .reverse()
        .map((tx) => (
          <div
            key={tx.id}
            className="flex items-center justify-between bg-white rounded-xl px-4 py-3 shadow-sm"
          >
            <div className="flex items-center gap-2">
              <span className="text-2xl">{tx.category.emoji}</span>
              <div>
                <div className="font-medium">{tx.category.name}</div>
                {tx.note && (
                  <div className="text-xs text-gray-400">{tx.note}</div>
                )}
              </div>
            </div>
            <span
              className={`font-bold text-lg ${
                tx.type === "income" ? "text-green-500" : "text-pink-500"
              }`}
            >
              {tx.type === "income" ? "+" : "-"}${tx.amount}
            </span>
          </div>
        ))}
    </div>
  );
}

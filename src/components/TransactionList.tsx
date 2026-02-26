"use client";

import type { Transaction } from "@/lib/types";

type TransactionListProps = {
  transactions: Transaction[];
};

export default function TransactionList({ transactions }: TransactionListProps) {
  if (transactions.length === 0) {
    return (
      <div className="text-center py-8">
        <span className="text-4xl block mb-2">🐾</span>
        <p className="text-amber-600">還沒有記帳紀錄喔</p>
        <p className="text-amber-400 text-sm">快來記第一筆吧！</p>
      </div>
    );
  }

  const grouped = groupByDate(transactions);

  return (
    <div className="space-y-4 w-full max-w-sm">
      <h2 className="text-lg font-bold text-amber-800">📖 記帳紀錄</h2>
      {Object.entries(grouped)
        .sort(([a], [b]) => b.localeCompare(a))
        .map(([date, txs]) => (
          <div key={date}>
            <div className="text-xs text-gray-400 mb-1 px-1">{formatDate(date)}</div>
            <div className="space-y-1.5">
              {txs
                .slice()
                .reverse()
                .map((tx) => (
                  <div
                    key={tx.id}
                    className="flex items-center justify-between bg-white rounded-xl px-4 py-3 shadow-sm hover:shadow-md transition-shadow"
                  >
                    <div className="flex items-center gap-3">
                      <span className="text-2xl">{tx.category.emoji}</span>
                      <div>
                        <div className="font-medium text-sm">{tx.category.name}</div>
                        {tx.note && (
                          <div className="text-xs text-gray-400">{tx.note}</div>
                        )}
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      {tx.parentHeart && <span className="text-sm">❤️</span>}
                      {tx.approved && <span className="text-xs text-green-400">✓</span>}
                      <span
                        className={`font-bold text-lg ${
                          tx.type === "income" ? "text-green-500" : "text-pink-500"
                        }`}
                      >
                        {tx.type === "income" ? "+" : "-"}${tx.amount}
                      </span>
                    </div>
                  </div>
                ))}
            </div>
          </div>
        ))}
    </div>
  );
}

function groupByDate(transactions: Transaction[]): Record<string, Transaction[]> {
  const groups: Record<string, Transaction[]> = {};
  for (const tx of transactions) {
    const date = tx.createdAt.split("T")[0];
    if (!groups[date]) groups[date] = [];
    groups[date].push(tx);
  }
  return groups;
}

function formatDate(dateStr: string): string {
  const d = new Date(dateStr);
  const now = new Date();
  const today = now.toISOString().split("T")[0];
  const yesterday = new Date(now.getTime() - 86400000).toISOString().split("T")[0];

  if (dateStr === today) return "今天";
  if (dateStr === yesterday) return "昨天";
  return `${d.getMonth() + 1}/${d.getDate()}`;
}

export type TransactionType = "income" | "expense";

export type Category = {
  id: string;
  name: string;
  emoji: string;
  type: TransactionType;
};

export type Transaction = {
  id: string;
  amount: number;
  category: Category;
  type: TransactionType;
  note: string;
  createdAt: string;
};

export const CATEGORIES: Category[] = [
  { id: "food", name: "飲食", emoji: "🐟", type: "expense" },
  { id: "fun", name: "娛樂", emoji: "🧶", type: "expense" },
  { id: "transport", name: "交通", emoji: "🚌", type: "expense" },
  { id: "income", name: "收入", emoji: "🪙", type: "income" },
  { id: "gift", name: "禮物", emoji: "🎁", type: "income" },
  { id: "allowance", name: "零用錢", emoji: "💰", type: "income" },
];

let transactions: Transaction[] = [];

export function getTransactions(): Transaction[] {
  return [...transactions];
}

export function addTransaction(
  tx: Omit<Transaction, "id" | "createdAt">
): Transaction {
  const newTx: Transaction = {
    ...tx,
    id: crypto.randomUUID(),
    createdAt: new Date().toISOString(),
  };
  transactions.push(newTx);
  return newTx;
}

export function getBalance(): number {
  return transactions.reduce((sum, tx) => {
    return tx.type === "income" ? sum + tx.amount : sum - tx.amount;
  }, 0);
}

export function resetTransactions(): void {
  transactions = [];
}

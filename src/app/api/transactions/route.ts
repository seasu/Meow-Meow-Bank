import { NextResponse } from "next/server";
import {
  getTransactions,
  addTransaction,
  getBalance,
  CATEGORIES,
} from "@/lib/transactions";

export async function GET() {
  const transactions = getTransactions();
  const balance = getBalance();
  return NextResponse.json({ transactions, balance });
}

export async function POST(request: Request) {
  const body = await request.json();
  const { amount, categoryId, type, note } = body;

  if (!amount || !categoryId || !type) {
    return NextResponse.json(
      { error: "amount, categoryId, and type are required" },
      { status: 400 }
    );
  }

  const category = CATEGORIES.find((c) => c.id === categoryId);
  if (!category) {
    return NextResponse.json(
      { error: "Invalid category" },
      { status: 400 }
    );
  }

  const transaction = addTransaction({
    amount: Number(amount),
    category,
    type,
    note: note || "",
  });

  return NextResponse.json(transaction, { status: 201 });
}

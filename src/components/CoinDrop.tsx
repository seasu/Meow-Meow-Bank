"use client";

type CoinDropProps = {
  amount: number;
  type: "income" | "expense";
};

function breakIntoCoins(amount: number): number[] {
  const denoms = [100, 50, 10, 5, 1];
  const coins: number[] = [];
  let remaining = amount;
  for (const d of denoms) {
    while (remaining >= d && coins.length < 12) {
      coins.push(d);
      remaining -= d;
    }
  }
  return coins;
}

export default function CoinDrop({ amount, type }: CoinDropProps) {
  const coins = breakIntoCoins(amount);

  return (
    <div className="flex flex-wrap justify-center gap-1.5 py-2 animate-fade-in-up">
      {coins.map((value, i) => (
        <span
          key={i}
          className="inline-flex items-center justify-center w-9 h-9 rounded-full text-xs font-black animate-coin-fall"
          style={{
            animationDelay: `${i * 0.08}s`,
            background: type === "income"
              ? "linear-gradient(135deg, #fcd34d, #f59e0b)"
              : "linear-gradient(135deg, #fda4af, #f43f5e)",
            color: type === "income" ? "#78350f" : "#881337",
            border: type === "income" ? "2px solid #d97706" : "2px solid #e11d48",
          }}
        >
          {value}
        </span>
      ))}
    </div>
  );
}

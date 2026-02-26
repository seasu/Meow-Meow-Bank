"use client";

type CoinDropProps = {
  amount: number;
  type: "income" | "expense";
};

export default function CoinDrop({ amount, type }: CoinDropProps) {
  const coinCount = Math.min(Math.ceil(amount / 10), 10);

  return (
    <div className="flex flex-wrap justify-center gap-1 py-2">
      {Array.from({ length: coinCount }).map((_, i) => (
        <span
          key={i}
          className="text-3xl animate-bounce-coin"
          style={{ animationDelay: `${i * 0.1}s` }}
        >
          {type === "income" ? "🪙" : "💸"}
        </span>
      ))}
    </div>
  );
}

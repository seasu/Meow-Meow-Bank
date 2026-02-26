"use client";

import { useMemo } from "react";
import DragCoin from "./DragCoin";

type CoinTrayProps = {
  onCoinDropped: (value: number) => void;
  dropTargetRef: React.RefObject<HTMLDivElement | null>;
};

const DENOMINATIONS = [
  { value: 1, label: "1" },
  { value: 5, label: "5" },
  { value: 10, label: "10" },
  { value: 50, label: "50" },
  { value: 100, label: "100" },
];

export default function CoinTray({ onCoinDropped, dropTargetRef }: CoinTrayProps) {
  return (
    <div className="w-full max-w-sm">
      <div className="text-center mb-2">
        <span className="text-xs text-amber-600 font-medium">
          👆 拖拉金幣到招財貓身上記帳！
        </span>
      </div>
      <div className="flex items-center justify-center gap-3 bg-amber-50 rounded-2xl p-4 border-2 border-dashed border-amber-200">
        {DENOMINATIONS.map((d) => (
          <DragCoin
            key={d.value}
            value={d.value}
            label={d.label}
            onDropped={onCoinDropped}
            dropTargetRef={dropTargetRef}
          />
        ))}
      </div>
    </div>
  );
}

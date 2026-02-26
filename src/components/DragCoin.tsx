"use client";

import { useRef, useState } from "react";

type DragCoinProps = {
  value: number;
  label: string;
  onDropped: (value: number) => void;
  dropTargetRef: React.RefObject<HTMLDivElement | null>;
};

export default function DragCoin({ value, label, onDropped, dropTargetRef }: DragCoinProps) {
  const coinRef = useRef<HTMLDivElement>(null);
  const [dragging, setDragging] = useState(false);
  const [pos, setPos] = useState({ x: 0, y: 0 });
  const startPos = useRef({ x: 0, y: 0 });
  const originPos = useRef({ x: 0, y: 0 });

  function handlePointerDown(e: React.PointerEvent) {
    e.preventDefault();
    const coin = coinRef.current;
    if (!coin) return;
    coin.setPointerCapture(e.pointerId);

    const rect = coin.getBoundingClientRect();
    startPos.current = { x: e.clientX, y: e.clientY };
    originPos.current = { x: rect.left, y: rect.top };
    setDragging(true);
    setPos({ x: 0, y: 0 });
  }

  function handlePointerMove(e: React.PointerEvent) {
    if (!dragging) return;
    setPos({
      x: e.clientX - startPos.current.x,
      y: e.clientY - startPos.current.y,
    });
  }

  function handlePointerUp(e: React.PointerEvent) {
    if (!dragging) return;
    setDragging(false);

    const target = dropTargetRef.current;
    if (target) {
      const targetRect = target.getBoundingClientRect();
      const coinX = originPos.current.x + pos.x + 30;
      const coinY = originPos.current.y + pos.y + 30;

      if (
        coinX >= targetRect.left &&
        coinX <= targetRect.right &&
        coinY >= targetRect.top &&
        coinY <= targetRect.bottom
      ) {
        onDropped(value);
      }
    }

    setPos({ x: 0, y: 0 });
  }

  const coinSize = value >= 100 ? "w-16 h-16 text-lg" : value >= 50 ? "w-14 h-14 text-base" : "w-12 h-12 text-sm";

  return (
    <div
      ref={coinRef}
      onPointerDown={handlePointerDown}
      onPointerMove={handlePointerMove}
      onPointerUp={handlePointerUp}
      onPointerCancel={() => { setDragging(false); setPos({ x: 0, y: 0 }); }}
      className={`${coinSize} rounded-full flex flex-col items-center justify-center cursor-grab select-none touch-none transition-shadow ${
        dragging
          ? "shadow-xl scale-110 z-50 opacity-90"
          : "shadow-md hover:shadow-lg hover:scale-105"
      } bg-gradient-to-br from-yellow-300 via-amber-400 to-yellow-500 border-2 border-amber-500`}
      style={{
        transform: dragging ? `translate(${pos.x}px, ${pos.y}px) scale(1.1)` : undefined,
        position: dragging ? "relative" : undefined,
        zIndex: dragging ? 100 : undefined,
      }}
    >
      <span className="font-black text-amber-800 leading-none">{label}</span>
      <span className="text-[10px] text-amber-700 font-bold">元</span>
    </div>
  );
}

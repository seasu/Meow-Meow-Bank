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
  const [renderPos, setRenderPos] = useState({ x: 0, y: 0 });
  const startPos = useRef({ x: 0, y: 0 });
  const originPos = useRef({ x: 0, y: 0 });
  const currentPos = useRef({ x: 0, y: 0 });

  function handlePointerDown(e: React.PointerEvent) {
    e.preventDefault();
    const coin = coinRef.current;
    if (!coin) return;
    coin.setPointerCapture(e.pointerId);

    const rect = coin.getBoundingClientRect();
    startPos.current = { x: e.clientX, y: e.clientY };
    originPos.current = { x: rect.left, y: rect.top };
    currentPos.current = { x: 0, y: 0 };
    setDragging(true);
    setRenderPos({ x: 0, y: 0 });
  }

  function handlePointerMove(e: React.PointerEvent) {
    if (!dragging) return;
    const dx = e.clientX - startPos.current.x;
    const dy = e.clientY - startPos.current.y;
    currentPos.current = { x: dx, y: dy };
    setRenderPos({ x: dx, y: dy });
  }

  function handlePointerUp() {
    if (!dragging) return;
    setDragging(false);

    const target = dropTargetRef.current;
    if (target) {
      const targetRect = target.getBoundingClientRect();
      const coinCenterX = originPos.current.x + currentPos.current.x + 24;
      const coinCenterY = originPos.current.y + currentPos.current.y + 24;

      const hit =
        coinCenterX >= targetRect.left - 20 &&
        coinCenterX <= targetRect.right + 20 &&
        coinCenterY >= targetRect.top - 20 &&
        coinCenterY <= targetRect.bottom + 20;

      if (hit) {
        onDropped(value);
      }
    }

    currentPos.current = { x: 0, y: 0 };
    setRenderPos({ x: 0, y: 0 });
  }

  const coinSize = value >= 100 ? "w-16 h-16 text-lg" : value >= 50 ? "w-14 h-14 text-base" : "w-12 h-12 text-sm";

  return (
    <div
      ref={coinRef}
      onPointerDown={handlePointerDown}
      onPointerMove={handlePointerMove}
      onPointerUp={handlePointerUp}
      onPointerCancel={() => {
        setDragging(false);
        currentPos.current = { x: 0, y: 0 };
        setRenderPos({ x: 0, y: 0 });
      }}
      className={`${coinSize} rounded-full flex flex-col items-center justify-center cursor-grab select-none touch-none ${
        dragging
          ? "shadow-xl z-50 opacity-90"
          : "shadow-md hover:shadow-lg hover:scale-105 transition-all"
      } bg-gradient-to-br from-yellow-300 via-amber-400 to-yellow-500 border-2 border-amber-500`}
      style={{
        transform: dragging
          ? `translate(${renderPos.x}px, ${renderPos.y}px) scale(1.15)`
          : undefined,
        position: "relative",
        zIndex: dragging ? 100 : 1,
      }}
    >
      <span className="font-black text-amber-800 leading-none">{label}</span>
      <span className="text-[10px] text-amber-700 font-bold">元</span>
    </div>
  );
}

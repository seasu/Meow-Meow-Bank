"use client";

import type { BuildingLevel } from "@/lib/types";
import { BUILDING_NAMES, BUILDING_THRESHOLDS } from "@/lib/constants";

type BuildingSceneProps = {
  level: BuildingLevel;
  totalSaved: number;
};

export default function BuildingScene({ level, totalSaved }: BuildingSceneProps) {
  const nextLevel = level < 2 ? ((level + 1) as BuildingLevel) : null;
  const nextThreshold = nextLevel !== null ? BUILDING_THRESHOLDS[nextLevel] : null;
  const progress = nextThreshold
    ? Math.min(
        ((totalSaved - BUILDING_THRESHOLDS[level]) /
          (nextThreshold - BUILDING_THRESHOLDS[level])) *
          100,
        100
      )
    : 100;

  return (
    <div className="w-full max-w-sm rounded-2xl overflow-hidden shadow-md relative">
      {/* Sky gradient */}
      <div
        className={`h-48 relative transition-all duration-1000 ${
          level === 0
            ? "bg-gradient-to-b from-sky-300 to-sky-100"
            : level === 1
            ? "bg-gradient-to-b from-sky-400 to-amber-100"
            : "bg-gradient-to-b from-indigo-400 via-pink-300 to-amber-200"
        }`}
      >
        {/* Sun/Moon */}
        <div
          className={`absolute top-4 right-6 w-10 h-10 rounded-full ${
            level === 2 ? "bg-yellow-200 shadow-lg shadow-yellow-200/50" : "bg-yellow-300"
          }`}
        />

        {/* Stars for castle level */}
        {level === 2 && (
          <>
            <span className="absolute top-3 left-6 text-sm animate-pulse">⭐</span>
            <span className="absolute top-8 left-16 text-xs animate-pulse delay-300">✨</span>
            <span className="absolute top-5 left-28 text-sm animate-pulse delay-500">⭐</span>
          </>
        )}

        {/* Clouds */}
        <div className="absolute top-6 left-4 flex gap-1">
          <div className="w-8 h-4 bg-white/70 rounded-full" />
          <div className="w-12 h-5 bg-white/60 rounded-full -mt-1" />
          <div className="w-6 h-3 bg-white/50 rounded-full mt-1" />
        </div>

        {/* Building */}
        <div className="absolute bottom-0 left-1/2 -translate-x-1/2">
          {level === 0 && <WoodHouse />}
          {level === 1 && <SandHouse />}
          {level === 2 && <Castle />}
        </div>

        {/* Ground */}
        <div className="absolute bottom-0 left-0 right-0 h-8 bg-green-400 rounded-t-[50%]" />
        <div className="absolute bottom-0 left-0 right-0 h-3 bg-green-500" />
      </div>

      {/* Info bar */}
      <div className="bg-white px-4 py-3">
        <div className="flex justify-between items-center mb-1">
          <span className="text-sm font-bold text-amber-700">
            {BUILDING_NAMES[level]}
          </span>
          {nextLevel !== null && (
            <span className="text-xs text-gray-400">
              下一階段: {BUILDING_NAMES[nextLevel]} (${nextThreshold})
            </span>
          )}
          {nextLevel === null && (
            <span className="text-xs text-amber-500">🏆 最高等級!</span>
          )}
        </div>
        {nextLevel !== null && (
          <div className="w-full h-2 bg-gray-100 rounded-full overflow-hidden">
            <div
              className="h-full bg-gradient-to-r from-amber-300 to-amber-500 rounded-full transition-all duration-500"
              style={{ width: `${progress}%` }}
            />
          </div>
        )}
      </div>
    </div>
  );
}

function WoodHouse() {
  return (
    <div className="relative w-24 h-28 mb-3">
      {/* Roof */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-0 h-0 border-l-[40px] border-r-[40px] border-b-[24px] border-l-transparent border-r-transparent border-b-amber-700" />
      {/* Walls */}
      <div className="absolute top-6 left-1/2 -translate-x-1/2 w-20 h-22 bg-amber-600 rounded-b-md">
        {/* Door */}
        <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-7 h-10 bg-amber-800 rounded-t-full" />
        {/* Window */}
        <div className="absolute top-3 left-2 w-5 h-5 bg-amber-200 rounded-sm border border-amber-800" />
        <div className="absolute top-3 right-2 w-5 h-5 bg-amber-200 rounded-sm border border-amber-800" />
      </div>
    </div>
  );
}

function SandHouse() {
  return (
    <div className="relative w-28 h-32 mb-3">
      {/* Roof */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-0 h-0 border-l-[44px] border-r-[44px] border-b-[28px] border-l-transparent border-r-transparent border-b-orange-400" />
      {/* Chimney */}
      <div className="absolute top-[-4px] right-6 w-4 h-8 bg-orange-500" />
      {/* Walls */}
      <div className="absolute top-7 left-1/2 -translate-x-1/2 w-24 h-25 bg-orange-200 rounded-b-md border-2 border-orange-300">
        {/* Door */}
        <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-8 h-11 bg-orange-700 rounded-t-lg">
          <div className="absolute top-4 right-1.5 w-1.5 h-1.5 bg-amber-300 rounded-full" />
        </div>
        {/* Windows */}
        <div className="absolute top-3 left-1.5 w-6 h-6 bg-amber-100 rounded-md border-2 border-orange-400">
          <div className="absolute top-1/2 left-0 right-0 h-[1px] bg-orange-400" />
          <div className="absolute left-1/2 top-0 bottom-0 w-[1px] bg-orange-400" />
        </div>
        <div className="absolute top-3 right-1.5 w-6 h-6 bg-amber-100 rounded-md border-2 border-orange-400">
          <div className="absolute top-1/2 left-0 right-0 h-[1px] bg-orange-400" />
          <div className="absolute left-1/2 top-0 bottom-0 w-[1px] bg-orange-400" />
        </div>
      </div>
      {/* Flower pots */}
      <div className="absolute bottom-2 -left-1 text-sm">🌷</div>
      <div className="absolute bottom-2 -right-1 text-sm">🌻</div>
    </div>
  );
}

function Castle() {
  return (
    <div className="relative w-36 h-40 mb-3">
      {/* Towers */}
      <div className="absolute top-0 left-2 w-8 h-16 bg-purple-300 rounded-t-md">
        <div className="absolute -top-2 left-1/2 -translate-x-1/2 w-2 h-4 bg-purple-400" />
        <div className="absolute top-0 left-0 right-0 flex justify-between px-0.5">
          <div className="w-1.5 h-2 bg-purple-400" />
          <div className="w-1.5 h-2 bg-purple-400" />
          <div className="w-1.5 h-2 bg-purple-400" />
        </div>
        <div className="absolute top-5 left-1/2 -translate-x-1/2 w-3 h-3 bg-purple-100 rounded-t-full" />
      </div>
      <div className="absolute top-0 right-2 w-8 h-16 bg-purple-300 rounded-t-md">
        <div className="absolute -top-2 left-1/2 -translate-x-1/2 w-2 h-4 bg-purple-400" />
        <div className="absolute top-0 left-0 right-0 flex justify-between px-0.5">
          <div className="w-1.5 h-2 bg-purple-400" />
          <div className="w-1.5 h-2 bg-purple-400" />
          <div className="w-1.5 h-2 bg-purple-400" />
        </div>
        <div className="absolute top-5 left-1/2 -translate-x-1/2 w-3 h-3 bg-purple-100 rounded-t-full" />
      </div>
      {/* Main body */}
      <div className="absolute top-8 left-1/2 -translate-x-1/2 w-28 h-32 bg-purple-200 border-2 border-purple-300 rounded-b-md">
        {/* Flag */}
        <div className="absolute -top-6 left-1/2 -translate-x-1/2 text-lg">🚩</div>
        {/* Arch door */}
        <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-10 h-14 bg-purple-500 rounded-t-full">
          <div className="absolute top-6 right-2 w-1.5 h-1.5 bg-amber-300 rounded-full" />
        </div>
        {/* Windows row */}
        <div className="absolute top-4 left-0 right-0 flex justify-around px-3">
          <div className="w-5 h-6 bg-purple-100 rounded-t-full border border-purple-400" />
          <div className="w-5 h-6 bg-purple-100 rounded-t-full border border-purple-400" />
          <div className="w-5 h-6 bg-purple-100 rounded-t-full border border-purple-400" />
        </div>
      </div>
      {/* Sparkles */}
      <span className="absolute -top-2 left-0 text-xs animate-pulse">✨</span>
      <span className="absolute -top-1 right-0 text-xs animate-pulse delay-500">✨</span>
    </div>
  );
}

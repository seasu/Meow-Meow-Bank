"use client";

import { useMemo } from "react";

type Mood = "happy" | "neutral" | "sleepy" | "excited" | "remind";

type LuckyCatProps = {
  hunger: number;
  mood?: Mood;
  message?: string;
  isWaving?: boolean;
  equippedAccessories?: string[];
};

export default function LuckyCat({
  hunger,
  mood,
  message,
  isWaving = false,
  equippedAccessories = [],
}: LuckyCatProps) {
  const baseMood: Mood = useMemo(() => {
    if (hunger < 20) return "sleepy";
    if (hunger < 50) return "neutral";
    return "happy";
  }, [hunger]);

  const baseMessage = useMemo(() => {
    if (hunger < 20) return "好久沒記帳了，我好餓喵...";
    if (hunger < 50) return "嗨，快來記帳吧！";
    return "喵～今天也要好好記帳喔！";
  }, [hunger]);

  const currentMood = mood ?? baseMood;
  const currentMessage = message ?? baseMessage;
  const catOpacity = currentMood === "sleepy" ? "opacity-60" : "";
  const pawClass = isWaving ? "animate-wave-paw origin-bottom" : "";

  return (
    <div className="flex flex-col items-center gap-3 relative">
      {equippedAccessories.length > 0 && (
        <div className="flex gap-1 text-lg">
          {equippedAccessories.map((id) => (
            <span key={id} className="animate-bounce-coin" style={{ animationDuration: "2s" }}>
              {accessoryEmoji(id)}
            </span>
          ))}
        </div>
      )}

      <div className={`relative ${catOpacity} transition-opacity duration-500`}>
        <div className="w-32 h-36 relative">
          <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-28 h-28 bg-amber-300 rounded-[50%_50%_45%_45%]" />

          <div className="absolute top-0 left-1/2 -translate-x-1/2 w-24 h-22 bg-amber-300 rounded-full z-10">
            <div className="absolute -top-3 left-1 w-0 h-0 border-l-[12px] border-r-[12px] border-b-[18px] border-l-transparent border-r-transparent border-b-amber-300" />
            <div className="absolute -top-3 right-1 w-0 h-0 border-l-[12px] border-r-[12px] border-b-[18px] border-l-transparent border-r-transparent border-b-amber-300" />
            <div className="absolute -top-1 left-2.5 w-0 h-0 border-l-[8px] border-r-[8px] border-b-[12px] border-l-transparent border-r-transparent border-b-pink-300" />
            <div className="absolute -top-1 right-2.5 w-0 h-0 border-l-[8px] border-r-[8px] border-b-[12px] border-l-transparent border-r-transparent border-b-pink-300" />

            <div className="absolute top-6 left-0 right-0 flex flex-col items-center">
              <div className="flex gap-5 mb-1">
                <CatEye mood={currentMood} />
                <CatEye mood={currentMood} />
              </div>
              <div className="w-2 h-1.5 bg-pink-400 rounded-full" />
              <div className="flex gap-0.5 mt-0.5">
                <div className={`w-2.5 h-1.5 border-b-2 rounded-b-full ${
                  currentMood === "excited" || currentMood === "happy" ? "border-pink-500" : "border-gray-600"
                }`} />
                <div className={`w-2.5 h-1.5 border-b-2 rounded-b-full ${
                  currentMood === "excited" || currentMood === "happy" ? "border-pink-500" : "border-gray-600"
                }`} />
              </div>
              {(currentMood === "excited" || currentMood === "happy") && (
                <div className="flex gap-8 -mt-3">
                  <div className="w-3 h-2 bg-pink-200 rounded-full opacity-70" />
                  <div className="w-3 h-2 bg-pink-200 rounded-full opacity-70" />
                </div>
              )}
            </div>
          </div>

          <div className={`absolute top-14 -right-2 z-20 ${pawClass}`}>
            <div className="w-8 h-10 bg-amber-200 rounded-full flex items-end justify-center">
              <div className="w-5 h-3 bg-pink-200 rounded-full mb-1" />
            </div>
          </div>

          <div className="absolute top-16 -left-1 z-20">
            <div className="w-7 h-8 bg-amber-200 rounded-full flex items-end justify-center">
              <div className="w-4 h-2.5 bg-pink-200 rounded-full mb-1" />
            </div>
          </div>

          <div className="absolute bottom-4 left-1/2 -translate-x-1/2 w-14 h-12 bg-amber-100 rounded-full z-10" />
          <div className="absolute bottom-7 left-1/2 -translate-x-1/2 z-10 text-xl">💰</div>
        </div>
      </div>

      <div className="w-32 h-2 bg-gray-200 rounded-full overflow-hidden">
        <div
          className={`h-full rounded-full transition-all duration-500 ${
            hunger > 60 ? "bg-green-400" : hunger > 30 ? "bg-amber-400" : "bg-red-400"
          }`}
          style={{ width: `${hunger}%` }}
        />
      </div>
      <span className="text-xs text-amber-600">飽食度 {hunger}%</span>

      <p className={`text-base font-bold text-center animate-fade-in-up ${
        currentMood === "remind" ? "text-pink-500" :
        currentMood === "excited" ? "text-amber-600" :
        "text-amber-800"
      }`}>
        {currentMessage}
      </p>
    </div>
  );
}

function CatEye({ mood }: { mood: Mood }) {
  if (mood === "sleepy") return <div className="w-4 h-0.5 bg-gray-500 rounded-full mt-1" />;
  if (mood === "excited") return <div className="w-3 h-3 rounded-full bg-pink-400 animate-pulse" />;
  return <div className="w-3 h-3 rounded-full bg-gray-800" />;
}

function accessoryEmoji(id: string): string {
  const map: Record<string, string> = {
    "red-bell": "🔔", "blue-scarf": "🧣", "gold-crown": "👑", "star-glasses": "🕶️",
    "cat-bed": "🛏️", "fish-toy": "🐠", "cat-tower": "🗼", "magic-wand": "✨",
  };
  return map[id] ?? "🎀";
}

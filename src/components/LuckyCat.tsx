"use client";

import { useState, useEffect } from "react";

type Mood = "happy" | "neutral" | "sleepy" | "excited";

const CAT_FACES: Record<Mood, string> = {
  happy: "😺",
  neutral: "🐱",
  sleepy: "😿",
  excited: "😻",
};

const CAT_MESSAGES: Record<Mood, string> = {
  happy: "喵～今天也要好好記帳喔！",
  neutral: "嗨，快來記帳吧！",
  sleepy: "好久沒記帳了，我好餓喵...",
  excited: "太棒了！存錢真開心喵～✨",
};

type LuckyCatProps = {
  mood?: Mood;
  lastAction?: "income" | "expense" | null;
};

export default function LuckyCat({
  mood = "neutral",
  lastAction,
}: LuckyCatProps) {
  const [isWaving, setIsWaving] = useState(false);
  const [currentMood, setCurrentMood] = useState<Mood>(mood);

  useEffect(() => {
    if (lastAction === "income") {
      setCurrentMood("excited");
      setIsWaving(true);
      setTimeout(() => setIsWaving(false), 1200);
      setTimeout(() => setCurrentMood("happy"), 3000);
    } else if (lastAction === "expense") {
      setCurrentMood("happy");
    }
  }, [lastAction]);

  useEffect(() => {
    setCurrentMood(mood);
  }, [mood]);

  return (
    <div className="flex flex-col items-center gap-2">
      <div
        className={`text-8xl transition-transform duration-300 select-none ${
          isWaving ? "animate-wave-paw" : ""
        }`}
        role="img"
        aria-label="招財貓"
      >
        {CAT_FACES[currentMood]}
      </div>
      <p className="text-lg font-bold text-amber-800 text-center animate-fade-in-up">
        {CAT_MESSAGES[currentMood]}
      </p>
    </div>
  );
}

"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const TABS = [
  { href: "/", label: "記帳", emoji: "🪙" },
  { href: "/stats", label: "統計", emoji: "📊" },
  { href: "/dream-tree", label: "夢想樹", emoji: "🌳" },
  { href: "/accessories", label: "收藏", emoji: "✨" },
  { href: "/parent", label: "家長", emoji: "👨‍👩‍👧" },
];

export default function TabBar() {
  const pathname = usePathname();

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-white/90 backdrop-blur-md border-t border-amber-100 z-50">
      <div className="flex justify-around max-w-lg mx-auto">
        {TABS.map((tab) => {
          const active = pathname === tab.href;
          return (
            <Link
              key={tab.href}
              href={tab.href}
              className={`flex flex-col items-center py-2 px-3 transition-colors ${
                active ? "text-amber-600" : "text-gray-400"
              }`}
            >
              <span className={`text-2xl ${active ? "scale-110" : ""} transition-transform`}>
                {tab.emoji}
              </span>
              <span className="text-xs font-medium mt-0.5">{tab.label}</span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}

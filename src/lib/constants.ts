import type { Category, Accessory, BuildingLevel } from "./types";

export const BUILDING_NAMES: Record<BuildingLevel, string> = {
  0: "木造小屋",
  1: "精緻砂屋",
  2: "豪華城堡",
};

export const BUILDING_THRESHOLDS: Record<BuildingLevel, number> = {
  0: 0,
  1: 500,
  2: 2000,
};

export const CATEGORIES: Category[] = [
  { id: "food", name: "飲食", emoji: "🐟", type: "expense" },
  { id: "fun", name: "娛樂", emoji: "🧶", type: "expense" },
  { id: "transport", name: "交通", emoji: "🚌", type: "expense" },
  { id: "shopping", name: "購物", emoji: "🛍️", type: "expense" },
  { id: "income", name: "收入", emoji: "🪙", type: "income" },
  { id: "gift", name: "禮物", emoji: "🎁", type: "income" },
  { id: "allowance", name: "零用錢", emoji: "💰", type: "income" },
  { id: "interest", name: "利息", emoji: "🏦", type: "income" },
];

export const ACCESSORIES: Accessory[] = [
  {
    id: "red-bell",
    name: "紅色鈴鐺",
    emoji: "🔔",
    description: "連續記帳 3 天解鎖",
    requirement: { type: "streak", days: 3 },
  },
  {
    id: "blue-scarf",
    name: "藍色圍兜",
    emoji: "🧣",
    description: "連續記帳 7 天解鎖",
    requirement: { type: "streak", days: 7 },
  },
  {
    id: "gold-crown",
    name: "金色皇冠",
    emoji: "👑",
    description: "連續記帳 14 天解鎖",
    requirement: { type: "streak", days: 14 },
  },
  {
    id: "star-glasses",
    name: "星星眼鏡",
    emoji: "🕶️",
    description: "連續記帳 30 天解鎖",
    requirement: { type: "streak", days: 30 },
  },
  {
    id: "cat-bed",
    name: "貓咪小窩",
    emoji: "🛏️",
    description: "存款達 200 元解鎖",
    requirement: { type: "savings", amount: 200 },
  },
  {
    id: "fish-toy",
    name: "小魚玩具",
    emoji: "🐠",
    description: "存款達 500 元解鎖",
    requirement: { type: "savings", amount: 500 },
  },
  {
    id: "cat-tower",
    name: "豪華貓塔",
    emoji: "🗼",
    description: "存款達 1000 元解鎖",
    requirement: { type: "savings", amount: 1000 },
  },
  {
    id: "magic-wand",
    name: "魔法棒",
    emoji: "✨",
    description: "存款達 3000 元解鎖",
    requirement: { type: "savings", amount: 3000 },
  },
];

export const MAX_HUNGER = 100;
export const HUNGER_DECAY_PER_DAY = 15;
export const HUNGER_FEED_AMOUNT = 30;

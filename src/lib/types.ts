export type TransactionType = "income" | "expense";

export type Category = {
  id: string;
  name: string;
  emoji: string;
  type: TransactionType;
};

export type Transaction = {
  id: string;
  amount: number;
  category: Category;
  type: TransactionType;
  note: string;
  createdAt: string;
  approved: boolean;
  parentHeart: boolean;
};

export type BuildingLevel = 0 | 1 | 2;


export type Accessory = {
  id: string;
  name: string;
  emoji: string;
  description: string;
  requirement: { type: "streak"; days: number } | { type: "savings"; amount: number };
};

export type Wish = {
  id: string;
  name: string;
  emoji: string;
  targetAmount: number;
  savedAmount: number;
  createdAt: string;
  completedAt: string | null;
};

export type InterestPeriod = "weekly" | "monthly";

export type ParentConfig = {
  interestRate: number;
  interestPeriod: InterestPeriod;
  lastInterestDate: string;
};

export type AppState = {
  transactions: Transaction[];
  wishes: Wish[];
  profile: {
    name: string;
    lastRecordDate: string | null;
    streak: number;
    catHunger: number;
    buildingLevel: BuildingLevel;
    unlockedAccessories: string[];
    equippedAccessories: string[];
  };
  parentConfig: ParentConfig;
};

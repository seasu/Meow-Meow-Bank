import 'transaction.dart';

const List<TxCategory> kCategories = [
  TxCategory(id: 'food', name: '飲食', emoji: '🐟', type: TransactionType.expense),
  TxCategory(id: 'fun', name: '娛樂', emoji: '🧶', type: TransactionType.expense),
  TxCategory(id: 'transport', name: '交通', emoji: '🚌', type: TransactionType.expense),
  TxCategory(id: 'shopping', name: '購物', emoji: '🛍️', type: TransactionType.expense),
  TxCategory(id: 'income', name: '收入', emoji: '🪙', type: TransactionType.income),
  TxCategory(id: 'gift', name: '禮物', emoji: '🎁', type: TransactionType.income),
  TxCategory(id: 'allowance', name: '零用錢', emoji: '💰', type: TransactionType.income),
  TxCategory(id: 'interest', name: '利息', emoji: '🏦', type: TransactionType.income),
];

const List<AccessoryDef> kAccessories = [
  AccessoryDef(id: 'red-bell', name: '紅色鈴鐺', emoji: '🔔', description: '連續記帳 3 天解鎖', reqType: 'streak', reqValue: 3),
  AccessoryDef(id: 'blue-scarf', name: '藍色圍兜', emoji: '🧣', description: '連續記帳 7 天解鎖', reqType: 'streak', reqValue: 7),
  AccessoryDef(id: 'gold-crown', name: '金色皇冠', emoji: '👑', description: '連續記帳 14 天解鎖', reqType: 'streak', reqValue: 14),
  AccessoryDef(id: 'star-glasses', name: '星星眼鏡', emoji: '🕶️', description: '連續記帳 30 天解鎖', reqType: 'streak', reqValue: 30),
  AccessoryDef(id: 'cat-bed', name: '貓咪小窩', emoji: '🛏️', description: '存款達 200 元解鎖', reqType: 'savings', reqValue: 200),
  AccessoryDef(id: 'fish-toy', name: '小魚玩具', emoji: '🐠', description: '存款達 500 元解鎖', reqType: 'savings', reqValue: 500),
  AccessoryDef(id: 'cat-tower', name: '豪華貓塔', emoji: '🗼', description: '存款達 1000 元解鎖', reqType: 'savings', reqValue: 1000),
  AccessoryDef(id: 'magic-wand', name: '魔法棒', emoji: '✨', description: '存款達 3000 元解鎖', reqType: 'savings', reqValue: 3000),
];

const Map<int, String> kBuildingNames = {0: '木造小屋', 1: '精緻砂屋', 2: '豪華城堡'};
const Map<int, double> kBuildingThresholds = {0: 0, 1: 500, 2: 2000};
const double kMaxHunger = 100;
const double kHungerDecayPerDay = 15;
const double kHungerFeedAmount = 30;

class AccessoryDef {
  final String id, name, emoji, description, reqType;
  final int reqValue;
  const AccessoryDef({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.reqType,
    required this.reqValue,
  });
}

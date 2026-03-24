class TxCategory {
  final String id;
  final String name;
  final String emoji;
  final TransactionType type;

  const TxCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'type': type.name,
      };

  factory TxCategory.fromJson(Map<String, dynamic> json) => TxCategory(
        id: json['id'],
        name: json['name'],
        emoji: json['emoji'],
        type: TransactionType.values.byName(json['type']),
      );
}

enum TransactionType { income, expense }

class Transaction {
  final String id;
  double amount;
  TxCategory category;
  TransactionType type;
  String note;
  DateTime createdAt;
  bool approved;
  bool parentHeart;

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.type,
    required this.note,
    required this.createdAt,
    this.approved = false,
    this.parentHeart = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'category': category.toJson(),
        'type': type.name,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'approved': approved,
        'parentHeart': parentHeart,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        amount: (json['amount'] as num).toDouble(),
        category: TxCategory.fromJson(json['category']),
        type: TransactionType.values.byName(json['type']),
        note: json['note'] ?? '',
        createdAt: DateTime.parse(json['createdAt']),
        approved: json['approved'] ?? false,
        parentHeart: json['parentHeart'] ?? false,
      );
}

class Wish {
  final String id;
  final String name;
  final String emoji;
  final double targetAmount;
  double savedAmount;
  final DateTime createdAt;
  DateTime? completedAt;

  Wish({
    required this.id,
    required this.name,
    required this.emoji,
    required this.targetAmount,
    this.savedAmount = 0,
    required this.createdAt,
    this.completedAt,
  });

  double get progress =>
      targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory Wish.fromJson(Map<String, dynamic> json) => Wish(
        id: json['id'],
        name: json['name'],
        emoji: json['emoji'],
        targetAmount: (json['targetAmount'] as num).toDouble(),
        savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.parse(json['createdAt']),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
      );
}

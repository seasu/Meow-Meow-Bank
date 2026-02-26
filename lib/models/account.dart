class Account {
  final String id;
  String name;
  String emoji;
  final DateTime createdAt;

  Account({
    required this.id,
    required this.name,
    required this.emoji,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'],
        name: json['name'],
        emoji: json['emoji'] ?? '🐱',
        createdAt: DateTime.parse(json['createdAt']),
      );
}

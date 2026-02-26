import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/transaction.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final txs = state.transactions.reversed.toList();

    final grouped = <String, List<Transaction>>{};
    for (final tx in txs) {
      final date = tx.createdAt.toIso8601String().split('T')[0];
      grouped.putIfAbsent(date, () => []).add(tx);
    }
    final dates = grouped.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('📖 完整紀錄')),
      body: txs.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🐾', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 8),
                  Text('還沒有紀錄喔', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: dates.length,
              itemBuilder: (_, i) {
                final date = dates[i];
                final dayTxs = grouped[date]!;
                final dayIncome = dayTxs
                    .where((t) => t.type == TransactionType.income)
                    .fold(0.0, (s, t) => s + t.amount);
                final dayExpense = dayTxs
                    .where((t) => t.type == TransactionType.expense)
                    .fold(0.0, (s, t) => s + t.amount);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            _formatDate(date),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800),
                          ),
                          const Spacer(),
                          if (dayIncome > 0)
                            Text('+\$${dayIncome.toInt()} ',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green.shade600,
                                    fontWeight: FontWeight.w600)),
                          if (dayExpense > 0)
                            Text('-\$${dayExpense.toInt()}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.pink,
                                    fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    // Transactions for this date
                    ...dayTxs.map((tx) => Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4)
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(tx.category.emoji,
                                  style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tx.category.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14)),
                                    if (tx.note.isNotEmpty)
                                      Text(tx.note,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade500)),
                                    Text(
                                      _formatTime(tx.createdAt),
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade400),
                                    ),
                                  ],
                                ),
                              ),
                              if (tx.parentHeart)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child:
                                      Text('❤️', style: TextStyle(fontSize: 14)),
                                ),
                              if (tx.approved)
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Icon(Icons.check_circle,
                                      size: 16, color: Colors.green.shade400),
                                ),
                              Text(
                                '${tx.type == TransactionType.income ? '+' : '-'}\$${tx.amount.toInt()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: tx.type == TransactionType.income
                                      ? Colors.green.shade600
                                      : Colors.pink,
                                ),
                              ),
                            ],
                          ),
                        )),
                    if (i < dates.length - 1)
                      Divider(color: Colors.grey.shade200, height: 16),
                  ],
                );
              },
            ),
    );
  }

  String _formatDate(String dateStr) {
    final d = DateTime.parse(dateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return '今天';
    if (diff == 1) return '昨天';
    if (diff < 7) return '$diff 天前';
    return '${d.month}/${d.day}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

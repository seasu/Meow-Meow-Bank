import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/transaction.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(state),
          const SizedBox(height: 20),
          _buildWeeklyChart(state),
          const SizedBox(height: 20),
          _buildCategoryBreakdown(state),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(AppState state) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: '總收入',
            amount: state.totalSaved,
            emoji: '🪙',
            gradient: [Colors.green.shade300, Colors.green.shade600],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: '總支出',
            amount: state.totalExpense,
            emoji: '💸',
            gradient: [Colors.pink.shade200, Colors.pink.shade500],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: '餘額',
            amount: state.balance,
            emoji: '🏦',
            gradient: [Colors.amber.shade300, Colors.amber.shade700],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(AppState state) {
    final now = DateTime.now();
    final weekDays = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return DateTime(day.year, day.month, day.day);
    });

    final dailyIncome = <DateTime, double>{};
    final dailyExpense = <DateTime, double>{};

    for (final day in weekDays) {
      dailyIncome[day] = 0;
      dailyExpense[day] = 0;
    }

    for (final tx in state.transactions) {
      final txDay = DateTime(tx.createdAt.year, tx.createdAt.month, tx.createdAt.day);
      if (tx.type == TransactionType.income && dailyIncome.containsKey(txDay)) {
        dailyIncome[txDay] = dailyIncome[txDay]! + tx.amount;
      } else if (tx.type == TransactionType.expense && dailyExpense.containsKey(txDay)) {
        dailyExpense[txDay] = dailyExpense[txDay]! + tx.amount;
      }
    }

    final maxVal = [
      ...dailyIncome.values,
      ...dailyExpense.values,
    ].fold<double>(0, (a, b) => a > b ? a : b);

    const chartHeight = 140.0;
    const weekdayLabels = ['一', '二', '三', '四', '五', '六', '日'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 近 7 天收支',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _legendDot(Colors.green.shade400, '收入'),
              const SizedBox(width: 12),
              _legendDot(Colors.pink.shade300, '支出'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: chartHeight + 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final day = weekDays[i];
                final income = dailyIncome[day] ?? 0;
                final expense = dailyExpense[day] ?? 0;
                final incomeH = maxVal > 0 ? (income / maxVal) * chartHeight : 0.0;
                final expenseH = maxVal > 0 ? (expense / maxVal) * chartHeight : 0.0;
                final label = weekdayLabels[day.weekday - 1];

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _bar(incomeH, Colors.green.shade400),
                          const SizedBox(width: 2),
                          _bar(expenseH, Colors.pink.shade300),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _bar(double height, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      width: 12,
      height: height.clamp(0, 140),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }

  Widget _buildCategoryBreakdown(AppState state) {
    final expenses = state.transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    if (expenses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
        ),
        child: const Column(
          children: [
            Text('🐾', style: TextStyle(fontSize: 32)),
            SizedBox(height: 8),
            Text('還沒有支出紀錄喔！', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final catTotals = <String, _CategoryTotal>{};
    for (final tx in expenses) {
      final key = tx.category.id;
      catTotals.putIfAbsent(
        key,
        () => _CategoryTotal(
          name: tx.category.name,
          emoji: tx.category.emoji,
          amount: 0,
        ),
      );
      catTotals[key]!.amount += tx.amount;
    }

    final sorted = catTotals.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final total = sorted.fold<double>(0, (s, c) => s + c.amount);

    final barColors = [
      Colors.pink.shade400,
      Colors.amber.shade500,
      Colors.purple.shade300,
      Colors.teal.shade400,
      Colors.orange.shade400,
      Colors.blue.shade300,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🍰 支出分類',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade800,
            ),
          ),
          const SizedBox(height: 12),
          ...sorted.asMap().entries.map((entry) {
            final i = entry.key;
            final cat = entry.value;
            final ratio = total > 0 ? cat.amount / total : 0.0;
            final color = barColors[i % barColors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(cat.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cat.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '\$${cat.amount.toInt()}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink.shade600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${(ratio * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final String emoji;
  final List<Color> gradient;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.emoji,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '\$${amount.toInt()}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTotal {
  final String name;
  final String emoji;
  double amount;

  _CategoryTotal({
    required this.name,
    required this.emoji,
    required this.amount,
  });
}

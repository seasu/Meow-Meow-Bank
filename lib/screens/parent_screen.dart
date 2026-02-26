import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/transaction.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  late TextEditingController _rateController;
  late String _selectedPeriod;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _rateController =
        TextEditingController(text: state.interestRate.toString());
    _selectedPeriod = state.interestPeriod;
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('👨‍👩‍👧 家長儀表板'),
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(state),
            const SizedBox(height: 20),
            _buildPendingApprovals(state),
            const SizedBox(height: 20),
            _buildInterestSettings(state),
            const SizedBox(height: 20),
            _buildRecentTransactions(state),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(AppState state) {
    final totalIncome = state.transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);

    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: '🔥',
            label: '連續記帳',
            value: '${state.streak} 天',
            gradient: [Colors.orange.shade400, Colors.deepOrange.shade400],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            icon: '💰',
            label: '目前餘額',
            value: '\$${state.balance.toInt()}',
            gradient: [Colors.blue.shade400, Colors.indigo.shade400],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            icon: '📈',
            label: '總收入',
            value: '\$${totalIncome.toInt()}',
            gradient: [Colors.amber.shade400, Colors.orange.shade400],
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String icon,
    required String label,
    required String value,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          FittedBox(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovals(AppState state) {
    final pending =
        state.transactions.where((t) => !t.approved).toList().reversed.toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pending_actions, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 8),
              Text('待審核項目',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade800)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: pending.isEmpty
                      ? Colors.green.shade100
                      : Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${pending.length} 筆',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: pending.isEmpty
                        ? Colors.green.shade700
                        : Colors.amber.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (pending.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('所有項目已審核完畢 ✅',
                    style: TextStyle(
                        fontSize: 13, color: Colors.green.shade600)),
              ),
            )
          else
            ...pending.take(20).map((tx) => _pendingItem(state, tx)),
        ],
      ),
    );
  }

  Widget _pendingItem(AppState state, Transaction tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(tx.category.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.category.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                if (tx.note.isNotEmpty)
                  Text(tx.note,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600)),
                Text(
                  '${tx.type == TransactionType.income ? '+' : '-'}\$${tx.amount.toInt()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: tx.type == TransactionType.income
                        ? Colors.green.shade600
                        : Colors.pink.shade400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _actionButton(
            label: '✓ 核准',
            color: Colors.blue.shade600,
            onTap: () => state.approveTransaction(tx.id),
          ),
          const SizedBox(width: 6),
          _actionButton(
            label: '❤️',
            color: tx.parentHeart ? Colors.grey.shade400 : Colors.pink.shade400,
            onTap: tx.parentHeart ? null : () => state.sendHeart(tx.id),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildInterestSettings(AppState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.savings, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 8),
              Text('利息設定',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade800)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _rateController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: '利率 (%)',
                    labelStyle: TextStyle(color: Colors.blueGrey.shade600),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blueGrey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blueGrey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.blue.shade400, width: 2),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueGrey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPeriod,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'weekly', child: Text('每週')),
                        DropdownMenuItem(value: 'monthly', child: Text('每月')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedPeriod = v);
                      },
                      style: TextStyle(
                          fontSize: 15, color: Colors.blueGrey.shade800),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final rate = double.tryParse(_rateController.text);
                    if (rate != null && rate > 0) {
                      state.updateInterestConfig(rate, _selectedPeriod);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('利息設定已更新 ✅'),
                          backgroundColor: Colors.green.shade600,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('儲存設定'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blueGrey.shade700,
                    side: BorderSide(color: Colors.blueGrey.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: state.balance > 0
                      ? () {
                          state.applyInterest();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('利息已發放 🎉'),
                              backgroundColor: Colors.amber.shade700,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.monetization_on, size: 18),
                  label: const Text('發放利息'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade600,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '目前設定：${state.interestRate}% / ${state.interestPeriod == "weekly" ? "每週" : "每月"}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(AppState state) {
    final recent = state.transactions.reversed.take(15).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: Colors.blueGrey.shade600, size: 20),
              const SizedBox(width: 8),
              Text('近期交易紀錄',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade800)),
            ],
          ),
          const SizedBox(height: 12),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('尚無交易紀錄',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade500)),
              ),
            )
          else
            ...recent.map((tx) => _transactionRow(tx)),
        ],
      ),
    );
  }

  Widget _transactionRow(Transaction tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(tx.category.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(tx.category.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    if (tx.approved) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.check_circle,
                          size: 14, color: Colors.green.shade500),
                    ],
                    if (tx.parentHeart) ...[
                      const SizedBox(width: 4),
                      const Text('❤️', style: TextStyle(fontSize: 11)),
                    ],
                  ],
                ),
                if (tx.note.isNotEmpty)
                  Text(tx.note,
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Text(
            '${tx.type == TransactionType.income ? '+' : '-'}\$${tx.amount.toInt()}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: tx.type == TransactionType.income
                  ? Colors.green.shade600
                  : Colors.pink.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

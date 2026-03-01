import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/transaction.dart';
import '../models/constants.dart';

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
                    ...dayTxs.map((tx) => GestureDetector(
                          onTap: () => _showEditSheet(context, tx),
                          child: Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    child: Text('❤️',
                                        style: TextStyle(fontSize: 14)),
                                  ),
                                if (tx.approved)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Icon(Icons.check_circle,
                                        size: 16,
                                        color: Colors.green.shade400),
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
                                const SizedBox(width: 4),
                                Icon(Icons.edit,
                                    size: 14, color: Colors.grey.shade300),
                              ],
                            ),
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

  void _showEditSheet(BuildContext context, Transaction tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _EditTransactionSheet(tx: tx),
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

// ─── Edit Transaction Bottom Sheet ─────────────────────────────────────────

class _EditTransactionSheet extends StatefulWidget {
  final Transaction tx;
  const _EditTransactionSheet({required this.tx});

  @override
  State<_EditTransactionSheet> createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends State<_EditTransactionSheet> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  late TxCategory _category;
  late TransactionType _type;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _amountCtrl =
        TextEditingController(text: widget.tx.amount.toInt().toString());
    _noteCtrl = TextEditingController(text: widget.tx.note);
    _category = widget.tx.category;
    _type = widget.tx.type;
    _date = widget.tx.createdAt;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  List<TxCategory> get _availableCategories =>
      kCategories.where((c) => c.type == _type).toList();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _date = DateTime(
            picked.year, picked.month, picked.day, _date.hour, _date.minute);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (picked != null) {
      setState(() {
        _date = DateTime(
            _date.year, _date.month, _date.day, picked.hour, picked.minute);
      });
    }
  }

  void _save(AppState state) {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) return;
    // If category type changed, reset to first matching category
    final cat = _availableCategories.any((c) => c.id == _category.id)
        ? _category
        : _availableCategories.first;
    state.updateTransaction(
      widget.tx.id,
      amount: amount,
      category: cat,
      type: _type,
      note: _noteCtrl.text.trim(),
      createdAt: _date,
    );
    Navigator.pop(context);
  }

  Future<void> _delete(AppState state) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('刪除紀錄'),
        content: const Text('確定要刪除這筆紀錄嗎？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      state.deleteTransaction(widget.tx.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final dateStr =
        '${_date.year}/${_date.month.toString().padLeft(2, '0')}/${_date.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${_date.hour.toString().padLeft(2, '0')}:${_date.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Text('✏️ 修改紀錄',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: '刪除',
                  onPressed: () => _delete(state),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Type toggle
            Row(
              children: [
                Expanded(
                  child: _TypeButton(
                    label: '💰 收入',
                    selected: _type == TransactionType.income,
                    color: Colors.green.shade400,
                    onTap: () => setState(() {
                      _type = TransactionType.income;
                      _category = kCategories
                          .firstWhere((c) => c.type == TransactionType.income);
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TypeButton(
                    label: '🛍️ 支出',
                    selected: _type == TransactionType.expense,
                    color: Colors.pink.shade400,
                    onTap: () => setState(() {
                      _type = TransactionType.expense;
                      _category = kCategories
                          .firstWhere((c) => c.type == TransactionType.expense);
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Amount
            Text('金額',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700)),
            const SizedBox(height: 6),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                prefixText: '\$ ',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: _type == TransactionType.income
                            ? Colors.green.shade400
                            : Colors.pink.shade400)),
              ),
            ),
            const SizedBox(height: 16),

            // Category
            Text('類別',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableCategories.map((cat) {
                final sel = cat.id == _category.id;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel
                          ? (_type == TransactionType.income
                              ? Colors.green.shade50
                              : Colors.pink.shade50)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel
                            ? (_type == TransactionType.income
                                ? Colors.green.shade300
                                : Colors.pink.shade300)
                            : Colors.grey.shade200,
                        width: sel ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cat.emoji,
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 4),
                        Text(cat.name,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: sel
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: sel
                                    ? (_type == TransactionType.income
                                        ? Colors.green.shade700
                                        : Colors.pink.shade700)
                                    : Colors.grey.shade700)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Note
            Text('備註',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700)),
            const SizedBox(height: 6),
            TextField(
              controller: _noteCtrl,
              decoration: InputDecoration(
                hintText: '選填',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade400)),
              ),
            ),
            const SizedBox(height: 16),

            // Date & Time
            Text('日期與時間',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(dateStr),
                    onPressed: _pickDate,
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, size: 16),
                    label: Text(timeStr),
                    onPressed: _pickTime,
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Save button
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _amountCtrl,
              builder: (context, value, _) {
                final amount = double.tryParse(value.text) ?? 0;
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: amount > 0 ? () => _save(state) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _type == TransactionType.income
                          ? Colors.green.shade400
                          : Colors.pink.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('儲存修改',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper widget ──────────────────────────────────────────────────────────

class _TypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton(
      {required this.label,
      required this.selected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? color : Colors.grey.shade200,
              width: selected ? 2 : 1),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? color : Colors.grey.shade600)),
        ),
      ),
    );
  }
}

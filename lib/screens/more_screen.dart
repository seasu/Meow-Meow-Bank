import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/transaction.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pending = state.transactions.where((t) => !t.approved).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.amber.shade100, Colors.amber.shade50]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Text('👨‍👩‍👧', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('家長設定', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('管理帳戶、審核記錄、設定利息', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Stats
        Row(
          children: [
            _statCard('餘額', '\$${state.balance.toInt()}', Colors.green),
            const SizedBox(width: 8),
            _statCard('連續', '${state.streak}天', Colors.amber),
            const SizedBox(width: 8),
            _statCard('帳戶', '${state.accounts.length}個', Colors.blue),
          ],
        ),
        const SizedBox(height: 20),

        // Pending approvals
        if (pending.isNotEmpty) ...[
          _sectionTitle('📋 待審核 (${pending.length})'),
          const SizedBox(height: 8),
          ...pending.reversed.take(10).map((tx) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
                ),
                child: Row(
                  children: [
                    Text(tx.category.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx.category.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            '${tx.type == TransactionType.income ? '+' : '-'}\$${tx.amount.toInt()}',
                            style: TextStyle(
                              fontSize: 13,
                              color: tx.type == TransactionType.income ? Colors.green : Colors.pink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => state.approveTransaction(tx.id),
                      icon: Icon(Icons.check_circle, color: Colors.green.shade400, size: 28),
                    ),
                    IconButton(
                      onPressed: () => state.sendHeart(tx.id),
                      icon: Icon(
                        Icons.favorite,
                        color: tx.parentHeart ? Colors.red : Colors.grey.shade300,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
        ],

        // Interest settings
        _sectionTitle('🏦 虛擬利息'),
        const SizedBox(height: 8),
        _InterestCard(state: state),
        const SizedBox(height: 20),

        // Account management
        _sectionTitle('👤 帳戶管理'),
        const SizedBox(height: 8),
        ...state.accounts.map((acc) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: acc.id == state.currentAccountId ? Colors.amber.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: acc.id == state.currentAccountId
                    ? Border.all(color: Colors.amber.shade300, width: 1.5)
                    : null,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(acc.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(acc.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            if (acc.id == state.currentAccountId)
                              Text('目前使用中', style: TextStyle(fontSize: 11, color: Colors.amber.shade700)),
                          ],
                        ),
                      ),
                      if (acc.id == state.currentAccountId)
                        Icon(Icons.check_circle, color: Colors.green.shade400, size: 22),
                      if (acc.id != state.currentAccountId)
                        TextButton(
                          onPressed: () => state.switchAccount(acc.id),
                          child: const Text('切換'),
                        ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _showEditAccount(context, state, acc.id, acc.name, acc.emoji),
                        icon: Icon(Icons.edit, size: 16, color: Colors.blue.shade400),
                        label: Text('編輯', style: TextStyle(fontSize: 12, color: Colors.blue.shade400)),
                      ),
                      TextButton.icon(
                        onPressed: () => _confirmClearData(context, state, acc.id, acc.name),
                        icon: Icon(Icons.cleaning_services, size: 16, color: Colors.orange.shade400),
                        label: Text('清除記錄', style: TextStyle(fontSize: 12, color: Colors.orange.shade400)),
                      ),
                      if (state.accounts.length > 1)
                        TextButton.icon(
                          onPressed: () => _confirmDelete(context, state, acc.id, acc.name),
                          icon: Icon(Icons.delete_forever, size: 16, color: Colors.red.shade300),
                          label: Text('刪除帳戶', style: TextStyle(fontSize: 12, color: Colors.red.shade300)),
                        ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.amber.shade800));
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: color)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  static const _avatarEmojis = [
    '🐱', '🐶', '🐰', '🐻', '🦊', '🐸', '🐧', '🦄',
    '🐼', '🐨', '🦁', '🐯', '🐮', '🐷', '🐵', '🐔',
    '🦋', '🐢', '🐙', '🦖', '👦', '👧', '👶', '🧒',
    '👸', '🤴', '🦸', '🧙', '🎅', '🤖', '👽', '💀',
  ];

  void _showEditAccount(BuildContext context, AppState state, String accountId, String currentName, String currentEmoji) {
    String emoji = currentEmoji;
    final nameCtrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('✏️ 編輯帳戶', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 240,
                width: double.maxFinite,
                child: GridView.count(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: _avatarEmojis.map((e) => GestureDetector(
                    onTap: () => setS(() => emoji = e),
                    child: Container(
                      decoration: BoxDecoration(
                        color: emoji == e ? Colors.amber.shade100 : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: emoji == e ? Border.all(color: Colors.amber, width: 3) : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(e, style: const TextStyle(fontSize: 32)),
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '名字',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            ElevatedButton(
              onPressed: () {
                final n = nameCtrl.text.trim();
                if (n.isNotEmpty) {
                  state.renameAccount(accountId, n, emoji);
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: const Text('儲存', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearData(BuildContext context, AppState state, String accountId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🧹 清除記帳資料'),
        content: Text('確定要清除「$name」的所有記帳資料嗎？\n\n帳戶會保留，但所有收支紀錄將被刪除。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              if (accountId == state.currentAccountId) {
                state.clearAccountData();
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('確定清除'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState state, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('⚠️ 刪除帳戶'),
        content: Text('確定要刪除「$name」嗎？\n\n帳戶和所有記錄將永久刪除，無法復原。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () { state.deleteAccount(id); Navigator.pop(ctx); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('永久刪除'),
          ),
        ],
      ),
    );
  }
}

class _InterestCard extends StatefulWidget {
  final AppState state;
  const _InterestCard({required this.state});

  @override
  State<_InterestCard> createState() => _InterestCardState();
}

class _InterestCardState extends State<_InterestCard> {
  bool _editing = false;
  late double _rate;
  late String _period;
  String? _message;

  @override
  void initState() {
    super.initState();
    _rate = widget.state.interestRate;
    _period = widget.state.interestPeriod;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final interestPreview = state.balance > 0
        ? (state.balance * state.interestRate / 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
      ),
      child: Column(
        children: [
          if (!_editing) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('利率', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                Text('${state.interestRate}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('計息週期', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                Text(state.interestPeriod == 'weekly' ? '每週' : '每月',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            if (state.balance > 0) ...[
              const SizedBox(height: 4),
              Text('預估本次利息: \$$interestPreview',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade300)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: state.balance > 0
                          ? () {
                              state.applyInterest();
                              setState(() => _message = '✅ 已發放 \$$interestPreview 利息！');
                              Future.delayed(const Duration(seconds: 3), () {
                                if (mounted) setState(() => _message = null);
                              });
                            }
                          : null,
                      icon: const Text('💰', style: TextStyle(fontSize: 16)),
                      label: const Text('發放利息', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _editing = true;
                      _rate = state.interestRate;
                      _period = state.interestPeriod;
                    }),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('⚙️ 設定'),
                  ),
                ),
              ],
            ),
            if (_message != null) ...[
              const SizedBox(height: 8),
              Text(_message!, style: TextStyle(fontSize: 13, color: Colors.green.shade600, fontWeight: FontWeight.bold)),
            ],
            if (state.balance <= 0) ...[
              const SizedBox(height: 8),
              Text('餘額為 0，無法發放利息', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
            ],
          ] else ...[
            // Edit mode
            Row(
              children: [
                Text('利率 %', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                const Spacer(),
                IconButton(
                  onPressed: _rate > 0.5 ? () => setState(() => _rate = (_rate - 0.5).clamp(0.5, 50)) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 28,
                ),
                Text('${_rate.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: _rate < 50 ? () => setState(() => _rate = (_rate + 0.5).clamp(0.5, 50)) : null,
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 28,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('計息週期', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                const Spacer(),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'weekly', label: Text('每週')),
                    ButtonSegment(value: 'monthly', label: Text('每月')),
                  ],
                  selected: {_period},
                  onSelectionChanged: (v) => setState(() => _period = v.first),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _editing = false),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      state.updateInterestConfig(_rate, _period);
                      setState(() => _editing = false);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.white),
                    child: const Text('儲存設定', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/transaction.dart';
import '../models/constants.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        children: [
          _buildSection(
            context,
            emoji: '🌳',
            title: '夢想樹',
            subtitle: '設定願望目標',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const _DreamMiniPage())),
          ),
          _buildSection(
            context,
            emoji: '✨',
            title: '收藏櫃',
            subtitle: '收集配件打扮招財貓',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const _AccessoriesMiniPage())),
          ),
          _buildSection(
            context,
            emoji: '👨‍👩‍👧',
            title: '家長設定',
            subtitle: '審核、利息、獎勵',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const _ParentMiniPage())),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String emoji,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _DreamMiniPage extends StatefulWidget {
  const _DreamMiniPage();
  @override
  State<_DreamMiniPage> createState() => _DreamMiniPageState();
}

class _DreamMiniPageState extends State<_DreamMiniPage> {
  final _wishEmojis = ['🚗', '🧸', '🎮', '📚', '🎨', '⚽', '🎸', '🎂', '👟', '🎪'];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('🌳 夢想樹')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...state.wishes.where((w) => w.completedAt == null).map((w) {
            final pct = w.progress;
            final tree = pct >= 1 ? '🌳' : pct >= 0.6 ? '🌿' : pct >= 0.3 ? '🌱' : '🫘';
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(w.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(w.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('\$${w.savedAmount.toInt()} / \$${w.targetAmount.toInt()}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                        Text(tree, style: const TextStyle(fontSize: 28)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: Colors.green.shade50,
                        valueColor: AlwaysStoppedAnimation(Colors.green.shade400),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _waterDialog(state, w.id),
                            child: const Text('💧 灌溉'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => state.deleteWish(w.id),
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          ElevatedButton.icon(
            onPressed: () => _addWishDialog(state),
            icon: const Text('🌟', style: TextStyle(fontSize: 18)),
            label: const Text('新增願望'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  void _waterDialog(AppState state, String wishId) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('💧 灌溉金額'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(prefixText: '\$ '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(ctrl.text) ?? 0;
              if (amt > 0) state.waterWish(wishId, amt);
              Navigator.pop(context);
            },
            child: const Text('灌溉'),
          ),
        ],
      ),
    );
  }

  void _addWishDialog(AppState state) {
    String emoji = '🧸';
    final nameCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('🌟 新願望'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                children: _wishEmojis
                    .map((e) => GestureDetector(
                          onTap: () => setS(() => emoji = e),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: emoji == e ? Colors.amber.shade100 : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(e, style: const TextStyle(fontSize: 24)),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(hintText: '願望名稱'),
              ),
              TextField(
                controller: amtCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '目標金額', prefixText: '\$ '),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final amt = double.tryParse(amtCtrl.text) ?? 0;
                if (name.isNotEmpty && amt > 0) {
                  state.addWish(name, emoji, amt);
                }
                Navigator.pop(ctx);
              },
              child: const Text('種下夢想 🌱'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessoriesMiniPage extends StatelessWidget {
  const _AccessoriesMiniPage();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('✨ 收藏櫃')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: kAccessories.length,
        itemBuilder: (_, i) {
          final acc = kAccessories[i];
          final unlocked = state.unlockedAccessories.contains(acc.id);
          final equipped = state.equippedAccessories.contains(acc.id);
          return GestureDetector(
            onTap: unlocked ? () => state.toggleAccessory(acc.id) : null,
            child: Container(
              decoration: BoxDecoration(
                color: equipped ? Colors.amber.shade100 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: equipped ? Border.all(color: Colors.amber, width: 2) : null,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(acc.emoji,
                      style: TextStyle(
                          fontSize: 36,
                          color: unlocked ? null : Colors.grey.shade400)),
                  const SizedBox(height: 4),
                  Text(acc.name,
                      style:
                          const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(
                    unlocked ? (equipped ? '裝備中' : '點擊裝備') : acc.description,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ParentMiniPage extends StatelessWidget {
  const _ParentMiniPage();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pending = state.transactions.where((t) => !t.approved).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('👨‍👩‍👧 家長設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats
          Row(
            children: [
              _statCard('餘額', '\$${state.balance.toInt()}', Colors.green),
              const SizedBox(width: 8),
              _statCard('連續', '${state.streak}天', Colors.amber),
            ],
          ),
          const SizedBox(height: 16),

          // Pending
          if (pending.isNotEmpty) ...[
            Text('待審核 (${pending.length})',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...pending.reversed.take(10).map((tx) => Card(
                  child: ListTile(
                    leading: Text(tx.category.emoji,
                        style: const TextStyle(fontSize: 24)),
                    title: Text(
                        '${tx.type == TransactionType.income ? '+' : '-'}\$${tx.amount.toInt()}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => state.approveTransaction(tx.id),
                          icon: const Icon(Icons.check_circle,
                              color: Colors.green),
                        ),
                        IconButton(
                          onPressed: () => state.sendHeart(tx.id),
                          icon: Icon(
                            Icons.favorite,
                            color:
                                tx.parentHeart ? Colors.red : Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],

          const SizedBox(height: 16),

          // Interest
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🏦 虛擬利息',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('利率: ${state.interestRate}% / ${state.interestPeriod == "weekly" ? "週" : "月"}'),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          state.balance > 0 ? () => state.applyInterest() : null,
                      child: const Text('💰 發放利息'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: color)),
            Text(value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

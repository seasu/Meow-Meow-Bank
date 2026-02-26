import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/transaction.dart';

class DreamTreeScreen extends StatefulWidget {
  const DreamTreeScreen({super.key});

  @override
  State<DreamTreeScreen> createState() => _DreamTreeScreenState();
}

class _DreamTreeScreenState extends State<DreamTreeScreen> {
  final Map<String, TextEditingController> _waterControllers = {};

  @override
  void dispose() {
    for (final c in _waterControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _treeStage(double progress) {
    if (progress >= 1.0) return '🌳';
    if (progress >= 0.6) return '🌿';
    if (progress >= 0.3) return '🌱';
    return '🫘';
  }

  void _showAddWishDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String selectedEmoji = '🚗';

    const emojis = ['🚗', '🧸', '🎮', '📚', '🎨', '⚽', '🎸', '🎂', '👟', '🎪'];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.green.shade50,
              title: Row(
                children: [
                  Text('🌱', style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    '新增願望',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '選擇圖示',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: emojis.map((e) {
                        final isSelected = e == selectedEmoji;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedEmoji = e),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.green.shade200 : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Colors.green : Colors.grey.shade300,
                                width: isSelected ? 2.5 : 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(e, style: const TextStyle(fontSize: 22)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: '願望名稱',
                        labelStyle: TextStyle(color: Colors.green.shade600),
                        hintText: '例如：新書包',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.green.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.green.shade500, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '目標金額',
                        labelStyle: TextStyle(color: Colors.green.shade600),
                        prefixText: '\$ ',
                        hintText: '0',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.green.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.green.shade500, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('取消', style: TextStyle(color: Colors.grey.shade500)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final amount = double.tryParse(amountCtrl.text.trim());
                    if (name.isEmpty || amount == null || amount <= 0) return;

                    context.read<AppState>().addWish(name, selectedEmoji, amount);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('種下願望 🌱', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final active = state.wishes.where((w) => w.completedAt == null).toList();
    final completed = state.wishes.where((w) => w.completedAt != null).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade100, Colors.green.shade50],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('🌳', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 4),
                Text(
                  '夢想樹',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                Text(
                  '種下願望，用存款灌溉它成長！',
                  style: TextStyle(fontSize: 13, color: Colors.green.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Add wish button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddWishDialog(context),
              icon: const Text('🌱', style: TextStyle(fontSize: 18)),
              label: const Text(
                '新增願望',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Active wishes
          if (active.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
                ],
              ),
              child: Column(
                children: [
                  const Text('🫘', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(
                    '還沒有願望喔，快來種一顆吧！',
                    style: TextStyle(color: Colors.green.shade400, fontSize: 14),
                  ),
                ],
              ),
            )
          else
            ...active.map((wish) => _buildWishCard(wish, state)),

          // Completed section
          if (completed.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              '✅ 已實現的願望',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            ...completed.map((wish) => _buildCompletedCard(wish, state)),
          ],
        ],
      ),
    );
  }

  Widget _buildWishCard(Wish wish, AppState state) {
    _waterControllers.putIfAbsent(wish.id, () => TextEditingController());
    final ctrl = _waterControllers[wish.id]!;
    final tree = _treeStage(wish.progress);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(color: Colors.green.withValues(alpha: 0.08), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(wish.emoji, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wish.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    Text(
                      '\$${wish.savedAmount.toInt()} / \$${wish.targetAmount.toInt()}',
                      style: TextStyle(fontSize: 13, color: Colors.green.shade600),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(tree, style: const TextStyle(fontSize: 28)),
                  Text(
                    '${(wish.progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: wish.progress,
              minHeight: 10,
              backgroundColor: Colors.green.shade50,
              valueColor: AlwaysStoppedAnimation(
                wish.progress >= 0.8 ? Colors.green : Colors.green.shade300,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('💧', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '灌溉金額',
                    prefixText: '\$ ',
                    filled: true,
                    fillColor: Colors.green.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green.shade500, width: 2),
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(ctrl.text.trim());
                  if (amount == null || amount <= 0) return;
                  state.waterWish(wish.id, amount);
                  ctrl.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('灌溉 🌊', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Text('確認刪除？'),
                      content: Text('要刪除願望「${wish.name}」嗎？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () {
                            state.deleteWish(wish.id);
                            _waterControllers.remove(wish.id)?.dispose();
                            Navigator.pop(ctx);
                          },
                          child: Text('刪除', style: TextStyle(color: Colors.red.shade400)),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.delete_outline, color: Colors.grey.shade400, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCard(Wish wish, AppState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Text(wish.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wish.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.green.shade300,
                  ),
                ),
                Text(
                  '\$${wish.targetAmount.toInt()} 達成！',
                  style: TextStyle(fontSize: 12, color: Colors.green.shade500),
                ),
              ],
            ),
          ),
          const Text('🌳', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 4),
          const Text('✅', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/transaction.dart';
import '../models/constants.dart';
import '../widgets/lucky_cat.dart';
import '../widgets/building_scene.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TransactionType _type = TransactionType.expense;
  String _categoryId = '';
  String _amount = '';
  String _note = '';
  String? _catMood;
  String? _catMessage;
  bool _catWaving = false;
  double _dragTotal = 0;
  bool _dragMode = true;
  List<_FallingCoin> _fallingCoins = [];

  void _submitTransaction(AppState state, double amount, String catId) {
    final cat = kCategories.firstWhere((c) => c.id == catId);
    state.addTransaction(amount, cat, cat.type, _note);

    setState(() {
      if (cat.type == TransactionType.income) {
        _catMood = 'excited';
        _catMessage = '太棒了！存錢真開心喵～✨';
        _catWaving = true;
      } else {
        _catMood = 'remind';
        _catMessage = '花錢要想一想喔～🤔';
        _catWaving = false;
      }
      _fallingCoins = _breakIntoCoins(amount, cat.type);
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _catWaving = false);
      }
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
        _catMood = null;
          _catMood = null;
          _catMessage = null;
          _fallingCoins = [];
        });
      }
    });
  }

  List<_FallingCoin> _breakIntoCoins(double amount, TransactionType type) {
    final denoms = [100, 50, 10, 5, 1];
    final coins = <_FallingCoin>[];
    var remaining = amount.toInt();
    for (final d in denoms) {
      while (remaining >= d && coins.length < 12) {
        coins.add(_FallingCoin(value: d, type: type));
        remaining -= d;
      }
    }
    return coins;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        children: [
          // Building
          BuildingScene(level: state.buildingLevel, totalSaved: state.totalSaved),
          const SizedBox(height: 12),

          // Lucky Cat (drop target)
          DragTarget<int>(
            onAcceptWithDetails: (details) {
              setState(() => _dragTotal += details.data);
            },
            builder: (context, candidateData, rejectedData) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: candidateData.isNotEmpty
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 8)],
                      )
                    : null,
                child: LuckyCat(
                  hunger: state.catHunger,
                  mood: _catMood,
                  message: _catMessage,
                  isWaving: _catWaving,
                  equippedAccessories: state.equippedAccessories,
                ),
              );
            },
          ),

          // Falling coins
          if (_fallingCoins.isNotEmpty)
            Wrap(
              spacing: 4,
              children: _fallingCoins.asMap().entries.map((e) {
                final coin = e.value;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 400 + e.key * 80),
                  curve: Curves.bounceOut,
                  builder: (_, v, child) => Opacity(
                    opacity: v,
                    child: Transform.translate(
                      offset: Offset(0, (1 - v) * -30),
                      child: child,
                    ),
                  ),
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: coin.type == TransactionType.income
                            ? [Colors.yellow.shade300, Colors.amber]
                            : [Colors.pink.shade200, Colors.red.shade300],
                      ),
                      border: Border.all(
                        color: coin.type == TransactionType.income
                            ? Colors.amber.shade700
                            : Colors.red.shade400,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text('${coin.value}',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: coin.type == TransactionType.income
                                ? Colors.amber.shade900
                                : Colors.red.shade900)),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 12),

          // Balance card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.amber.shade50, Colors.pink.shade50]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('目前餘額',
                      style: TextStyle(fontSize: 11, color: Colors.amber.shade700)),
                  Text('\$${state.balance.toInt()}',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: state.balance >= 0
                              ? Colors.green.shade600
                              : Colors.pink)),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('連續記帳',
                      style: TextStyle(fontSize: 11, color: Colors.amber.shade700)),
                  Text('🔥 ${state.streak} 天',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Mode toggle
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _dragMode = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dragMode ? Colors.amber : Colors.amber.shade50,
                    foregroundColor: _dragMode ? Colors.white : Colors.amber.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('🪙 拖拉記帳', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _dragMode = false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_dragMode ? Colors.amber : Colors.amber.shade50,
                    foregroundColor: !_dragMode ? Colors.white : Colors.amber.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('✏️ 輸入記帳', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_dragMode) _buildDragMode(state) else _buildFormMode(state),

          const SizedBox(height: 16),
          _buildRecentTransactions(state),
        ],
      ),
    );
  }

  Widget _buildDragMode(AppState state) {
    final allCats = kCategories.where((c) => c.id != 'interest').toList();
    return Column(
      children: [
        Text('👆 拖拉金幣到招財貓身上記帳！',
            style: TextStyle(fontSize: 12, color: Colors.amber.shade700)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.shade200, style: BorderStyle.solid),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [1, 5, 10, 50, 100].map((v) => _buildDraggableCoin(v)).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('已投入金額', style: TextStyle(fontSize: 13, color: Colors.amber.shade800)),
                  Text('\$${_dragTotal.toInt()}',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.amber.shade700)),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: allCats
                    .map((c) => _catChip(c, _categoryId == c.id,
                        () => setState(() => _categoryId = c.id)))
                    .toList(),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: '備註（選填）✏️',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.amber.shade200)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: (v) => _note = v,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _dragTotal > 0 && _categoryId.isNotEmpty
                          ? () {
                              _submitTransaction(state, _dragTotal, _categoryId);
                              setState(() { _dragTotal = 0; _note = ''; });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('記帳喵！🐾',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (_dragTotal > 0) ...[
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => setState(() => _dragTotal = 0),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('重置'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDraggableCoin(int value) {
    final size = value >= 100 ? 52.0 : value >= 50 ? 46.0 : 40.0;
    return Draggable<int>(
      data: value,
      feedback: Material(
        color: Colors.transparent,
        child: _coinWidget(value, size, true),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _coinWidget(value, size, false)),
      child: _coinWidget(value, size, false),
    );
  }

  Widget _coinWidget(int value, double size, bool dragging) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDE68A), Color(0xFFF59E0B), Color(0xFFFCD34D)],
        ),
        border: Border.all(color: Colors.amber.shade700, width: 2),
        boxShadow: dragging
            ? [BoxShadow(color: Colors.amber.withValues(alpha: 0.5), blurRadius: 12)]
            : [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$value',
              style: TextStyle(
                  fontSize: size * 0.3,
                  fontWeight: FontWeight.w900,
                  color: Colors.amber.shade900)),
          Text('元',
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.amber.shade800)),
        ],
      ),
    );
  }

  Widget _buildFormMode(AppState state) {
    final cats = kCategories.where((c) => c.type == _type && c.id != 'interest').toList();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() { _type = TransactionType.expense; _categoryId = ''; }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _type == TransactionType.expense ? Colors.pink.shade400 : Colors.pink.shade50,
                  foregroundColor: _type == TransactionType.expense ? Colors.white : Colors.pink.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('💸 支出', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() { _type = TransactionType.income; _categoryId = ''; }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _type == TransactionType.income ? Colors.amber : Colors.amber.shade50,
                  foregroundColor: _type == TransactionType.income ? Colors.white : Colors.amber.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('🪙 收入', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cats.map((c) => _catChip(c, _categoryId == c.id,
              () => setState(() => _categoryId = c.id))).toList(),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            hintText: '輸入金額',
            prefixText: '\$ ',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.amber.shade200)),
          ),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
          onChanged: (v) => setState(() => _amount = v),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: '備註（選填）✏️',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.amber.shade200)),
          ),
          onChanged: (v) => _note = v,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _amount.isNotEmpty && _categoryId.isNotEmpty
                ? () {
                    _submitTransaction(state, double.tryParse(_amount) ?? 0, _categoryId);
                    setState(() { _amount = ''; _categoryId = ''; _note = ''; });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('記帳喵！🐾',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _catChip(TxCategory c, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.amber.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.amber : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: Colors.amber.withValues(alpha: 0.2), blurRadius: 8)]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(c.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 2),
            Text(c.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(AppState state) {
    if (state.transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Text('🐾', style: TextStyle(fontSize: 36)),
            SizedBox(height: 8),
            Text('還沒有記帳紀錄喔，快來記第一筆吧！',
                style: TextStyle(color: Colors.amber)),
          ],
        ),
      );
    }
    final recent = state.transactions.reversed.take(10).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('📖 記帳紀錄',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber.shade800)),
        const SizedBox(height: 8),
        ...recent.map((tx) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
              ),
              child: Row(
                children: [
                  Text(tx.category.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tx.category.name,
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                        if (tx.note.isNotEmpty)
                          Text(tx.note,
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  if (tx.parentHeart) const Text('❤️ ', style: TextStyle(fontSize: 12)),
                  Text(
                    '${tx.type == TransactionType.income ? '+' : '-'}\$${tx.amount.toInt()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: tx.type == TransactionType.income
                          ? Colors.green
                          : Colors.pink,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _FallingCoin {
  final int value;
  final TransactionType type;
  _FallingCoin({required this.value, required this.type});
}

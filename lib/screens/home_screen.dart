import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/transaction.dart';
import '../models/constants.dart';
import '../utils/sounds.dart';
import '../widgets/lucky_cat.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _catMood;
  String? _catMessage;
  bool _catWaving = false;
  bool _coinDragging = false;

  static final _incomeCat = kCategories.firstWhere((c) => c.id == 'income');

  void _onSaveMoney(AppState state) {
    _showAmountDialog(
      title: '🪙 存多少錢？',
      color: Colors.amber,
      onConfirm: (amount) {
        SoundService.playCoinDrop();
        HapticFeedback.mediumImpact();
        state.addTransaction(amount, _incomeCat, TransactionType.income, '');
        setState(() {
          _catMood = 'excited';
          _catMessage = '+\$${amount.toInt()} 喵～✨';
          _catWaving = true;
        });
        _resetAnimAfter();
      },
    );
  }

  void _onSpendMoney(AppState state) {
    _showExpenseDialog(
      onConfirm: (amount, cat) {
        HapticFeedback.mediumImpact();
        state.addTransaction(amount, cat, TransactionType.expense, '');
        setState(() {
          _catMood = 'remind';
          _catMessage = '-\$${amount.toInt()} 花錢要想想喔～';
        });
        _resetAnimAfter();
      },
    );
  }

  void _resetAnimAfter() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _catWaving = false);
      }
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() { _catMood = null; _catMessage = null; });
      }
    });
  }

  void _showAmountDialog({
    required String title,
    required Color color,
    required void Function(double amount) onConfirm,
  }) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: const TextStyle(fontSize: 22), textAlign: TextAlign.center),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: color),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(fontSize: 40, color: color.withValues(alpha: 0.3)),
            prefixText: '\$ ',
            prefixStyle: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: color),
            border: InputBorder.none,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: 200,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(ctrl.text) ?? 0;
                if (amt > 0) {
                  Navigator.pop(ctx);
                  onConfirm(amt);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('確定！', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showExpenseDialog({required void Function(double, TxCategory) onConfirm}) {
    String selectedId = '';
    final ctrl = TextEditingController();
    final expCats = kCategories.where((c) => c.type == TransactionType.expense).toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('💸 花了什麼錢？', style: TextStyle(fontSize: 22), textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: expCats.map((c) => GestureDetector(
                  onTap: () => setS(() => selectedId = c.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: selectedId == c.id ? Colors.pink.shade100 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: selectedId == c.id ? Border.all(color: Colors.pink, width: 3) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(c.emoji, style: const TextStyle(fontSize: 24)),
                        Text(c.name, style: const TextStyle(fontSize: 9)),
                      ],
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.pink.shade400),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(fontSize: 36, color: Colors.pink.shade100),
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.pink.shade300),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: 200, height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final amt = double.tryParse(ctrl.text) ?? 0;
                  if (amt > 0 && selectedId.isNotEmpty) {
                    Navigator.pop(ctx);
                    onConfirm(amt, expCats.firstWhere((c) => c.id == selectedId));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('確定！', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      child: Column(
        children: [
          // Balance
          Text(
            '\$${state.balance.toInt()}',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: state.balance >= 0 ? Colors.green.shade600 : Colors.pink,
            ),
          ),
          if (state.streak > 0)
            Text('🔥 連續 ${state.streak} 天',
                style: TextStyle(fontSize: 13, color: Colors.amber.shade700)),

          const SizedBox(height: 12),

          // Cat (drop target for coin)
          DragTarget<String>(
            onAcceptWithDetails: (d) {
              if (d.data == 'coin') _onSaveMoney(state);
            },
            builder: (context, candidateData, _) {
              final hovering = candidateData.isNotEmpty;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: hovering
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.5), blurRadius: 30, spreadRadius: 10)],
                      )
                    : null,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    LuckyCat(
                      hunger: state.catHunger,
                      balance: state.balance,
                      mood: _catMood,
                      message: _catMessage,
                      isWaving: _catWaving,
                      equippedAccessories: state.equippedAccessories,
                    ),
                    // Draggable bill on cat's paw (top-right of cat)
                    if (state.balance > 0 && _catMood == null)
                      Positioned(
                        top: 30,
                        right: 0,
                        child: Draggable<String>(
                          data: 'bill',
                          onDragEnd: (details) {
                            if (details.offset.distance > 60) {
                              _onSpendMoney(state);
                            }
                          },
                          feedback: Material(
                            color: Colors.transparent,
                            child: _buildBill(dragging: true),
                          ),
                          childWhenDragging: Opacity(opacity: 0.2, child: _buildBill()),
                          child: _buildBill(),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // One big draggable coin
          _coinDragging
              ? Opacity(opacity: 0.3, child: _buildCoin())
              : Draggable<String>(
                  data: 'coin',
                  onDragStarted: () => setState(() => _coinDragging = true),
                  onDragEnd: (_) => setState(() => _coinDragging = false),
                  feedback: Material(
                    color: Colors.transparent,
                    child: _buildCoin(dragging: true),
                  ),
                  childWhenDragging: Opacity(opacity: 0.3, child: _buildCoin()),
                  child: _buildCoin(),
                ),

          const SizedBox(height: 8),
          Text('👆 拖金幣到貓咪存錢', style: TextStyle(fontSize: 12, color: Colors.amber.shade500)),
          if (state.balance > 0)
            Text('👆 從貓咪拖走紙鈔花錢', style: TextStyle(fontSize: 12, color: Colors.pink.shade300)),

          const SizedBox(height: 20),

          // Recent transactions
          if (state.transactions.isNotEmpty) _buildRecent(state),
        ],
      ),
    );
  }

  Widget _buildCoin({bool dragging = false}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDE68A), Color(0xFFF59E0B), Color(0xFFFCD34D)],
        ),
        border: Border.all(color: Colors.amber.shade700, width: 3),
        boxShadow: [
          BoxShadow(
            color: dragging ? Colors.amber.withValues(alpha: 0.6) : Colors.black26,
            blurRadius: dragging ? 20 : 6,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text('\$',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.amber.shade900)),
    );
  }

  Widget _buildBill({bool dragging = false}) {
    return Container(
      width: 56,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          colors: [Colors.green.shade300, Colors.green.shade500],
        ),
        border: Border.all(color: Colors.green.shade700, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: dragging ? Colors.green.withValues(alpha: 0.5) : Colors.black26,
            blurRadius: dragging ? 12 : 4,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text('\$', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.green.shade900)),
    );
  }

  Widget _buildRecent(AppState state) {
    final recent = state.transactions.reversed.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('最近紀錄', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber.shade800)),
        const SizedBox(height: 6),
        ...recent.map((tx) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Text(tx.category.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(child: Text(tx.category.name, style: const TextStyle(fontSize: 13))),
              Text(
                '${tx.type == TransactionType.income ? '+' : '-'}\$${tx.amount.toInt()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14,
                  color: tx.type == TransactionType.income ? Colors.green : Colors.pink,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

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
  List<_FallingCoin> _fallingCoins = [];

  static final _incomeCat = kCategories.firstWhere((c) => c.id == 'income');

  void _onCoinDropped(int value, AppState state) {
    SoundService.playCoinDrop();
    HapticFeedback.mediumImpact();

    state.addTransaction(
        value.toDouble(), _incomeCat, TransactionType.income, '');

    setState(() {
      _catMood = 'excited';
      _catMessage = '+\$$value 喵～✨';
      _catWaving = true;
      _fallingCoins = _breakIntoCoins(value.toDouble(), TransactionType.income);
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _catWaving = false);
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _catMood = null;
          _catMessage = null;
          _fallingCoins = [];
        });
      }
    });
  }

  void _showExpenseSheet(AppState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ExpenseSheet(
        onSubmit: (amount, category) {
          state.addTransaction(amount, category, TransactionType.expense, '');
          Navigator.pop(context);
          setState(() {
            _catMood = 'remind';
            _catMessage = '-\$${amount.toInt()} 花錢要想想喔～';
            _fallingCoins =
                _breakIntoCoins(amount, TransactionType.expense);
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _catMood = null;
                _catMessage = null;
                _fallingCoins = [];
              });
            }
          });
        },
      ),
    );
  }

  List<_FallingCoin> _breakIntoCoins(double amount, TransactionType type) {
    final denoms = [100, 50, 10, 5, 1];
    final coins = <_FallingCoin>[];
    var remaining = amount.toInt();
    for (final d in denoms) {
      while (remaining >= d && coins.length < 8) {
        coins.add(_FallingCoin(value: d, type: type));
        remaining -= d;
      }
    }
    return coins;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
          child: Column(
            children: [
              // Balance — BIG and simple
              Text(
                '\$${state.balance.toInt()}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color:
                      state.balance >= 0 ? Colors.green.shade600 : Colors.pink,
                ),
              ),
              if (state.streak > 0)
                Text('🔥 連續 ${state.streak} 天',
                    style: TextStyle(
                        fontSize: 13, color: Colors.amber.shade700)),
              const SizedBox(height: 8),

              // Cat — center of the universe
              DragTarget<int>(
                onAcceptWithDetails: (d) => _onCoinDropped(d.data, state),
                builder: (context, candidateData, _) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: candidateData.isNotEmpty
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.amber.withValues(alpha: 0.5),
                                  blurRadius: 30,
                                  spreadRadius: 10)
                            ],
                          )
                        : null,
                    child: LuckyCat(
                      hunger: state.catHunger,
                      balance: state.balance,
                      mood: _catMood,
                      message: _catMessage,
                      isWaving: _catWaving,
                      equippedAccessories: state.equippedAccessories,
                    ),
                  );
                },
              ),

              // Falling coins animation
              if (_fallingCoins.isNotEmpty) _buildFallingCoins(),

              const SizedBox(height: 16),

              // Coin tray — just coins, no extra UI
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  children: [
                    Text('👆 拖金幣到貓咪存錢！',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.amber.shade600,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [1, 5, 10, 50, 100]
                          .map((v) => _buildDraggableCoin(v))
                          .toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Recent transactions (compact)
              if (state.transactions.isNotEmpty) _buildRecent(state),
            ],
          ),
        ),

        // Floating expense button
        Positioned(
          bottom: 90,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _showExpenseSheet(state),
            backgroundColor: Colors.pink.shade400,
            foregroundColor: Colors.white,
            icon: const Text('💸', style: TextStyle(fontSize: 20)),
            label: const Text('花錢',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildDraggableCoin(int value) {
    final size = value >= 100
        ? 56.0
        : value >= 50
            ? 50.0
            : 44.0;
    return Draggable<int>(
      data: value,
      feedback: Material(
        color: Colors.transparent,
        child: _coinWidget(value, size + 8, true),
      ),
      childWhenDragging:
          Opacity(opacity: 0.3, child: _coinWidget(value, size, false)),
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
            ? [BoxShadow(color: Colors.amber.withValues(alpha: 0.6), blurRadius: 16)]
            : [const BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: TextStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w900,
          color: Colors.amber.shade900,
        ),
      ),
    );
  }

  Widget _buildFallingCoins() {
    return Wrap(
      spacing: 4,
      children: _fallingCoins.asMap().entries.map((e) {
        final coin = e.value;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + e.key * 60),
          curve: Curves.bounceOut,
          builder: (_, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(0, (1 - v) * -20),
              child: child,
            ),
          ),
          child: Container(
            width: 28,
            height: 28,
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
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: coin.type == TransactionType.income
                        ? Colors.amber.shade900
                        : Colors.red.shade900)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecent(AppState state) {
    final recent = state.transactions.reversed.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('最近紀錄',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade800)),
        const SizedBox(height: 6),
        ...recent.map((tx) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text(tx.category.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(tx.category.name,
                        style: const TextStyle(fontSize: 13)),
                  ),
                  Text(
                    '${tx.type == TransactionType.income ? '+' : '-'}\$${tx.amount.toInt()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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

class _ExpenseSheet extends StatefulWidget {
  final void Function(double amount, TxCategory category) onSubmit;
  const _ExpenseSheet({required this.onSubmit});

  @override
  State<_ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends State<_ExpenseSheet> {
  String _selectedCatId = '';
  String _amount = '';

  static final _expenseCats =
      kCategories.where((c) => c.type == TransactionType.expense).toList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('花了什麼錢？',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Big category icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _expenseCats
                .map((c) => GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCatId = c.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: _selectedCatId == c.id
                              ? Colors.pink.shade100
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: _selectedCatId == c.id
                              ? Border.all(color: Colors.pink, width: 3)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(c.emoji,
                                style: const TextStyle(fontSize: 28)),
                            Text(c.name,
                                style: const TextStyle(fontSize: 9)),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),

          // Amount input
          TextField(
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '多少錢？',
              hintStyle: TextStyle(
                  fontSize: 24, color: Colors.grey.shade300),
              prefixText: '\$ ',
              prefixStyle: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink.shade300),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: (v) => setState(() => _amount = v),
          ),
          const SizedBox(height: 16),

          // Submit
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _amount.isNotEmpty && _selectedCatId.isNotEmpty
                  ? () {
                      final cat =
                          _expenseCats.firstWhere((c) => c.id == _selectedCatId);
                      widget.onSubmit(double.tryParse(_amount) ?? 0, cat);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade400,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('記錄支出',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FallingCoin {
  final int value;
  final TransactionType type;
  _FallingCoin({required this.value, required this.type});
}

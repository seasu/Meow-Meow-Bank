import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/transaction.dart';
import '../models/constants.dart';
import '../utils/sounds.dart';
import '../widgets/lucky_cat.dart';
import 'amount_input_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _catMood;
  String? _catMessage;
  bool _catWaving = false;

  static final _incomeCat = kCategories.firstWhere((c) => c.id == 'income');

  void _onSaveMoney(AppState state) async {
    final amount = await Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: (_) => const AmountInputScreen(
          title: '存多少錢？',
          emoji: '🪙',
          color: Colors.amber,
        ),
      ),
    );
    if (amount != null && amount > 0 && mounted) {
      SoundService.playCoinDrop();
      HapticFeedback.mediumImpact();
      state.addTransaction(amount, _incomeCat, TransactionType.income, '');
      setState(() {
        _catMood = 'excited';
        _catMessage = '+\$${amount.toInt()} 喵～✨';
        _catWaving = true;
      });
      _resetAnimAfter();
    }
  }

  void _onSpendMoney(AppState state) {
    _showCategoryPicker(
      onCategorySelected: (cat) async {
        final amount = await Navigator.push<double>(
          context,
          MaterialPageRoute(
            builder: (_) => AmountInputScreen(
              title: '${cat.emoji} 花多少錢？',
              emoji: '💸',
              color: Colors.pink.shade400,
            ),
          ),
        );
        if (amount != null && amount > 0 && mounted) {
          HapticFeedback.mediumImpact();
          state.addTransaction(amount, cat, TransactionType.expense, '');
          setState(() {
            _catMood = 'remind';
            _catMessage = '-\$${amount.toInt()} 花錢要想想喔～';
          });
          _resetAnimAfter();
        }
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

  void _showCategoryPicker({required void Function(TxCategory cat) onCategorySelected}) {
    final expCats = kCategories.where((c) => c.type == TransactionType.expense).toList();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('花了什麼？', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: expCats.map((c) => GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  onCategorySelected(c);
                },
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.pink.shade200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(c.emoji, style: const TextStyle(fontSize: 32)),
                      Text(c.name, style: TextStyle(fontSize: 11, color: Colors.pink.shade400)),
                    ],
                  ),
                ),
              )).toList(),
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

          const SizedBox(height: 16),

          // Cat with left-hand coin and right-hand bill
          Stack(
            clipBehavior: Clip.none,
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

              // LEFT hand: coin (save)
              Positioned(
                left: 0,
                top: 55,
                child: GestureDetector(
                  onTap: () => _onSaveMoney(state),
                  child: _buildHandItem(
                    emoji: '🪙',
                    label: '存錢',
                    color: Colors.amber,
                    size: 60,
                  ),
                ),
              ),

              // RIGHT hand: bill (spend)
              Positioned(
                right: 0,
                top: 55,
                child: GestureDetector(
                  onTap: () => _onSpendMoney(state),
                  child: _buildHandItem(
                    emoji: '💵',
                    label: '花錢',
                    color: Colors.pink,
                    size: 60,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Hint text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _hintChip('👈 點左手存錢', Colors.amber),
              const SizedBox(width: 12),
              _hintChip('點右手花錢 👉', Colors.pink),
            ],
          ),

          const SizedBox(height: 20),

          // Recent transactions
          if (state.transactions.isNotEmpty) _buildRecent(state),
        ],
      ),
    );
  }

  Widget _buildHandItem({
    required String emoji,
    required String label,
    required Color color,
    required double size,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8)],
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 30)),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _hintChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: color)),
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

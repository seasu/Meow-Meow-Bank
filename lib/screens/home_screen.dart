import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/transaction.dart';
import '../models/constants.dart';
import '../utils/sounds.dart';
import '../widgets/lucky_cat.dart';
import '../widgets/spending_boy.dart';
import 'amount_input_screen.dart';
import 'history_screen.dart';
import 'receipt_scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _catMood;
  String? _catMessage;
  bool _catWaving = false;
  int _idleFrame = 0;
  Timer? _idleTimer;

  static final _incomeCat = kCategories.firstWhere((c) => c.id == 'income');

  @override
  void initState() {
    super.initState();
    _idleTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (mounted) {
        setState(() => _idleFrame++);
      }
    });
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  void _onSaveMoney(AppState state) async {
    final amount = await Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: (_) => const AmountInputScreen(
          title: '存多少錢？',
          color: Colors.amber,
          mode: AmountMode.save,
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
              color: Colors.pink.shade400,
              mode: AmountMode.spend,
            ),
          ),
        );
        if (amount != null && amount > 0 && mounted) {
          SoundService.playSpendMoney();
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

  void _onScanReceipt(AppState state) async {
    final recorded = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ReceiptScanScreen()),
    );
    if (recorded == true && mounted) {
      SoundService.playSpendMoney();
      setState(() {
        _catMood = 'remind';
        _catMessage = '發票記帳完成！📷✅';
      });
      _resetAnimAfter();
    }
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
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: expCats.map((c) => GestureDetector(
                onTap: () { Navigator.pop(ctx); onCategorySelected(c); },
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
    final saved = state.totalSaved;
    final spent = state.totalExpense;
    final total = saved + spent;

    // Size ratio: cat vs boy (min 0.35, max 0.65)
    double catRatio = total > 0 ? (saved / total).clamp(0.35, 0.65) : 0.5;
    double boyRatio = 1.0 - catRatio;
    final screenW = MediaQuery.of(context).size.width - 48;
    final catSize = (screenW * catRatio).clamp(80.0, 200.0);
    final boySize = (screenW * boyRatio).clamp(80.0, 200.0);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < -300) {
          _onSpendMoney(state);
        } else if (details.primaryVelocity! > 300) {
          _onSaveMoney(state);
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        child: Column(
          children: [
            // Balance
            Text(
              '\$${state.balance.toInt()}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: state.balance >= 0 ? Colors.green.shade600 : Colors.pink,
              ),
            ),
            if (state.streak > 0)
              Text('🔥 連續 ${state.streak} 天',
                  style: TextStyle(fontSize: 13, color: Colors.amber.shade700)),

            const SizedBox(height: 12),

            // Two characters side by side
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // LEFT: Lucky Cat (save)
                GestureDetector(
                  onTap: () => _onSaveMoney(state),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        width: catSize,
                        height: catSize * 1.1,
                        child: FittedBox(
                          child: LuckyCat(
                            hunger: state.catHunger,
                            balance: state.balance,
                            mood: _catMood,
                            message: null,
                            isWaving: _catWaving || (_idleFrame % 80 > 70),
                            equippedAccessories: state.equippedAccessories,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('招財貓 🪙',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber.shade800)),
                      ),
                      Text('收入 \$${saved.toInt()}',
                          style: TextStyle(fontSize: 11, color: Colors.green.shade600)),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Divider
                Container(
                  width: 2, height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.grey.shade300, Colors.transparent],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // RIGHT: Spending Boy (spend)
                GestureDetector(
                  onTap: () => _onSpendMoney(state),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        width: boySize,
                        height: boySize * 1.1,
                        child: FittedBox(
                          child: SpendingBoy(
                            size: 120,
                            idleFrame: _idleFrame,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('散財童子 💸',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.pink.shade400)),
                      ),
                      Text('支出 \$${spent.toInt()}',
                          style: TextStyle(fontSize: 11, color: Colors.pink)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Cat message
            if (_catMessage != null)
              Text(_catMessage!,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _catMood == 'remind' ? Colors.pink : Colors.amber.shade800)),

            const SizedBox(height: 12),

            // Swipe hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('👈', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text('左滑存錢', style: TextStyle(fontSize: 12, color: Colors.amber.shade700)),
                  Text('  ·  ', style: TextStyle(color: Colors.grey.shade400)),
                  Text('右滑花錢', style: TextStyle(fontSize: 12, color: Colors.pink.shade400)),
                  const SizedBox(width: 4),
                  Text('👉', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Scan receipt button
            GestureDetector(
              onTap: () => _onScanReceipt(state),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink.shade300, Colors.orange.shade300],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('📷', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 8),
                    Text(
                      '掃發票自動記帳',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (state.transactions.isNotEmpty) _buildRecent(state),
          ],
        ),
      ),
    );
  }

  Widget _buildRecent(AppState state) {
    final recent = state.transactions.reversed.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('最近紀錄', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber.shade800)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Text('查看全部 📖', style: TextStyle(fontSize: 12, color: Colors.amber.shade700, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
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

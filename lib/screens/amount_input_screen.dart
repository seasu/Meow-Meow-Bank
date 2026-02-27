import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/sounds.dart';
import '../widgets/lucky_cat.dart';
import '../widgets/spending_boy.dart';

enum AmountMode { save, spend }

class AmountInputScreen extends StatefulWidget {
  final String title;
  final Color color;
  final AmountMode mode;

  const AmountInputScreen({
    super.key,
    required this.title,
    required this.color,
    this.mode = AmountMode.save,
  });

  @override
  State<AmountInputScreen> createState() => _AmountInputScreenState();
}

class _AmountInputScreenState extends State<AmountInputScreen> {
  int _amount = 0;
  int _animFrame = 0;
  Timer? _animTimer;

  static const _denoms = [1, 10, 500, 1000];

  @override
  void initState() {
    super.initState();
    _animTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) {
        setState(() => _animFrame++);
      }
    });
  }

  @override
  void dispose() {
    _animTimer?.cancel();
    super.dispose();
  }

  void _add(int v) {
    HapticFeedback.lightImpact();
    if (widget.mode == AmountMode.save) {
      SoundService.playCoinDrop();
    }
    setState(() => _amount += v);
  }

  void _sub(int v) {
    HapticFeedback.lightImpact();
    setState(() => _amount = (_amount - v).clamp(0, 999999));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color;
    final isSave = widget.mode == AmountMode.save;

    return Scaffold(
      backgroundColor: c.withValues(alpha: 0.05),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 28),
                    color: Colors.grey,
                  ),
                  const Spacer(),
                  if (_amount > 0)
                    TextButton(
                      onPressed: () => setState(() => _amount = 0),
                      child: Text('歸零', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                    ),
                ],
              ),
            ),

            // Animated character (3x size)
            SizedBox(
              height: 360,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isSave)
                    SizedBox(width: 360, height: 360, child: FittedBox(child: LuckyCat(hunger: 100, balance: _amount.toDouble(), isWaving: true)))
                  else
                    SizedBox(width: 360, height: 360, child: FittedBox(child: SpendingBoy(size: 120, idleFrame: _animFrame))),

                  ..._buildFlyingMoney(isSave),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(widget.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c)),

            const SizedBox(height: 8),

            // + buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _denoms
                    .map((d) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _AmountButton(label: '+$d', color: c, onTap: () => _add(d), isAdd: true),
                          ),
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Amount display
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: c.withValues(alpha: 0.15), blurRadius: 20, spreadRadius: 2)],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: Text(
                    '\$ $_amount',
                    key: ValueKey(_amount),
                    style: TextStyle(
                      fontSize: _amount > 99999 ? 40 : 56,
                      fontWeight: FontWeight.w900,
                      color: _amount > 0 ? c : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // - buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _denoms
                    .map((d) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _AmountButton(label: '-$d', color: Colors.grey.shade500, onTap: _amount >= d ? () => _sub(d) : null, isAdd: false),
                          ),
                        ))
                    .toList(),
              ),
            ),

            const Spacer(flex: 2),

            // Confirm
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _amount > 0 ? () => Navigator.pop(context, _amount.toDouble()) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: _amount > 0 ? 4 : 0,
                  ),
                  child: Text(
                    _amount > 0 ? '確定 \$$_amount！🐾' : '請輸入金額',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _amount > 0 ? Colors.white : Colors.grey.shade400),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFlyingMoney(bool isSave) {
    if (_amount <= 0) return [];
    final items = <Widget>[];
    for (var i = 0; i < 8; i++) {
      final phase = (_animFrame * 0.08 + i * 0.8) % (2 * pi);
      final radius = 140.0 + sin(phase * 2) * 30;
      final dx = cos(phase) * radius;
      final dy = sin(phase) * radius * 0.5 - 40;
      final opacity = (0.4 + sin(phase) * 0.4).clamp(0.2, 0.9);

      if (isSave) {
        items.add(Positioned(
          left: 160 + dx,
          top: 150 + dy,
          child: Opacity(
            opacity: opacity,
            child: Text('🪙', style: TextStyle(fontSize: 36 + sin(phase) * 8)),
          ),
        ));
      } else {
        items.add(Positioned(
          left: 160 + dx * 1.2,
          top: 140 + dy,
          child: Opacity(
            opacity: opacity,
            child: Transform.rotate(
              angle: phase,
              child: Text('💸', style: TextStyle(fontSize: 32 + cos(phase) * 6)),
            ),
          ),
        ));
      }
    }
    return items;
  }
}

class _AmountButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isAdd;

  const _AmountButton({required this.label, required this.color, required this.onTap, required this.isAdd});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 56,
        decoration: BoxDecoration(
          color: enabled ? (isAdd ? color.withValues(alpha: 0.15) : Colors.grey.shade100) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled ? (isAdd ? color.withValues(alpha: 0.4) : Colors.grey.shade300) : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: enabled ? (isAdd ? color : Colors.grey.shade600) : Colors.grey.shade300)),
      ),
    );
  }
}

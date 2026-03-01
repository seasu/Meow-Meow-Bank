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
      if (mounted) setState(() => _animFrame++);
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
    } else {
      SoundService.playSpendMoney();
    }
    setState(() => _amount += v);
  }

  void _sub(int v) {
    HapticFeedback.lightImpact();
    if (widget.mode == AmountMode.spend) {
      SoundService.playSpendMoney();
    }
    setState(() => _amount = (_amount - v).clamp(0, 999999));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color;
    final isSave = widget.mode == AmountMode.save;

    return Scaffold(
      backgroundColor: Color.alphaBlend(c.withValues(alpha: 0.08), Colors.white),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar (compact)
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 24),
                  color: Colors.grey,
                ),
                const Spacer(),
                if (_amount > 0)
                  TextButton(
                    onPressed: () => setState(() => _amount = 0),
                    child: Text('歸零', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                  ),
              ],
            ),

            // Character area — takes all remaining space
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final areaW = constraints.maxWidth;
                  final areaH = constraints.maxHeight;
                  final charSize = min(areaW * 0.6, areaH * 0.7);

                  return Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Character centered
                      SizedBox(
                        width: charSize,
                        height: charSize,
                        child: FittedBox(
                          child: isSave
                              ? LuckyCat(hunger: 100, balance: _amount.toDouble(), isWaving: true)
                              : SpendingBoy(size: 120, idleFrame: _animFrame),
                        ),
                      ),
                      // Flying money
                      if (_amount > 0)
                        ..._buildFlyingMoney(isSave, areaW, areaH),
                    ],
                  );
                },
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(widget.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c)),
            ),

            // + buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: _denoms.map((d) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _AmountButton(label: '+$d', color: c, onTap: () => _add(d), isAdd: true),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 8),

            // Amount display
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: c.withValues(alpha: 0.12), blurRadius: 16)],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: Text('\$ $_amount', key: ValueKey(_amount),
                    style: TextStyle(fontSize: _amount > 99999 ? 36 : 48, fontWeight: FontWeight.w900, color: _amount > 0 ? c : Colors.grey.shade300)),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // - buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: _denoms.map((d) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _AmountButton(label: '-$d', color: Colors.grey.shade500, onTap: _amount >= d ? () => _sub(d) : null, isAdd: false),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Confirm
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _amount > 0 ? () => Navigator.pop(context, _amount.toDouble()) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c, foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: _amount > 0 ? 4 : 0,
                  ),
                  child: Text(
                    _amount > 0 ? '確定 \$$_amount！🐾' : '請輸入金額',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _amount > 0 ? Colors.white : Colors.grey.shade400),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFlyingMoney(bool isSave, double areaW, double areaH) {
    final cx = areaW / 2;
    final cy = areaH / 2;
    final items = <Widget>[];

    for (var i = 0; i < 8; i++) {
      final t = (_animFrame * 0.04 + i * 0.125) % 1.0;

      if (isSave) {
        // Coins fly FROM edge IN toward cat center
        final angle = i * pi * 2 / 8;
        final startX = cx + cos(angle) * areaW * 0.55;
        final startY = cy + sin(angle) * areaH * 0.5;
        final curX = startX + (cx - startX) * t;
        final curY = startY + (cy - startY) * t;
        final opacity = t < 0.2 ? t / 0.2 : (t > 0.85 ? (1 - t) / 0.15 : 1.0);

        items.add(Positioned(
          left: curX - 16,
          top: curY - 16,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Text('🪙', style: TextStyle(fontSize: 28 + t * 8)),
          ),
        ));
      } else {
        // Bills fly FROM center OUT to edges
        final angle = i * pi * 2 / 8 + _animFrame * 0.02;
        final endX = cx + cos(angle) * areaW * 0.5;
        final endY = cy + sin(angle) * areaH * 0.45;
        final curX = cx + (endX - cx) * t;
        final curY = cy + (endY - cy) * t;
        final opacity = t < 0.1 ? t / 0.1 : (t > 0.7 ? (1 - t) / 0.3 : 1.0);

        items.add(Positioned(
          left: curX - 14,
          top: curY - 14,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: t * pi * 2,
              child: Text('💸', style: TextStyle(fontSize: 24 + (1 - t) * 8)),
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
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: enabled ? (isAdd ? color.withValues(alpha: 0.15) : Colors.grey.shade100) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled ? (isAdd ? color.withValues(alpha: 0.4) : Colors.grey.shade300) : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: enabled ? (isAdd ? color : Colors.grey.shade600) : Colors.grey.shade300)),
      ),
    );
  }
}

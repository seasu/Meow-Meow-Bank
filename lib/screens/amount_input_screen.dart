import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/sounds.dart';

class AmountInputScreen extends StatefulWidget {
  final String title;
  final String emoji;
  final Color color;

  const AmountInputScreen({
    super.key,
    required this.title,
    required this.emoji,
    required this.color,
  });

  @override
  State<AmountInputScreen> createState() => _AmountInputScreenState();
}

class _AmountInputScreenState extends State<AmountInputScreen> {
  int _amount = 0;

  static const _denoms = [1, 10, 500, 1000];

  void _add(int v) {
    HapticFeedback.lightImpact();
    SoundService.playCoinDrop();
    setState(() => _amount += v);
  }

  void _sub(int v) {
    HapticFeedback.lightImpact();
    setState(() => _amount = (_amount - v).clamp(0, 999999));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color;

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
                      child: Text('歸零',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                    ),
                ],
              ),
            ),

            const Spacer(flex: 1),

            // Title
            Text(widget.emoji,
                style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 4),
            Text(widget.title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: c)),

            const Spacer(flex: 1),

            // + buttons (top row)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _denoms
                    .map((d) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _AmountButton(
                              label: '+$d',
                              color: c,
                              onTap: () => _add(d),
                              isAdd: true,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Amount display (center)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: c.withValues(alpha: 0.15), blurRadius: 20, spreadRadius: 2),
                ],
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

            // - buttons (bottom row)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _denoms
                    .map((d) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _AmountButton(
                              label: '-$d',
                              color: Colors.grey.shade500,
                              onTap: _amount >= d ? () => _sub(d) : null,
                              isAdd: false,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),

            const Spacer(flex: 2),

            // Confirm button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _amount > 0
                      ? () => Navigator.pop(context, _amount.toDouble())
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: _amount > 0 ? 4 : 0,
                  ),
                  child: Text(
                    _amount > 0 ? '確定 \$$_amount！🐾' : '請輸入金額',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _amount > 0 ? Colors.white : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isAdd;

  const _AmountButton({
    required this.label,
    required this.color,
    required this.onTap,
    required this.isAdd,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 56,
        decoration: BoxDecoration(
          color: enabled
              ? (isAdd ? color.withValues(alpha: 0.15) : Colors.grey.shade100)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled
                ? (isAdd ? color.withValues(alpha: 0.4) : Colors.grey.shade300)
                : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: enabled ? (isAdd ? color : Colors.grey.shade600) : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}

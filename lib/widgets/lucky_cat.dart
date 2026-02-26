import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class LuckyCat extends StatelessWidget {
  final double hunger;
  final double balance;
  final String? mood;
  final String? message;
  final bool isWaving;
  final List<String> equippedAccessories;

  const LuckyCat({
    super.key,
    required this.hunger,
    this.balance = 0,
    this.mood,
    this.message,
    this.isWaving = false,
    this.equippedAccessories = const [],
  });

  @override
  Widget build(BuildContext context) {
    final baseMood = hunger < 20
        ? 'sleepy'
        : hunger < 50
            ? 'neutral'
            : 'happy';
    final baseMsg = hunger < 20
        ? '好久沒記帳了，我好餓喵...'
        : hunger < 50
            ? '嗨，快來記帳吧！'
            : '喵～今天也要好好記帳喔！';
    final currentMood = mood ?? baseMood;
    final currentMsg = message ?? baseMsg;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (equippedAccessories.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: equippedAccessories
                .map((id) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(_accEmoji(id), style: const TextStyle(fontSize: 18)),
                    ))
                .toList(),
          ),
        const SizedBox(height: 4),
        if (balance <= -3000)
          _SkeletonCat()
        else if (balance > 60000)
          _SuperCat(isWaving: isWaving)
        else
          AnimatedOpacity(
            opacity: currentMood == 'sleepy' ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 500),
            child: _CatBody(mood: currentMood, isWaving: isWaving, balance: balance),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: 130,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: hunger / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                hunger > 60
                    ? Colors.green
                    : hunger > 30
                        ? Colors.amber
                        : Colors.red,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('飽食度 ${hunger.toInt()}%',
            style: TextStyle(fontSize: 11, color: Colors.amber.shade800)),
        const SizedBox(height: 8),
        Text(
          currentMsg,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: currentMood == 'remind'
                ? Colors.pink
                : currentMood == 'excited'
                    ? Colors.amber.shade800
                    : AppColors.darkText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _accEmoji(String id) {
    const map = {
      'red-bell': '🔔', 'blue-scarf': '🧣', 'gold-crown': '👑',
      'star-glasses': '🕶️', 'cat-bed': '🛏️', 'fish-toy': '🐠',
      'cat-tower': '🗼', 'magic-wand': '✨',
    };
    return map[id] ?? '🎀';
  }
}

class _CatBody extends StatelessWidget {
  final String mood;
  final bool isWaving;
  final double balance;

  const _CatBody({required this.mood, required this.isWaving, required this.balance});

  @override
  Widget build(BuildContext context) {
    // Fatness scale:
    //   balance ≤ -2000 → 0.3 (thinnest before skeleton)
    //   balance = 0     → 1.0 (normal)
    //   balance = 50000 → 5.0 (max chonk)
    //   balance > 60000 → super cat (handled by parent)
    //   balance ≤ -3000 → skeleton (handled by parent)
    double fatness;
    if (balance >= 0) {
      fatness = 1.0 + (balance / 50000).clamp(0.0, 1.0) * 4.0;
    } else {
      fatness = 1.0 - (balance.abs() / 2000).clamp(0.0, 1.0) * 0.7;
    }
    final scale = fatness.clamp(0.3, 5.0);
    final w = 140.0 * (0.6 + scale * 0.2);
    final h = 150.0 * (0.6 + scale * 0.2);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      width: w,
      height: h,
      child: CustomPaint(
        painter: _CatPainter(mood: mood, isWaving: isWaving, fatness: scale),
      ),
    );
  }
}

class _CatPainter extends CustomPainter {
  final String mood;
  final bool isWaving;
  final double fatness;

  _CatPainter({required this.mood, required this.isWaving, this.fatness = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final bodyPaint = Paint()..color = AppColors.catBody;
    final lightPaint = Paint()..color = AppColors.catLight;
    final pinkPaint = Paint()..color = const Color(0xFFFFB3B3);
    final f = fatness;

    // Body — gets wider and rounder with fatness
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, size.height - 45),
        width: 100 * f,
        height: 90 * f,
      ),
      bodyPaint,
    );

    // Belly — scales with fatness
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, size.height - 40),
        width: 55 * f,
        height: 45 * f,
      ),
      lightPaint,
    );

    // Head
    canvas.drawCircle(Offset(cx, 42), 40, bodyPaint);

    // Ears
    final earPath = Path();
    earPath.moveTo(cx - 32, 20);
    earPath.lineTo(cx - 20, -5);
    earPath.lineTo(cx - 8, 18);
    earPath.close();
    canvas.drawPath(earPath, bodyPaint);

    final earPath2 = Path();
    earPath2.moveTo(cx + 32, 20);
    earPath2.lineTo(cx + 20, -5);
    earPath2.lineTo(cx + 8, 18);
    earPath2.close();
    canvas.drawPath(earPath2, bodyPaint);

    // Inner ears
    final innerEarPaint = Paint()..color = const Color(0xFFFDA4AF);
    final ie1 = Path();
    ie1.moveTo(cx - 28, 20);
    ie1.lineTo(cx - 20, 3);
    ie1.lineTo(cx - 12, 20);
    ie1.close();
    canvas.drawPath(ie1, innerEarPaint);
    final ie2 = Path();
    ie2.moveTo(cx + 28, 20);
    ie2.lineTo(cx + 20, 3);
    ie2.lineTo(cx + 12, 20);
    ie2.close();
    canvas.drawPath(ie2, innerEarPaint);

    // Eyes
    final eyePaint = Paint()
      ..color = mood == 'excited' ? Colors.pink : Colors.black87;
    if (mood == 'sleepy') {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx - 12, 38), width: 12, height: 3),
            const Radius.circular(2)),
        Paint()..color = Colors.grey.shade700,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx + 12, 38), width: 12, height: 3),
            const Radius.circular(2)),
        Paint()..color = Colors.grey.shade700,
      );
    } else {
      canvas.drawCircle(Offset(cx - 12, 38), 5, eyePaint);
      canvas.drawCircle(Offset(cx + 12, 38), 5, eyePaint);
      if (mood == 'excited' || mood == 'happy') {
        canvas.drawCircle(Offset(cx - 11, 37), 1.5, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(cx + 13, 37), 1.5, Paint()..color = Colors.white);
      }
    }

    // Nose
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, 48), width: 6, height: 4),
      pinkPaint,
    );

    // Mouth
    final mouthPaint = Paint()
      ..color = (mood == 'excited' || mood == 'happy')
          ? Colors.pink.shade400
          : Colors.grey.shade700
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final mp = Path();
    mp.moveTo(cx - 6, 52);
    mp.quadraticBezierTo(cx - 3, 56, cx, 52);
    mp.quadraticBezierTo(cx + 3, 56, cx + 6, 52);
    canvas.drawPath(mp, mouthPaint);

    // Blush — cheeks get chubbier with fatness
    if (mood == 'excited' || mood == 'happy') {
      final cheekW = 10.0 + (f - 1.0) * 12;
      final cheekH = 6.0 + (f - 1.0) * 8;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx - 22, 46), width: cheekW, height: cheekH),
        Paint()..color = const Color(0xFFFFB3B3).withValues(alpha: 0.6),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + 22, 46), width: cheekW, height: cheekH),
        Paint()..color = const Color(0xFFFFB3B3).withValues(alpha: 0.6),
      );
    }

    // Paws
    final pawPaint = Paint()..color = AppColors.catLight;
    final padPaint = Paint()..color = pinkPaint.color;

    // Right paw (waving) — spreads outward with fatness
    final pawSpread = 42.0 + (f - 1.0) * 16;
    canvas.save();
    if (isWaving) {
      canvas.translate(cx + pawSpread, 80);
      canvas.rotate(-0.3);
      canvas.translate(-(cx + pawSpread), -80);
    }
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + pawSpread, 80), width: 24, height: 30), pawPaint);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + pawSpread, 90), width: 14, height: 8), padPaint);
    canvas.restore();

    // Left paw
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx - pawSpread, 85), width: 22, height: 26), pawPaint);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx - pawSpread, 93), width: 12, height: 7), padPaint);

    // Coin on belly — grows with fatness
    final coinPaint = Paint()..color = Colors.amber.shade600;
    canvas.drawCircle(Offset(cx, size.height - 40), 12 * f, coinPaint);
    final dollarStyle = TextPainter(
      text: TextSpan(
          text: '\$',
          style: TextStyle(
              color: Colors.amber.shade900,
              fontSize: 14,
              fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    dollarStyle.layout();
    dollarStyle.paint(
        canvas, Offset(cx - dollarStyle.width / 2, size.height - 48));
  }

  @override
  bool shouldRepaint(covariant _CatPainter old) =>
      old.mood != mood || old.isWaving != isWaving || old.fatness != fatness;
}

class _SkeletonCat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 150,
      child: CustomPaint(painter: _SkeletonPainter()),
    );
  }
}

class _SkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final bonePaint = Paint()
      ..color = const Color(0xFFE0D5C5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final fillPaint = Paint()..color = const Color(0xFFF5EDE0);

    // Skull
    canvas.drawCircle(Offset(cx, 38), 30, fillPaint);
    canvas.drawCircle(Offset(cx, 38), 30, bonePaint);

    // Skull eyes (hollow)
    canvas.drawCircle(Offset(cx - 10, 34), 8, Paint()..color = const Color(0xFF4A3728));
    canvas.drawCircle(Offset(cx + 10, 34), 8, Paint()..color = const Color(0xFF4A3728));

    // Nose hole
    final nosePath = Path();
    nosePath.moveTo(cx, 44);
    nosePath.lineTo(cx - 4, 50);
    nosePath.lineTo(cx + 4, 50);
    nosePath.close();
    canvas.drawPath(nosePath, Paint()..color = const Color(0xFF4A3728));

    // Ear bones
    canvas.drawLine(Offset(cx - 22, 14), Offset(cx - 14, -4), bonePaint);
    canvas.drawLine(Offset(cx - 14, -4), Offset(cx - 6, 14), bonePaint);
    canvas.drawLine(Offset(cx + 22, 14), Offset(cx + 14, -4), bonePaint);
    canvas.drawLine(Offset(cx + 14, -4), Offset(cx + 6, 14), bonePaint);

    // Spine
    for (var i = 0; i < 5; i++) {
      final y = 72.0 + i * 14;
      canvas.drawCircle(Offset(cx, y), 5, fillPaint);
      canvas.drawCircle(Offset(cx, y), 5, bonePaint);
    }

    // Ribs
    for (var i = 0; i < 3; i++) {
      final y = 78.0 + i * 14;
      final ribPaint = Paint()
        ..color = const Color(0xFFE0D5C5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(Rect.fromCenter(center: Offset(cx, y), width: 50, height: 16), 0.2, 2.7, false, ribPaint);
      canvas.drawArc(Rect.fromCenter(center: Offset(cx, y), width: 50, height: 16), -2.9, -2.7, false, ribPaint);
    }

    // "嗚嗚..." text
    final tp = TextPainter(
      text: const TextSpan(
        text: '💀 嗚嗚...沒錢了喵',
        style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, size.height - 12));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _SuperCat extends StatelessWidget {
  final bool isWaving;
  const _SuperCat({this.isWaving = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 210,
      child: CustomPaint(painter: _SuperCatPainter(isWaving: isWaving)),
    );
  }
}

class _SuperCatPainter extends CustomPainter {
  final bool isWaving;
  _SuperCatPainter({this.isWaving = false});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // Golden aura glow
    for (var i = 3; i >= 1; i--) {
      canvas.drawCircle(
        Offset(cx, size.height * 0.45),
        60.0 + i * 15,
        Paint()..color = Colors.amber.withValues(alpha: 0.08 * i),
      );
    }

    // Cape
    final capePath = Path();
    capePath.moveTo(cx - 30, 60);
    capePath.quadraticBezierTo(cx - 55, size.height * 0.6, cx - 40, size.height - 30);
    capePath.lineTo(cx + 40, size.height - 30);
    capePath.quadraticBezierTo(cx + 55, size.height * 0.6, cx + 30, 60);
    capePath.close();
    canvas.drawPath(capePath, Paint()..color = Colors.red.shade600);
    // Cape inner
    final capeInner = Path();
    capeInner.moveTo(cx - 25, 65);
    capeInner.quadraticBezierTo(cx - 45, size.height * 0.6, cx - 35, size.height - 35);
    capeInner.lineTo(cx + 35, size.height - 35);
    capeInner.quadraticBezierTo(cx + 45, size.height * 0.6, cx + 25, 65);
    capeInner.close();
    canvas.drawPath(capeInner, Paint()..color = Colors.red.shade400);

    // Fat body (golden)
    final bodyPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, size.height - 55), width: 120, height: 100),
      bodyPaint,
    );

    // Belly with S emblem
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, size.height - 50), width: 65, height: 50),
      Paint()..color = const Color(0xFFFFF3C4),
    );

    // "S" emblem on belly
    final sPaint = Paint()
      ..color = Colors.red.shade700
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final sPath = Path();
    sPath.moveTo(cx + 8, size.height - 62);
    sPath.cubicTo(cx - 8, size.height - 65, cx - 12, size.height - 52, cx, size.height - 50);
    sPath.cubicTo(cx + 12, size.height - 48, cx + 8, size.height - 36, cx - 8, size.height - 38);
    canvas.drawPath(sPath, sPaint);

    // Head (golden)
    canvas.drawCircle(Offset(cx, 45), 42, bodyPaint);

    // Ears
    final earPath = Path()..moveTo(cx - 34, 22)..lineTo(cx - 22, -6)..lineTo(cx - 8, 20)..close();
    canvas.drawPath(earPath, bodyPaint);
    final earPath2 = Path()..moveTo(cx + 34, 22)..lineTo(cx + 22, -6)..lineTo(cx + 8, 20)..close();
    canvas.drawPath(earPath2, bodyPaint);

    // Star eyes ⭐
    _drawStar(canvas, Offset(cx - 13, 40), 7, Colors.amber.shade800);
    _drawStar(canvas, Offset(cx + 13, 40), 7, Colors.amber.shade800);

    // Sparkle around eyes
    canvas.drawCircle(Offset(cx - 12, 38), 2, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx + 14, 38), 2, Paint()..color = Colors.white);

    // Nose
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, 51), width: 7, height: 5),
      Paint()..color = Colors.pink.shade300,
    );

    // Big grin
    final grinPaint = Paint()
      ..color = Colors.pink.shade400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final gp = Path();
    gp.moveTo(cx - 10, 55);
    gp.quadraticBezierTo(cx - 5, 62, cx, 55);
    gp.quadraticBezierTo(cx + 5, 62, cx + 10, 55);
    canvas.drawPath(gp, grinPaint);

    // Blush
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 25, 50), width: 14, height: 8),
      Paint()..color = Colors.pink.shade200.withValues(alpha: 0.6),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 25, 50), width: 14, height: 8),
      Paint()..color = Colors.pink.shade200.withValues(alpha: 0.6),
    );

    // Muscular paws
    final pawPaint = Paint()..color = const Color(0xFFFFF3C4);
    // Right paw (power fist up)
    canvas.save();
    if (isWaving) {
      canvas.translate(cx + 48, 75);
      canvas.rotate(-0.4);
      canvas.translate(-(cx + 48), -75);
    }
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 48, 75), width: 28, height: 34),
      pawPaint,
    );
    canvas.restore();

    // Left paw
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 48, 80), width: 26, height: 30),
      pawPaint,
    );

    // Crown on head
    final crownPaint = Paint()..color = Colors.amber.shade600;
    final crownPath = Path();
    crownPath.moveTo(cx - 20, 8);
    crownPath.lineTo(cx - 15, -8);
    crownPath.lineTo(cx - 5, 2);
    crownPath.lineTo(cx, -12);
    crownPath.lineTo(cx + 5, 2);
    crownPath.lineTo(cx + 15, -8);
    crownPath.lineTo(cx + 20, 8);
    crownPath.close();
    canvas.drawPath(crownPath, crownPaint);
    // Crown gems
    canvas.drawCircle(Offset(cx, -4), 3, Paint()..color = Colors.red.shade400);
    canvas.drawCircle(Offset(cx - 12, 0), 2, Paint()..color = Colors.blue.shade400);
    canvas.drawCircle(Offset(cx + 12, 0), 2, Paint()..color = Colors.green.shade400);

    // Floating sparkles
    _drawStar(canvas, Offset(cx - 50, 20), 4, Colors.amber.shade300);
    _drawStar(canvas, Offset(cx + 50, 15), 3, Colors.amber.shade200);
    _drawStar(canvas, Offset(cx - 40, size.height - 25), 3, Colors.amber.shade200);
    _drawStar(canvas, Offset(cx + 45, size.height - 30), 4, Colors.amber.shade300);
  }

  void _drawStar(Canvas canvas, Offset center, double r, Color color) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final outerAngle = -pi / 2 + i * 2 * pi / 5;
      final innerAngle = outerAngle + pi / 5;
      if (i == 0) {
        path.moveTo(center.dx + r * cos(outerAngle), center.dy + r * sin(outerAngle));
      } else {
        path.lineTo(center.dx + r * cos(outerAngle), center.dy + r * sin(outerAngle));
      }
      path.lineTo(center.dx + r * 0.4 * cos(innerAngle), center.dy + r * 0.4 * sin(innerAngle));
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SuperCatPainter old) => old.isWaving != isWaving;
}

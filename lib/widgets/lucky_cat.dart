import 'package:flutter/material.dart';
import '../utils/theme.dart';

class LuckyCat extends StatelessWidget {
  final double hunger;
  final String? mood;
  final String? message;
  final bool isWaving;
  final List<String> equippedAccessories;

  const LuckyCat({
    super.key,
    required this.hunger,
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
        AnimatedOpacity(
          opacity: currentMood == 'sleepy' ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 500),
          child: _CatBody(mood: currentMood, isWaving: isWaving),
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

  const _CatBody({required this.mood, required this.isWaving});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 150,
      child: CustomPaint(
        painter: _CatPainter(mood: mood, isWaving: isWaving),
      ),
    );
  }
}

class _CatPainter extends CustomPainter {
  final String mood;
  final bool isWaving;

  _CatPainter({required this.mood, required this.isWaving});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final bodyPaint = Paint()..color = AppColors.catBody;
    final lightPaint = Paint()..color = AppColors.catLight;
    final pinkPaint = Paint()..color = const Color(0xFFFFB3B3);

    // Body
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, size.height - 45), width: 100, height: 90),
      bodyPaint,
    );

    // Belly
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, size.height - 40), width: 55, height: 45),
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

    // Blush
    if (mood == 'excited' || mood == 'happy') {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx - 22, 46), width: 10, height: 6),
        Paint()..color = const Color(0xFFFFB3B3).withValues(alpha: 0.6),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + 22, 46), width: 10, height: 6),
        Paint()..color = const Color(0xFFFFB3B3).withValues(alpha: 0.6),
      );
    }

    // Paws
    final pawPaint = Paint()..color = AppColors.catLight;
    final padPaint = Paint()..color = pinkPaint.color;

    // Right paw (waving)
    canvas.save();
    if (isWaving) {
      canvas.translate(cx + 42, 80);
      canvas.rotate(-0.3);
      canvas.translate(-(cx + 42), -80);
    }
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + 42, 80), width: 24, height: 30), pawPaint);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + 42, 90), width: 14, height: 8), padPaint);
    canvas.restore();

    // Left paw
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx - 42, 85), width: 22, height: 26), pawPaint);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx - 42, 93), width: 12, height: 7), padPaint);

    // Coin on belly
    final coinPaint = Paint()..color = Colors.amber.shade600;
    canvas.drawCircle(Offset(cx, size.height - 40), 12, coinPaint);
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
      old.mood != mood || old.isWaving != isWaving;
}

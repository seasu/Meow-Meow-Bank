import 'dart:math';
import 'package:flutter/material.dart';

class SpendingBoy extends StatelessWidget {
  final double size;
  final int idleFrame;

  const SpendingBoy({super.key, this.size = 120, this.idleFrame = 0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.1,
      child: CustomPaint(painter: _SpendingBoyPainter(idleFrame: idleFrame)),
    );
  }
}

class _SpendingBoyPainter extends CustomPainter {
  final int idleFrame;
  _SpendingBoyPainter({this.idleFrame = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final scale = size.width / 120;

    final bodyColor = const Color(0xFF90CAF9);
    final skinColor = const Color(0xFFFFCC80);
    final darkColor = const Color(0xFF5D4037);
    final robeColor = const Color(0xFF42A5F5);

    final wobble = sin(idleFrame * 0.15) * 3 * scale;
    final bounce = sin(idleFrame * 0.2).abs() * 4 * scale;

    canvas.save();
    canvas.translate(0, -bounce);

    // Body / robe
    final robePaint = Paint()..color = robeColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, size.height - 35 * scale), width: 60 * scale, height: 55 * scale),
        Radius.circular(16 * scale),
      ),
      robePaint,
    );

    // Robe pattern
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, size.height - 35 * scale), width: 36 * scale, height: 45 * scale),
        Radius.circular(12 * scale),
      ),
      Paint()..color = bodyColor,
    );

    // Head
    canvas.save();
    canvas.translate(cx, 32 * scale);
    canvas.rotate(wobble * 0.02);
    canvas.translate(-cx, -32 * scale);

    canvas.drawCircle(Offset(cx, 32 * scale), 28 * scale, Paint()..color = skinColor);

    // Hair (bowl cut)
    final hairPaint = Paint()..color = darkColor;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, 26 * scale), width: 58 * scale, height: 40 * scale),
      pi, pi, true, hairPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(cx - 29 * scale, 20 * scale, 58 * scale, 8 * scale),
      hairPaint,
    );

    // Eyes (cute round)
    final eyeWhite = Paint()..color = Colors.white;
    final eyeBlack = Paint()..color = darkColor;
    canvas.drawCircle(Offset(cx - 9 * scale, 32 * scale), 6 * scale, eyeWhite);
    canvas.drawCircle(Offset(cx + 9 * scale, 32 * scale), 6 * scale, eyeWhite);

    // Pupil direction varies with idle
    final pupilOff = sin(idleFrame * 0.1) * 2 * scale;
    canvas.drawCircle(Offset(cx - 9 * scale + pupilOff, 33 * scale), 3 * scale, eyeBlack);
    canvas.drawCircle(Offset(cx + 9 * scale + pupilOff, 33 * scale), 3 * scale, eyeBlack);
    canvas.drawCircle(Offset(cx - 8 * scale + pupilOff, 32 * scale), 1 * scale, eyeWhite);
    canvas.drawCircle(Offset(cx + 10 * scale + pupilOff, 32 * scale), 1 * scale, eyeWhite);

    // Blush
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 16 * scale, 38 * scale), width: 8 * scale, height: 5 * scale),
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.5),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 16 * scale, 38 * scale), width: 8 * scale, height: 5 * scale),
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.5),
    );

    // Mouth (grin)
    final mouthPaint = Paint()
      ..color = darkColor
      ..strokeWidth = 1.5 * scale
      ..style = PaintingStyle.stroke;
    final mp = Path();
    mp.moveTo(cx - 5 * scale, 42 * scale);
    mp.quadraticBezierTo(cx, 48 * scale, cx + 5 * scale, 42 * scale);
    canvas.drawPath(mp, mouthPaint);

    canvas.restore(); // head rotation

    // Arms
    final armPaint = Paint()..color = skinColor;
    // Left arm (waving money)
    canvas.save();
    canvas.translate(cx - 32 * scale, size.height - 50 * scale);
    canvas.rotate(sin(idleFrame * 0.12) * 0.2);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 16 * scale, height: 22 * scale), armPaint);
    canvas.restore();

    // Right arm (holding coin)
    canvas.save();
    canvas.translate(cx + 32 * scale, size.height - 48 * scale);
    canvas.rotate(-sin(idleFrame * 0.15) * 0.15);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 16 * scale, height: 22 * scale), armPaint);

    // Spinning coin in hand
    final coinAngle = idleFrame * 0.1;
    final coinW = (8 * cos(coinAngle)).abs() * scale + 2 * scale;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, -12 * scale), width: coinW, height: 8 * scale),
      Paint()..color = Colors.amber,
    );
    canvas.restore();

    // Feet
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 12 * scale, size.height - 8 * scale), width: 18 * scale, height: 10 * scale),
      Paint()..color = darkColor,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 12 * scale, size.height - 8 * scale), width: 18 * scale, height: 10 * scale),
      Paint()..color = darkColor,
    );

    // Money bag
    final bagPaint = Paint()..color = Colors.amber.shade600;
    canvas.drawCircle(Offset(cx, size.height - 30 * scale), 10 * scale, bagPaint);
    final yenPainter = TextPainter(
      text: TextSpan(text: '\$', style: TextStyle(color: Colors.amber.shade900, fontSize: 10 * scale, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    yenPainter.layout();
    yenPainter.paint(canvas, Offset(cx - yenPainter.width / 2, size.height - 36 * scale));

    canvas.restore(); // bounce
  }

  @override
  bool shouldRepaint(covariant _SpendingBoyPainter old) => old.idleFrame != idleFrame;
}

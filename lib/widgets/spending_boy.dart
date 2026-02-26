import 'dart:math';
import 'package:flutter/material.dart';
import 'pixel_utils.dart';

class SpendingBoy extends StatelessWidget {
  final double size;
  final int idleFrame;

  const SpendingBoy({super.key, this.size = 120, this.idleFrame = 0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.1,
      child: CustomPaint(painter: _PixelBoyPainter(idleFrame: idleFrame)),
    );
  }
}

class _PixelBoyPainter extends CustomPainter {
  final int idleFrame;
  _PixelBoyPainter({this.idleFrame = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final ps = size.width / 16;

    // Palette
    const palette = {
      1: Color(0xFF90CAF9), // light blue robe
      2: Color(0xFF42A5F5), // blue robe
      3: Color(0xFFFFCC80), // skin
      4: Color(0xFF5D4037), // brown hair
      5: Color(0xFF1F2937), // black (eyes/shoes)
      6: Color(0xFFFFFFFF), // white (eye)
      7: Color(0xFFF59E0B), // gold coin
      8: Color(0xFFD97706), // dark gold
      9: Color(0xFFFF8A80), // blush
    };

    // Bounce idle
    final bounce = (sin(idleFrame * 0.2).abs() * 1.5).round();

    // Boy pixel art 16x17
    final grid = [
      // Row 0: hair top
      [0,0,0,0,4,4,4,4,4,4,4,0,0,0,0,0],
      // Row 1: hair
      [0,0,0,4,4,4,4,4,4,4,4,4,0,0,0,0],
      // Row 2: forehead
      [0,0,0,4,4,4,4,4,4,4,4,4,0,0,0,0],
      // Row 3: face top
      [0,0,3,3,3,3,3,3,3,3,3,3,3,0,0,0],
      // Row 4: eyes
      [0,0,3,5,6,3,3,3,3,5,6,3,3,0,0,0],
      // Row 5: eyes bottom + blush
      [0,0,3,5,5,3,9,3,9,5,5,3,3,0,0,0],
      // Row 6: nose
      [0,0,3,3,3,3,3,3,3,3,3,3,3,0,0,0],
      // Row 7: mouth
      [0,0,3,3,3,5,5,5,5,3,3,3,3,0,0,0],
      // Row 8: neck
      [0,0,0,0,3,3,3,3,3,3,3,0,0,0,0,0],
      // Row 9: robe top
      [0,0,0,2,2,1,1,1,1,1,2,2,0,0,0,0],
      // Row 10: robe + arms
      [0,3,3,2,1,1,7,8,1,1,2,3,3,0,0,0],
      // Row 11: robe body
      [0,0,0,2,1,1,8,7,1,1,2,0,0,0,0,0],
      // Row 12: robe
      [0,0,0,2,2,1,1,1,1,1,2,2,0,0,0,0],
      // Row 13: robe bottom
      [0,0,2,2,2,2,2,2,2,2,2,2,2,0,0,0],
      // Row 14: legs
      [0,0,0,0,3,3,0,0,0,3,3,0,0,0,0,0],
      // Row 15: shoes
      [0,0,0,5,5,5,0,0,0,5,5,5,0,0,0,0],
    ];

    canvas.save();
    canvas.translate(0, -bounce * ps);

    drawPixels(canvas, grid, ps, 0, 0, palette);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PixelBoyPainter old) => old.idleFrame != idleFrame;
}

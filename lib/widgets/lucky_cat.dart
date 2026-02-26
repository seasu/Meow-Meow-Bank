import 'package:flutter/material.dart';
import 'pixel_utils.dart';

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
    return SizedBox(
      width: 120,
      height: 130,
      child: CustomPaint(
        painter: _PixelCatPainter(
          balance: balance,
          isWaving: isWaving,
          mood: mood,
        ),
      ),
    );
  }
}

class _PixelCatPainter extends CustomPainter {
  final double balance;
  final bool isWaving;
  final String? mood;

  _PixelCatPainter({this.balance = 0, this.isWaving = false, this.mood});

  @override
  void paint(Canvas canvas, Size size) {
    final ps = size.width / 16;

    // Palette
    const palette = {
      1: Color(0xFFFCD34D), // body yellow
      2: Color(0xFFF59E0B), // dark yellow
      3: Color(0xFFFDE68A), // light yellow
      4: Color(0xFF1F2937), // black (eyes)
      5: Color(0xFFFDA4AF), // pink (ears, nose, paws)
      6: Color(0xFFFFFFFF), // white (eye shine)
      7: Color(0xFFD97706), // coin dark
      8: Color(0xFFEF4444), // red (collar)
    };

    // Cat pixel art 16x17
    const catGrid = [
      // Row 0-1: ears
      [0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0],
      [0,0,1,5,1,0,0,0,0,1,5,1,0,0,0,0],
      // Row 2-3: head top
      [0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0],
      [0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0],
      // Row 4: eyes
      [0,1,1,4,6,1,1,1,1,4,6,1,1,0,0,0],
      // Row 5: face
      [0,1,1,4,4,1,1,1,1,4,4,1,1,0,0,0],
      // Row 6: nose + blush
      [0,1,5,1,1,1,5,5,1,1,1,5,1,0,0,0],
      // Row 7: mouth
      [0,1,1,1,1,2,1,1,2,1,1,1,1,0,0,0],
      // Row 8: collar
      [0,0,1,8,8,8,8,8,8,8,8,1,0,0,0,0],
      // Row 9-10: body
      [0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0],
      [0,1,1,1,3,3,3,3,3,3,1,1,1,0,0,0],
      // Row 11: body + coin
      [0,1,1,3,3,7,7,7,7,3,3,1,1,0,0,0],
      // Row 12: body
      [0,1,1,3,3,7,2,2,7,3,3,1,1,0,0,0],
      // Row 13: body bottom
      [0,1,1,1,3,3,3,3,3,3,1,1,1,0,0,0],
      // Row 14: paws
      [0,0,5,5,1,1,1,1,1,1,5,5,0,0,0,0],
      // Row 15: feet
      [0,5,5,5,0,0,0,0,0,0,5,5,5,0,0,0],
    ];

    // Waving paw variation
    final grid = catGrid.map((row) => List<int>.from(row)).toList();
    if (isWaving) {
      // Right side paw goes up
      if (grid.length > 9) {
        grid[4] = [0,1,1,4,6,1,1,1,1,4,6,1,1,0,5,0];
        grid[5] = [0,1,1,4,4,1,1,1,1,4,4,1,1,0,5,0];
        grid[6] = [0,1,5,1,1,1,5,5,1,1,1,5,1,5,1,0];
      }
    }

    // Fatness scaling
    double fatScale = 1.0;
    if (balance >= 0) {
      fatScale = 1.0 + (balance / 50000).clamp(0.0, 1.0) * 0.4;
    } else {
      fatScale = 1.0 - (balance.abs() / 2000).clamp(0.0, 1.0) * 0.3;
    }

    canvas.save();
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.translate(cx, cy);
    canvas.scale(fatScale, fatScale);
    canvas.translate(-cx, -cy);

    drawPixels(canvas, grid, ps, 0, 0, palette);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PixelCatPainter old) =>
      old.balance != balance || old.isWaving != isWaving || old.mood != mood;
}

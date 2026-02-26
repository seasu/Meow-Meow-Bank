import 'package:flutter/material.dart';
import '../models/constants.dart';

class BuildingScene extends StatelessWidget {
  final int level;
  final double totalSaved;

  const BuildingScene({super.key, required this.level, required this.totalSaved});

  @override
  Widget build(BuildContext context) {
    final nextLevel = level < 2 ? level + 1 : null;
    final nextThreshold = nextLevel != null ? kBuildingThresholds[nextLevel]! : null;
    final progress = nextThreshold != null
        ? ((totalSaved - kBuildingThresholds[level]!) /
                (nextThreshold - kBuildingThresholds[level]!))
            .clamp(0.0, 1.0)
        : 1.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: level == 2
                    ? [Colors.indigo.shade300, Colors.pink.shade200, Colors.amber.shade100]
                    : [Colors.lightBlue.shade300, Colors.lightBlue.shade50],
              ),
            ),
            child: Stack(
              children: [
                Positioned(right: 20, top: 12, child: _sun(level)),
                Positioned(left: 15, top: 15, child: _cloud()),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(100)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(child: _buildHouse(level)),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(kBuildingNames[level]!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.amber.shade800)),
                    if (nextLevel != null)
                      Text('下一階段: ${kBuildingNames[nextLevel]} (\$${nextThreshold!.toInt()})',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500))
                    else
                      Text('🏆 最高等級!',
                          style: TextStyle(fontSize: 10, color: Colors.amber.shade600)),
                  ],
                ),
                if (nextLevel != null) ...[
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation(Colors.amber.shade400),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sun(int level) => Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: level == 2 ? Colors.yellow.shade200 : Colors.yellow.shade400,
          boxShadow: level == 2
              ? [BoxShadow(color: Colors.yellow.shade200, blurRadius: 12)]
              : null,
        ),
      );

  Widget _cloud() => Row(
        children: [
          Container(
              width: 24,
              height: 12,
              decoration: BoxDecoration(
                  color: Colors.white70, borderRadius: BorderRadius.circular(8))),
          Container(
              width: 36,
              height: 16,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                  color: Colors.white60, borderRadius: BorderRadius.circular(10))),
        ],
      );

  Widget _buildHouse(int level) {
    if (level == 0) return _woodHouse();
    if (level == 1) return _sandHouse();
    return _castle();
  }

  Widget _woodHouse() => SizedBox(
        width: 60,
        height: 70,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomPaint(size: const Size(60, 20), painter: _RoofPainter(Colors.brown.shade600)),
            ),
            Positioned(
              top: 18,
              left: 5,
              child: Container(width: 50, height: 52, color: Colors.brown.shade400),
            ),
            Positioned(
              bottom: 0,
              left: 20,
              child: Container(
                width: 20,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.brown.shade700,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _sandHouse() => SizedBox(
        width: 70,
        height: 80,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomPaint(size: const Size(70, 22), painter: _RoofPainter(Colors.orange.shade400)),
            ),
            Positioned(
              top: 20,
              left: 5,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  border: Border.all(color: Colors.orange.shade300, width: 2),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 25,
              child: Container(
                width: 22,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.orange.shade700,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ),
            ),
            const Positioned(bottom: 2, left: 5, child: Text('🌷', style: TextStyle(fontSize: 12))),
            const Positioned(bottom: 2, right: 5, child: Text('🌻', style: TextStyle(fontSize: 12))),
          ],
        ),
      );

  Widget _castle() => SizedBox(
        width: 90,
        height: 100,
        child: Stack(
          children: [
            Positioned(left: 2, top: 0, child: Container(width: 20, height: 40, color: Colors.purple.shade200)),
            Positioned(right: 2, top: 0, child: Container(width: 20, height: 40, color: Colors.purple.shade200)),
            Positioned(
              top: 20,
              left: 10,
              child: Container(
                width: 70,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  border: Border.all(color: Colors.purple.shade300, width: 2),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 30,
              child: Container(
                width: 28,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.purple.shade400,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
              ),
            ),
            const Positioned(top: 12, left: 35, child: Text('🚩', style: TextStyle(fontSize: 14))),
            const Positioned(top: -2, left: 2, child: Text('✨', style: TextStyle(fontSize: 10))),
            const Positioned(top: -2, right: 2, child: Text('✨', style: TextStyle(fontSize: 10))),
          ],
        ),
      );
}

class _RoofPainter extends CustomPainter {
  final Color color;
  _RoofPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

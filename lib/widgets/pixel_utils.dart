import 'package:flutter/material.dart';

void drawPixel(Canvas canvas, double x, double y, double size, Color color) {
  canvas.drawRect(
    Rect.fromLTWH(x * size, y * size, size, size),
    Paint()..color = color,
  );
}

void drawPixels(Canvas canvas, List<List<int>> grid, double pixelSize, double offsetX, double offsetY, Map<int, Color> palette) {
  for (var y = 0; y < grid.length; y++) {
    for (var x = 0; x < grid[y].length; x++) {
      final c = grid[y][x];
      if (c != 0 && palette.containsKey(c)) {
        canvas.drawRect(
          Rect.fromLTWH(offsetX + x * pixelSize, offsetY + y * pixelSize, pixelSize, pixelSize),
          Paint()..color = palette[c]!,
        );
      }
    }
  }
}

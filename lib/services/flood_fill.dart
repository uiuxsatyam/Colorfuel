import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class FloodFill {
  static void fill({
    required Uint32List imageBytes,
    required int width,
    required int height,
    required int startX,
    required int startY,
    required int fillColor,
  }) {
    int startColor = imageBytes[startY * width + startX];
    if (startColor == fillColor) return;

    Queue<Point> queue = Queue<Point>();
    queue.add(Point(startX, startY));

    while (queue.isNotEmpty) {
      Point p = queue.removeFirst();
      int index = p.y * width + p.x;

      if (imageBytes[index] == startColor) {
        imageBytes[index] = fillColor;

        if (p.x > 0) queue.add(Point(p.x - 1, p.y));
        if (p.x < width - 1) queue.add(Point(p.x + 1, p.y));
        if (p.y > 0) queue.add(Point(p.x, p.y - 1));
        if (p.y < height - 1) queue.add(Point(p.x, p.y + 1));
      }
    }
  }
}

class Point {
  final int x;
  final int y;
  Point(this.x, this.y);
}

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/drawing_point.dart';

class DrawScreen extends StatefulWidget {
  const DrawScreen({super.key});

  @override
  State<DrawScreen> createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  List<DrawingPoint?> points = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 5;
  GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Free Draw'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => setState(() => points.clear()),
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _saveDrawing,
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                points.add(DrawingPoint(
                  offset: renderBox.globalToLocal(details.globalPosition),
                  paint: Paint()
                    ..color = selectedColor
                    ..strokeWidth = strokeWidth
                    ..strokeCap = StrokeCap.round,
                ));
              });
            },
            onPanStart: (details) {
              setState(() {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                points.add(DrawingPoint(
                  offset: renderBox.globalToLocal(details.globalPosition),
                  paint: Paint()
                    ..color = selectedColor
                    ..strokeWidth = strokeWidth
                    ..strokeCap = StrokeCap.round,
                ));
              });
            },
            onPanEnd: (details) {
              setState(() {
                points.add(null);
              });
            },
            child: RepaintBoundary(
              key: _globalKey,
              child: CustomPaint(
                size: Size.infinite,
                painter: DrawingPainter(pointsList: points),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 1),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   _buildColorButton(Colors.red),
                   _buildColorButton(Colors.blue),
                   _buildColorButton(Colors.green),
                   _buildColorButton(Colors.yellow),
                   _buildColorButton(Colors.orange),
                   _buildColorButton(Colors.purple),
                   _buildColorButton(Colors.black),
                   const VerticalDivider(),
                   IconButton(
                     icon: Icon(Icons.brush, color: strokeWidth == 5 ? Colors.blue : Colors.grey),
                     onPressed: () => setState(() => strokeWidth = 5),
                   ),
                   IconButton(
                     icon: Icon(Icons.brush, size: 32, color: strokeWidth == 15 ? Colors.blue : Colors.grey),
                     onPressed: () => setState(() => strokeWidth = 15),
                   ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selectedColor == color ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
             if (selectedColor == color)
               BoxShadow(color: Colors.black26, blurRadius: 5)
          ],
        ),
      ),
    );
  }

  Future<void> _saveDrawing() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = (await getApplicationDocumentsDirectory()).path;
      final String fileName = 'drawing_${DateTime.now().millisecondsSinceEpoch}.png';
      final String fullPath = '$directory/$fileName';
      File imgFile = File(fullPath);
      await imgFile.writeAsBytes(pngBytes);

      // Save to Hive for Gallery
      await Hive.box('gallery').add(fullPath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to Gallery!')),
      );
    } catch (e) {
      print(e);
    }
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> pointsList;

  DrawingPainter({required this.pointsList});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(
          pointsList[i]!.offset,
          pointsList[i + 1]!.offset,
          pointsList[i]!.paint,
        );
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        canvas.drawPoints(
          ui.PointMode.points,
          [pointsList[i]!.offset],
          pointsList[i]!.paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) => true;
}

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:math';
import 'dart:typed_data';

class Stroke {
  final List<Offset> points;
  final Color color;
  final double width;

  Stroke(this.points, this.color, this.width);
}

class ColoringScreen extends StatefulWidget {
  const ColoringScreen({super.key});

  @override
  State<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends State<ColoringScreen> {
  ui.Image? baseImage;
  img.Image? bitmap;
  List<Stroke> strokes = [];
  List<Stroke> undoneStrokes = [];

  Color selectedColor = Colors.pink;
  double strokeWidth = 8;
  bool bucketMode = true;

  final List<Color> palette = [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
    Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
    Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    Colors.brown, Colors.grey, Colors.black, Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final data = await DefaultAssetBundle.of(context).load('assets/line_art/lion_outline.png');
    final bytes = data.buffer.asUint8List();
    final decoded = img.decodeImage(bytes)!;
    bitmap = decoded;
    
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() => baseImage = frame.image);
  }

  void _onTapBucket(Offset pos, Size size) {
    if (bitmap == null) return;

    // Map screen coordinates to bitmap coordinates
    final x = (pos.dx / size.width * bitmap!.width).toInt();
    final y = (pos.dy / size.height * bitmap!.height).toInt();

    if (x < 0 || y < 0 || x >= bitmap!.width || y >= bitmap!.height) return;

    final targetPixel = bitmap!.getPixel(x, y);
    final replacementColor = img.ColorRgb8(selectedColor.red, selectedColor.green, selectedColor.blue);

    // If tapping on black outline (assuming outline is black 0,0,0) or already filled
    if (targetPixel.r < 30 && targetPixel.g < 30 && targetPixel.b < 30) return;
    
    // Flood fill
    _floodFill(x, y, targetPixel, replacementColor);
    
    // Update the base UI image
    _updateUiImage();
  }

  void _floodFill(int x, int y, img.Pixel target, img.ColorRgb8 replacement) {
    final queue = <Point<int>>[Point(x, y)];
    final targetR = target.r;
    final targetG = target.g;
    final targetB = target.b;

    while (queue.isNotEmpty) {
      final p = queue.removeLast();
      if (p.x < 0 || p.y < 0 || p.x >= bitmap!.width || p.y >= bitmap!.height) continue;
      
      final currentPixel = bitmap!.getPixel(p.x, p.y);
      if (currentPixel.r == targetR && currentPixel.g == targetG && currentPixel.b == targetB) {
        bitmap!.setPixel(p.x, p.y, replacement);
        
        queue.add(Point(p.x + 1, p.y));
        queue.add(Point(p.x - 1, p.y));
        queue.add(Point(p.x, p.y + 1));
        queue.add(Point(p.x, p.y - 1));
      }
    }
  }

  Future<void> _updateUiImage() async {
    final encoded = img.encodePng(bitmap!);
    final codec = await ui.instantiateImageCodec(Uint8List.fromList(encoded));
    final frame = await codec.getNextFrame();
    setState(() => baseImage = frame.image);
  }

  @override
  Widget build(BuildContext context) {
    if (baseImage == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.pink)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text('Coloring Time', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() {
              strokes.clear();
              undoneStrokes.clear();
              _loadImage(); // Reset bitmap
            }),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GestureDetector(
                          onTapDown: bucketMode
                              ? (d) => _onTapBucket(d.localPosition, constraints.biggest)
                              : null,
                          onPanStart: bucketMode
                              ? null
                              : (d) {
                                  setState(() {
                                    strokes.add(Stroke([d.localPosition], selectedColor, strokeWidth));
                                    undoneStrokes.clear();
                                  });
                                },
                          onPanUpdate: bucketMode
                              ? null
                              : (d) {
                                  setState(() {
                                    strokes.last.points.add(d.localPosition);
                                  });
                                },
                          child: CustomPaint(
                            size: constraints.biggest,
                            painter: ColoringPainter(baseImage!, strokes),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              _buildControlBar(),
              _buildPalette(),
              const SizedBox(height: 20),
            ],
          ),
          _buildToolSwitcher(),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildActionButton(
                icon: Icons.undo_rounded,
                onPressed: strokes.isEmpty ? null : () {
                  setState(() {
                    undoneStrokes.add(strokes.removeLast());
                  });
                },
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.redo_rounded,
                onPressed: undoneStrokes.isEmpty ? null : () {
                  setState(() {
                    strokes.add(undoneStrokes.removeLast());
                  });
                },
              ),
            ],
          ),
          Row(
            children: [
              _buildStrokeSizeButton(4, "S"),
              const SizedBox(width: 8),
              _buildStrokeSizeButton(8, "M"),
              const SizedBox(width: 8),
              _buildStrokeSizeButton(16, "L"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        icon: Icon(icon, color: onPressed == null ? Colors.grey : Colors.blueGrey),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildStrokeSizeButton(double size, String label) {
    bool isSelected = strokeWidth == size;
    return GestureDetector(
      onTap: () => setState(() => strokeWidth = size),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildToolSwitcher() {
    return Positioned(
      top: 10,
      left: 24,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            _buildToolIcon(Icons.format_paint_rounded, true),
            _buildToolIcon(Icons.brush_rounded, false),
          ],
        ),
      ),
    );
  }

  Widget _buildToolIcon(IconData icon, bool forBucket) {
    bool isSelected = bucketMode == forBucket;
    return GestureDetector(
      onTap: () => setState(() => bucketMode = forBucket),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildPalette() {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: palette.length,
        itemBuilder: (context, index) {
          final color = palette[index];
          bool isSelected = selectedColor == color;
          return GestureDetector(
            onTap: () {
              setState(() => selectedColor = color);
              // Feedback? 
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 55 : 45,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ColoringPainter extends CustomPainter {
  final ui.Image base;
  final List<Stroke> strokes;

  ColoringPainter(this.base, this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Draw the base (which includes the flood-filled areas)
    canvas.drawImageRect(
      base,
      Rect.fromLTWH(0, 0, base.width.toDouble(), base.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );

    // Draw manual strokes
    for (final stroke in strokes) {
      final p = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      for (int i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(stroke.points[i], stroke.points[i + 1], p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ColoringPainter oldDelegate) => true;
}

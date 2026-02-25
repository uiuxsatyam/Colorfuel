import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:typed_data';
import '../services/flood_fill.dart';

class ColoringScreen extends StatefulWidget {
  const ColoringScreen({super.key});

  @override
  State<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends State<ColoringScreen> {
  ui.Image? _image;
  Uint32List? _pixels;
  bool _isLoading = true;
  Color _selectedColor = Colors.pink;

  @override
  void initState() {
    super.initState();
    _loadSvg('assets/line_art/animals/smile.svg');
  }

  Future<void> _loadSvg(String assetPath) async {
    final String svgString = await DefaultAssetBundle.of(context).loadString(assetPath);
    final DrawableRoot svgRoot = await svg.fromSvgString(svgString, svgString);
    
    // Render SVG to Image
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Size size = const Size(500, 500); // Fixed size for coloring
    svgRoot.draw(canvas, Rect.fromLTWH(0, 0, size.width, size.height));
    
    final ui.Image image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    
    setState(() {
      _image = image;
      _pixels = byteData!.buffer.asUint32List();
      _isLoading = false;
    });
  }

  void _handleTap(TapDownDetails details) {
    if (_pixels == null || _image == null) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPos = box.globalToLocal(details.globalPosition);
    
    // Scale touch coordinates to image size
    final double scaleX = _image!.width / box.size.width;
    final double scaleY = _image!.height / box.size.height;
    
    final int x = (localPos.dx * scaleX).toInt().clamp(0, _image!.width - 1);
    final int y = (localPos.dy * scaleY).toInt().clamp(0, _image!.height - 1);

    setState(() {
      FloodFill.fill(
        imageBytes: _pixels!,
        width: _image!.width,
        height: _image!.height,
        startX: x,
        startY: y,
        fillColor: _colorToUint32(_selectedColor),
      );
      _updateImageFromPixels();
    });
  }

  int _colorToUint32(Color color) {
    return color.value; // Simplification for Rgba
  }

  Future<void> _updateImageFromPixels() async {
    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(Uint8List.view(_pixels!.buffer));
    final ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: _image!.width,
      height: _image!.height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final ui.Codec codec = await descriptor.instantiateCodec();
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    setState(() {
      _image = frameInfo.image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coloring Time!')),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GestureDetector(
                    onTapDown: _handleTap,
                    child: Center(
                      child: RawImage(
                        image: _image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
          ),
          _buildColorPalette(),
        ],
      ),
    );
  }

  Widget _buildColorPalette() {
    final List<Color> colors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
      Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    ];

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => setState(() => _selectedColor = colors[index]),
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: colors[index],
                shape: BoxShape.circle,
                border: Border.all(
                  color: _selectedColor == colors[index] ? Colors.black : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late Box _galleryBox;
  List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    _galleryBox = Hive.box('gallery');
    _loadImages();
  }

  void _loadImages() {
    setState(() {
      _imagePaths = _galleryBox.values.cast<String>().toList().reversed.toList();
    });
  }

  Future<void> _deleteImage(int index) async {
    final path = _imagePaths[index];
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    await _galleryBox.deleteAt(_imagePaths.length - 1 - index);
    _loadImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Masterpieces')),
      body: _imagePaths.isEmpty
          ? const Center(
              child: Text(
                'No drawings yet. Start creating!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(_imagePaths[index]),
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _deleteImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white70,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

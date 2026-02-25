import 'package:flutter/material.dart';
import 'coloring_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Animals', 'color': Colors.orangeAccent, 'icon': Icons.pets},
      {'name': 'Vehicles', 'color': Colors.blueAccent, 'icon': Icons.directions_car},
      {'name': 'Fruits', 'color': Colors.greenAccent, 'icon': Icons.apple},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Pick a Category')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _buildCategoryCard(
                      context,
                      name: cat['name'] as String,
                      color: cat['color'] as Color,
                      icon: cat['icon'] as IconData,
                      onTap: () {
                        // For MVP, all categories lead to the same sample SVG
                        // In a full version, you'd pass the category to ColoringScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ColoringScreen()),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String name,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.white),
            const SizedBox(width: 20),
            Text(
              name,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

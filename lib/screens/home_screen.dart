import 'package:flutter/material.dart';
import 'coloring_screen.dart';
import 'draw_screen.dart';
import 'gallery_screen.dart';
import 'category_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'ColorFuel',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.pink[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Choose your fun!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 40),
                _buildMenuCard(
                  context,
                  title: 'Coloring Pages',
                  subtitle: 'Animals, Vehicles & more!',
                  color: const Color(0xFFFF80AB),
                  icon: Icons.palette_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CategoryScreen()),
                  ),
                ),
                const SizedBox(height: 20),
                _buildMenuCard(
                  context,
                  title: 'Free Draw',
                  subtitle: 'Draw anything you like!',
                  color: const Color(0xFF81D4FA),
                  icon: Icons.edit_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DrawScreen()),
                  ),
                ),
                const SizedBox(height: 20),
                _buildMenuCard(
                  context,
                  title: 'My Gallery',
                  subtitle: 'See your masterpieces!',
                  color: const Color(0xFFC5E1A5),
                  icon: Icons.photo_library_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GalleryScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

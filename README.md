# ColorFuel - Kids Coloring App MVP

A bright, fun, and kid-friendly coloring app built with Flutter.

## 🚀 Features
- **Coloring Pages**: Tap-to-fill (bucket tool) on cute outlines.
- **Free Draw**: Blank canvas for creative drawing with multiple brush sizes.
- **Gallery**: Save and view your masterpieces locally.
- **Kid-Safe UI**: Large touch targets, bright pastel colors, and no ads/external links.
- **Offline Mode**: Works entirely without internet.

## 🛠️ Setup Instructions

1. **Prerequisites**:
   - Install Flutter SDK: [flutter.dev](https://docs.flutter.dev/get-started/install)
   - Android Studio or VS Code with Flutter extension.

2. **Installation**:
   ```bash
   # Clone the repository (or navigate to the folder)
   cd ColorFuel

   # Get dependencies
   flutter pub get
   ```

3. **Running the App**:
   ```bash
   flutter run
   ```

## 🎨 How to Add New Coloring Pages
1. Place your Black & White SVG files in `assets/line_art/animals/`, `assets/line_art/fruits/`, or `assets/line_art/vehicles/`.
2. Update the `assets` section in `pubspec.yaml` if you create new subfolders.
3. Update `lib/screens/category_screen.dart` to link to your new assets.

## 📦 APK Build Steps
To generate a production APK for Android:
```bash
flutter build apk --release
```
The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

## ⚡ Performance Optimization Tips
- **Image Compression**: Use compressed PNGs for the gallery to save space.
- **RepaintBoundary**: Used in drawing screens to prevent unnecessary UI rebuilds.
- **Flood Fill**: Optimized using `Uint32List` for faster pixel processing.

## 📁 Project Structure
- `lib/screens/`: Main app screens (Home, Category, Coloring, Draw, Gallery).
- `lib/services/`: Core logic like the Flood Fill algorithm.
- `lib/models/`: Data models for drawing points.
- `assets/`: SVG line art and images.

import 'package:flutter/material.dart';

enum BrandColor {
  mint(
    name: '薄荷绿',
    emoji: '🌿',
    primary: Color(0xFF10B981),
    secondary: Color(0xFF059669),
  ),
  iceBlue(
    name: '天空蓝',
    emoji: '❄️',
    primary: Color(0xFF0284C7),
    secondary: Color(0xFF0369A1),
  ),
  twilightPurple(
    name: '星空紫',
    emoji: '🔮',
    primary: Color(0xFF8B5CF6),
    secondary: Color(0xFF7C3AED),
  ),
  sunsetCoral(
    name: '珊瑚橙',
    emoji: '🌅',
    primary: Color(0xFFF97316),
    secondary: Color(0xFFEA580C),
  );

  final String name;
  final String emoji;
  final Color primary;
  final Color secondary;

  const BrandColor({
    required this.name,
    required this.emoji,
    required this.primary,
    required this.secondary,
  });
}

class ThemeService extends ChangeNotifier {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  ThemeMode _themeMode = ThemeMode.system;
  BrandColor _brandColor = BrandColor.mint;

  ThemeMode get themeMode => _themeMode;
  BrandColor get brandColor => _brandColor;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void setBrandColor(BrandColor color) {
    if (_brandColor != color) {
      _brandColor = color;
      notifyListeners();
    }
  }

  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: _brandColor.primary,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: _brandColor.primary,
        secondary: _brandColor.secondary,
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: _brandColor.primary,
      scaffoldBackgroundColor: const Color(0xFF0F1715),
      cardColor: const Color(0xFF16201D),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white70),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      colorScheme: ColorScheme.dark(
        primary: _brandColor.primary,
        secondary: _brandColor.secondary,
      ),
    );
  }
}

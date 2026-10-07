// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // 品牌核心色：薄荷绿
  static const Color mintGreen = Color(0xFF34D399);
  static const Color darkMintGreen = Color(0xFF059669);
  static const Color lightMintGreen = Color(0xFFA7F3D0);

  // 背景色 (深色主题基础)
  static const Color darkBackground = Color(0xFF121212);
  static const Color cardDarkBackground = Color(0xFF1E1E1E);

  // 默认亮色主题
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: mintGreen,
      scaffoldBackgroundColor: const Color(0xFFF9FAFB),
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
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: mintGreen,
        secondary: darkMintGreen,
      ),
    );
  }

  // 默认深色主题
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: mintGreen,
      scaffoldBackgroundColor: darkBackground,
      cardColor: cardDarkBackground,
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
      colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark).copyWith(
        primary: mintGreen,
        secondary: darkMintGreen,
      ),
    );
  }
}

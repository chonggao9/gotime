import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotime/core/services/theme_service.dart';

void main() {
  group('ThemeService Reactive Theme & Brand Color Tests', () {
    test('ThemeMode switching works correctly', () {
      final service = ThemeService.instance;
      service.setThemeMode(ThemeMode.light);
      expect(service.themeMode, equals(ThemeMode.light));

      service.setThemeMode(ThemeMode.dark);
      expect(service.themeMode, equals(ThemeMode.dark));

      service.setThemeMode(ThemeMode.system);
      expect(service.themeMode, equals(ThemeMode.system));
    });

    test('BrandColor switching updates light and dark themes accordingly', () {
      final service = ThemeService.instance;
      service.setBrandColor(BrandColor.mint);
      expect(service.brandColor, equals(BrandColor.mint));
      expect(service.lightTheme.primaryColor, equals(BrandColor.mint.primary));
      expect(service.darkTheme.primaryColor, equals(BrandColor.mint.primary));

      service.setBrandColor(BrandColor.iceBlue);
      expect(service.brandColor, equals(BrandColor.iceBlue));
      expect(service.lightTheme.primaryColor, equals(BrandColor.iceBlue.primary));
      expect(service.darkTheme.primaryColor, equals(BrandColor.iceBlue.primary));

      service.setBrandColor(BrandColor.twilightPurple);
      expect(service.brandColor, equals(BrandColor.twilightPurple));
      expect(service.lightTheme.primaryColor, equals(BrandColor.twilightPurple.primary));

      service.setBrandColor(BrandColor.sunsetCoral);
      expect(service.brandColor, equals(BrandColor.sunsetCoral));
      expect(service.lightTheme.primaryColor, equals(BrandColor.sunsetCoral.primary));
    });

    test('BrandColor enum metadata validity', () {
      for (final color in BrandColor.values) {
        expect(color.name.isNotEmpty, isTrue);
        expect(color.emoji.isNotEmpty, isTrue);
        expect(color.primary, isNotNull);
        expect(color.secondary, isNotNull);
      }
    });
  });
}

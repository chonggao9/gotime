import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'core/services/locale_service.dart';
import 'core/services/theme_service.dart';
import 'core/theme/app_theme.dart';
import 'features/common/privacy_lock_overlay.dart';
import 'features/home/home_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/social/community_screen.dart';
import 'features/settings/settings_screen.dart';

void main() {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const GoTimeApp());
}

class GoTimeApp extends StatelessWidget {
  const GoTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([ThemeService.instance, LocaleService.instance]),
      builder: (context, child) {
        final themeService = ThemeService.instance;
        final localeService = LocaleService.instance;
        return MaterialApp(
          title: 'GoTime',
          debugShowCheckedModeBanner: false,
          theme: themeService.lightTheme,
          darkTheme: themeService.darkTheme,
          themeMode: themeService.themeMode,
          locale: localeService.locale,
          home: const PrivacyLockOverlay(child: MainLayout()),
        );
      },
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StatsScreen(),
    const CommunityScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppTheme.mintGreen,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.check_circle_outline_rounded),
            activeIcon: const Icon(Icons.check_circle_rounded),
            label: LocaleService.instance.t('tab_habits'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.insights_outlined),
            activeIcon: const Icon(Icons.insights_rounded),
            label: LocaleService.instance.t('tab_stats'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.groups_outlined),
            activeIcon: const Icon(Icons.groups_rounded),
            label: LocaleService.instance.t('tab_community'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.tune_outlined),
            activeIcon: const Icon(Icons.tune_rounded),
            label: LocaleService.instance.t('tab_settings'),
          ),
        ],
      ),
    );
  }
}

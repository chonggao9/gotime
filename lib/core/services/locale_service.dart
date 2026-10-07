import 'package:flutter/material.dart';

enum AppLanguage {
  system(code: '', name: '跟随系统', flagEmoji: '⚙️'),
  zhHans(code: 'zh', name: '简体中文', flagEmoji: '🇨🇳'),
  zhHant(code: 'zh_Hant', name: '繁體中文', flagEmoji: '🇭🇰'),
  en(code: 'en', name: 'English (US)', flagEmoji: '🇺🇸'),
  ja(code: 'ja', name: '日本語', flagEmoji: '🇯🇵');

  final String code;
  final String name;
  final String flagEmoji;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.flagEmoji,
  });
}

/// 多语言国际化引擎服务 (i18n Localization Service)
class LocaleService extends ChangeNotifier {
  LocaleService._();
  static final LocaleService instance = LocaleService._();

  AppLanguage _currentLanguage = AppLanguage.system;

  AppLanguage get currentLanguage => _currentLanguage;

  Locale? get locale {
    if (_currentLanguage == AppLanguage.system) return null;
    if (_currentLanguage == AppLanguage.zhHant) {
      return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
    }
    return Locale(_currentLanguage.code);
  }

  void setLanguage(AppLanguage language) {
    _currentLanguage = language;
    notifyListeners();
  }

  /// 获取本地化文本
  String t(String key) {
    final lang = _currentLanguage;
    final dict = _translations[key];
    if (dict == null) return key;

    switch (lang) {
      case AppLanguage.en:
        return dict['en'] ?? dict['zh'] ?? key;
      case AppLanguage.ja:
        return dict['ja'] ?? dict['zh'] ?? key;
      case AppLanguage.zhHant:
        return dict['zh_Hant'] ?? dict['zh'] ?? key;
      case AppLanguage.zhHans:
      case AppLanguage.system:
      default:
        return dict['zh'] ?? key;
    }
  }

  static final Map<String, Map<String, String>> _translations = {
    'app_name': {
      'zh': 'GoTime 极简自律',
      'zh_Hant': 'GoTime 極簡自律',
      'en': 'GoTime Habit Tracker',
      'ja': 'GoTime 習慣トラッカー',
    },
    'tab_habits': {
      'zh': '今日习惯',
      'zh_Hant': '今日習慣',
      'en': 'Today',
      'ja': '今日',
    },
    'tab_stats': {
      'zh': '数据洞察',
      'zh_Hant': '數據洞察',
      'en': 'Insights',
      'ja': '統計',
    },
    'tab_settings': {
      'zh': '圈子与设置',
      'zh_Hant': '圈子與設定',
      'en': 'Settings',
      'ja': '設定',
    },
    'btn_create_habit': {
      'zh': '建立新习惯',
      'zh_Hant': '建立新習慣',
      'en': 'New Habit',
      'ja': '習慣を作成',
    },
    'streak_title': {
      'zh': '当前连胜',
      'zh_Hant': '當前連勝',
      'en': 'Current Streak',
      'ja': '連続達成',
    },
    'strength_title': {
      'zh': '习惯稳固度',
      'zh_Hant': '習慣穩固度',
      'en': 'Habit Strength',
      'ja': '習慣の強度',
    },
    'completion_rate': {
      'zh': '本月达成',
      'zh_Hant': '本月達成',
      'en': 'Monthly Rate',
      'ja': '今月の達成率',
    },
    'freeze_mode_title': {
      'zh': '休假/生病免责模式',
      'zh_Hant': '休假/生病免責模式',
      'en': 'Vacation & Sick Freeze',
      'ja': '休暇・病欠フリーズモード',
    },
    'freeze_mode_sub': {
      'zh': '开启期间不扣减强度分，连胜不中断',
      'zh_Hant': '開啟期間不扣減強度分，連勝不中斷',
      'en': 'Preserves streaks and strength during rest',
      'ja': '休止中もストリークと強度を保護します',
    },
    'privacy_lock_title': {
      'zh': '隐私安全锁 (PIN / 生物识别)',
      'zh_Hant': '隱私安全鎖 (PIN / 生物辨識)',
      'en': 'Privacy Lock (PIN & Biometric)',
      'ja': 'プライバシーロック (PIN・生体認証)',
    },
    'widgets_workshop': {
      'zh': '桌面小组件工坊 (Widgets)',
      'zh_Hant': '桌面小組件工坊 (Widgets)',
      'en': 'Home Screen Widgets',
      'ja': 'ホーム画面ウィジェット',
    },
    'smartwatch_title': {
      'zh': '智能手表微端与表盘 (watchOS / Wear OS)',
      'zh_Hant': '智慧手錶微端與錶盤 (watchOS / Wear OS)',
      'en': 'Smartwatch Companion (Apple Watch & Wear OS)',
      'ja': 'スマートウォッチ拡張 (Apple Watch / Wear OS)',
    },
    'webdav_sync_title': {
      'zh': 'WebDAV 私有网盘双向同步',
      'zh_Hant': 'WebDAV 私有網盤雙向同步',
      'en': 'WebDAV Cloud Sync',
      'ja': 'WebDAV クラウド同期',
    },
    'backup_json_title': {
      'zh': '本地全量数据备份 (JSON)',
      'zh_Hant': '本地全量數據備份 (JSON)',
      'en': 'Full JSON Backup',
      'ja': '完全JSONバックアップ',
    },
    'export_csv_title': {
      'zh': '导出打卡数据报表 (CSV)',
      'zh_Hant': '導出打卡數據報表 (CSV)',
      'en': 'Export Data (CSV)',
      'ja': 'CSVデータエクスポート',
    },
    'language_title': {
      'zh': '语言偏好 (Language)',
      'zh_Hant': '語言偏好 (Language)',
      'en': 'Language',
      'ja': '言語設定',
    },
    'year_in_pixels_title': {
      'zh': '全景年鉴 🎨',
      'zh_Hant': '全景年鑑 🎨',
      'en': 'Year in Pixels 🎨',
      'ja': '年鑑ピクセル 🎨',
    },
    'trophy_hall_title': {
      'zh': '自律成就勋章',
      'zh_Hant': '自律成就勳章',
      'en': 'Achievement Badges',
      'ja': '実績バッジ',
    },
    'confetti_all_done': {
      'zh': '太棒了！今日全部目标达成',
      'zh_Hant': '太棒了！今日全部目標達成',
      'en': 'Awesome! All habits completed today',
      'ja': '素晴らしい！今日の目標をすべて達成しました',
    },
  };
}

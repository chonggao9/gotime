import 'package:flutter_test/flutter_test.dart';
import 'package:gotime/core/services/locale_service.dart';

void main() {
  group('LocaleService i18n Localization Tests', () {
    final service = LocaleService.instance;

    setUp(() {
      service.setLanguage(AppLanguage.system);
    });

    test('Initial language defaults to system with null locale override', () {
      expect(service.currentLanguage, equals(AppLanguage.system));
      expect(service.locale, isNull);
    });

    test('Switching to English updates locale and translates keys', () {
      service.setLanguage(AppLanguage.en);
      expect(service.currentLanguage, equals(AppLanguage.en));
      expect(service.locale?.languageCode, equals('en'));

      expect(service.t('tab_habits'), equals('Today'));
      expect(service.t('tab_stats'), equals('Insights'));
      expect(service.t('tab_community'), equals('Community'));
      expect(service.t('tab_settings'), equals('Settings'));
      expect(service.t('btn_create_habit'), equals('New Habit'));
    });

    test('Switching to Japanese updates locale and translates keys', () {
      service.setLanguage(AppLanguage.ja);
      expect(service.currentLanguage, equals(AppLanguage.ja));
      expect(service.locale?.languageCode, equals('ja'));

      expect(service.t('tab_habits'), equals('今日'));
      expect(service.t('tab_stats'), equals('統計'));
      expect(service.t('tab_community'), equals('サークル'));
      expect(service.t('tab_settings'), equals('設定'));
    });

    test('Switching to Traditional Chinese updates locale with Hant script', () {
      service.setLanguage(AppLanguage.zhHant);
      expect(service.currentLanguage, equals(AppLanguage.zhHant));
      expect(service.locale?.languageCode, equals('zh'));
      expect(service.locale?.scriptCode, equals('Hant'));

      expect(service.t('tab_habits'), equals('今日習慣'));
      expect(service.t('tab_stats'), equals('數據洞察'));
      expect(service.t('tab_community'), equals('自律圈子'));
    });

    test('Unknown keys fallback gracefully to key itself', () {
      expect(service.t('unknown_non_existent_key'), equals('unknown_non_existent_key'));
    });
  });
}
